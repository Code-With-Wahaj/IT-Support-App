import React, { useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { Shield, Sparkles } from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { useAuthStore } from '../../stores/useAuthStore';
import { colors } from '../../theme/colors';

type SplashScreenProps = {
  navigation: StackNavigationProp<RootStackParamList, 'Splash'>;
};

export const SplashScreen: React.FC<SplashScreenProps> = ({ navigation }) => {
  const { user, firebaseUser, isLoading, initializeAuth } = useAuthStore();

  useEffect(() => {
    const unsubscribe = initializeAuth();
    return () => unsubscribe();
  }, []);

  useEffect(() => {
    if (isLoading) return;

    const timer = setTimeout(() => {
      if (firebaseUser && user) {
        if (user.isApproved) {
          navigation.replace('Dashboard');
        } else {
          navigation.replace('Login');
        }
      } else {
        navigation.replace('Login');
      }
    }, 1200);

    return () => clearTimeout(timer);
  }, [isLoading, firebaseUser, user, navigation]);

  return (
    <View style={styles.container}>
      <View style={styles.glowCircle} />
      <View style={styles.logoBadge}>
        <Shield size={48} color={colors.primary} />
      </View>
      <Text style={styles.title}>Aptech IT Support</Text>
      <Text style={styles.subtitle}>Campus Helpdesk & Smart Lab Diagnostics</Text>

      <View style={styles.loaderContainer}>
        <ActivityIndicator size="small" color={colors.primary} />
        <Text style={styles.loadingText}>Initializing system modules...</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    position: 'relative',
  },
  glowCircle: {
    position: 'absolute',
    width: 250,
    height: 250,
    borderRadius: 125,
    backgroundColor: 'rgba(6, 182, 212, 0.08)',
  },
  logoBadge: {
    width: 90,
    height: 90,
    borderRadius: 24,
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1.5,
    borderColor: colors.surfaceBorderHighlight,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 20,
    shadowColor: colors.primary,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.35,
    shadowRadius: 16,
    elevation: 8,
  },
  title: {
    fontSize: 26,
    fontWeight: '800',
    color: colors.textPrimary,
    letterSpacing: -0.5,
    marginBottom: 6,
  },
  subtitle: {
    fontSize: 14,
    color: colors.textSecondary,
    textAlign: 'center',
    maxWidth: 280,
    lineHeight: 20,
  },
  loaderContainer: {
    position: 'absolute',
    bottom: 50,
    alignItems: 'center',
    gap: 10,
  },
  loadingText: {
    fontSize: 12,
    color: colors.textMuted,
    fontWeight: '500',
  },
});
