import React, { useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { ArrowLeft, Plus, Monitor, ChevronRight, User } from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { useAuthStore } from '../../stores/useAuthStore';
import { useLabStore } from '../../stores/useLabStore';
import { LabModel } from '../../types/lab';
import { GlassCard } from '../../components/common/GlassCard';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'LabList'>;
};

export const LabListScreen: React.FC<Props> = ({ navigation }) => {
  const { user } = useAuthStore();
  const { labs, isLoading, subscribeToLabs } = useLabStore();

  useEffect(() => {
    const unsub = subscribeToLabs();
    return () => unsub();
  }, []);

  const renderLab = ({ item }: { item: LabModel }) => {
    const totalPcs = (item.rows || 0) * (item.columns || 0);

    return (
      <TouchableOpacity
        activeOpacity={0.7}
        onPress={() => navigation.navigate('Lab3D', { lab: item })}
      >
        <GlassCard elevated style={styles.labCard}>
          <View style={styles.labCardLeft}>
            <View style={styles.iconBox}>
              <Monitor size={22} color={colors.primary} />
            </View>
            <View>
              <Text style={styles.labTitle}>{item.name}</Text>
              <Text style={styles.labCapacity}>
                Capacity: {totalPcs} PCs ({item.rows} x {item.columns} Grid)
              </Text>
              <View style={styles.techRow}>
                <User size={13} color={colors.textSecondary} />
                <Text style={styles.techText}>
                  Technician: <Text style={{ color: colors.textPrimary }}>{item.assignedTo || 'Unassigned'}</Text>
                </Text>
              </View>
            </View>
          </View>

          <View style={styles.enter3DRow}>
            <Text style={styles.enter3DText}>3D View</Text>
            <ChevronRight size={18} color={colors.primary} />
          </View>
        </GlassCard>
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.appBar}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <ArrowLeft size={20} color={colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Computer Labs</Text>

        {user?.role === 'Admin' ? (
          <TouchableOpacity
            style={styles.addBtn}
            onPress={() => navigation.navigate('AddEditLab')}
          >
            <Plus size={18} color="#020617" />
            <Text style={styles.addText}>Add Lab</Text>
          </TouchableOpacity>
        ) : <View style={{ width: 40 }} />}
      </View>

      {isLoading ? (
        <View style={styles.loaderContainer}>
          <ActivityIndicator size="large" color={colors.primary} />
        </View>
      ) : (
        <FlatList
          data={labs}
          keyExtractor={(item: LabModel) => item.id}
          renderItem={renderLab}
          contentContainerStyle={styles.listContent}
          ListEmptyComponent={
            <GlassCard style={styles.emptyCard}>
              <Text style={styles.emptyText}>No computer labs registered yet.</Text>
            </GlassCard>
          }
        />
      )}
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
    justifyContent: 'space-between',
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
  addBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: colors.primary,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
  },
  addText: {
    color: '#020617',
    fontSize: 13,
    fontWeight: '700',
  },
  loaderContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  listContent: {
    padding: 16,
  },
  labCard: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 12,
    padding: 16,
  },
  labCardLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
    flex: 1,
  },
  iconBox: {
    width: 46,
    height: 46,
    borderRadius: 12,
    backgroundColor: 'rgba(6, 182, 212, 0.12)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  labTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.textPrimary,
    marginBottom: 2,
  },
  labCapacity: {
    fontSize: 12,
    color: colors.textSecondary,
    marginBottom: 4,
  },
  techRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  techText: {
    fontSize: 11,
    color: colors.textMuted,
  },
  enter3DRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(6, 182, 212, 0.1)',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 8,
  },
  enter3DText: {
    fontSize: 12,
    fontWeight: '700',
    color: colors.primary,
  },
  emptyCard: {
    padding: 40,
    alignItems: 'center',
    marginTop: 20,
  },
  emptyText: {
    color: colors.textMuted,
    fontSize: 14,
  },
});
