import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ScrollView,
  TextInput,
  Alert,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import {
  ArrowLeft,
  Search,
  Download,
  RotateCcw,
  ChevronRight,
  Filter as FilterIcon,
} from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { ComplaintCategory, ComplaintModel, ComplaintStatus } from '../../types/complaint';
import { useComplaintStore } from '../../stores/useComplaintStore';
import { excelService } from '../../services/excelService';
import { GlassCard } from '../../components/common/GlassCard';
import { StatusBadge } from '../../components/common/StatusBadge';

type Props = {
  navigation: StackNavigationProp<RootStackParamList, 'FilterComplaints'>;
};

const STATUS_LIST: (ComplaintStatus | 'All')[] = ['All', 'Pending', 'In Progress', 'Resolved'];
const CATEGORY_LIST: (ComplaintCategory | 'All')[] = [
  'All',
  'Hardware',
  'Software',
  'Network',
  'Exam',
  'Access',
];
const DATE_RANGES = [
  { label: 'All Time', value: 'all' },
  { label: 'Today', value: 'today' },
  { label: '7 Days', value: '7days' },
  { label: '30 Days', value: '30days' },
] as const;

export const FilterComplaintsScreen: React.FC<Props> = ({ navigation }) => {
  const {
    searchQuery,
    statusFilter,
    categoryFilter,
    dateRange,
    setSearchQuery,
    setStatusFilter,
    setCategoryFilter,
    setDateRange,
    resetFilters,
    getFilteredComplaints,
  } = useComplaintStore();

  const filtered = getFilteredComplaints();

  const handleExport = () => {
    if (filtered.length === 0) {
      Alert.alert('No Data', 'There are no complaints matching current filters to export.');
      return;
    }
    excelService.exportComplaintsToExcel(filtered);
    Alert.alert('Success', `Generated spreadsheet report with ${filtered.length} tickets.`);
  };

  const renderItem = ({ item }: { item: ComplaintModel }) => (
    <TouchableOpacity
      activeOpacity={0.7}
      onPress={() => navigation.navigate('ComplaintDetail', { complaint: item })}
    >
      <GlassCard style={styles.ticketCard}>
        <View style={styles.ticketTop}>
          <View style={styles.labBadge}>
            <Text style={styles.labText}>{item.lab}</Text>
          </View>
          <View style={styles.badgeGroup}>
            <StatusBadge category={item.issueCategory} size="sm" />
            <StatusBadge status={item.status} size="sm" />
          </View>
        </View>

        <Text style={styles.ticketMsg} numberOfLines={2}>
          {item.message}
        </Text>

        <View style={styles.ticketFooter}>
          <Text style={styles.facultyText}>Reporter: {item.facultyName}</Text>
          <View style={styles.techRow}>
            <Text style={styles.techText}>Assigned: {item.assignedToName}</Text>
            <ChevronRight size={16} color={colors.textMuted} />
          </View>
        </View>
      </GlassCard>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.appBar}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <ArrowLeft size={20} color={colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Filter Complaints</Text>

        <TouchableOpacity onPress={handleExport} style={styles.exportBtn}>
          <Download size={18} color={colors.primary} />
          <Text style={styles.exportText}>Export</Text>
        </TouchableOpacity>
      </View>

      {/* Search Field */}
      <View style={styles.searchSection}>
        <View style={styles.searchBox}>
          <Search size={18} color={colors.textMuted} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search keywords, lab, faculty, issue..."
            placeholderTextColor={colors.textMuted}
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
          {searchQuery ? (
            <TouchableOpacity onPress={() => setSearchQuery('')}>
              <Text style={{ color: colors.textMuted, fontSize: 13 }}>Clear</Text>
            </TouchableOpacity>
          ) : null}
        </View>
      </View>

      {/* Filter Horizontal Pills */}
      <View style={styles.filtersSection}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.pillsRow}>
          {STATUS_LIST.map((s) => (
            <TouchableOpacity
              key={s}
              style={[styles.pill, statusFilter === s && styles.pillActive]}
              onPress={() => setStatusFilter(s)}
            >
              <Text style={[styles.pillText, statusFilter === s && styles.pillTextActive]}>
                {s}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.pillsRow}>
          {CATEGORY_LIST.map((c) => (
            <TouchableOpacity
              key={c}
              style={[styles.pill, categoryFilter === c && styles.pillActive]}
              onPress={() => setCategoryFilter(c)}
            >
              <Text style={[styles.pillText, categoryFilter === c && styles.pillTextActive]}>
                {c}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.pillsRow}>
          {DATE_RANGES.map((d) => (
            <TouchableOpacity
              key={d.value}
              style={[styles.pill, dateRange === d.value && styles.pillActive]}
              onPress={() => setDateRange(d.value)}
            >
              <Text style={[styles.pillText, dateRange === d.value && styles.pillTextActive]}>
                {d.label}
              </Text>
            </TouchableOpacity>
          ))}

          <TouchableOpacity onPress={resetFilters} style={styles.resetBtn}>
            <RotateCcw size={14} color={colors.danger} />
            <Text style={styles.resetText}>Reset</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>

      {/* Count Indicator */}
      <View style={styles.countRow}>
        <Text style={styles.countText}>
          Showing <Text style={{ color: colors.primary, fontWeight: '700' }}>{filtered.length}</Text>{' '}
          tickets
        </Text>
      </View>

      {/* List */}
      <FlatList
        data={filtered}
        keyExtractor={(item: ComplaintModel) => item.complaintId}
        renderItem={renderItem}
        contentContainerStyle={styles.listContent}
        ListEmptyComponent={
          <GlassCard style={styles.emptyCard}>
            <FilterIcon size={40} color={colors.textMuted} />
            <Text style={styles.emptyTitle}>No matching tickets found</Text>
            <Text style={styles.emptyDesc}>
              Try adjusting your search criteria or reset filters.
            </Text>
          </GlassCard>
        }
      />
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
  exportBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: 'rgba(6, 182, 212, 0.12)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: colors.surfaceBorderHighlight,
  },
  exportText: {
    color: colors.primary,
    fontSize: 13,
    fontWeight: '700',
  },
  searchSection: {
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  searchBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.inputBg,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.inputBorder,
    paddingHorizontal: 12,
    height: 46,
    gap: 10,
  },
  searchInput: {
    flex: 1,
    color: colors.textPrimary,
    fontSize: 14,
  },
  filtersSection: {
    paddingHorizontal: 16,
    gap: 8,
    marginBottom: 10,
  },
  pillsRow: {
    flexDirection: 'row',
  },
  pill: {
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    marginRight: 8,
  },
  pillActive: {
    backgroundColor: 'rgba(6, 182, 212, 0.15)',
    borderColor: colors.primary,
  },
  pillText: {
    color: colors.textSecondary,
    fontSize: 12,
    fontWeight: '600',
  },
  pillTextActive: {
    color: colors.primary,
    fontWeight: '700',
  },
  resetBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: colors.dangerBg,
    marginRight: 8,
  },
  resetText: {
    color: colors.danger,
    fontSize: 12,
    fontWeight: '700',
  },
  countRow: {
    paddingHorizontal: 20,
    paddingVertical: 8,
  },
  countText: {
    fontSize: 12,
    color: colors.textMuted,
  },
  listContent: {
    padding: 16,
  },
  ticketCard: {
    marginBottom: 12,
    padding: 14,
  },
  ticketTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  badgeGroup: {
    flexDirection: 'row',
    gap: 6,
  },
  labBadge: {
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
  },
  labText: {
    color: colors.primary,
    fontSize: 12,
    fontWeight: '700',
  },
  ticketMsg: {
    fontSize: 14,
    color: colors.textPrimary,
    lineHeight: 20,
    marginBottom: 10,
  },
  ticketFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.05)',
    paddingTop: 8,
  },
  facultyText: {
    fontSize: 11,
    color: colors.textSecondary,
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
  emptyCard: {
    padding: 40,
    alignItems: 'center',
    marginTop: 20,
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.textPrimary,
    marginTop: 12,
    marginBottom: 4,
  },
  emptyDesc: {
    fontSize: 13,
    color: colors.textSecondary,
    textAlign: 'center',
  },
});
