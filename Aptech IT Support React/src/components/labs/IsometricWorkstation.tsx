import React from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
import Svg, {
  Defs,
  LinearGradient,
  RadialGradient,
  Stop,
  Rect,
  Circle,
  Polygon,
  Line,
  G,
} from 'react-native-svg';
import { colors } from '../../theme/colors';
import { PcStatusModel, isPcHealthy } from '../../types/lab';

export type LabViewMode = 'isometric' | 'blueprint' | 'heatmap';

interface IsometricWorkstationProps {
  pcId: string;
  status?: PcStatusModel;
  isActive?: boolean;
  isSelected?: boolean;
  isInstructor?: boolean;
  viewMode?: LabViewMode;
  onPress: () => void;
}

export const IsometricWorkstation: React.FC<IsometricWorkstationProps> = ({
  pcId,
  status,
  isActive = true,
  isSelected = false,
  isInstructor = false,
  viewMode = 'isometric',
  onPress,
}) => {
  const healthy = status ? isPcHealthy(status) : false;

  // Compute status color
  let statusColor = colors.success; // #10B981
  let glowColor = 'rgba(16, 185, 129, 0.4)';
  let statusLabel = 'Optimal';

  if (!isActive) {
    statusColor = colors.pcOffline; // #475569
    glowColor = 'rgba(71, 85, 105, 0.2)';
    statusLabel = 'Offline';
  } else if (!healthy) {
    statusColor = colors.danger; // #EF4444
    glowColor = 'rgba(239, 68, 68, 0.5)';
    statusLabel = 'Fault';
  }

  // Count broken components
  const issues: string[] = [];
  if (status) {
    if (!status.keyboardOk) issues.push('KB');
    if (!status.mouseOk) issues.push('Mouse');
    if (!status.ledOk) issues.push('Display');
    if (!status.internetCableOk) issues.push('LAN');
    if (!status.powerCableOk) issues.push('Power');
    if (!status.vgaCableOk) issues.push('Video');
    if (!status.cpuWorking) issues.push('CPU');
  }

  // Primary fault category for heatmap view
  let heatmapColor = statusColor;
  if (!healthy && status) {
    if (!status.internetCableOk || !status.powerCableOk || !status.vgaCableOk) {
      heatmapColor = '#F59E0B'; // Amber for Cable
    } else if (!status.keyboardOk || !status.mouseOk || !status.ledOk) {
      heatmapColor = '#38BDF8'; // Sky for Peripherals
    } else {
      heatmapColor = '#EF4444'; // Red for Core System
    }
  }

  const cleanId = pcId.replace('PC-', '').replace('Terminal', '').trim();

  // ----------------------------------------------------
  // 1. BLUEPRINT / 2D SCHEMATIC MODE
  // ----------------------------------------------------
  if (viewMode === 'blueprint') {
    return (
      <Pressable
        onPress={onPress}
        style={({ pressed }) => [
          styles.touchable,
          pressed && styles.pressed,
          isSelected && styles.selectedContainer,
        ]}
      >
        <View
          style={[
            styles.blueprintCard,
            { borderColor: isSelected ? colors.primary : statusColor },
            isInstructor && styles.instructorBlueprintCard,
          ]}
        >
          {/* Top schematic header */}
          <View style={styles.blueprintHeader}>
            <View style={[styles.statusDot, { backgroundColor: statusColor }]} />
            <Text style={styles.blueprintTitle} numberOfLines={1}>
              {isInstructor ? 'INSTRUCTOR' : `PC ${cleanId}`}
            </Text>
          </View>

          {/* Schematic visual */}
          <View style={styles.blueprintVisual}>
            {/* Monitor outline */}
            <View style={[styles.blueprintMonitor, { borderColor: statusColor }]} />
            {/* Keyboard outline */}
            <View style={styles.blueprintKb} />
            {/* CPU chassis */}
            <View style={[styles.blueprintTower, { borderColor: statusColor }]} />
          </View>

          {/* Specs / Status pills */}
          <View style={styles.blueprintSpecs}>
            <Text style={styles.blueprintSpecText}>
              {status?.ram ? status.ram.split(' ')[0] : '16'}G
            </Text>
            {issues.length > 0 ? (
              <Text style={styles.blueprintIssueTag}>{issues[0]}</Text>
            ) : (
              <Text style={styles.blueprintOkTag}>OK</Text>
            )}
          </View>
        </View>
      </Pressable>
    );
  }

  // ----------------------------------------------------
  // 2. DIAGNOSTIC HEATMAP MODE
  // ----------------------------------------------------
  if (viewMode === 'heatmap') {
    return (
      <Pressable
        onPress={onPress}
        style={({ pressed }) => [
          styles.touchable,
          pressed && styles.pressed,
          isSelected && styles.selectedContainer,
        ]}
      >
        <View
          style={[
            styles.heatmapCard,
            {
              borderColor: heatmapColor,
              backgroundColor: `${heatmapColor}15`,
            },
            isInstructor && styles.instructorHeatmap,
          ]}
        >
          <View style={[styles.heatmapBadge, { backgroundColor: heatmapColor }]}>
            <Text style={styles.heatmapBadgeText}>{cleanId}</Text>
          </View>

          <Text style={[styles.heatmapStatusText, { color: heatmapColor }]} numberOfLines={1}>
            {issues.length > 0 ? issues.join(', ') : 'Healthy'}
          </Text>

          <View style={styles.heatmapFooter}>
            <Text style={styles.heatmapSpecText}>{status?.os || 'Win 11'}</Text>
            <View style={[styles.statusIndicator, { backgroundColor: heatmapColor }]} />
          </View>
        </View>
      </Pressable>
    );
  }

  // ----------------------------------------------------
  // 3. 3D ISOMETRIC DIGITAL-TWIN MODE (DEFAULT / EXTRAORDINARY)
  // ----------------------------------------------------
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.touchable,
        pressed && styles.pressed,
        isSelected && styles.selectedContainer,
      ]}
    >
      <View style={styles.isoContainer}>
        {/* Floating ID Tag Banner */}
        <View
          style={[
            styles.floatingBadge,
            { borderColor: isSelected ? colors.primary : 'rgba(255, 255, 255, 0.12)' },
            isSelected && styles.floatingBadgeSelected,
          ]}
        >
          <View style={[styles.badgeDot, { backgroundColor: statusColor }]} />
          <Text style={styles.badgeText} numberOfLines={1}>
            {isInstructor ? 'INSTRUCTOR' : cleanId}
          </Text>
          {issues.length > 0 && (
            <View style={styles.alertCountBadge}>
              <Text style={styles.alertCountText}>{issues.length}</Text>
            </View>
          )}
        </View>

        {/* SVG Isometric Workstation */}
        <Svg width={96} height={84} viewBox="0 0 96 84">
          <Defs>
            {/* Ambient Floor Glow */}
            <RadialGradient id={`floorGlow-${pcId}`} cx="50%" cy="50%" rx="50%" ry="40%">
              <Stop offset="0%" stopColor={statusColor} stopOpacity="0.45" />
              <Stop offset="65%" stopColor={statusColor} stopOpacity="0.15" />
              <Stop offset="100%" stopColor={statusColor} stopOpacity="0" />
            </RadialGradient>

            {/* Desk Top Wood / Carbon Gradient */}
            <LinearGradient id="deskTopGrad" x1="0%" y1="0%" x2="100%" y2="100%">
              <Stop offset="0%" stopColor="#1E293B" />
              <Stop offset="100%" stopColor="#0F172A" />
            </LinearGradient>

            {/* Monitor Glass Gradient */}
            <LinearGradient id="screenGrad" x1="0%" y1="0%" x2="0%" y2="100%">
              <Stop offset="0%" stopColor="#030712" />
              <Stop offset="100%" stopColor="#0B132B" />
            </LinearGradient>

            {/* Monitor Reflection Glare */}
            <LinearGradient id="screenGlare" x1="0%" y1="0%" x2="100%" y2="100%">
              <Stop offset="0%" stopColor="rgba(255, 255, 255, 0.18)" />
              <Stop offset="40%" stopColor="rgba(255, 255, 255, 0.03)" />
              <Stop offset="100%" stopColor="rgba(255, 255, 255, 0)" />
            </LinearGradient>

            {/* PC Chassis Side Panel */}
            <LinearGradient id="pcChassisGrad" x1="0%" y1="0%" x2="100%" y2="100%">
              <Stop offset="0%" stopColor="#0F172A" />
              <Stop offset="100%" stopColor="#020617" />
            </LinearGradient>
          </Defs>

          {/* 1. Floor Ambient Shadow & Colored Underglow */}
          <Polygon
            points="48,78 88,58 48,38 8,58"
            fill={`url(#floorGlow-${pcId})`}
          />
          <Polygon
            points="48,74 84,56 48,40 12,56"
            fill="rgba(0, 0, 0, 0.4)"
          />

          {/* 2. Desk Legs / Frame */}
          <Line x1="14" y1="56" x2="14" y2="72" stroke="#334155" strokeWidth="2.5" />
          <Line x1="82" y1="56" x2="82" y2="72" stroke="#1E293B" strokeWidth="2.5" />
          <Line x1="48" y1="72" x2="48" y2="79" stroke="#1E293B" strokeWidth="2" />

          {/* 3. Desk Top & Beveled Edge */}
          {/* Left Side Face */}
          <Polygon points="12,48 48,66 48,72 12,54" fill="#0B132B" />
          {/* Right Side Face */}
          <Polygon points="48,66 84,48 84,54 48,72" fill="#020617" />
          {/* Top Surface */}
          <Polygon
            points="48,32 84,48 48,66 12,48"
            fill="url(#deskTopGrad)"
            stroke={isSelected ? colors.primary : '#334155'}
            strokeWidth={isSelected ? 1.5 : 0.8}
          />

          {/* Desk Mat / Mousepad */}
          <Polygon
            points="44,45 68,56 48,64 26,53"
            fill="#030712"
            stroke={statusColor}
            strokeWidth="0.8"
            strokeOpacity="0.7"
          />

          {/* Keyboard Isometric Block */}
          <Polygon points="38,47 54,55 46,59 30,51" fill="#1E293B" />
          <Line x1="33" y1="50" x2="49" y2="57" stroke="rgba(255,255,255,0.2)" strokeWidth="0.8" />
          <Line x1="36" y1="53" x2="45" y2="58" stroke="rgba(255,255,255,0.2)" strokeWidth="0.8" />

          {/* Mouse Dot with Glow */}
          <Circle cx="58" cy="56" r="2" fill="#38BDF8" />

          {/* 4. Monitor Stand */}
          <Polygon points="48,45 54,42 48,39 42,42" fill="#475569" />
          <Line x1="48" y1="42" x2="48" y2="28" stroke="#64748B" strokeWidth="3" />

          {/* 5. Monitor Display (Elevated & Angled) */}
          {/* Monitor Back Housing */}
          <Polygon
            points="28,14 68,-3 68,23 28,40"
            fill="#030712"
            stroke="#1E293B"
            strokeWidth="1"
          />

          {/* Monitor Bezel Border (colored with status glow) */}
          <Polygon
            points="30,15 66,-1 66,21 30,37"
            fill="url(#screenGrad)"
            stroke={statusColor}
            strokeWidth={isInstructor ? 2 : 1.4}
          />

          {/* Monitor Screen Glass Content */}
          <Polygon
            points="32,17 64,2 64,19 32,34"
            fill="#020617"
          />

          {/* Screen UI Lines / Telemetry */}
          <Line x1="36" y1="20" x2="52" y2="12" stroke={statusColor} strokeWidth="1.2" strokeOpacity="0.8" />
          <Line x1="36" y1="24" x2="58" y2="14" stroke="#38BDF8" strokeWidth="0.9" strokeOpacity="0.6" />
          <Line x1="36" y1="28" x2="48" y2="22" stroke="#94A3B8" strokeWidth="0.8" strokeOpacity="0.5" />

          {/* Glass Glare Highlight */}
          <Polygon
            points="32,17 56,6 44,22 32,25"
            fill="url(#screenGlare)"
          />

          {/* 6. PC Tower Chassis (Next to desk) */}
          {/* Tower Top */}
          <Polygon points="72,34 82,29 76,26 66,31" fill="#334155" />
          {/* Tower Left Face */}
          <Polygon points="66,31 76,26 76,52 66,57" fill="url(#pcChassisGrad)" />
          {/* Tower Front Face */}
          <Polygon
            points="76,26 82,29 82,55 76,52"
            fill="#020617"
            stroke="#1E293B"
            strokeWidth="0.8"
          />
          {/* Front RGB Light Strip */}
          <Line
            x1="79"
            y1="31"
            x2="79"
            y2="49"
            stroke={statusColor}
            strokeWidth="1.2"
          />
          {/* Power Button LED */}
          <Circle cx="79" cy="29" r="1.2" fill={statusColor} />

          {/* 7. Selection Ring if active */}
          {isSelected && (
            <Polygon
              points="48,82 92,60 48,36 4,60"
              fill="none"
              stroke={colors.primary}
              strokeWidth="2"
              strokeDasharray="4, 3"
            />
          )}
        </Svg>

        {/* Bottom Specs Micro-Bar */}
        <View style={styles.microBar}>
          <Text style={styles.microRamText}>{status?.ram ? status.ram.split(' ')[0] : '16'}G</Text>
          <View
            style={[
              styles.microStatusBadge,
              { backgroundColor: healthy ? 'rgba(16, 185, 129, 0.15)' : 'rgba(239, 68, 68, 0.15)' },
            ]}
          >
            <Text
              style={[
                styles.microStatusText,
                { color: healthy ? colors.success : colors.danger },
              ]}
            >
              {healthy ? 'PASS' : `${issues.length} ERR`}
            </Text>
          </View>
        </View>
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  touchable: {
    margin: 4,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
  },
  pressed: {
    opacity: 0.85,
    transform: [{ scale: 0.96 }],
  },
  selectedContainer: {
    backgroundColor: 'rgba(6, 182, 212, 0.08)',
    borderRadius: 14,
  },
  isoContainer: {
    alignItems: 'center',
    paddingVertical: 4,
    paddingHorizontal: 2,
    position: 'relative',
  },
  floatingBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: '#0F172A',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 10,
    borderWidth: 1,
    marginBottom: -4,
    zIndex: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.4,
    shadowRadius: 3,
    elevation: 3,
  },
  floatingBadgeSelected: {
    backgroundColor: '#1E293B',
    borderColor: colors.primary,
  },
  badgeDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  badgeText: {
    fontSize: 10,
    fontWeight: '800',
    color: '#F8FAFC',
    letterSpacing: 0.4,
  },
  alertCountBadge: {
    backgroundColor: colors.danger,
    borderRadius: 6,
    paddingHorizontal: 4,
    paddingVertical: 1,
  },
  alertCountText: {
    color: '#FFF',
    fontSize: 8,
    fontWeight: '900',
  },
  microBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: 80,
    marginTop: -2,
    paddingHorizontal: 4,
  },
  microRamText: {
    fontSize: 9,
    color: colors.textMuted,
    fontWeight: '700',
  },
  microStatusBadge: {
    paddingHorizontal: 4,
    paddingVertical: 1,
    borderRadius: 4,
  },
  microStatusText: {
    fontSize: 8,
    fontWeight: '800',
    letterSpacing: 0.3,
  },

  // Blueprint Styles
  blueprintCard: {
    width: 88,
    height: 94,
    backgroundColor: '#070D1E',
    borderRadius: 10,
    borderWidth: 1.5,
    padding: 6,
    justifyContent: 'space-between',
  },
  instructorBlueprintCard: {
    borderColor: colors.primary,
    backgroundColor: '#081730',
  },
  blueprintHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  statusDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  blueprintTitle: {
    fontSize: 10,
    fontWeight: '800',
    color: colors.textPrimary,
  },
  blueprintVisual: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    marginVertical: 4,
  },
  blueprintMonitor: {
    width: 40,
    height: 24,
    backgroundColor: '#020617',
    borderRadius: 4,
    borderWidth: 1.5,
  },
  blueprintKb: {
    width: 14,
    height: 18,
    backgroundColor: '#1E293B',
    borderRadius: 2,
  },
  blueprintTower: {
    width: 10,
    height: 26,
    backgroundColor: '#020617',
    borderRadius: 2,
    borderWidth: 1,
  },
  blueprintSpecs: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  blueprintSpecText: {
    fontSize: 9,
    fontWeight: '700',
    color: colors.textSecondary,
  },
  blueprintOkTag: {
    fontSize: 8,
    fontWeight: '800',
    color: colors.success,
  },
  blueprintIssueTag: {
    fontSize: 8,
    fontWeight: '800',
    color: colors.danger,
  },

  // Heatmap Styles
  heatmapCard: {
    width: 86,
    height: 86,
    borderRadius: 10,
    borderWidth: 1.5,
    padding: 8,
    justifyContent: 'space-between',
  },
  instructorHeatmap: {
    borderWidth: 2,
  },
  heatmapBadge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 6,
  },
  heatmapBadgeText: {
    color: '#FFF',
    fontSize: 9,
    fontWeight: '800',
  },
  heatmapStatusText: {
    fontSize: 10,
    fontWeight: '700',
  },
  heatmapFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  heatmapSpecText: {
    fontSize: 8,
    color: colors.textMuted,
    fontWeight: '600',
  },
  statusIndicator: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
});
