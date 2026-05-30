// Model `Note` đại diện cho một ghi chú liên quan tới media (ảnh/video).
// Trường `createdAt` được lưu dưới dạng millisecondsSinceEpoch khi ghi vào SQLite.

class Note {
  final int? id;
  final String title;
  final String? content;
  final String mediaId;
  final DateTime createdAt;

  Note({
    this.id,
    required this.title,
    this.content,
    required this.mediaId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Chuyển từ Map (từ SQLite) thành Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String?,
      mediaId: map['media_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Chuyển Note thành Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'media_id': mediaId,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
