export type UserRole = 'Admin' | 'Faculty' | 'IT Technician';

export interface UserModel {
  uid: string;
  name: string;
  email: string;
  role: UserRole;
  isApproved: boolean;
  createdAt: number;
  associatedLabs?: string[];
}
