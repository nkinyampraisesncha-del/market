class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String receiverId;
  final String content;
  final String messageType;
  final bool isRead;
  final String? attachmentUrl;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.receiverId,
    required this.content,
    this.messageType = 'text',
    this.isRead = false,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String? ?? 'Unknown',
      senderImageUrl: json['sender_image_url'] as String?,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      isRead: json['is_read'] as bool? ?? false,
      attachmentUrl: json['attachment_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_image_url': senderImageUrl,
      'receiver_id': receiverId,
      'content': content,
      'message_type': messageType,
      'is_read': isRead,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderImageUrl,
    String? receiverId,
    String? content,
    String? messageType,
    bool? isRead,
    String? attachmentUrl,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isTextMessage => messageType == 'text';
  bool get isImageMessage => messageType == 'image';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MessageModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ConversationModel {
  final String id;
  final List<String> participantIds;
  final List<String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String? productId;
  final String? productTitle;
  final String? productImageUrl;

  const ConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.productId,
    this.productTitle,
    this.productImageUrl,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participantIds: (json['participant_ids'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      participantNames: (json['participant_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      productId: json['product_id'] as String?,
      productTitle: json['product_title'] as String?,
      productImageUrl: json['product_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'participant_names': participantNames,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
      'product_id': productId,
      'product_title': productTitle,
      'product_image_url': productImageUrl,
    };
  }

  String otherParticipantName(String currentUserId) {
    final idx = participantIds.indexOf(currentUserId);
    if (idx == -1 || participantNames.isEmpty) return 'Unknown';
    final otherIdx = idx == 0 ? 1 : 0;
    if (otherIdx >= participantNames.length) return 'Unknown';
    return participantNames[otherIdx];
  }
}
