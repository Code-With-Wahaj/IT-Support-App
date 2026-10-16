import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { sendPasswordResetEmail } from 'firebase/auth';
import { KeyRound, ArrowLeft, MailCheck } from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { auth } from '../../config/firebase';
import { colors } from '../../theme/colors';
import { CustomInput } from '../../components/common/CustomInput';
import { CustomButton } from '../../components/common/CustomButton';
import { GlassCard } from '../../components/common/GlassCard';

type ForgotPasswordProps = {
  navigation: StackNavigationProp<RootStackParamList, 'ForgotPassword'>;
};

export const ForgotPasswordScreen: React.FC<ForgotPasswordProps> = ({ navigation }) => {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState('');

  const handleReset = async () => {
    setError('');
    const trimmed = email.trim();
    if (!trimmed) {
      setError('Please enter your institutional email address');
      return;
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(trimmed)) {
      setError('Please enter a valid email address (e.g. user@aptech.edu)');
      return;
    }

    setLoading(true);
    try {
      await sendPasswordResetEmail(auth, trimmed);
      setSent(true);
    } catch (e: any) {
      if (e.code === 'auth/user-not-found') {
        setError('No registered account was found with this email address.');
      } else if (e.code === 'auth/invalid-email') {
        setError('The email address entered is invalid.');
      } else if (e.code === 'auth/too-many-requests') {
        setError('Too many reset attempts. Please wait a few moments and try again.');
      } else {
        setError(e.message || 'Failed to send recovery email. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
    >
      <View style={styles.content}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <ArrowLeft size={20} color={colors.textSecondary} />
          <Text style={styles.backText}>Back to Login</Text>
        </TouchableOpacity>

        <View style={styles.headerArea}>
          <View style={styles.logoIcon}>
            <KeyRound size={36} color={colors.primary} />
          </View>
          <Text style={styles.title}>Reset Password</Text>
          <Text style={styles.subtitle}>
            Enter your institutional email to receive a secure recovery link
          </Text>
        </View>

        <GlassCard elevated style={styles.card}>
          {sent ? (
            <View style={styles.sentBox}>
              <MailCheck size={48} color={colors.success} />
              <Text style={styles.sentTitle}>Recovery Email Dispatched</Text>
              <Text style={styles.sentDesc}>
                Check your inbox for <Text style={{ color: colors.primary }}>{email}</Text> and
                follow the instructions to set a new password.
              </Text>
              <CustomButton
                title="Back to Sign In"
                onPress={() => navigation.navigate('Login')}
                style={{ width: '100%', marginTop: 20 }}
              />
            </View>
          ) : (
            <>
              {error ? (
                <View style={styles.errorBanner}>
                  <Text style={styles.errorText}>{error}</Text>
                </View>
              ) : null}

              <CustomInput
                label="Email Address"
                placeholder="e.g. user@aptech.edu"
                value={email}
                onChangeText={(t) => {
                  setEmail(t);
                  setError('');
                }}
                autoCapitalize="none"
                keyboardType="email-address"
              />

              <CustomButton
                title="Send Recovery Link"
                onPress={handleReset}
                loading={loading}
                style={{ marginTop: 10 }}
              />
            </>
          )}
        </GlassCard>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    padding: 24,
  },
  backBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    position: 'absolute',
    top: 50,
    left: 24,
  },
  backText: {
    color: colors.textSecondary,
    fontSize: 14,
    fontWeight: '600',
  },
  headerArea: {
    alignItems: 'center',
    marginBottom: 24,
  },
  logoIcon: {
    width: 68,
    height: 68,
    borderRadius: 20,
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1.5,
    borderColor: colors.surfaceBorderHighlight,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: '800',
    color: colors.textPrimary,
  },
  subtitle: {
    fontSize: 14,
    color: colors.textSecondary,
    textAlign: 'center',
    marginTop: 4,
    maxWidth: 280,
  },
  card: {
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
  errorText: {
    color: colors.danger,
    fontSize: 13,
    fontWeight: '600',
    textAlign: 'center',
  },
  sentBox: {
    alignItems: 'center',
    paddingVertical: 12,
  },
  sentTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: colors.textPrimary,
    marginTop: 12,
    marginBottom: 6,
  },
  sentDesc: {
    fontSize: 13,
    color: colors.textSecondary,
    textAlign: 'center',
    lineHeight: 20,
  },
});
