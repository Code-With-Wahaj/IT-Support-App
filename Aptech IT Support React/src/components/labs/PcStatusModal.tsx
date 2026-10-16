import React, { useState, useEffect } from 'react';
import {
  Modal,
  View,
  Text,
  StyleSheet,
  ScrollView,
  Switch,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { X, Check, Monitor, Cpu, Cable, HardDrive } from 'lucide-react-native';
import { colors } from '../../theme/colors';
import { PcStatusModel } from '../../types/lab';
import { CustomInput } from '../common/CustomInput';
import { CustomButton } from '../common/CustomButton';

interface PcStatusModalProps {
  visible: boolean;
  pc: PcStatusModel | null;
  onClose: () => void;
  onSave: (pcId: string, updated: Partial<PcStatusModel>) => Promise<void>;
}

export const PcStatusModal: React.FC<PcStatusModalProps> = ({
  visible,
  pc,
  onClose,
  onSave,
}) => {
  if (!pc) return null;

  const [keyboardOk, setKeyboardOk] = useState(pc.keyboardOk);
  const [mouseOk, setMouseOk] = useState(pc.mouseOk);
  const [ledOk, setLedOk] = useState(pc.ledOk);

  const [vgaCableOk, setVgaCableOk] = useState(pc.vgaCableOk);
  const [powerCableOk, setPowerCableOk] = useState(pc.powerCableOk);
  const [internetCableOk, setInternetCableOk] = useState(pc.internetCableOk);

  const [cpuWorking, setCpuWorking] = useState(pc.cpuWorking);

  const [ram, setRam] = useState(pc.ram || '16 GB');
  const [ssd, setSsd] = useState(pc.ssd || '512 GB');
  const [os, setOs] = useState(pc.os || 'Windows 11');
  const [notes, setNotes] = useState(pc.notes || '');

  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (pc) {
      setKeyboardOk(pc.keyboardOk);
      setMouseOk(pc.mouseOk);
      setLedOk(pc.ledOk);
      setVgaCableOk(pc.vgaCableOk);
      setPowerCableOk(pc.powerCableOk);
      setInternetCableOk(pc.internetCableOk);
      setCpuWorking(pc.cpuWorking);
      setRam(pc.ram || '16 GB');
      setSsd(pc.ssd || '512 GB');
      setOs(pc.os || 'Windows 11');
      setNotes(pc.notes || '');
    }
  }, [pc]);

  const handleSave = async () => {
    setSaving(true);
    try {
      await onSave(pc.pcId, {
        keyboardOk,
        mouseOk,
        ledOk,
        vgaCableOk,
        powerCableOk,
        internetCableOk,
        cpuWorking,
        ram,
        ssd,
        os,
        notes,
      });
      onClose();
    } catch (err) {
      console.error('Failed to save PC status:', err);
    } finally {
      setSaving(false);
    }
  };

  const renderSwitch = (
    label: string,
    value: boolean,
    onChange: (val: boolean) => void
  ) => (
    <View style={styles.switchRow}>
      <Text style={styles.switchLabel}>{label}</Text>
      <Switch
        value={value}
        onValueChange={onChange}
        trackColor={{ false: '#334155', true: colors.successBg }}
        thumbColor={value ? colors.success : '#94A3B8'}
      />
    </View>
  );

  return (
    <Modal visible={visible} animationType="slide" transparent>
      <View style={styles.overlay}>
        <View style={styles.dialog}>
          {/* Header */}
          <View style={styles.header}>
            <View style={styles.titleRow}>
              <Monitor size={22} color={colors.primary} />
              <Text style={styles.headerTitle}>{pc.pcId} Diagnostics</Text>
            </View>
            <TouchableOpacity onPress={onClose} style={styles.closeBtn}>
              <X size={20} color={colors.textSecondary} />
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
            {/* Peripherals */}
            <View style={styles.section}>
              <View style={styles.sectionHeader}>
                <Monitor size={16} color={colors.primary} />
                <Text style={styles.sectionTitle}>Peripherals</Text>
              </View>
              {renderSwitch('Keyboard Functional', keyboardOk, setKeyboardOk)}
              {renderSwitch('Mouse Functional', mouseOk, setMouseOk)}
              {renderSwitch('LED Display Monitor OK', ledOk, setLedOk)}
            </View>

            {/* Cabling */}
            <View style={styles.section}>
              <View style={styles.sectionHeader}>
                <Cable size={16} color={colors.accent} />
                <Text style={styles.sectionTitle}>Cabling & Network</Text>
              </View>
              {renderSwitch('VGA / HDMI Cable OK', vgaCableOk, setVgaCableOk)}
              {renderSwitch('Power Cable OK', powerCableOk, setPowerCableOk)}
              {renderSwitch('Ethernet LAN Cable OK', internetCableOk, setInternetCableOk)}
            </View>

            {/* CPU System */}
            <View style={styles.section}>
              <View style={styles.sectionHeader}>
                <Cpu size={16} color={colors.secondary} />
                <Text style={styles.sectionTitle}>CPU & Hardware Power</Text>
              </View>
              {renderSwitch('CPU Booting Normally', cpuWorking, setCpuWorking)}
            </View>

            {/* Specifications */}
            <View style={styles.section}>
              <View style={styles.sectionHeader}>
                <HardDrive size={16} color={colors.warning} />
                <Text style={styles.sectionTitle}>System Specifications</Text>
              </View>
              <CustomInput
                label="Installed RAM"
                value={ram}
                onChangeText={setRam}
                placeholder="e.g. 16 GB"
              />
              <CustomInput
                label="Primary Storage (SSD/HDD)"
                value={ssd}
                onChangeText={setSsd}
                placeholder="e.g. 512 GB NVMe"
              />
              <CustomInput
                label="Operating System"
                value={os}
                onChangeText={setOs}
                placeholder="e.g. Windows 11 Pro"
              />
              <CustomInput
                label="Maintenance Notes"
                value={notes}
                onChangeText={setNotes}
                placeholder="Add technician remarks or fault details"
                multiline
                numberOfLines={3}
                style={{ height: 80, textAlignVertical: 'top' }}
              />
            </View>
          </ScrollView>

          {/* Footer Actions */}
          <View style={styles.footer}>
            <CustomButton
              title="Save Changes"
              onPress={handleSave}
              loading={saving}
              icon={<Check size={18} color="#020617" />}
              style={styles.saveBtn}
            />
          </View>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(2, 6, 23, 0.85)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
  },
  dialog: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: 20,
    width: '100%',
    maxWidth: 500,
    maxHeight: '85%',
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.5,
    shadowRadius: 15,
    elevation: 10,
    overflow: 'hidden',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: colors.surfaceBorder,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: colors.textPrimary,
  },
  closeBtn: {
    padding: 6,
    borderRadius: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
  },
  content: {
    padding: 20,
  },
  section: {
    marginBottom: 20,
    backgroundColor: colors.surface,
    padding: 14,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 12,
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: colors.textSecondary,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  switchRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.04)',
  },
  switchLabel: {
    fontSize: 14,
    color: colors.textPrimary,
    fontWeight: '500',
  },
  footer: {
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: colors.surfaceBorder,
    backgroundColor: colors.surfaceElevated,
  },
  saveBtn: {
    width: '100%',
  },
});
