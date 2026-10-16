import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
} from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { ArrowLeft, Send, Sparkles, AlertTriangle } from 'lucide-react-native';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { useAuthStore } from '../../stores/useAuthStore';
import { useComplaintStore } from '../../stores/useComplaintStore';
import { complaintService } from '../../services/complaintService';
import { ComplaintModel } from '../../types/complaint';
import { StatusBadge } from '../../components/common/StatusBadge';

type ChatsScreenProps = {
  navigation: StackNavigationProp<RootStackParamList, 'Chats'>;
};

export const ChatsScreen: React.FC<ChatsScreenProps> = ({ navigation }) => {
  const { user } = useAuthStore();
  const { complaints } = useComplaintStore();
  const [inputText, setInputText] = useState('');
  const [sending, setSending] = useState(false);
  const flatListRef = useRef<FlatList>(null);

  const handleSend = async () => {
    const text = inputText.trim();
    if (!text) return;

    setInputText('');
    setSending(true);

    try {
      await complaintService.createComplaint(text);
      setTimeout(() => {
        flatListRef.current?.scrollToEnd({ animated: true });
      }, 300);
    } catch (err: any) {
      console.error('Error sending complaint:', err);
    } finally {
      setSending(false);
    }
  };

  // Reverse list so newest at bottom or chronological
  const sortedComplaints = [...complaints].sort((a, b) => {
    const tA = a.timestamp?.toMillis ? a.timestamp.toMillis() : new Date(a.timestamp || 0).getTime();
    const tB = b.timestamp?.toMillis ? b.timestamp.toMillis() : new Date(b.timestamp || 0).getTime();
    return tA - tB;
  });

  const renderMessage = ({ item }: { item: ComplaintModel }) => {
    const isCurrentUser = item.facultyId === user?.uid;

    return (
      <View
        style={[
          styles.bubbleWrapper,
          isCurrentUser ? styles.bubbleWrapperRight : styles.bubbleWrapperLeft,
        ]}
      >
        <View
          style={[
            styles.bubble,
            isCurrentUser ? styles.bubbleRight : styles.bubbleLeft,
          ]}
        >
          {/* Sender & Badges */}
          <View style={styles.bubbleHeader}>
            <Text style={styles.senderName}>{item.facultyName || 'Faculty'}</Text>
            <View style={styles.badgeRow}>
              <View style={styles.labPill}>
                <Text style={styles.labPillText}>{item.lab}</Text>
              </View>
              <StatusBadge category={item.issueCategory} size="sm" />
            </View>
          </View>

          {/* Message Text */}
          <Text style={styles.bubbleMessage}>{item.message}</Text>

          {/* Assignment & Status Info */}
          <View style={styles.bubbleFooter}>
            <Text style={styles.assignedTechText}>
              Tech: <Text style={{ color: colors.textPrimary }}>{item.assignedToName}</Text>
            </Text>
            <StatusBadge status={item.status} size="sm" />
          </View>
        </View>
      </View>
    );
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      style={styles.container}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 90 : 0}
    >
      {/* Header */}
      <View style={styles.appBar}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <ArrowLeft size={20} color={colors.textPrimary} />
        </TouchableOpacity>
        <View>
          <Text style={styles.headerTitle}>IT Support Chat</Text>
          <Text style={styles.headerSubtitle}>Live ticket auto-detection channel</Text>
        </View>
      </View>

      {/* Suggestion / Instruction Banner */}
      <View style={styles.nlpTipBox}>
        <Sparkles size={16} color={colors.primary} />
        <Text style={styles.nlpTipText}>
          Tip: Mention room number (e.g. <Text style={{ color: colors.primary }}>Lab 102</Text>) and issue
          type to auto-assign technicians!
        </Text>
      </View>

      {/* Chat Messages */}
      <FlatList
        ref={flatListRef}
        data={sortedComplaints}
        keyExtractor={(item: ComplaintModel) => item.complaintId}
        renderItem={renderMessage}
        contentContainerStyle={styles.listContent}
        onContentSizeChange={() => flatListRef.current?.scrollToEnd({ animated: false })}
      />

      {/* Input Field */}
      <View style={styles.inputArea}>
        <TextInput
          style={styles.chatInput}
          placeholder="Describe issue (e.g. Need IT in Lab 201 keyboard broken)..."
          placeholderTextColor={colors.textMuted}
          value={inputText}
          onChangeText={setInputText}
          multiline
          maxLength={300}
        />
        <TouchableOpacity
          style={[styles.sendBtn, !inputText.trim() && styles.sendBtnDisabled]}
          onPress={handleSend}
          disabled={!inputText.trim() || sending}
        >
          {sending ? (
            <ActivityIndicator size="small" color="#020617" />
          ) : (
            <Send size={18} color="#020617" />
          )}
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
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
  headerSubtitle: {
    fontSize: 12,
    color: colors.textSecondary,
  },
  nlpTipBox: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    backgroundColor: 'rgba(6, 182, 212, 0.08)',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(6, 182, 212, 0.15)',
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  nlpTipText: {
    fontSize: 12,
    color: colors.textSecondary,
    flex: 1,
  },
  listContent: {
    padding: 16,
    paddingBottom: 20,
  },
  bubbleWrapper: {
    marginBottom: 16,
    maxWidth: '85%',
  },
  bubbleWrapperLeft: {
    alignSelf: 'flex-start',
  },
  bubbleWrapperRight: {
    alignSelf: 'flex-end',
  },
  bubble: {
    borderRadius: 16,
    padding: 14,
    borderWidth: 1,
  },
  bubbleLeft: {
    backgroundColor: colors.surface,
    borderColor: colors.surfaceBorder,
  },
  bubbleRight: {
    backgroundColor: colors.surfaceElevated,
    borderColor: 'rgba(6, 182, 212, 0.3)',
  },
  bubbleHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 6,
    gap: 8,
  },
  senderName: {
    fontSize: 13,
    fontWeight: '700',
    color: colors.textPrimary,
  },
  badgeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  labPill: {
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 4,
  },
  labPillText: {
    color: colors.primary,
    fontSize: 11,
    fontWeight: '700',
  },
  bubbleMessage: {
    fontSize: 14,
    color: colors.textPrimary,
    lineHeight: 20,
    marginBottom: 10,
  },
  bubbleFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.06)',
    paddingTop: 8,
    gap: 8,
  },
  assignedTechText: {
    fontSize: 11,
    color: colors.textMuted,
  },
  inputArea: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: colors.surfaceElevated,
    borderTopWidth: 1,
    borderTopColor: colors.surfaceBorder,
    gap: 10,
  },
  chatInput: {
    flex: 1,
    backgroundColor: colors.inputBg,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: colors.inputBorder,
    paddingHorizontal: 14,
    paddingVertical: 10,
    color: colors.textPrimary,
    fontSize: 14,
    maxHeight: 90,
  },
  sendBtn: {
    width: 44,
    height: 44,
    borderRadius: 12,
    backgroundColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sendBtnDisabled: {
    opacity: 0.4,
  },
});
