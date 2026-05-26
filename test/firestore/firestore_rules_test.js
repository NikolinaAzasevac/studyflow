const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const path = require('node:path');

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, updateDoc } = require('firebase/firestore');

const projectId = 'demo-studyflow';
const rulesPath = path.join(process.cwd(), 'firestore.rules');

let testEnv;

async function authedDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: await fs.readFile(rulesPath, 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

test.afterEach(async () => {
  await testEnv.clearFirestore();
});

async function seedUser(userId, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), `users/${userId}`), data);
  });
}

async function seedGoal(userId, goalId, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), `users/${userId}/goals/${goalId}`), data);
  });
}

async function seedTask(userId, taskId, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), `users/${userId}/tasks/${taskId}`), data);
  });
}

function validUser(overrides = {}) {
  return {
    name: 'Test User',
    email: 'user@example.com',
    avatarUrl: null,
    role: 'user',
    disabled: false,
    ...overrides,
  };
}

function validGoal(overrides = {}) {
  return {
    area: 'Mathematics',
    type: 'Midterm',
    description: 'Prepare for exam.',
    coverUrl: null,
    targetDate: '2026-04-01T00:00:00.000',
    ...overrides,
  };
}

function validTask(overrides = {}) {
  return {
    goalId: 'goal-1',
    title: 'Solve exercises',
    notes: 'Focus on derivatives.',
    dueDate: '2026-04-02T00:00:00.000',
    isDone: false,
    priority: 1,
    createdAt: '2026-03-18T00:00:00.000',
    subtasks: [],
    ...overrides,
  };
}

test('owner can create their own user document with valid shape', async () => {
  const db = await authedDb('user-1');
  await assertSucceeds(setDoc(doc(db, 'users/user-1'), validUser()));
});

test('owner cannot elevate their own role on create', async () => {
  const db = await authedDb('user-1');
  await assertFails(setDoc(doc(db, 'users/user-1'), validUser({ role: 'admin' })));
});

test('owner cannot update their own role', async () => {
  await seedUser('user-1', validUser());
  const db = await authedDb('user-1');
  await assertFails(updateDoc(doc(db, 'users/user-1'), { role: 'admin' }));
});

test('admin can update another user role', async () => {
  await seedUser('admin-1', validUser({ role: 'admin' }));
  await seedUser('user-1', validUser());
  const db = await authedDb('admin-1');
  await assertSucceeds(updateDoc(doc(db, 'users/user-1'), { role: 'admin' }));
});

test('user can read only their own valid profile', async () => {
  await seedUser('user-1', validUser());
  await seedUser('user-2', validUser({ email: 'other@example.com' }));
  const db = await authedDb('user-1');
  await assertSucceeds(getDoc(doc(db, 'users/user-1')));
  await assertFails(getDoc(doc(db, 'users/user-2')));
});

test('owner can create a valid goal but not a malformed one', async () => {
  await seedUser('user-1', validUser());
  const db = await authedDb('user-1');
  await assertSucceeds(
    setDoc(doc(db, 'users/user-1/goals/goal-1'), validGoal()),
  );
  await assertFails(
    setDoc(doc(db, 'users/user-1/goals/goal-2'), {
      ...validGoal(),
      unexpected: true,
    }),
  );
});

test('owner cannot write tasks with invalid priority', async () => {
  await seedUser('user-1', validUser());
  const db = await authedDb('user-1');
  await assertFails(
    setDoc(doc(db, 'users/user-1/tasks/task-1'), validTask({ priority: 7 })),
  );
});

test('owner can read and write their own valid task', async () => {
  await seedUser('user-1', validUser());
  await seedTask('user-1', 'task-1', validTask());
  const db = await authedDb('user-1');
  await assertSucceeds(getDoc(doc(db, 'users/user-1/tasks/task-1')));
  await assertSucceeds(
    updateDoc(doc(db, 'users/user-1/tasks/task-1'), { isDone: true }),
  );
});

test('admin can read and manage another users data', async () => {
  await seedUser('admin-1', validUser({ role: 'admin' }));
  await seedUser('user-1', validUser());
  await seedGoal('user-1', 'goal-1', validGoal());
  const db = await authedDb('admin-1');
  await assertSucceeds(getDoc(doc(db, 'users/user-1/goals/goal-1')));
  await assertSucceeds(
    setDoc(doc(db, 'users/user-1/tasks/task-1'), validTask()),
  );
});
