import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import {
  Monitor,
  CheckCircle2,
  AlertCircle,
  Wrench,
  X,
  Cpu,
  HardDrive,
  Globe,
  Zap,
} from 'lucide-react-native';
import { colors } from '../../theme/colors';
import { PcStatusModel, isPcHealthy } from '../../types/lab';

interface WorkstationQuickInspectorProps {
  pc: PcStatusModel;
  onOpenFullDiagnostics: () => void;
  onClose: () => void;
}

export const WorkstationQuickInspector: React.FC<WorkstationQuickInspectorProps> = ({
  pc,
  onOpenFullDiagnostics,
  onClose,
}) => {
  const healthy = isPcHealthy(pc);
  const statusColor = healthy ? colors.success : colors.danger;

  // Build component status checklist
  const checks = [
    { label: 'Keyboard', ok: pc.keyboardOk },
    { label: 'Mouse', ok: pc.mouseOk },
    { label: 'Display', ok: pc.ledOk },
    { label: 'CPU Core', ok: pc.cpuWorking },
    { label: 'Power', ok: pc.powerCableOk },
    { label: 'Ethernet', ok: pc.internetCableOk },
    { label: 'Video (VGA/HDMI)', ok: pc.vgaCableOk },
  ];

  const failedCount = checks.filter((c) => !c.ok).length;

  return (
    <View style={styles.container}>
      {/* Top Banner */}
      <View style={styles.header}>
        <View style={styles.titleArea}>
          <View style={[styles.statusGlowDot, { backgroundColor: statusColor }]} />
          <View>
            <Text style={styles.pcTitle}>{pc.pcId}</Text>
            <Text style={styles.pcSubtitle}>
              {healthy ? 'All Subsystems Operational' : `${failedCount} Subsystem Fault(s) Detected`}
            </Text>
          </View>
        </View>

        <TouchableOpacity onPress={onClose} style={styles.closeBtn} hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}>
          <X size={16} color={colors.textSecondary} />
        </TouchableOpacity>
      </View>

      {/* Hardware Specs Micro Row */}
      <View style={styles.specsRow}>
        <View style={styles.specChip}>
          <Cpu size={12} color={colors.primary} />
          <Text style={styles.specText}>{pc.ram || '16 GB RAM'}</Text>
        </View>

        <View style={styles.specChip}>
          <HardDrive size={12} color={colors.primary} />
          <Text style={styles.specText}>{pc.ssd || '512 GB SSD'}</Text>
        </View>

        <View style={styles.specChip}>
          <Globe size={12} color={colors.primary} />
          <Text style={styles.specText}>{pc.os || 'Windows 11'}</Text>
        </View>
      </View>

      {/* Component Status Grid */}
      <View style={styles.checksGrid}>
        {checks.map((item, idx) => (
          <View
            key={idx}
            style={[
              styles.checkPill,
              {
                backgroundColor: item.ok ? 'rgba(16, 185, 129, 0.08)' : 'rgba(239, 68, 68, 0.12)',
                borderColor: item.ok ? 'rgba(16, 185, 129, 0.25)' : 'rgba(239, 68, 68, 0.35)',
              },
            ]}
          >
            {item.ok ? (
              <CheckCircle2 size={11} color={colors.success} />
            ) : (
              <AlertCircle size={11} color={colors.danger} />
            )}
            <Text
              style={[
                styles.checkText,
                { color: item.ok ? colors.success : colors.danger },
              ]}
            >
              {item.label}
            </Text>
          </View>
        ))}
      </View>

      {/* Notes if available */}
      {Boolean(pc.notes && pc.notes.trim()) && (
        <View style={styles.notesBox}>
          <Text style={styles.notesText} numberOfLines={2}>
            📝 {pc.notes}
          </Text>
        </View>
      )}

      {/* Action Footer */}
      <TouchableOpacity
        onPress={onOpenFullDiagnostics}
        style={[
          styles.actionButton,
          { backgroundColor: healthy ? 'rgba(6, 182, 212, 0.15)' : 'rgba(239, 68, 68, 0.2)' },
        ]}
      >
        <Wrench size={14} color={healthy ? colors.primary : colors.danger} />
        <Text
          style={[
            styles.actionButtonText,
            { color: healthy ? colors.primary : colors.danger },
          ]}
        >
          Open Diagnostics & Hardware Config
        </Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 20,
    left: 16,
    right: 16,
    backgroundColor: 'rgba(15, 23, 42, 0.96)',
    borderRadius: 18,
    borderWidth: 1.5,
    borderColor: 'rgba(6, 182, 212, 0.35)',
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.5,
    shadowRadius: 16,
    elevation: 10,
    zIndex: 100,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  titleArea: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  statusGlowDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  pcTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: colors.textPrimary,
  },
  pcSubtitle: {
    fontSize: 11,
    color: colors.textSecondary,
    fontWeight: '500',
  },
  closeBtn: {
    padding: 6,
    borderRadius: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
  },
  specsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 10,
  },
  specChip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(255, 255, 255, 0.04)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.06)',
  },
  specText: {
    fontSize: 10,
    fontWeight: '700',
    color: colors.textSecondary,
  },
  checksGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 6,
    marginBottom: 10,
  },
  checkPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
    borderWidth: 1,
  },
  checkText: {
    fontSize: 10,
    fontWeight: '700',
  },
  notesBox: {
    backgroundColor: 'rgba(255, 255, 255, 0.03)',
    padding: 8,
    borderRadius: 6,
    marginBottom: 10,
  },
  notesText: {
    fontSize: 11,
    color: colors.textMuted,
    fontStyle: 'italic',
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    paddingVertical: 10,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: 'rgba(6, 182, 212, 0.3)',
  },
  actionButtonText: {
    fontSize: 12,
    fontWeight: '800',
    letterSpacing: 0.3,
  },
});
