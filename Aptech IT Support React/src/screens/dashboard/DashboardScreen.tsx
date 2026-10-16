import React, { useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  RefreshControl,
  Alert,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import {
  MessageSquarePlus,
  Monitor,
  Filter,
  Users,
  LogOut,
  Clock,
  CheckCircle2,
  AlertCircle,
  ChevronRight,
} from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { useAuthStore } from '../../stores/useAuthStore';
import { useComplaintStore } from '../../stores/useComplaintStore';
import { GlassCard } from '../../components/common/GlassCard';
import { StatusBadge } from '../../components/common/StatusBadge';

type DashboardScreenProps = {
  navigation: StackNavigationProp<RootStackParamList, 'Dashboard'>;
};

export const DashboardScreen: React.FC<DashboardScreenProps> = ({ navigation }) => {
  const { user, logout } = useAuthStore();
  const { complaints, isLoading, startListening } = useComplaintStore();

  useEffect(() => {
    const unsub = startListening();
    return () => unsub();
  }, []);

  const handleLogout = () => {
    Alert.alert('Confirm Sign Out', 'Are you sure you want to sign out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Sign Out',
        style: 'destructive',
        onPress: async () => {
          await logout();
          navigation.replace('Login');
        },
      },
    ]);
  };

  // Metrics
  const pendingCount = complaints.filter((c) => c.status === 'Pending').length;
  const inProgressCount = complaints.filter((c) => c.status === 'In Progress').length;
  const resolvedCount = complaints.filter((c) => c.status === 'Resolved').length;

  return (
    <View style={styles.container}>
      {/* Top App Bar */}
      <View style={styles.appBar}>
        <View>
          <Text style={styles.welcomeText}>Welcome back,</Text>
          <Text style={styles.userName}>{user?.name || 'Authorized User'}</Text>
        </View>

        <View style={styles.appBarRight}>
          <StatusBadge role={user?.role} />
          <TouchableOpacity onPress={handleLogout} style={styles.logoutBtn}>
            <LogOut size={18} color={colors.danger} />
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={isLoading} tintColor={colors.primary} />
        }
      >
        {/* Metrics Grid */}
        <View style={styles.metricsRow}>
          <GlassCard style={[styles.metricCard, { borderColor: colors.dangerBorder }]}>
            <View style={styles.metricHeader}>
              <AlertCircle size={18} color={colors.danger} />
              <Text style={[styles.metricCount, { color: colors.danger }]}>{pendingCount}</Text>
            </View>
            <Text style={styles.metricLabel}>Pending</Text>
          </GlassCard>

          <GlassCard style={[styles.metricCard, { borderColor: colors.warningBorder }]}>
            <View style={styles.metricHeader}>
              <Clock size={18} color={colors.warning} />
              <Text style={[styles.metricCount, { color: colors.warning }]}>{inProgressCount}</Text>
            </View>
            <Text style={styles.metricLabel}>In Progress</Text>
          </GlassCard>

          <GlassCard style={[styles.metricCard, { borderColor: colors.successBorder }]}>
            <View style={styles.metricHeader}>
              <CheckCircle2 size={18} color={colors.success} />
              <Text style={[styles.metricCount, { color: colors.success }]}>{resolvedCount}</Text>
            </View>
            <Text style={styles.metricLabel}>Resolved</Text>
          </GlassCard>
        </View>

        {/* Quick Action Navigation Buttons */}
        <Text style={styles.sectionHeading}>Quick Services</Text>
        <View style={styles.actionsGrid}>
          <TouchableOpacity
            style={styles.actionCard}
            onPress={() => navigation.navigate('Chats')}
          >
            <View style={[styles.actionIconBox, { backgroundColor: 'rgba(6, 182, 212, 0.15)' }]}>
              <MessageSquarePlus size={24} color={colors.primary} />
            </View>
            <Text style={styles.actionTitle}>Report / Chat</Text>
            <Text style={styles.actionDesc}>Auto-detect room & issue</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.actionCard}
            onPress={() => navigation.navigate('LabList')}
          >
            <View style={[styles.actionIconBox, { backgroundColor: 'rgba(59, 130, 246, 0.15)' }]}>
              <Monitor size={24} color={colors.secondary} />
            </View>
            <Text style={styles.actionTitle}>Labs & 3D View</Text>
            <Text style={styles.actionDesc}>Isometric PC diagnostics</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.actionCard}
            onPress={() => navigation.navigate('FilterComplaints')}
          >
            <View style={[styles.actionIconBox, { backgroundColor: 'rgba(139, 92, 246, 0.15)' }]}>
              <Filter size={24} color={colors.accent} />
            </View>
            <Text style={styles.actionTitle}>Filter & Excel</Text>
            <Text style={styles.actionDesc}>Search, filter, export</Text>
          </TouchableOpacity>

          {user?.role === 'Admin' ? (
            <TouchableOpacity
              style={styles.actionCard}
              onPress={() => navigation.navigate('ManageUsers')}
            >
              <View style={[styles.actionIconBox, { backgroundColor: 'rgba(239, 68, 68, 0.15)' }]}>
                <Users size={24} color={colors.danger} />
              </View>
              <Text style={styles.actionTitle}>User Management</Text>
              <Text style={styles.actionDesc}>Approve & assign roles</Text>
            </TouchableOpacity>
          ) : null}
        </View>

        {/* Recent Tickets Feed */}
        <View style={styles.recentHeader}>
          <Text style={styles.sectionHeading}>Recent Complaints</Text>
          <TouchableOpacity onPress={() => navigation.navigate('FilterComplaints')}>
            <Text style={styles.viewAllLink}>View All</Text>
          </TouchableOpacity>
        </View>

        {complaints.length === 0 ? (
          <GlassCard style={styles.emptyCard}>
            <Text style={styles.emptyText}>No registered tickets found.</Text>
          </GlassCard>
        ) : (
          complaints.slice(0, 5).map((item) => (
            <TouchableOpacity
              key={item.complaintId}
              activeOpacity={0.7}
              onPress={() => navigation.navigate('ComplaintDetail', { complaint: item })}
            >
              <GlassCard style={styles.ticketCard}>
                <View style={styles.ticketTop}>
                  <View style={styles.labBadge}>
                    <Text style={styles.labText}>{item.lab}</Text>
                  </View>
                  <StatusBadge status={item.status} size="sm" />
                </View>

                <Text style={styles.ticketMessage} numberOfLines={2}>
                  {item.message}
                </Text>

                <View style={styles.ticketBottom}>
                  <Text style={styles.facultyText}>By {item.facultyName}</Text>
                  <View style={styles.assignedRow}>
                    <Text style={styles.assignedText}>Assigned: {item.assignedToName}</Text>
                    <ChevronRight size={16} color={colors.textMuted} />
                  </View>
                </View>
              </GlassCard>
            </TouchableOpacity>
          ))
        )}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  appBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: 50,
    paddingHorizontal: 20,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: colors.surfaceBorder,
    backgroundColor: colors.surfaceElevated,
  },
  welcomeText: {
    fontSize: 12,
    color: colors.textSecondary,
    fontWeight: '500',
  },
  userName: {
    fontSize: 18,
    fontWeight: '800',
    color: colors.textPrimary,
  },
  appBarRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  logoutBtn: {
    padding: 8,
    borderRadius: 8,
    backgroundColor: colors.dangerBg,
  },
  scrollContent: {
    padding: 20,
  },
  metricsRow: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 24,
  },
  metricCard: {
    flex: 1,
    padding: 12,
    borderRadius: 14,
  },
  metricHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
  },
  metricCount: {
    fontSize: 20,
    fontWeight: '800',
  },
  metricLabel: {
    fontSize: 11,
    color: colors.textSecondary,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  sectionHeading: {
    fontSize: 16,
    fontWeight: '800',
    color: colors.textPrimary,
    marginBottom: 12,
  },
  actionsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    marginBottom: 28,
  },
  actionCard: {
    width: '48%',
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    borderRadius: 16,
    padding: 16,
  },
  actionIconBox: {
    width: 44,
    height: 44,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  actionTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: colors.textPrimary,
    marginBottom: 4,
  },
  actionDesc: {
    fontSize: 11,
    color: colors.textSecondary,
  },
  recentHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  viewAllLink: {
    color: colors.primary,
    fontSize: 13,
    fontWeight: '600',
  },
  ticketCard: {
    marginBottom: 10,
    padding: 14,
  },
  ticketTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  labBadge: {
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
  },
  labText: {
    color: colors.primary,
    fontSize: 11,
    fontWeight: '700',
  },
  ticketMessage: {
    fontSize: 14,
    color: colors.textPrimary,
    fontWeight: '500',
    marginBottom: 10,
    lineHeight: 20,
  },
  ticketBottom: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.05)',
    paddingTop: 8,
  },
  facultyText: {
    fontSize: 12,
    color: colors.textSecondary,
  },
  assignedRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  assignedText: {
    fontSize: 12,
    color: colors.textMuted,
  },
  emptyCard: {
    padding: 30,
    alignItems: 'center',
  },
  emptyText: {
    color: colors.textMuted,
    fontSize: 14,
  },
});
