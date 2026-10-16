import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { ArrowLeft, UserPlus, ShieldCheck } from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { UserRole } from '../../types/user';
import { authService } from '../../services/authService';
import { CustomInput } from '../../components/common/CustomInput';
import { CustomButton } from '../../components/common/CustomButton';
import { GlassCard } from '../../components/common/GlassCard';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'AdminAddUser'>;
};

const ALL_LABS = ['Lab 101', 'Lab 102', 'Lab 201', 'Lab 210', 'JBR Lab', 'IBR Lab'];

export const AdminAddUserScreen: React.FC<Props> = ({ navigation }) => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState<UserRole>('IT Technician');
  const [selectedLabs, setSelectedLabs] = useState<string[]>(['Lab 101']);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const toggleLab = (lab: string) => {
    if (selectedLabs.includes(lab)) {
      setSelectedLabs(selectedLabs.filter((l) => l !== lab));
    } else {
      setSelectedLabs([...selectedLabs, lab]);
    }
  };

  const handleCreate = async () => {
    setError('');
    if (!name.trim() || !email.trim() || !password.trim()) {
      setError('Please fill in all mandatory fields');
      return;
    }

    if (role === 'IT Technician' && selectedLabs.length === 0) {
      setError('Please select at least one assigned lab for the technician');
      return;
    }

    setLoading(true);
    try {
      const err = await authService.signUp({
        name: name.trim(),
        email: email.trim(),
        password: password.trim(),
        role,
        associatedLabs: role === 'IT Technician' ? selectedLabs : undefined,
        isApproved: true, // Immediate approval for admin creations
      });

      if (err) {
        setError(err);
        setLoading(false);
        return;
      }

      Alert.alert('User Provisioned', `Account for ${name} (${role}) has been activated.`);
      navigation.goBack();
    } catch (e: any) {
      setError(e.message || 'Failed to create user');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.appBar}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <ArrowLeft size={20} color={colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Provision User</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <GlassCard elevated style={styles.card}>
          <View style={styles.badgeRow}>
            <ShieldCheck size={20} color={colors.success} />
            <Text style={styles.badgeNote}>
              Users provisioned by Administrators are approved automatically.
            </Text>
          </View>

          {error ? (
            <View style={styles.errorBox}>
              <Text style={styles.errorText}>{error}</Text>
            </View>
          ) : null}

          <CustomInput
            label="Full Name"
            placeholder="e.g. Sara Ahmed"
            value={name}
            onChangeText={setName}
          />

          <CustomInput
            label="Email Address"
            placeholder="e.g. tech.sara@aptech.edu"
            value={email}
            onChangeText={setEmail}
            autoCapitalize="none"
            keyboardType="email-address"
          />

          <CustomInput
            label="Temporary Password"
            placeholder="Minimum 6 characters"
            value={password}
            onChangeText={setPassword}
            isPassword
          />

          <Text style={styles.sectionLabel}>System Role</Text>
          <View style={styles.roleRow}>
            {(['IT Technician', 'Faculty', 'Admin'] as UserRole[]).map((r) => (
              <TouchableOpacity
                key={r}
                onPress={() => setRole(r)}
                style={[styles.roleChip, role === r && styles.roleChipActive]}
              >
                <Text style={[styles.roleChipText, role === r && styles.roleChipTextActive]}>
                  {r}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          {role === 'IT Technician' ? (
            <View style={{ marginBottom: 16 }}>
              <Text style={styles.sectionLabel}>Assigned Labs</Text>
              <View style={styles.labsGrid}>
                {ALL_LABS.map((lab) => {
                  const active = selectedLabs.includes(lab);
                  return (
                    <TouchableOpacity
                      key={lab}
                      onPress={() => toggleLab(lab)}
                      style={[styles.labChip, active && styles.labChipActive]}
                    >
                      <Text style={[styles.labChipText, active && styles.labChipTextActive]}>
                        {lab}
                      </Text>
                    </TouchableOpacity>
                  );
                })}
              </View>
            </View>
          ) : null}

          <CustomButton
            title="Create & Activate Account"
            onPress={handleCreate}
            loading={loading}
            icon={<UserPlus size={18} color="#020617" />}
            style={{ marginTop: 10 }}
          />
        </GlassCard>
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
  card: {
    padding: 24,
  },
  badgeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    backgroundColor: 'rgba(16, 185, 129, 0.08)',
    borderWidth: 1,
    borderColor: 'rgba(16, 185, 129, 0.2)',
    padding: 10,
    borderRadius: 10,
    marginBottom: 20,
  },
  badgeNote: {
    fontSize: 12,
    color: colors.success,
    flex: 1,
    fontWeight: '500',
  },
  errorBox: {
    backgroundColor: colors.dangerBg,
    borderColor: colors.dangerBorder,
    borderWidth: 1,
    borderRadius: 10,
    padding: 12,
    marginBottom: 16,
  },
  errorText: {
    color: colors.danger,
    fontSize: 13,
    fontWeight: '600',
  },
  sectionLabel: {
    fontSize: 13,
    fontWeight: '600',
    color: colors.textSecondary,
    marginBottom: 8,
  },
  roleRow: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 16,
  },
  roleChip: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 8,
    backgroundColor: colors.inputBg,
    borderWidth: 1,
    borderColor: colors.inputBorder,
    alignItems: 'center',
  },
  roleChipActive: {
    borderColor: colors.primary,
    backgroundColor: 'rgba(6, 182, 212, 0.12)',
  },
  roleChipText: {
    color: colors.textSecondary,
    fontSize: 12,
    fontWeight: '600',
  },
  roleChipTextActive: {
    color: colors.primary,
    fontWeight: '700',
  },
  labsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  labChip: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
    backgroundColor: colors.inputBg,
    borderWidth: 1,
    borderColor: colors.inputBorder,
  },
  labChipActive: {
    borderColor: colors.accent,
    backgroundColor: 'rgba(139, 92, 246, 0.15)',
  },
  labChipText: {
    color: colors.textSecondary,
    fontSize: 12,
  },
  labChipTextActive: {
    color: colors.accent,
    fontWeight: '700',
  },
});
