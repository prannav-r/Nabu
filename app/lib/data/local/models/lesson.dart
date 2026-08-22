class Lesson {
  final String id;
  final String title;
  final String description;
  final String content;
  final int orderIndex;
  final bool isCompleted;
  final String updatedAt;
  final String syncStatus;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.orderIndex,
    this.isCompleted = false,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'order_index': orderIndex,
      'is_completed': isCompleted ? 1 : 0,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      content: map['content'] as String,
      orderIndex: (map['order_index'] as num).toInt(),
      isCompleted: (map['is_completed'] as int) == 1,
      updatedAt: map['updated_at'] as String,
      syncStatus: (map['sync_status'] as String?) ?? 'synced',
    );
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    int? orderIndex,
    bool? isCompleted,
    String? updatedAt,
    String? syncStatus,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      orderIndex: orderIndex ?? this.orderIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
