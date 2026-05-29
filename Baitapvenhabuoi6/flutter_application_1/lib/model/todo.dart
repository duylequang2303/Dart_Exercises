class Todo {
  final int? id;
  final String title;
  final String content;
  final bool isDone;

  Todo({
    this.id,
    required this.title,
    required this.content,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: (map['id'] as num?)?.toInt(),
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      isDone: map['isDone'] == 1,
    );
  }

  // Tạo bản copy với 1 field thay đổi
  Todo copyWith({int? id, String? title, String? content, bool? isDone}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isDone: isDone ?? this.isDone,
    );
  }
}