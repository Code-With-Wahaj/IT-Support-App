import {
  collection,
  doc,
  setDoc,
  getDoc,
  getDocs,
  updateDoc,
  query,
  where,
  orderBy,
  onSnapshot,
  serverTimestamp,
  Timestamp,
} from 'firebase/firestore';
import { auth, db } from '../config/firebase';
import { ComplaintCategory, ComplaintModel, ComplaintStatus } from '../types/complaint';

export const complaintService = {
  detectLab(text: string): string {
    const msg = text.toLowerCase();
    const regex = /\b(\d{3})\b/g;
    const matches = Array.from(msg.matchAll(regex));

    for (const m of matches) {
      const room = parseInt(m[1], 10);
      if ((room >= 101 && room <= 120) || (room >= 201 && room <= 220)) {
        return `Lab ${room}`;
      }
    }

    if (msg.includes('jbr')) return 'JBR Lab';
    if (msg.includes('ibr')) return 'IBR Lab';

    return 'Unknown Lab';
  },

  detectIssue(msgText: string): { issue: string; category: ComplaintCategory } {
    const msg = msgText.toLowerCase();

    const examKeywords = [
      'activex',
      'activex issue',
      'exam',
      'exam issue',
      'exam portal',
      'exam portal issue',
      'portal issue',
      'safe exam browser',
      'seb',
    ];

    const softwareKeywords = [
      'lanschool',
      'software',
      'sql',
      'android studio',
      'vscode',
      'mongodb',
      'not working',
      'app crash',
      'installation',
      'screen sharing',
    ];

    const hardwareKeywords = [
      'mouse',
      'keyboard',
      'monitor',
      'led',
      'pc',
      'cpu',
      'printer',
      'hardware',
      'ram',
      'screen',
    ];

    const networkKeywords = [
      'wifi',
      'internet',
      'internet issue',
      'internet problem',
      'lan',
      'network',
      'cable',
      'not connecting',
    ];

    const accessKeywords = [
      'login',
      'password',
      'blocked',
      'access denied',
      'account',
      'credentials',
      'admin credentials',
      'admin login',
      'admin password',
    ];

    const findMatch = (list: string[]) => list.find((w) => msg.includes(w));

    const exam = findMatch(examKeywords);
    if (exam) return { issue: exam, category: 'Exam' };

    const soft = findMatch(softwareKeywords);
    if (soft) return { issue: soft, category: 'Software' };

    const hard = findMatch(hardwareKeywords);
    if (hard) return { issue: hard, category: 'Hardware' };

    const net = findMatch(networkKeywords);
    if (net) return { issue: net, category: 'Network' };

    const acc = findMatch(accessKeywords);
    if (acc) return { issue: acc, category: 'Access' };

    return { issue: 'Other', category: 'Other' };
  },

  async createComplaint(message: string): Promise<string> {
    const user = auth.currentUser;
    if (!user) throw new Error('User must be logged in to create a complaint');

    const complaintId = doc(collection(db, 'complaints')).id;
    const detectedLab = this.detectLab(message);
    const msgWithoutLab = message.toLowerCase().replace(/\d+/g, '');
    const issueData = this.detectIssue(msgWithoutLab);

    // Find technician assigned to this lab
    let assignedToId = 'Not Assigned';
    let assignedToName = 'Not Assigned';

    if (detectedLab !== 'Unknown Lab') {
      const techQuery = query(
        collection(db, 'users'),
        where('role', '==', 'IT Technician'),
        where('associatedLabs', 'array-contains', detectedLab)
      );
      const techSnap = await getDocs(techQuery);
      if (!techSnap.empty) {
        const tech = techSnap.docs[0];
        assignedToId = tech.id;
        assignedToName = tech.data().name || 'Not Assigned';
      }
    }

    // Fetch user name
    let facultyName = user.displayName || '';
    if (!facultyName) {
      const userDoc = await getDoc(doc(db, 'users', user.uid));
      facultyName = userDoc.data()?.name || user.email || 'Faculty';
    }

    const complaintData: any = {
      complaintId,
      facultyId: user.uid,
      facultyName,
      message,
      timestamp: serverTimestamp(),
      lab: detectedLab,
      issue: issueData.issue,
      issueCategory: issueData.category,
      assignedToId,
      assignedToName,
      status: 'Pending',
      resolvedById: '',
      resolvedByName: '',
      statusUpdatedById: '',
      statusUpdatedByName: '',
      resolutionTimestamp: null,
      timeTaken: null,
    };

    await setDoc(doc(db, 'complaints', complaintId), complaintData);
    return complaintId;
  },

  async updateStatus(params: {
    complaintId: string;
    newStatus: ComplaintStatus;
    updaterId: string;
    updaterName: string;
    resolverId?: string;
    resolverName?: string;
  }): Promise<void> {
    const compRef = doc(db, 'complaints', params.complaintId);
    const docSnap = await getDoc(compRef);
    if (!docSnap.exists()) return;

    const data = docSnap.data();
    const createdAt = data.timestamp;

    const updateData: any = {
      status: params.newStatus,
      statusUpdatedById: params.updaterId,
      statusUpdatedByName: params.updaterName,
      resolvedById: params.resolverId || '',
      resolvedByName: params.resolverName || '',
    };

    if (params.newStatus === 'Resolved') {
      const resolvedAt = Timestamp.now();
      updateData.resolutionTimestamp = resolvedAt;

      if (createdAt) {
        const createdDate = createdAt.toDate ? createdAt.toDate() : new Date(createdAt);
        const diffMs = resolvedAt.toDate().getTime() - createdDate.getTime();
        updateData.timeTaken = Math.max(1, Math.round(diffMs / 60000));
      }
    }

    await updateDoc(compRef, updateData);
  },

  subscribeToComplaints(callback: (complaints: ComplaintModel[]) => void) {
    const q = query(collection(db, 'complaints'), orderBy('timestamp', 'desc'));
    return onSnapshot(q, (snapshot: any) => {
      const list = snapshot.docs.map((d: any) => d.data() as ComplaintModel);
      callback(list);
    });
  },
};
