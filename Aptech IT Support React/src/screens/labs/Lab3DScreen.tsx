import React, { useEffect, useState, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import {
  ArrowLeft,
  Download,
  Box,
  LayoutGrid,
  Activity,
  Search,
  Filter,
  CheckCircle2,
  AlertTriangle,
  Server,
  Layers,
  X,
  DoorOpen,
} from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { PcStatusModel, isPcHealthy } from '../../types/lab';
import { useLabStore } from '../../stores/useLabStore';
import { excelService } from '../../services/excelService';
import { IsometricWorkstation, LabViewMode } from '../../components/labs/IsometricWorkstation';
import { InstructorPodium3D } from '../../components/labs/InstructorPodium3D';
import { SmartBoard3D } from '../../components/labs/SmartBoard3D';
import { LabServerRack3D } from '../../components/labs/LabServerRack3D';
import { WorkstationQuickInspector } from '../../components/labs/WorkstationQuickInspector';
import { PcStatusModal } from '../../components/labs/PcStatusModal';

type RouteProps = RouteProp<RootStackParamList, 'Lab3D'>;
type NavProps = StackNavigationProp<RootStackParamList, 'Lab3D'>;

type Props = {
  route: RouteProps;
  navigation: NavProps;
};

type FilterCategory = 'all' | 'healthy' | 'faults' | 'offline';

export const Lab3DScreen: React.FC<Props> = ({ route, navigation }) => {
  const { lab } = route.params;
  const { currentLabPcs, isPcsLoading, subscribeToLabPcs, updatePcStatus } = useLabStore();

  const [selectedPc, setSelectedPc] = useState<PcStatusModel | null>(null);
  const [modalVisible, setModalVisible] = useState(false);
  const [viewMode, setViewMode] = useState<LabViewMode>('isometric');
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState<FilterCategory>('all');

  useEffect(() => {
    const unsub = subscribeToLabPcs(lab.id);
    return () => unsub();
  }, [lab.id]);

  const handleOpenDiagnostics = (pc: PcStatusModel) => {
    setSelectedPc(pc);
    setModalVisible(true);
  };

  const handleSavePc = async (pcId: string, updated: Partial<PcStatusModel>) => {
    await updatePcStatus(lab.id, pcId, updated);
  };

  const handleExportAudit = () => {
    if (currentLabPcs.length === 0) {
      Alert.alert('No Data', 'No workstation hardware data available.');
      return;
    }
    excelService.exportLabHardwareAudit(lab, currentLabPcs);
    Alert.alert('Audit Exported', `Generated hardware inventory for ${lab.name}.`);
  };

  // Build lookup map for student workstations
  const pcMap = useMemo(() => {
    const map = new Map<string, PcStatusModel>();
    currentLabPcs.forEach((pc) => map.set(pc.pcId, pc));
    return map;
  }, [currentLabPcs]);

  // Instructor terminal definition
  const instructorPc: PcStatusModel = pcMap.get('IP') || {
    pcId: 'IP',
    keyboardOk: true,
    mouseOk: true,
    ledOk: true,
    vgaCableOk: true,
    powerCableOk: true,
    internetCableOk: true,
    cpuWorking: true,
    ram: '32 GB',
    ssd: '1 TB NVMe',
    os: 'Windows 11 Pro',
    notes: 'Instructor Workstation (Master)',
  };

  // Compute live statistics
  const totalSlots = lab.rows * lab.columns + 1; // student desks + instructor
  const allWorkstationsList: PcStatusModel[] = useMemo(() => {
    const list: PcStatusModel[] = [instructorPc];
    for (let r = 0; r < lab.rows; r++) {
      for (let c = 0; c < lab.columns; c++) {
        const pcId = `PC-${r + 1}-${c + 1}`;
        list.push(
          pcMap.get(pcId) || {
            pcId,
            keyboardOk: true,
            mouseOk: true,
            ledOk: true,
            vgaCableOk: true,
            powerCableOk: true,
            internetCableOk: true,
            cpuWorking: true,
            ram: '16 GB',
            ssd: '512 GB',
            os: 'Windows 11',
            notes: '',
          }
        );
      }
    }
    return list;
  }, [lab.rows, lab.columns, pcMap, instructorPc]);

  const healthyCount = allWorkstationsList.filter((p) => isPcHealthy(p)).length;
  const issueCount = allWorkstationsList.length - healthyCount;

  // Filter check helper
  const isPcMatching = (pc: PcStatusModel) => {
    const isHealthy = isPcHealthy(pc);

    // Filter check
    if (activeFilter === 'healthy' && !isHealthy) return false;
    if (activeFilter === 'faults' && isHealthy) return false;

    // Search query check
    if (searchQuery.trim().length > 0) {
      const q = searchQuery.toLowerCase().trim();
      return (
        pc.pcId.toLowerCase().includes(q) ||
        (pc.ram && pc.ram.toLowerCase().includes(q)) ||
        (pc.os && pc.os.toLowerCase().includes(q)) ||
        (pc.notes && pc.notes.toLowerCase().includes(q))
      );
    }

    return true;
  };

  return (
    <View style={styles.container}>
      {/* 1. FUTURISTIC TOP APP BAR */}
      <View style={styles.appBar}>
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          style={styles.backBtn}
          hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
        >
          <ArrowLeft size={20} color={colors.textPrimary} />
        </TouchableOpacity>

        <View style={styles.headerInfo}>
          <View style={styles.headerTitleRow}>
            <Text style={styles.headerTitle}>{lab.name}</Text>
            <View style={styles.onlinePill}>
              <View style={styles.onlineDot} />
              <Text style={styles.onlineText}>DIGITAL TWIN</Text>
            </View>
          </View>
          <Text style={styles.headerSubtitle}>
            {lab.rows}x{lab.columns} Matrix • Lead: {lab.assignedTo || 'Unassigned'}
          </Text>
        </View>

        <TouchableOpacity onPress={handleExportAudit} style={styles.auditBtn}>
          <Download size={15} color={colors.primary} />
          <Text style={styles.auditBtnText}>Export</Text>
        </TouchableOpacity>
      </View>

      {/* 2. PERSPECTIVE / VIEW MODE SWITCHER */}
      <View style={styles.viewModeBar}>
        <TouchableOpacity
          onPress={() => setViewMode('isometric')}
          style={[
            styles.modeTab,
            viewMode === 'isometric' && styles.modeTabActive,
          ]}
        >
          <Box size={14} color={viewMode === 'isometric' ? colors.primary : colors.textMuted} />
          <Text
            style={[
              styles.modeTabText,
              viewMode === 'isometric' && styles.modeTabTextActive,
            ]}
          >
            3D Isometric
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => setViewMode('blueprint')}
          style={[
            styles.modeTab,
            viewMode === 'blueprint' && styles.modeTabActive,
          ]}
        >
          <LayoutGrid size={14} color={viewMode === 'blueprint' ? colors.primary : colors.textMuted} />
          <Text
            style={[
              styles.modeTabText,
              viewMode === 'blueprint' && styles.modeTabTextActive,
            ]}
          >
            2D Blueprint
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => setViewMode('heatmap')}
          style={[
            styles.modeTab,
            viewMode === 'heatmap' && styles.modeTabActive,
          ]}
        >
          <Activity size={14} color={viewMode === 'heatmap' ? colors.primary : colors.textMuted} />
          <Text
            style={[
              styles.modeTabText,
              viewMode === 'heatmap' && styles.modeTabTextActive,
            ]}
          >
            Fault Heatmap
          </Text>
        </TouchableOpacity>
      </View>

      {/* 3. SEARCH & QUICK FILTER PILLS */}
      <View style={styles.controlsRow}>
        {/* Search Input */}
        <View style={styles.searchBox}>
          <Search size={14} color={colors.textMuted} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search PC (e.g. 1-2, RAM, OS)..."
            placeholderTextColor={colors.textMuted}
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity onPress={() => setSearchQuery('')}>
              <X size={14} color={colors.textSecondary} />
            </TouchableOpacity>
          )}
        </View>

        {/* Filter Chips */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.filterScroll}>
          <TouchableOpacity
            onPress={() => setActiveFilter('all')}
            style={[
              styles.filterChip,
              activeFilter === 'all' && styles.filterChipActive,
            ]}
          >
            <Text
              style={[
                styles.filterChipText,
                activeFilter === 'all' && styles.filterChipTextActive,
              ]}
            >
              All ({allWorkstationsList.length})
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => setActiveFilter('healthy')}
            style={[
              styles.filterChip,
              activeFilter === 'healthy' && styles.filterChipActiveSuccess,
            ]}
          >
            <View style={[styles.filterDot, { backgroundColor: colors.success }]} />
            <Text
              style={[
                styles.filterChipText,
                activeFilter === 'healthy' && styles.filterChipTextActiveSuccess,
              ]}
            >
              Healthy ({healthyCount})
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => setActiveFilter('faults')}
            style={[
              styles.filterChip,
              activeFilter === 'faults' && styles.filterChipActiveDanger,
            ]}
          >
            <View style={[styles.filterDot, { backgroundColor: colors.danger }]} />
            <Text
              style={[
                styles.filterChipText,
                activeFilter === 'faults' && styles.filterChipTextActiveDanger,
              ]}
            >
              Faults ({issueCount})
            </Text>
          </TouchableOpacity>
        </ScrollView>
      </View>

      {/* 4. MAIN DIGITAL-TWIN FLOORPLAN CANVAS */}
      {isPcsLoading ? (
        <View style={styles.loaderArea}>
          <ActivityIndicator size="large" color={colors.primary} />
          <Text style={styles.loaderText}>Syncing Digital Twin telemetry stream...</Text>
        </View>
      ) : (
        <ScrollView
          style={styles.viewport}
          contentContainerStyle={styles.viewportContent}
          showsVerticalScrollIndicator={false}
        >
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            <View style={styles.floorplanBounds}>
              {/* Classroom Wall Boundary Frame */}
              <View style={styles.roomWallFrame}>
                {/* 4K SMART PRESENTATION SCREEN / LECTURE DISPLAY */}
                <SmartBoard3D
                  labName={lab.name}
                  totalPcs={allWorkstationsList.length}
                  healthyCount={healthyCount}
                  issueCount={issueCount}
                />

                {/* Infrastructure Corridor: Server Rack + Entrance */}
                <View style={styles.corridorRow}>
                  {/* Entrance Door Symbol */}
                  <View style={styles.entrancePill}>
                    <DoorOpen size={14} color={colors.primary} />
                    <Text style={styles.entranceText}>MAIN LAB ENTRY</Text>
                  </View>

                  {/* Server Rack 3D */}
                  <LabServerRack3D />
                </View>

                {/* INSTRUCTOR MASTER PODIUM */}
                <InstructorPodium3D
                  instructorPc={instructorPc}
                  assignedTo={lab.assignedTo}
                  viewMode={viewMode}
                  isSelected={selectedPc?.pcId === instructorPc.pcId}
                  onPress={() => setSelectedPc(instructorPc)}
                />

                {/* Aisle Walkway Divider */}
                <View style={styles.aisleDivider}>
                  <View style={styles.aisleLine} />
                  <Text style={styles.aisleText}>STUDENT WORKSTATION FLOOR</Text>
                  <View style={styles.aisleLine} />
                </View>

                {/* STUDENT WORKSTATION MATRIX */}
                <View style={styles.studentGrid}>
                  {Array.from({ length: lab.rows }).map((_, rIdx) => (
                    <View key={`row-${rIdx}`} style={styles.matrixRowContainer}>
                      {/* Row Label Indicator */}
                      <View style={styles.rowLabelBadge}>
                        <Text style={styles.rowLabelText}>R{rIdx + 1}</Text>
                      </View>

                      {/* Workstations in Row */}
                      <View style={styles.rowWorkstations}>
                        {Array.from({ length: lab.columns }).map((_, cIdx) => {
                          const pcId = `PC-${rIdx + 1}-${cIdx + 1}`;
                          const status = pcMap.get(pcId) || {
                            pcId,
                            keyboardOk: true,
                            mouseOk: true,
                            ledOk: true,
                            vgaCableOk: true,
                            powerCableOk: true,
                            internetCableOk: true,
                            cpuWorking: true,
                            ram: '16 GB',
                            ssd: '512 GB',
                            os: 'Windows 11',
                            notes: '',
                          };

                          const matching = isPcMatching(status);
                          const isSelected = selectedPc?.pcId === pcId;

                          return (
                            <View
                              key={pcId}
                              style={[
                                styles.slotWrapper,
                                !matching && styles.slotDimmed,
                              ]}
                            >
                              <IsometricWorkstation
                                pcId={pcId}
                                status={status}
                                isSelected={isSelected}
                                viewMode={viewMode}
                                onPress={() => setSelectedPc(status)}
                              />
                            </View>
                          );
                        })}
                      </View>
                    </View>
                  ))}
                </View>
              </View>
            </View>
          </ScrollView>
        </ScrollView>
      )}

      {/* 5. FLOATING WORKSTATION QUICK INSPECTOR HUD */}
      {selectedPc && (
        <WorkstationQuickInspector
          pc={selectedPc}
          onOpenFullDiagnostics={() => handleOpenDiagnostics(selectedPc)}
          onClose={() => setSelectedPc(null)}
        />
      )}

      {/* 6. FULL HARDWARE DIAGNOSTICS & EDIT MODAL */}
      <PcStatusModal
        visible={modalVisible}
        pc={selectedPc}
        onClose={() => {
          setModalVisible(false);
          setSelectedPc(null);
        }}
        onSave={handleSavePc}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },

  // 1. App Bar
  appBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: 48,
    paddingHorizontal: 16,
    paddingBottom: 14,
    backgroundColor: colors.surfaceElevated,
    borderBottomWidth: 1,
    borderBottomColor: colors.surfaceBorder,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
    zIndex: 10,
  },
  backBtn: {
    padding: 8,
    borderRadius: 10,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.08)',
  },
  headerInfo: {
    flex: 1,
    marginHorizontal: 12,
  },
  headerTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '900',
    color: colors.textPrimary,
    letterSpacing: 0.3,
  },
  onlinePill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(6, 182, 212, 0.12)',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: 'rgba(6, 182, 212, 0.3)',
  },
  onlineDot: {
    width: 5,
    height: 5,
    borderRadius: 2.5,
    backgroundColor: colors.primary,
  },
  onlineText: {
    color: colors.primary,
    fontSize: 8,
    fontWeight: '900',
    letterSpacing: 0.6,
  },
  headerSubtitle: {
    fontSize: 11,
    color: colors.textSecondary,
    fontWeight: '500',
    marginTop: 2,
  },
  auditBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: 'rgba(6, 182, 212, 0.14)',
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: 'rgba(6, 182, 212, 0.35)',
  },
  auditBtnText: {
    color: colors.primary,
    fontSize: 12,
    fontWeight: '800',
    letterSpacing: 0.3,
  },

  // 2. View Mode Switcher
  viewModeBar: {
    flexDirection: 'row',
    backgroundColor: '#070D1E',
    padding: 4,
    marginHorizontal: 16,
    marginTop: 10,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    gap: 4,
  },
  modeTab: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    paddingVertical: 8,
    borderRadius: 8,
  },
  modeTabActive: {
    backgroundColor: 'rgba(6, 182, 212, 0.18)',
    borderWidth: 1,
    borderColor: 'rgba(6, 182, 212, 0.4)',
  },
  modeTabText: {
    fontSize: 11,
    color: colors.textMuted,
    fontWeight: '700',
  },
  modeTabTextActive: {
    color: colors.primary,
    fontWeight: '800',
  },

  // 3. Search and Filters
  controlsRow: {
    paddingHorizontal: 16,
    paddingTop: 10,
    paddingBottom: 6,
    gap: 8,
  },
  searchBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(15, 23, 42, 0.8)',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    gap: 8,
  },
  searchInput: {
    flex: 1,
    color: colors.textPrimary,
    fontSize: 12,
    padding: 0,
  },
  filterScroll: {
    flexDirection: 'row',
  },
  filterChip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
    backgroundColor: 'rgba(255, 255, 255, 0.04)',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.08)',
    marginRight: 6,
  },
  filterChipActive: {
    backgroundColor: 'rgba(6, 182, 212, 0.15)',
    borderColor: colors.primary,
  },
  filterChipActiveSuccess: {
    backgroundColor: 'rgba(16, 185, 129, 0.15)',
    borderColor: colors.success,
  },
  filterChipActiveDanger: {
    backgroundColor: 'rgba(239, 68, 68, 0.15)',
    borderColor: colors.danger,
  },
  filterDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  filterChipText: {
    fontSize: 11,
    color: colors.textSecondary,
    fontWeight: '700',
  },
  filterChipTextActive: {
    color: colors.primary,
  },
  filterChipTextActiveSuccess: {
    color: colors.success,
  },
  filterChipTextActiveDanger: {
    color: colors.danger,
  },

  // 4. Floorplan Viewport
  viewport: {
    flex: 1,
  },
  viewportContent: {
    paddingVertical: 20,
    paddingHorizontal: 16,
    alignItems: 'center',
  },
  floorplanBounds: {
    alignItems: 'center',
    paddingHorizontal: 12,
  },
  roomWallFrame: {
    backgroundColor: '#04091A',
    borderRadius: 24,
    borderWidth: 2,
    borderColor: 'rgba(6, 182, 212, 0.25)',
    paddingHorizontal: 24,
    paddingVertical: 20,
    alignItems: 'center',
    shadowColor: colors.primary,
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.2,
    shadowRadius: 20,
    elevation: 8,
    minWidth: 380,
  },
  corridorRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
    marginVertical: 10,
    paddingHorizontal: 12,
  },
  entrancePill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: 'rgba(6, 182, 212, 0.08)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: 'rgba(6, 182, 212, 0.2)',
  },
  entranceText: {
    color: colors.primary,
    fontSize: 10,
    fontWeight: '800',
    letterSpacing: 0.8,
  },
  aisleDivider: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    width: '100%',
    marginVertical: 14,
  },
  aisleLine: {
    flex: 1,
    height: 1,
    backgroundColor: 'rgba(6, 182, 212, 0.15)',
  },
  aisleText: {
    color: colors.textMuted,
    fontSize: 9,
    fontWeight: '800',
    letterSpacing: 1.5,
  },
  studentGrid: {
    gap: 20,
    alignItems: 'center',
    marginTop: 6,
  },
  matrixRowContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  rowLabelBadge: {
    backgroundColor: '#0B132B',
    paddingHorizontal: 6,
    paddingVertical: 10,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.08)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  rowLabelText: {
    fontSize: 10,
    fontWeight: '900',
    color: colors.primary,
    letterSpacing: 0.5,
  },
  rowWorkstations: {
    flexDirection: 'row',
    gap: 12,
    justifyContent: 'center',
  },
  slotWrapper: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  slotDimmed: {
    opacity: 0.25,
  },

  // Loader Area
  loaderArea: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
  },
  loaderText: {
    fontSize: 13,
    color: colors.textSecondary,
    fontWeight: '600',
  },
});
