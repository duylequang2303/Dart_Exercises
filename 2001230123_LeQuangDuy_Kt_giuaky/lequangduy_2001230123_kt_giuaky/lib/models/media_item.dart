
/// Model lưu thông tin media (image/video)
class MediaItemModel {
  final int? id; // id trong DB
  final String mediaId; // khóa định danh dạng string (uuid)
  final String url; // đường dẫn file hoặc URL
  final String type; // 'image' or 'video'
  final String? thumbnail; // url path cho thumbnail (có thể giống url)
  final DateTime createdAt;

  MediaItemModel({
    this.id,
    required this.mediaId,
    required this.url,
    required this.type,
    this.thumbnail,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MediaItemModel.fromMap(Map<String, dynamic> map) {
    return MediaItemModel(
      id: map['id'] as int?,
      mediaId: map['media_id'] as String,
      url: map['url'] as String,
      type: map['type'] as String,
      thumbnail: map['thumbnail'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'media_id': mediaId,
      'url': url,
      'type': type,
      'thumbnail': thumbnail,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
