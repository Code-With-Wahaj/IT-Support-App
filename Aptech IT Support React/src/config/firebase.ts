import { initializeApp, getApps, getApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyCZpD7tWO02MEJv5VMphU82aC3dt_RUCjs',
  authDomain: 'aptech-it-support.firebaseapp.com',
  projectId: 'aptech-it-support',
  storageBucket: 'aptech-it-support.firebasestorage.app',
  messagingSenderId: '416774545611',
  appId: '1:416774545611:web:0d6fd58723dc987b997b4e',
  measurementId: 'G-EGMFY8YY7F',
};

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApp();
const auth = getAuth(app);
const db = getFirestore(app);

export { app, auth, db };
