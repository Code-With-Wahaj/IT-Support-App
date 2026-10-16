import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { ArrowLeft, Save, PlusCircle } from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { useLabStore } from '../../stores/useLabStore';
import { CustomInput } from '../../components/common/CustomInput';
import { CustomButton } from '../../components/common/CustomButton';
import { GlassCard } from '../../components/common/GlassCard';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'AddEditLab'>;
};

export const AddEditLabScreen: React.FC<Props> = ({ navigation }) => {
  const [name, setName] = useState('');
  const [rows, setRows] = useState('4');
  const [columns, setColumns] = useState('5');
  const [assignedTo, setAssignedTo] = useState('Ali Khan');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const { addLab } = useLabStore();

  const handleSave = async () => {
    setError('');
    if (!name.trim()) {
      setError('Please provide a lab name (e.g. Lab 105)');
      return;
    }

    const r = parseInt(rows, 10);
    const c = parseInt(columns, 10);

    if (isNaN(r) || r < 1 || r > 10) {
      setError('Rows must be between 1 and 10');
      return;
    }

    if (isNaN(c) || c < 1 || c > 10) {
      setError('Columns must be between 1 and 10');
      return;
    }

    setSaving(true);
    try {
      await addLab({
        name: name.trim(),
        rows: r,
        columns: c,
        layoutType: 'Grid',
        assignedTo: assignedTo.trim() || 'Unknown',
      });
      Alert.alert('Lab Created', `Lab ${name} has been configured with ${r * c} PC workstations.`);
      navigation.goBack();
    } catch (err: any) {
      setError(err.message || 'Failed to create lab');
    } finally {
      setSaving(false);
    }
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.appBar}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <ArrowLeft size={20} color={colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Configure Computer Lab</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <GlassCard elevated style={styles.card}>
          {error ? (
            <View style={styles.errorBox}>
              <Text style={styles.errorText}>{error}</Text>
            </View>
          ) : null}

          <CustomInput
            label="Lab Room Identifier"
            placeholder="e.g. Lab 103"
            value={name}
            onChangeText={setName}
          />

          <View style={styles.rowTwo}>
            <View style={{ flex: 1 }}>
              <CustomInput
                label="Rows of Desks"
                placeholder="4"
                keyboardType="numeric"
                value={rows}
                onChangeText={setRows}
              />
            </View>
            <View style={{ flex: 1 }}>
              <CustomInput
                label="Columns (PCs per row)"
                placeholder="5"
                keyboardType="numeric"
                value={columns}
                onChangeText={setColumns}
              />
            </View>
          </View>

          <CustomInput
            label="Lead Technician"
            placeholder="e.g. Ali Khan"
            value={assignedTo}
            onChangeText={setAssignedTo}
          />

          <View style={styles.infoBox}>
            <Text style={styles.infoText}>
              Saving will automatically provision individual workstation diagnostic records from{' '}
              <Text style={{ color: colors.primary, fontWeight: '700' }}>PC-1-1</Text> up to{' '}
              <Text style={{ color: colors.primary, fontWeight: '700' }}>
                PC-{rows || 4}-{columns || 5}
              </Text>{' '}
              along with the Instructor Terminal (IP).
            </Text>
          </View>

          <CustomButton
            title="Create Lab & Initialize PCs"
            onPress={handleSave}
            loading={saving}
            icon={<Save size={18} color="#020617" />}
            style={{ marginTop: 10 }}
          />
        </GlassCard>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  appBar: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
    paddingTop: 50,
    paddingHorizontal: 20,
    paddingBottom: 16,
    backgroundColor: colors.surfaceElevated,
    borderBottomWidth: 1,
    borderBottomColor: colors.surfaceBorder,
  },
  backBtn: {
    padding: 6,
    borderRadius: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: colors.textPrimary,
  },
  content: {
    padding: 20,
  },
  card: {
    padding: 24,
  },
  errorBox: {
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
  },
  rowTwo: {
    flexDirection: 'row',
    gap: 12,
  },
  infoBox: {
    backgroundColor: 'rgba(255, 255, 255, 0.04)',
    borderRadius: 10,
    padding: 12,
    marginBottom: 16,
  },
  infoText: {
    fontSize: 12,
    color: colors.textSecondary,
    lineHeight: 18,
  },
});
