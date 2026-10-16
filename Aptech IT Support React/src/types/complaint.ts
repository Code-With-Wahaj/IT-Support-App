export type ComplaintCategory = 'Hardware' | 'Software' | 'Network' | 'Exam' | 'Access' | 'Other';

export type ComplaintStatus = 'Pending' | 'In Progress' | 'Resolved';

export interface ComplaintModel {
  complaintId: string;
  facultyId: string;
  facultyName: string;
  message: string;
  timestamp: any;
  lab: string;
  issue: string;
  issueCategory: ComplaintCategory;
  assignedToId: string;
  assignedToName: string;
  status: ComplaintStatus;
  resolvedById: string;
  resolvedByName: string;
  statusUpdatedById: string;
  statusUpdatedByName: string;
  resolutionTimestamp?: any;
  timeTaken?: number | null;
}
