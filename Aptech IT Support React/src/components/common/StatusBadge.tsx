import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../../theme/colors';
import { ComplaintCategory, ComplaintStatus } from '../../types/complaint';

interface StatusBadgeProps {
  status?: ComplaintStatus;
  category?: ComplaintCategory;
  role?: string;
  size?: 'sm' | 'md';
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({
  status,
  category,
  role,
  size = 'md',
}) => {
  if (status) {
    const getStatusStyle = () => {
      switch (status) {
        case 'Resolved':
          return { bg: colors.successBg, border: colors.successBorder, text: colors.success };
        case 'In Progress':
          return { bg: colors.warningBg, border: colors.warningBorder, text: colors.warning };
        case 'Pending':
        default:
          return { bg: colors.dangerBg, border: colors.dangerBorder, text: colors.danger };
      }
    };

    const s = getStatusStyle();
    return (
      <View
        style={[
          styles.badge,
          size === 'sm' ? styles.badgeSm : styles.badgeMd,
          { backgroundColor: s.bg, borderColor: s.border },
        ]}
      >
        <View style={[styles.dot, { backgroundColor: s.text }]} />
        <Text style={[styles.badgeText, { color: s.text }]}>{status}</Text>
      </View>
    );
  }

  if (category) {
    const getCategoryColor = () => {
      switch (category) {
        case 'Hardware':
          return colors.primary;
        case 'Software':
          return colors.secondary;
        case 'Network':
          return colors.accent;
        case 'Exam':
          return '#F43F5E';
        case 'Access':
          return colors.warning;
        default:
          return colors.textMuted;
      }
    };

    const color = getCategoryColor();
    return (
      <View
        style={[
          styles.badge,
          size === 'sm' ? styles.badgeSm : styles.badgeMd,
          { backgroundColor: 'rgba(255,255,255,0.05)', borderColor: 'rgba(255,255,255,0.1)' },
        ]}
      >
        <Text style={[styles.badgeText, { color }]}>{category}</Text>
      </View>
    );
  }

  if (role) {
    const getRoleColor = () => {
      switch (role) {
        case 'Admin':
          return colors.danger;
        case 'IT Technician':
          return colors.primary;
        case 'Faculty':
          return colors.secondary;
        default:
          return colors.textMuted;
      }
    };

    const color = getRoleColor();
    return (
      <View
        style={[
          styles.badge,
          size === 'sm' ? styles.badgeSm : styles.badgeMd,
          { backgroundColor: `${color}15`, borderColor: `${color}40` },
        ]}
      >
        <Text style={[styles.badgeText, { color }]}>{role}</Text>
      </View>
    );
  }

  return null;
};

const styles = StyleSheet.create({
  badge: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 8,
    borderWidth: 1,
  },
  badgeMd: {
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  badgeSm: {
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  dot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    marginRight: 6,
  },
  badgeText: {
    fontSize: 12,
    fontWeight: '600',
  },
});
