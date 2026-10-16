import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Svg, { Polygon, Line, Circle, Rect, Defs, LinearGradient, Stop } from 'react-native-svg';
import { Server, Activity } from 'lucide-react-native';
import { colors } from '../../theme/colors';

export const LabServerRack3D: React.FC = () => {
  return (
    <View style={styles.container}>
      <View style={styles.headerRow}>
        <Server size={12} color={colors.primary} />
        <Text style={styles.rackLabel}>CORE SWITCH & RACK</Text>
      </View>

      <Svg width={72} height={80} viewBox="0 0 72 80">
        <Defs>
          <LinearGradient id="rackFrontGrad" x1="0%" y1="0%" x2="100%" y2="100%">
            <Stop offset="0%" stopColor="#1E293B" />
            <Stop offset="100%" stopColor="#0B132B" />
          </LinearGradient>
          <LinearGradient id="rackSideGrad" x1="0%" y1="0%" x2="100%" y2="100%">
            <Stop offset="0%" stopColor="#0F172A" />
            <Stop offset="100%" stopColor="#020617" />
          </LinearGradient>
        </Defs>

        {/* Floor Shadow */}
        <Polygon points="36,78 64,62 36,46 8,62" fill="rgba(0,0,0,0.4)" />

        {/* Rack Top */}
        <Polygon points="36,18 58,28 36,38 14,28" fill="#334155" stroke="#475569" strokeWidth="0.8" />

        {/* Rack Left Face */}
        <Polygon points="14,28 36,38 36,74 14,64" fill="url(#rackFrontGrad)" stroke="#1E293B" strokeWidth="0.8" />

        {/* Rack Right Face */}
        <Polygon points="36,38 58,28 58,64 36,74" fill="url(#rackSideGrad)" stroke="#1E293B" strokeWidth="0.8" />

        {/* Rack Server Slots (Horizontal Lines) */}
        <Line x1="18" y1="36" x2="32" y2="42" stroke="rgba(255,255,255,0.15)" strokeWidth="1" />
        <Line x1="18" y1="42" x2="32" y2="48" stroke="rgba(255,255,255,0.15)" strokeWidth="1" />
        <Line x1="18" y1="48" x2="32" y2="54" stroke="rgba(255,255,255,0.15)" strokeWidth="1" />
        <Line x1="18" y1="54" x2="32" y2="60" stroke="rgba(255,255,255,0.15)" strokeWidth="1" />
        <Line x1="18" y1="60" x2="32" y2="66" stroke="rgba(255,255,255,0.15)" strokeWidth="1" />

        {/* Blinking Activity LEDs */}
        <Circle cx="20" cy="35" r="1.5" fill={colors.success} />
        <Circle cx="25" cy="37" r="1.5" fill={colors.primary} />
        <Circle cx="30" cy="39" r="1.5" fill={colors.success} />

        <Circle cx="20" cy="41" r="1.5" fill={colors.primary} />
        <Circle cx="25" cy="43" r="1.5" fill={colors.success} />
        <Circle cx="30" cy="45" r="1.5" fill={colors.primary} />

        <Circle cx="20" cy="47" r="1.5" fill={colors.success} />
        <Circle cx="25" cy="49" r="1.5" fill={colors.success} />
        <Circle cx="30" cy="51" r="1.5" fill={colors.success} />

        {/* Glass Reflection Strip */}
        <Polygon points="16,30 20,32 20,64 16,62" fill="rgba(255,255,255,0.06)" />
      </Svg>

      <View style={styles.statusPill}>
        <View style={styles.statusDot} />
        <Text style={styles.statusText}>99.9% UP</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    backgroundColor: 'rgba(15, 23, 42, 0.7)',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.08)',
    padding: 10,
    marginHorizontal: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    marginBottom: 4,
  },
  rackLabel: {
    color: colors.primary,
    fontSize: 9,
    fontWeight: '800',
    letterSpacing: 0.6,
  },
  statusPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(16, 185, 129, 0.12)',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 6,
    marginTop: 2,
  },
  statusDot: {
    width: 5,
    height: 5,
    borderRadius: 2.5,
    backgroundColor: colors.success,
  },
  statusText: {
    color: colors.success,
    fontSize: 8,
    fontWeight: '800',
  },
});
