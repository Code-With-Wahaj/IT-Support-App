import React from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
import { ShieldCheck, Mic, Radio, Award } from 'lucide-react-native';
import { colors } from '../../theme/colors';
import { PcStatusModel } from '../../types/lab';
import { IsometricWorkstation, LabViewMode } from './IsometricWorkstation';

interface InstructorPodium3DProps {
  instructorPc: PcStatusModel;
  assignedTo: string;
  viewMode: LabViewMode;
  isSelected: boolean;
  onPress: () => void;
}

export const InstructorPodium3D: React.FC<InstructorPodium3DProps> = ({
  instructorPc,
  assignedTo,
  viewMode,
  isSelected,
  onPress,
}) => {
  return (
    <View style={styles.container}>
      {/* Platform Base */}
      <View style={styles.podiumPlatform}>
        {/* Header HUD Banner */}
        <View style={styles.podiumHeader}>
          <View style={styles.headerLeft}>
            <View style={styles.vipBadge}>
              <Award size={12} color="#F59E0B" />
              <Text style={styles.vipBadgeText}>MASTER CONSOLE</Text>
            </View>
            <Text style={styles.facultyName} numberOfLines={1}>
              Lead: {assignedTo || 'Unassigned'}
            </Text>
          </View>

          <View style={styles.headerRight}>
            <View style={styles.telemetryTag}>
              <Radio size={10} color={colors.primary} />
              <Text style={styles.telemetryText}>UPLINK 10Gbps</Text>
            </View>
          </View>
        </View>

        {/* Workstation Node */}
        <View style={styles.workstationWrapper}>
          <IsometricWorkstation
            pcId="IP Master"
            status={instructorPc}
            isInstructor
            isSelected={isSelected}
            viewMode={viewMode}
            onPress={onPress}
          />
        </View>

        <Text style={styles.footprintLabel}>FACULTY PODIUM & LECTERN</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    marginBottom: 16,
    width: '100%',
  },
  podiumPlatform: {
    backgroundColor: 'rgba(15, 23, 42, 0.85)',
    borderRadius: 20,
    borderWidth: 1.5,
    borderColor: 'rgba(6, 182, 212, 0.35)',
    paddingHorizontal: 28,
    paddingVertical: 14,
    alignItems: 'center',
    shadowColor: colors.primary,
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.3,
    shadowRadius: 16,
    elevation: 8,
    minWidth: 260,
  },
  podiumHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
    marginBottom: 8,
    gap: 12,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  vipBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(245, 158, 11, 0.15)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: 'rgba(245, 158, 11, 0.35)',
  },
  vipBadgeText: {
    color: '#F59E0B',
    fontSize: 9,
    fontWeight: '900',
    letterSpacing: 0.8,
  },
  facultyName: {
    color: colors.textSecondary,
    fontSize: 11,
    fontWeight: '600',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  telemetryTag: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(6, 182, 212, 0.1)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
  },
  telemetryText: {
    color: colors.primary,
    fontSize: 9,
    fontWeight: '800',
    letterSpacing: 0.5,
  },
  workstationWrapper: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  footprintLabel: {
    color: colors.textMuted,
    fontSize: 9,
    fontWeight: '700',
    letterSpacing: 1.5,
    marginTop: 4,
  },
});
