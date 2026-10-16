import { ComplaintModel } from '../types/complaint';
import { LabModel } from '../types/lab';

export type RootStackParamList = {
  Splash: undefined;
  Login: undefined;
  Signup: undefined;
  ForgotPassword: undefined;
  Dashboard: undefined;
  Chats: undefined;
  ComplaintDetail: { complaint: ComplaintModel };
  FilterComplaints: undefined;
  LabList: undefined;
  AddEditLab: { lab?: LabModel } | undefined;
  Lab3D: { lab: LabModel };
  ManageUsers: undefined;
  AdminAddUser: undefined;
};
