import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { UserPlus, UserCheck, CheckCircle2 } from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { UserRole } from '../../types/user';
import { CustomInput } from '../../components/common/CustomInput';
import { CustomButton } from '../../components/common/CustomButton';
import { GlassCard } from '../../components/common/GlassCard';
import { authService } from '../../services/authService';

type SignupScreenProps = {
  navigation: StackNavigationProp<RootStackParamList, 'Signup'>;
};

const AVAILABLE_LABS = ['Lab 101', 'Lab 102', 'Lab 201', 'Lab 210', 'JBR Lab', 'IBR Lab'];

export const SignupScreen: React.FC<SignupScreenProps> = ({ navigation }) => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [role, setRole] = useState<UserRole>('Faculty');
  const [selectedLabs, setSelectedLabs] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [success, setSuccess] = useState(false);

  const toggleLab = (lab: string) => {
    if (selectedLabs.includes(lab)) {
      setSelectedLabs(selectedLabs.filter((l) => l !== lab));
    } else {
      setSelectedLabs([...selectedLabs, lab]);
    }
  };

  const handleSignup = async () => {
    setErrorMessage('');
    if (!name.trim() || !email.trim() || !password.trim()) {
      setErrorMessage('Please fill in all mandatory fields');
      return;
    }

    if (password !== confirmPassword) {
      setErrorMessage('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      setErrorMessage('Password must be at least 6 characters');
      return;
    }

    if (role === 'IT Technician' && selectedLabs.length === 0) {
      setErrorMessage('Please select at least one assigned lab');
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
        isApproved: false,
      });

      if (err) {
        setErrorMessage(err);
        setLoading(false);
        return;
      }

      setSuccess(true);
      await authService.logout(); // Keep logged out until approved
    } catch (e: any) {
      setErrorMessage(e.message || 'Signup failed');
    } finally {
      setLoading(false);
    }
  };

  if (success) {
    return (
      <View style={styles.successContainer}>
        <View style={styles.successCard}>
          <CheckCircle2 size={64} color={colors.success} />
          <Text style={styles.successTitle}>Registration Submitted</Text>
          <Text style={styles.successBody}>
            Your account has been registered with role{' '}
            <Text style={{ color: colors.primary, fontWeight: '700' }}>{role}</Text>.
            {'\n\n'}
            For security compliance, an Administrator must review and approve your profile
            before you can log in.
          </Text>
          <CustomButton
            title="Return to Login"
            onPress={() => navigation.replace('Login')}
            style={{ width: '100%', marginTop: 20 }}
          />
        </View>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.headerArea}>
          <View style={styles.logoIcon}>
            <UserPlus size={36} color={colors.primary} />
          </View>
          <Text style={styles.title}>Create Account</Text>
          <Text style={styles.subtitle}>Join Aptech Campus IT Support Network</Text>
        </View>

        <GlassCard elevated style={styles.formCard}>
          {errorMessage ? (
            <View style={styles.errorBanner}>
              <Text style={styles.errorBannerText}>{errorMessage}</Text>
            </View>
          ) : null}

          <CustomInput
            label="Full Name"
            placeholder="e.g. Ali Khan"
            value={name}
            onChangeText={(t) => {
              setName(t);
              setErrorMessage('');
            }}
          />

          <CustomInput
            label="Email Address"
            placeholder="e.g. user@aptech.edu"
            value={email}
            onChangeText={(t) => {
              setEmail(t);
              setErrorMessage('');
            }}
            autoCapitalize="none"
            keyboardType="email-address"
          />

          {/* Role Selector */}
          <Text style={styles.sectionLabel}>System Role</Text>
          <View style={styles.roleRow}>
            {(['Faculty', 'IT Technician', 'Admin'] as UserRole[]).map((r) => (
              <TouchableOpacity
                key={r}
                onPress={() => setRole(r)}
                style={[
                  styles.roleChip,
                  role === r && styles.roleChipActive,
                ]}
              >
                <Text
                  style={[
                    styles.roleChipText,
                    role === r && styles.roleChipTextActive,
                  ]}
                >
                  {r}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          {/* Technician Lab Assignment */}
          {role === 'IT Technician' ? (
            <View style={styles.labSection}>
              <Text style={styles.sectionLabel}>Select Assigned Labs</Text>
              <View style={styles.labsGrid}>
                {AVAILABLE_LABS.map((lab) => {
                  const active = selectedLabs.includes(lab);
                  return (
                    <TouchableOpacity
                      key={lab}
                      onPress={() => toggleLab(lab)}
                      style={[
                        styles.labChip,
                        active && styles.labChipActive,
                      ]}
                    >
                      <Text
                        style={[
                          styles.labChipText,
                          active && styles.labChipTextActive,
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

          <CustomInput
            label="Password"
            placeholder="Minimum 6 characters"
            value={password}
            onChangeText={(t) => {
              setPassword(t);
              setErrorMessage('');
            }}
            isPassword
          />

          <CustomInput
            label="Confirm Password"
            placeholder="Re-enter password"
            value={confirmPassword}
            onChangeText={(t) => {
              setConfirmPassword(t);
              setErrorMessage('');
            }}
            isPassword
          />

          <CustomButton
            title="Register Account"
            onPress={handleSignup}
            loading={loading}
            icon={<UserCheck size={18} color="#020617" />}
            style={styles.submitBtn}
          />

          <View style={styles.loginRow}>
            <Text style={styles.alreadyText}>Already have an account? </Text>
            <TouchableOpacity onPress={() => navigation.goBack()}>
              <Text style={styles.loginLink}>Sign In</Text>
            </TouchableOpacity>
          </View>
        </GlassCard>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  scrollContent: {
    flexGrow: 1,
    padding: 24,
    justifyContent: 'center',
  },
  headerArea: {
    alignItems: 'center',
    marginBottom: 24,
  },
  logoIcon: {
    width: 68,
    height: 68,
    borderRadius: 18,
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1.5,
    borderColor: colors.surfaceBorderHighlight,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  title: {
    fontSize: 24,
    fontWeight: '800',
    color: colors.textPrimary,
  },
  subtitle: {
    fontSize: 14,
    color: colors.textSecondary,
  },
  formCard: {
    padding: 24,
  },
  errorBanner: {
    backgroundColor: colors.dangerBg,
    borderColor: colors.dangerBorder,
    borderWidth: 1,
    borderRadius: 10,
    padding: 12,
    marginBottom: 16,
  },
  errorBannerText: {
    color: colors.danger,
    fontSize: 13,
    fontWeight: '600',
    textAlign: 'center',
  },
  sectionLabel: {
    fontSize: 14,
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
    borderRadius: 10,
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
    fontSize: 13,
    fontWeight: '600',
  },
  roleChipTextActive: {
    color: colors.primary,
    fontWeight: '700',
  },
  labSection: {
    marginBottom: 16,
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
    fontWeight: '500',
  },
  labChipTextActive: {
    color: colors.accent,
    fontWeight: '700',
  },
  submitBtn: {
    width: '100%',
    marginTop: 10,
    marginBottom: 16,
  },
  loginRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  alreadyText: {
    color: colors.textSecondary,
    fontSize: 14,
  },
  loginLink: {
    color: colors.primary,
    fontSize: 14,
    fontWeight: '700',
  },
  successContainer: {
    flex: 1,
    backgroundColor: colors.background,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  successCard: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    padding: 28,
    alignItems: 'center',
    width: '100%',
    maxWidth: 400,
  },
  successTitle: {
    fontSize: 22,
    fontWeight: '800',
    color: colors.textPrimary,
    marginTop: 16,
    marginBottom: 10,
  },
  successBody: {
    fontSize: 14,
    color: colors.textSecondary,
    textAlign: 'center',
    lineHeight: 22,
  },
});
