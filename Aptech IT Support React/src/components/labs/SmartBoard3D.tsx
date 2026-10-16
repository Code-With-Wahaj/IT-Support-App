import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Tv, Activity, Wifi, Clock } from 'lucide-react-native';
import { colors } from '../../theme/colors';

interface SmartBoard3DProps {
  labName: string;
  totalPcs: number;
  healthyCount: number;
  issueCount: number;
}

export const SmartBoard3D: React.FC<SmartBoard3DProps> = ({
  labName,
  totalPcs,
  healthyCount,
  issueCount,
}) => {
  const healthPercent = totalPcs > 0 ? Math.round((healthyCount / totalPcs) * 100) : 100;
  const isOptimal = healthPercent >= 90;

  return (
    <View style={styles.container}>
      {/* Projection Glow Beam */}
      <View style={styles.projectionGlow} />

      {/* 4K Smart Display Screen Frame */}
      <View style={styles.boardFrame}>
        {/* Top Screen Bar */}
        <View style={styles.boardTopBar}>
          <View style={styles.brandRow}>
            <Tv size={14} color={colors.primary} />
            <Text style={styles.boardBrandText}>{labName.toUpperCase()} • DIGITAL TWIN HUD</Text>
          </View>
          <View style={styles.liveIndicator}>
            <View style={styles.livePulse} />
            <Text style={styles.liveText}>SYSTEM LIVE</Text>
          </View>
        </View>

        {/* Center Display Telemetry */}
        <View style={styles.telemetryContent}>
          <View style={styles.metricItem}>
            <Text style={styles.metricLabel}>TOTAL NODES</Text>
            <Text style={styles.metricValue}>{totalPcs}</Text>
          </View>

          <View style={styles.metricDivider} />

          <View style={styles.metricItem}>
            <Text style={styles.metricLabel}>HEALTH INDEX</Text>
            <Text
              style={[
                styles.metricValue,
                { color: isOptimal ? colors.success : colors.danger },
              ]}
            >
              {healthPercent}%
            </Text>
          </View>

          <View style={styles.metricDivider} />

          <View style={styles.metricItem}>
            <Text style={styles.metricLabel}>ANOMALIES</Text>
            <Text
              style={[
                styles.metricValue,
                { color: issueCount > 0 ? colors.danger : colors.textSecondary },
              ]}
            >
              {issueCount}
            </Text>
          </View>

          <View style={styles.metricDivider} />

          <View style={styles.metricItem}>
            <Text style={styles.metricLabel}>NETWORK MESH</Text>
            <View style={styles.networkStatus}>
              <Wifi size={12} color={colors.primary} />
              <Text style={styles.networkText}>10G Backbone</Text>
            </View>
          </View>
        </View>

        {/* Ambient Display Grid Line */}
        <View style={styles.gridLine} />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    width: '100%',
    alignItems: 'center',
    marginVertical: 14,
    position: 'relative',
  },
  projectionGlow: {
    position: 'absolute',
    top: -10,
    width: '75%',
    height: 40,
    backgroundColor: 'rgba(6, 182, 212, 0.08)',
    borderRadius: 30,
    transform: [{ scaleY: 0.5 }],
  },
  boardFrame: {
    width: '92%',
    maxWidth: 680,
    backgroundColor: '#030712',
    borderRadius: 14,
    borderWidth: 1.5,
    borderColor: 'rgba(6, 182, 212, 0.4)',
    paddingHorizontal: 16,
    paddingVertical: 10,
    shadowColor: colors.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 12,
    elevation: 6,
  },
  boardTopBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 8,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.06)',
    paddingBottom: 6,
  },
  brandRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  boardBrandText: {
    color: colors.primary,
    fontSize: 10,
    fontWeight: '900',
    letterSpacing: 1,
  },
  liveIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
  },
  livePulse: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: colors.success,
  },
  liveText: {
    color: colors.success,
    fontSize: 9,
    fontWeight: '800',
    letterSpacing: 0.8,
  },
  telemetryContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    paddingVertical: 4,
  },
  metricItem: {
    alignItems: 'center',
  },
  metricLabel: {
    color: colors.textMuted,
    fontSize: 9,
    fontWeight: '700',
    letterSpacing: 0.6,
    marginBottom: 2,
  },
  metricValue: {
    color: colors.textPrimary,
    fontSize: 15,
    fontWeight: '900',
  },
  metricDivider: {
    width: 1,
    height: 24,
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
  },
  networkStatus: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    marginTop: 2,
  },
  networkText: {
    color: colors.primary,
    fontSize: 11,
    fontWeight: '700',
  },
  gridLine: {
    height: 2,
    backgroundColor: colors.primaryGlow,
    marginTop: 8,
    borderRadius: 1,
  },
});
