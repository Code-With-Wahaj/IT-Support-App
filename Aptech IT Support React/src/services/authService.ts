import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  User,
} from 'firebase/auth';
import {
  doc,
  setDoc,
  getDoc,
  updateDoc,
  deleteDoc,
  collection,
  onSnapshot,
  query,
  orderBy,
} from 'firebase/firestore';
import { auth, db } from '../config/firebase';
import { UserModel, UserRole } from '../types/user';

export const authService = {
  async signUp(params: {
    name: string;
    email: string;
    password: string;
    role: UserRole;
    associatedLabs?: string[];
    isApproved?: boolean;
  }): Promise<string | null> {
    try {
      const cred = await createUserWithEmailAndPassword(auth, params.email, params.password);
      const data: UserModel = {
        uid: cred.user.uid,
        name: params.name,
        email: params.email,
        role: params.role,
        isApproved: params.isApproved ?? false,
        createdAt: Date.now(),
      };

      if (params.role === 'IT Technician' && params.associatedLabs?.length) {
        data.associatedLabs = params.associatedLabs;
      }

      await setDoc(doc(db, 'users', cred.user.uid), data);
      return null;
    } catch (err: any) {
      return err.message || 'Signup failed';
    }
  },

  async login(email: string, password: string): Promise<string | null> {
    try {
      await signInWithEmailAndPassword(auth, email, password);
      return null;
    } catch (err: any) {
      return err.message || 'Login failed';
    }
  },

  async logout(): Promise<void> {
    await signOut(auth);
  },

  getCurrentUser(): User | null {
    return auth.currentUser;
  },

  async getUserDoc(uid: string): Promise<UserModel | null> {
    const snap = await getDoc(doc(db, 'users', uid));
    if (snap.exists()) {
      return snap.data() as UserModel;
    }
    return null;
  },

  subscribeToUsers(callback: (users: UserModel[]) => void) {
    const q = query(collection(db, 'users'), orderBy('createdAt', 'desc'));
    return onSnapshot(q, (snapshot: any) => {
      const users = snapshot.docs.map((d: any) => d.data() as UserModel);
      callback(users);
    });
  },

  async updateUserDoc(uid: string, data: Partial<UserModel>): Promise<void> {
    await updateDoc(doc(db, 'users', uid), data);
  },

  async setApproval(uid: string, isApproved: boolean): Promise<void> {
    await updateDoc(doc(db, 'users', uid), { isApproved });
  },

  async deleteUser(uid: string): Promise<void> {
    await deleteDoc(doc(db, 'users', uid));
  },
};
