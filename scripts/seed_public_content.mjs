import { initializeApp } from 'firebase/app';
import { getAuth, signInWithEmailAndPassword } from 'firebase/auth';
import { doc, getFirestore, setDoc } from 'firebase/firestore';

const email = process.env.FIREBASE_SEED_EMAIL;
const password = process.env.FIREBASE_SEED_PASSWORD;

if (!email || !password) {
  console.error(
    'Missing credentials. Run with FIREBASE_SEED_EMAIL and FIREBASE_SEED_PASSWORD.',
  );
  process.exit(1);
}

const app = initializeApp({
  apiKey: 'AIzaSyAr_KncNJ7awiSRHzMOlStDs2pp1uKmJWw',
  authDomain: 'studyflow-mit-2026-df982.firebaseapp.com',
  projectId: 'studyflow-mit-2026-df982',
  storageBucket: 'studyflow-mit-2026-df982.firebasestorage.app',
  messagingSenderId: '1023070192441',
  appId: '1:1023070192441:web:0518a3f4e8c59074549ee8',
});

const auth = getAuth(app);
const db = getFirestore(app);

const goals = [
  {
    id: 'public-goal-math',
    data: {
      area: 'Mathematics',
      type: 'Midterm preparation',
      description:
        'Review derivatives, integrals, and common exam tasks before the next midterm.',
      coverUrl:
        'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=1200&q=80',
      targetDate: '2026-05-15T00:00:00.000',
    },
  },
  {
    id: 'public-goal-physics',
    data: {
      area: 'Physics',
      type: 'Lab report',
      description:
        'Organize measurements, graphs, and the final conclusion for a lab submission.',
      coverUrl:
        'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=1200&q=80',
      targetDate: '2026-05-08T00:00:00.000',
    },
  },
  {
    id: 'public-goal-writing',
    data: {
      area: 'Academic writing',
      type: 'Essay draft',
      description:
        'Prepare an outline, body paragraphs, references, and final proofreading notes.',
      coverUrl:
        'https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=1200&q=80',
      targetDate: '2026-05-20T00:00:00.000',
    },
  },
];

const tasks = [
  {
    id: 'public-task-math-summary',
    data: {
      goalId: 'public-goal-math',
      title: 'Create a one-page formula summary',
      notes: 'Include derivative rules, integral patterns, and common mistakes.',
      dueDate: '2026-05-03T00:00:00.000',
      isDone: false,
      priority: 2,
      createdAt: '2026-04-15T00:00:00.000',
      subtasks: [
        {
          id: 'public-subtask-math-1',
          title: 'List core formulas',
          isDone: true,
        },
        {
          id: 'public-subtask-math-2',
          title: 'Add solved examples',
          isDone: false,
        },
      ],
    },
  },
  {
    id: 'public-task-math-past-paper',
    data: {
      goalId: 'public-goal-math',
      title: 'Solve one previous exam',
      notes: 'Use a timer and mark questions that need another review.',
      dueDate: '2026-05-06T00:00:00.000',
      isDone: false,
      priority: 2,
      createdAt: '2026-04-15T00:00:00.000',
      subtasks: [],
    },
  },
  {
    id: 'public-task-physics-graphs',
    data: {
      goalId: 'public-goal-physics',
      title: 'Prepare lab graphs',
      notes: 'Check labels, units, and outlier values before writing the report.',
      dueDate: '2026-05-04T00:00:00.000',
      isDone: false,
      priority: 1,
      createdAt: '2026-04-15T00:00:00.000',
      subtasks: [],
    },
  },
  {
    id: 'public-task-writing-outline',
    data: {
      goalId: 'public-goal-writing',
      title: 'Finalize essay outline',
      notes: 'Lock the argument order and decide which sources belong in each section.',
      dueDate: '2026-05-07T00:00:00.000',
      isDone: false,
      priority: 1,
      createdAt: '2026-04-15T00:00:00.000',
      subtasks: [],
    },
  },
];

async function seed() {
  const credential = await signInWithEmailAndPassword(auth, email, password);
  console.log(`Signed in as ${credential.user.email}`);

  for (const goal of goals) {
    await setDoc(doc(db, 'public_goals', goal.id), goal.data);
    console.log(`Seeded public_goals/${goal.id}`);
  }

  for (const task of tasks) {
    await setDoc(doc(db, 'public_tasks', task.id), task.data);
    console.log(`Seeded public_tasks/${task.id}`);
  }

  console.log('Public seed complete.');
}

seed().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
