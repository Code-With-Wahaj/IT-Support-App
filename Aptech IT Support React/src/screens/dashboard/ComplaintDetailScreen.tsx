import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import {
  ArrowLeft,
  Calendar,
  User,
  MapPin,
  Clock,
  CheckCircle2,
  AlertCircle,
  Wrench,
} from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { ComplaintStatus } from '../../types/complaint';
import { useAuthStore } from '../../stores/useAuthStore';
import { complaintService } from '../../services/complaintService';
import { GlassCard } from '../../components/common/GlassCard';
import { StatusBadge } from '../../components/common/StatusBadge';
import { CustomButton } from '../../components/common/CustomButton';

type DetailScreenRouteProp = RouteProp<RootStackParamList, 'ComplaintDetail'>;
type DetailScreenNavProp = StackNavigationProp<RootStackParamList, 'ComplaintDetail'>;

type Props = {
  route: DetailScreenRouteProp;
  navigation: DetailScreenNavProp;
};

export const ComplaintDetailScreen: React.FC<Props> = ({ route, navigation }) => {
  const { complaint } = route.params;
  const { user } = useAuthStore();
  const [currentStatus, setCurrentStatus] = useState<ComplaintStatus>(complaint.status);
  const [updating, setUpdating] = useState(false);

  const canUpdate = user?.role === 'Admin' || user?.role === 'IT Technician';

  const handleStatusChange = async (newStatus: ComplaintStatus) => {
    if (!user) return;
    setUpdating(true);
    try {
      await complaintService.updateStatus({
        complaintId: complaint.complaintId,
        newStatus,
        updaterId: user.uid,
        updaterName: user.name,
        resolverId: newStatus === 'Resolved' ? user.uid : undefined,
        resolverName: newStatus === 'Resolved' ? user.name : undefined,
      });
      setCurrentStatus(newStatus);
      Alert.alert('Success', `Ticket marked as ${newStatus}`);
    } catch (e: any) {
      Alert.alert('Error', e.message || 'Failed to update status');
    } finally {
      setUpdating(false);
    }
  };

  let formattedDate = 'N/A';
  if (complaint.timestamp) {
    const d = complaint.timestamp.toDate
      ? complaint.timestamp.toDate()
      : new Date(complaint.timestamp);
    formattedDate = d.toLocaleString();
  }

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.appBar}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <ArrowLeft size={20} color={colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Ticket Details</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        {/* Top Info Card */}
        <GlassCard elevated style={styles.mainCard}>
          <View style={styles.cardHeader}>
            <Text style={styles.ticketId}>ID: #{complaint.complaintId.slice(0, 8)}</Text>
            <StatusBadge status={currentStatus} />
          </View>

          <Text style={styles.messageText}>{complaint.message}</Text>

          <View style={styles.metaDivider} />

          <View style={styles.metaRow}>
            <View style={styles.metaItem}>
              <MapPin size={16} color={colors.primary} />
              <Text style={styles.metaText}>{complaint.lab}</Text>
            </View>

            <StatusBadge category={complaint.issueCategory} size="sm" />
          </View>

          <View style={styles.metaRow}>
            <View style={styles.metaItem}>
              <User size={16} color={colors.textSecondary} />
              <Text style={styles.metaText}>Reporter: {complaint.facultyName}</Text>
            </View>
          </View>

          <View style={styles.metaRow}>
            <View style={styles.metaItem}>
              <Calendar size={16} color={colors.textSecondary} />
              <Text style={styles.metaText}>{formattedDate}</Text>
            </View>
          </View>

          <View style={styles.metaRow}>
            <View style={styles.metaItem}>
              <Wrench size={16} color={colors.secondary} />
              <Text style={styles.metaText}>Assigned: {complaint.assignedToName}</Text>
            </View>
          </View>

          {complaint.timeTaken != null ? (
            <View style={styles.metaRow}>
              <View style={styles.metaItem}>
                <Clock size={16} color={colors.success} />
                <Text style={[styles.metaText, { color: colors.success }]}>
                  Resolved in {complaint.timeTaken} minutes
                </Text>
              </View>
            </View>
          ) : null}
        </GlassCard>

        {/* Status Actions */}
        {canUpdate ? (
          <GlassCard style={styles.actionCard}>
            <Text style={styles.actionTitle}>Update Ticket State</Text>
            <Text style={styles.actionDesc}>
              Change workflow state as an authorized technician or administrator.
            </Text>

            <View style={styles.btnRow}>
              <CustomButton
                title="Mark In Progress"
                onPress={() => handleStatusChange('In Progress')}
                variant={currentStatus === 'In Progress' ? 'primary' : 'outline'}
                loading={updating}
                style={{ flex: 1 }}
              />

              <CustomButton
                title="Mark Resolved"
                onPress={() => handleStatusChange('Resolved')}
                variant={currentStatus === 'Resolved' ? 'secondary' : 'primary'}
                loading={updating}
                style={{ flex: 1 }}
              />
            </View>
          </GlassCard>
        ) : null}
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
    gap: 14,
    paddingTop: 50,
    paddingHorizontal: 20,
    paddingBottom: 16,
    backgroundColor: colors.surfaceElevated,
    borderBottomWidth: 1,
    borderBottomColor: colors.surfaceBorder,
  },
  backBtn: {
    padding: 6,
    borderRadius: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: colors.textPrimary,
  },
  content: {
    padding: 20,
  },
  mainCard: {
    padding: 20,
    marginBottom: 20,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  ticketId: {
    fontSize: 13,
    fontWeight: '700',
    color: colors.textMuted,
    letterSpacing: 0.5,
  },
  messageText: {
    fontSize: 17,
    fontWeight: '600',
    color: colors.textPrimary,
    lineHeight: 24,
    marginBottom: 16,
  },
  metaDivider: {
    height: 1,
    backgroundColor: colors.surfaceBorder,
    marginBottom: 14,
  },
  metaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  metaItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  metaText: {
    fontSize: 13,
    color: colors.textSecondary,
    fontWeight: '500',
  },
  actionCard: {
    padding: 20,
  },
  actionTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.textPrimary,
    marginBottom: 4,
  },
  actionDesc: {
    fontSize: 13,
    color: colors.textSecondary,
    marginBottom: 16,
  },
  btnRow: {
    flexDirection: 'row',
    gap: 10,
  },
});
