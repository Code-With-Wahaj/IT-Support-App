import { create } from 'zustand';
import { ComplaintCategory, ComplaintModel, ComplaintStatus } from '../types/complaint';
import { complaintService } from '../services/complaintService';

interface ComplaintState {
  complaints: ComplaintModel[];
  isLoading: boolean;
  searchQuery: string;
  statusFilter: ComplaintStatus | 'All';
  categoryFilter: ComplaintCategory | 'All';
  labFilter: string | 'All';
  dateRange: 'all' | 'today' | '7days' | '30days';

  setSearchQuery: (query: string) => void;
  setStatusFilter: (status: ComplaintStatus | 'All') => void;
  setCategoryFilter: (category: ComplaintCategory | 'All') => void;
  setLabFilter: (lab: string | 'All') => void;
  setDateRange: (range: 'all' | 'today' | '7days' | '30days') => void;
  resetFilters: () => void;

  startListening: () => () => void;
  getFilteredComplaints: () => ComplaintModel[];
}

export const useComplaintStore = create<ComplaintState>((set, get) => ({
  complaints: [],
  isLoading: true,
  searchQuery: '',
  statusFilter: 'All',
  categoryFilter: 'All',
  labFilter: 'All',
  dateRange: 'all',

  setSearchQuery: (searchQuery) => set({ searchQuery }),
  setStatusFilter: (statusFilter) => set({ statusFilter }),
  setCategoryFilter: (categoryFilter) => set({ categoryFilter }),
  setLabFilter: (labFilter) => set({ labFilter }),
  setDateRange: (dateRange) => set({ dateRange }),

  resetFilters: () =>
    set({
      searchQuery: '',
      statusFilter: 'All',
      categoryFilter: 'All',
      labFilter: 'All',
      dateRange: 'all',
    }),

  startListening: () => {
    set({ isLoading: true });
    return complaintService.subscribeToComplaints((complaints) => {
      set({ complaints, isLoading: false });
    });
  },

  getFilteredComplaints: () => {
    const { complaints, searchQuery, statusFilter, categoryFilter, labFilter, dateRange } = get();

    return complaints.filter((c) => {
      // Search
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        const matchesMsg = c.message?.toLowerCase().includes(q);
        const matchesFaculty = c.facultyName?.toLowerCase().includes(q);
        const matchesLab = c.lab?.toLowerCase().includes(q);
        const matchesIssue = c.issue?.toLowerCase().includes(q);
        if (!matchesMsg && !matchesFaculty && !matchesLab && !matchesIssue) return false;
      }

      // Status
      if (statusFilter !== 'All' && c.status !== statusFilter) return false;

      // Category
      if (categoryFilter !== 'All' && c.issueCategory !== categoryFilter) return false;

      // Lab
      if (labFilter !== 'All' && c.lab.toLowerCase() !== labFilter.toLowerCase()) return false;

      // Date Range
      if (dateRange !== 'all' && c.timestamp) {
        const ticketDate = c.timestamp.toDate ? c.timestamp.toDate() : new Date(c.timestamp);
        const now = new Date();
        const diffDays = (now.getTime() - ticketDate.getTime()) / (1000 * 3600 * 24);

        if (dateRange === 'today' && diffDays > 1) return false;
        if (dateRange === '7days' && diffDays > 7) return false;
        if (dateRange === '30days' && diffDays > 30) return false;
      }

      return true;
    });
  },
}));
