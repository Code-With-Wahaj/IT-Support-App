import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Switch,
  Alert,
  Modal,
  ScrollView,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import {
  ArrowLeft,
  UserPlus,
  Trash2,
  Edit3,
  Shield,
  CheckCircle,
  XCircle,
  X,
} from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { UserModel, UserRole } from '../../types/user';
import { authService } from '../../services/authService';
import { GlassCard } from '../../components/common/GlassCard';
import { StatusBadge } from '../../components/common/StatusBadge';
import { CustomInput } from '../../components/common/CustomInput';
import { CustomButton } from '../../components/common/CustomButton';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'ManageUsers'>;
};

const FILTER_TABS = ['All', 'Pending', 'IT Technician', 'Faculty', 'Admin'] as const;
const ALL_LABS = ['Lab 101', 'Lab 102', 'Lab 201', 'Lab 210', 'JBR Lab', 'IBR Lab'];

export const ManageUsersScreen: React.FC<Props> = ({ navigation }) => {
  const [users, setUsers] = useState<UserModel[]>([]);
  const [selectedTab, setSelectedTab] = useState<typeof FILTER_TABS[number]>('All');
  const [editingUser, setEditingUser] = useState<UserModel | null>(null);
  const [editRole, setEditRole] = useState<UserRole>('Faculty');
  const [editLabs, setEditLabs] = useState<string[]>([]);
  const [updating, setUpdating] = useState(false);

  useEffect(() => {
    const unsub = authService.subscribeToUsers((u) => setUsers(u));
    return () => unsub();
  }, []);

  const handleToggleApproval = async (uid: string, currentVal: boolean) => {
    try {
      await authService.setApproval(uid, !currentVal);
    } catch (e: any) {
      Alert.alert('Error', e.message || 'Failed to update approval');
    }
  };

  const handleDeleteUser = (user: UserModel) => {
    Alert.alert(
      'Delete User Record',
      `Are you sure you want to remove ${user.name}? This will revoke system access.`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await authService.deleteUser(user.uid);
            } catch (e: any) {
              Alert.alert('Error', e.message || 'Failed to delete user');
            }
          },
        },
      ]
    );
  };

  const openEditModal = (u: UserModel) => {
    setEditingUser(u);
    setEditRole(u.role);
    setEditLabs(u.associatedLabs || []);
  };

  const handleSaveEdit = async () => {
    if (!editingUser) return;
    setUpdating(true);
    try {
      await authService.updateUserDoc(editingUser.uid, {
        role: editRole,
        associatedLabs: editRole === 'IT Technician' ? editLabs : [],
      });
      setEditingUser(null);
    } catch (e: any) {
      Alert.alert('Error', e.message || 'Failed to update user profile');
    } finally {
      setUpdating(false);
    }
  };

  const toggleEditLab = (lab: string) => {
    if (editLabs.includes(lab)) {
      setEditLabs(editLabs.filter((l) => l !== lab));
    } else {
      setEditLabs([...editLabs, lab]);
    }
  };

  const filteredUsers = users.filter((u) => {
    if (selectedTab === 'Pending') return !u.isApproved;
    if (selectedTab === 'IT Technician') return u.role === 'IT Technician';
    if (selectedTab === 'Faculty') return u.role === 'Faculty';
    if (selectedTab === 'Admin') return u.role === 'Admin';
    return true;
  });

  const renderItem = ({ item }: { item: UserModel }) => (
    <GlassCard style={styles.userCard}>
      <View style={styles.userCardTop}>
        <View style={{ flex: 1 }}>
          <View style={styles.nameRow}>
            <Text style={styles.userName}>{item.name}</Text>
            <StatusBadge role={item.role} size="sm" />
          </View>
          <Text style={styles.userEmail}>{item.email}</Text>
        </View>

        <TouchableOpacity onPress={() => openEditModal(item)} style={styles.actionIcon}>
          <Edit3 size={18} color={colors.primary} />
        </TouchableOpacity>

        <TouchableOpacity onPress={() => handleDeleteUser(item)} style={styles.actionIcon}>
          <Trash2 size={18} color={colors.danger} />
        </TouchableOpacity>
      </View>

      {item.role === 'IT Technician' && item.associatedLabs?.length ? (
        <View style={styles.labsAssignedRow}>
          <Text style={styles.labsLabel}>Assigned Labs: </Text>
          <Text style={styles.labsList}>{item.associatedLabs.join(', ')}</Text>
        </View>
      ) : null}

      <View style={styles.approvalRow}>
        <View style={styles.approvalStatus}>
          {item.isApproved ? (
            <CheckCircle size={16} color={colors.success} />
          ) : (
            <XCircle size={16} color={colors.danger} />
          )}
          <Text style={[styles.approvalText, { color: item.isApproved ? colors.success : colors.danger }]}>
            {item.isApproved ? 'Approved Access' : 'Pending Approval'}
          </Text>
        </View>

        <Switch
          value={item.isApproved}
          onValueChange={() => handleToggleApproval(item.uid, item.isApproved)}
          trackColor={{ false: '#334155', true: colors.successBg }}
          thumbColor={item.isApproved ? colors.success : '#94A3B8'}
        />
      </View>
    </GlassCard>
  );

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.appBar}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <ArrowLeft size={20} color={colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>User Management</Text>
        <TouchableOpacity
          style={styles.addBtn}
          onPress={() => navigation.navigate('AdminAddUser')}
        >
          <UserPlus size={18} color="#020617" />
        </TouchableOpacity>
      </View>

      {/* Filter Tabs */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.tabsRow}>
        {FILTER_TABS.map((tab) => (
          <TouchableOpacity
            key={tab}
            style={[styles.tabChip, selectedTab === tab && styles.tabChipActive]}
            onPress={() => setSelectedTab(tab)}
          >
            <Text style={[styles.tabText, selectedTab === tab && styles.tabTextActive]}>
              {tab}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* List */}
      <FlatList
        data={filteredUsers}
        keyExtractor={(item: UserModel) => item.uid}
        renderItem={renderItem}
        contentContainerStyle={styles.listContent}
        ListEmptyComponent={
          <GlassCard style={styles.emptyCard}>
            <Text style={styles.emptyText}>No users matching filter.</Text>
          </GlassCard>
        }
      />

      {/* Edit User Modal */}
      <Modal visible={Boolean(editingUser)} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalCard}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Edit Profile: {editingUser?.name}</Text>
              <TouchableOpacity onPress={() => setEditingUser(null)}>
                <X size={20} color={colors.textSecondary} />
              </TouchableOpacity>
            </View>

            <ScrollView style={{ padding: 20 }}>
              <Text style={styles.sectionLabel}>System Role</Text>
              <View style={styles.modalRoleRow}>
                {(['Faculty', 'IT Technician', 'Admin'] as UserRole[]).map((r) => (
                  <TouchableOpacity
                    key={r}
                    onPress={() => setEditRole(r)}
                    style={[styles.roleSelectChip, editRole === r && styles.roleSelectChipActive]}
                  >
                    <Text
                      style={[
                        styles.roleSelectText,
                        editRole === r && styles.roleSelectTextActive,
                      ]}
                    >
                      {r}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>

              {editRole === 'IT Technician' ? (
                <View style={{ marginTop: 14 }}>
                  <Text style={styles.sectionLabel}>Associated Labs</Text>
                  <View style={styles.editLabsGrid}>
                    {ALL_LABS.map((lab) => {
                      const active = editLabs.includes(lab);
                      return (
                        <TouchableOpacity
                          key={lab}
                          onPress={() => toggleEditLab(lab)}
                          style={[styles.editLabChip, active && styles.editLabChipActive]}
                        >
                          <Text
                            style={[
                              styles.editLabChipText,
                              active && styles.editLabChipTextActive,
                            ]}
                          >
                            {lab}
                          </Text>
                        </TouchableOpacity>
                      );
                    })}
                  </View>
                </View>
              ) : null}

              <CustomButton
                title="Save Updates"
                onPress={handleSaveEdit}
                loading={updating}
                style={{ marginTop: 24 }}
              />
            </ScrollView>
          </View>
        </View>
      </Modal>
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
  addBtn: {
    backgroundColor: colors.primary,
    padding: 8,
    borderRadius: 8,
  },
  tabsRow: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    maxHeight: 56,
  },
  tabChip: {
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    marginRight: 8,
  },
  tabChipActive: {
    backgroundColor: 'rgba(6, 182, 212, 0.15)',
    borderColor: colors.primary,
  },
  tabText: {
    fontSize: 12,
    fontWeight: '600',
    color: colors.textSecondary,
  },
  tabTextActive: {
    color: colors.primary,
    fontWeight: '700',
  },
  listContent: {
    padding: 16,
  },
  userCard: {
    marginBottom: 12,
    padding: 16,
  },
  userCardTop: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 4,
  },
  userName: {
    fontSize: 15,
    fontWeight: '700',
    color: colors.textPrimary,
  },
  userEmail: {
    fontSize: 13,
    color: colors.textSecondary,
  },
  actionIcon: {
    padding: 8,
    marginLeft: 6,
    borderRadius: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.04)',
  },
  labsAssignedRow: {
    flexDirection: 'row',
    marginTop: 8,
    flexWrap: 'wrap',
  },
  labsLabel: {
    fontSize: 12,
    color: colors.textMuted,
  },
  labsList: {
    fontSize: 12,
    color: colors.primary,
    fontWeight: '600',
  },
  approvalRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.05)',
    paddingTop: 10,
    marginTop: 10,
  },
  approvalStatus: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  approvalText: {
    fontSize: 12,
    fontWeight: '600',
  },
  emptyCard: {
    padding: 30,
    alignItems: 'center',
    marginTop: 20,
  },
  emptyText: {
    color: colors.textMuted,
    fontSize: 14,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(2, 6, 23, 0.85)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalCard: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: 20,
    width: '100%',
    maxWidth: 450,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    overflow: 'hidden',
  },
  modalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 18,
    borderBottomWidth: 1,
    borderBottomColor: colors.surfaceBorder,
  },
  modalTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.textPrimary,
  },
  sectionLabel: {
    fontSize: 13,
    fontWeight: '600',
    color: colors.textSecondary,
    marginBottom: 8,
  },
  modalRoleRow: {
    flexDirection: 'row',
    gap: 8,
  },
  roleSelectChip: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 8,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    alignItems: 'center',
  },
  roleSelectChipActive: {
    borderColor: colors.primary,
    backgroundColor: 'rgba(6, 182, 212, 0.12)',
  },
  roleSelectText: {
    color: colors.textSecondary,
    fontSize: 12,
    fontWeight: '600',
  },
  roleSelectTextActive: {
    color: colors.primary,
    fontWeight: '700',
  },
  editLabsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  editLabChip: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
  },
  editLabChipActive: {
    borderColor: colors.accent,
    backgroundColor: 'rgba(139, 92, 246, 0.15)',
  },
  editLabChipText: {
    color: colors.textSecondary,
    fontSize: 12,
  },
  editLabChipTextActive: {
    color: colors.accent,
    fontWeight: '700',
  },
});
