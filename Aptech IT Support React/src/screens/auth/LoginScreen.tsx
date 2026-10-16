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
import { LogIn, ShieldCheck, Mail, Lock } from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { CustomInput } from '../../components/common/CustomInput';
import { CustomButton } from '../../components/common/CustomButton';
import { GlassCard } from '../../components/common/GlassCard';
import { authService } from '../../services/authService';
import { useAuthStore } from '../../stores/useAuthStore';

type LoginScreenProps = {
  navigation: StackNavigationProp<RootStackParamList, 'Login'>;
};

export const LoginScreen: React.FC<LoginScreenProps> = ({ navigation }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const { fetchUserProfile } = useAuthStore();

  const handleLogin = async () => {
    setErrorMessage('');
    if (!email.trim() || !password.trim()) {
      setErrorMessage('Please enter your email and password');
      return;
    }

    setLoading(true);
    try {
      const err = await authService.login(email.trim(), password.trim());
      if (err) {
        setErrorMessage(err);
        setLoading(false);
        return;
      }

      const currentUser = authService.getCurrentUser();
      if (currentUser) {
        const userDoc = await authService.getUserDoc(currentUser.uid);
        if (userDoc) {
          if (!userDoc.isApproved) {
            await authService.logout();
            setErrorMessage('Your account is pending Administrator approval.');
            setLoading(false);
            return;
          }
          await fetchUserProfile(currentUser.uid);
          navigation.replace('Dashboard');
        } else {
          setErrorMessage('User record not found in system.');
        }
      }
    } catch (e: any) {
      setErrorMessage(e.message || 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  };

  const fillQuickDemo = (userEmail: string, userPass: string) => {
    setEmail(userEmail);
    setPassword(userPass);
    setErrorMessage('');
  };

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
        {/* Header Badge */}
        <View style={styles.headerArea}>
          <View style={styles.logoIcon}>
            <ShieldCheck size={36} color={colors.primary} />
          </View>
          <Text style={styles.title}>Aptech IT Portal</Text>
          <Text style={styles.subtitle}>Sign in to access campus helpdesk & diagnostics</Text>
        </View>

        {/* Card Form */}
        <GlassCard elevated style={styles.formCard}>
          {errorMessage ? (
            <View style={styles.errorBanner}>
              <Text style={styles.errorBannerText}>{errorMessage}</Text>
            </View>
          ) : null}

          <CustomInput
            label="Institutional Email"
            placeholder="e.g. tech.ali@aptech.edu"
            value={email}
            onChangeText={(t) => {
              setEmail(t);
              setErrorMessage('');
            }}
            autoCapitalize="none"
            keyboardType="email-address"
          />

          <CustomInput
            label="Password"
            placeholder="••••••••••••"
            value={password}
            onChangeText={(t) => {
              setPassword(t);
              setErrorMessage('');
            }}
            isPassword
          />

          <TouchableOpacity
            style={styles.forgotBtn}
            onPress={() => navigation.navigate('ForgotPassword')}
          >
            <Text style={styles.forgotText}>Forgot password?</Text>
          </TouchableOpacity>

          <CustomButton
            title="Sign In"
            onPress={handleLogin}
            loading={loading}
            icon={<LogIn size={18} color="#020617" />}
            style={styles.submitBtn}
          />

          <View style={styles.signupRow}>
            <Text style={styles.noAccountText}>Don't have an account? </Text>
            <TouchableOpacity onPress={() => navigation.navigate('Signup')}>
              <Text style={styles.signupLink}>Register</Text>
            </TouchableOpacity>
          </View>
        </GlassCard>

        {/* Quick Demo Fillers */}
        <View style={styles.demoSection}>
          <Text style={styles.demoTitle}>Quick Demo Logins</Text>
          <View style={styles.demoButtonsRow}>
            <TouchableOpacity
              style={styles.demoChip}
              onPress={() => fillQuickDemo('admin@aptech.edu', 'AdminPassword123!')}
            >
              <Text style={styles.demoChipText}>👑 Admin</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.demoChip}
              onPress={() => fillQuickDemo('tech.ali@aptech.edu', 'TechPassword123!')}
            >
              <Text style={styles.demoChipText}>🛠 Tech Ali</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.demoChip}
              onPress={() => fillQuickDemo('faculty.hassan@aptech.edu', 'FacultyPassword123!')}
            >
              <Text style={styles.demoChipText}>👨‍🏫 Faculty</Text>
            </TouchableOpacity>
          </View>
        </View>
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
    justifyContent: 'center',
    padding: 24,
  },
  headerArea: {
    alignItems: 'center',
    marginBottom: 28,
  },
  logoIcon: {
    width: 72,
    height: 72,
    borderRadius: 20,
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1.5,
    borderColor: colors.surfaceBorderHighlight,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
    shadowColor: colors.primary,
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 6,
  },
  title: {
    fontSize: 24,
    fontWeight: '800',
    color: colors.textPrimary,
    letterSpacing: -0.4,
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: colors.textSecondary,
    textAlign: 'center',
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
  forgotBtn: {
    alignSelf: 'flex-end',
    marginBottom: 20,
  },
  forgotText: {
    color: colors.primary,
    fontSize: 13,
    fontWeight: '600',
  },
  submitBtn: {
    width: '100%',
    marginBottom: 16,
  },
  signupRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  noAccountText: {
    color: colors.textSecondary,
    fontSize: 14,
  },
  signupLink: {
    color: colors.primary,
    fontSize: 14,
    fontWeight: '700',
  },
  demoSection: {
    marginTop: 28,
    alignItems: 'center',
  },
  demoTitle: {
    fontSize: 12,
    color: colors.textMuted,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 0.8,
    marginBottom: 10,
  },
  demoButtonsRow: {
    flexDirection: 'row',
    gap: 8,
    flexWrap: 'wrap',
    justifyContent: 'center',
  },
  demoChip: {
    backgroundColor: colors.surfaceElevated,
    borderColor: colors.surfaceBorder,
    borderWidth: 1,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  demoChipText: {
    color: colors.textSecondary,
    fontSize: 12,
    fontWeight: '600',
  },
});
