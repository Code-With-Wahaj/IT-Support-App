import { create } from 'zustand';
import { User, onAuthStateChanged } from 'firebase/auth';
import { auth } from '../config/firebase';
import { UserModel } from '../types/user';
import { authService } from '../services/authService';

interface AuthState {
  user: UserModel | null;
  firebaseUser: User | null;
  isLoading: boolean;
  setUser: (user: UserModel | null) => void;
  fetchUserProfile: (uid: string) => Promise<void>;
  initializeAuth: () => () => void;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  firebaseUser: null,
  isLoading: true,

  setUser: (user) => set({ user }),

  fetchUserProfile: async (uid: string) => {
    const profile = await authService.getUserDoc(uid);
    set({ user: profile, isLoading: false });
  },

  initializeAuth: () => {
    return onAuthStateChanged(auth, async (fbUser: any) => {
      if (fbUser) {
        set({ firebaseUser: fbUser });
        const profile = await authService.getUserDoc(fbUser.uid);
        set({ user: profile, isLoading: false });
      } else {
        set({ user: null, firebaseUser: null, isLoading: false });
      }
    });
  },

  logout: async () => {
    await authService.logout();
    set({ user: null, firebaseUser: null });
  },
}));
