import { create } from 'zustand';
import {
  collection,
  doc,
  setDoc,
  getDocs,
  updateDoc,
  deleteDoc,
  onSnapshot,
  writeBatch,
} from 'firebase/firestore';
import { db } from '../config/firebase';
import { LabModel, PcStatusModel } from '../types/lab';

interface LabState {
  labs: LabModel[];
  currentLabPcs: PcStatusModel[];
  isLoading: boolean;
  isPcsLoading: boolean;

  subscribeToLabs: () => () => void;
  subscribeToLabPcs: (labId: string) => () => void;
  updatePcStatus: (labId: string, pcId: string, data: Partial<PcStatusModel>) => Promise<void>;
  addLab: (lab: Omit<LabModel, 'id'>) => Promise<string>;
}

export const useLabStore = create<LabState>((set) => ({
  labs: [],
  currentLabPcs: [],
  isLoading: true,
  isPcsLoading: false,

  subscribeToLabs: () => {
    set({ isLoading: true });
    return onSnapshot(collection(db, 'labs'), async (snapshot: any) => {
      const labsList: LabModel[] = snapshot.docs.map((d: any) => ({
        id: d.id,
        ...(d.data() as Omit<LabModel, 'id'>),
      }));
      set({ labs: labsList, isLoading: false });
    });
  },

  subscribeToLabPcs: (labId: string) => {
    set({ isPcsLoading: true });
    const pcsCollection = collection(db, 'labs', labId, 'pcs');
    return onSnapshot(pcsCollection, (snapshot: any) => {
      const pcs: PcStatusModel[] = snapshot.docs.map((d: any) => ({
        pcId: d.id,
        ...(d.data() as Omit<PcStatusModel, 'pcId'>),
      }));
      set({ currentLabPcs: pcs, isPcsLoading: false });
    });
  },

  updatePcStatus: async (labId: string, pcId: string, data: Partial<PcStatusModel>) => {
    const pcRef = doc(db, 'labs', labId, 'pcs', pcId);
    await updateDoc(pcRef, data);
  },

  addLab: async (labData) => {
    const labId = `lab_${Date.now()}`;
    const labRef = doc(db, 'labs', labId);
    await setDoc(labRef, labData);

    // Initialize PCs
    const batch = writeBatch(db);
    batch.set(doc(db, 'labs', labId, 'pcs', 'IP'), {
      keyboardOk: true,
      mouseOk: true,
      ledOk: true,
      vgaCableOk: true,
      powerCableOk: true,
      internetCableOk: true,
      cpuWorking: true,
      ram: '32 GB',
      ssd: '1 TB',
      os: 'Windows 11 Pro',
      notes: 'Instructor Workstation',
    });

    for (let r = 1; r <= labData.rows; r++) {
      for (let c = 1; c <= labData.columns; c++) {
        const pcId = `PC-${r}-${c}`;
        batch.set(doc(db, 'labs', labId, 'pcs', pcId), {
          keyboardOk: true,
          mouseOk: true,
          ledOk: true,
          vgaCableOk: true,
          powerCableOk: true,
          internetCableOk: true,
          cpuWorking: true,
          ram: '16 GB',
          ssd: '512 GB',
          os: 'Windows 11',
          notes: '',
        });
      }
    }

    await batch.commit();
    return labId;
  },
}));
