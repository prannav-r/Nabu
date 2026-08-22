class StudentProfile {
  final String id;
  final String name;
  final String createdAt;
  final String syncStatus; // 'pending', 'syncing', 'synced'

  const StudentProfile({
    required this.id,
    required this.name,
    required this.createdAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'sync_status': syncStatus,
    };
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: map['created_at'] as String,
      syncStatus: (map['sync_status'] as String?) ?? 'synced',
    );
  }

  StudentProfile copyWith({
    String? id,
    String? name,
    String? createdAt,
    String? syncStatus,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
