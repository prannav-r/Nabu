class StudentProgress {
  final String id;
  final String studentId;
  final int lessonsCompleted;
  final int totalLessons;
  final int quizzesCompleted;
  final double averageScore;
  final String updatedAt;
  final String syncStatus;

  const StudentProgress({
    required this.id,
    required this.studentId,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.quizzesCompleted,
    required this.averageScore,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'lessons_completed': lessonsCompleted,
      'total_lessons': totalLessons,
      'quizzes_completed': quizzesCompleted,
      'average_score': averageScore,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
    };
  }

  factory StudentProgress.fromMap(Map<String, dynamic> map) {
    return StudentProgress(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      lessonsCompleted: (map['lessons_completed'] as num).toInt(),
      totalLessons: (map['total_lessons'] as num).toInt(),
      quizzesCompleted: (map['quizzes_completed'] as num).toInt(),
      averageScore: (map['average_score'] as num).toDouble(),
      updatedAt: map['updated_at'] as String,
      syncStatus: (map['sync_status'] as String?) ?? 'pending',
    );
  }

  StudentProgress copyWith({
    String? id,
    String? studentId,
    int? lessonsCompleted,
    int? totalLessons,
    int? quizzesCompleted,
    double? averageScore,
    String? updatedAt,
    String? syncStatus,
  }) {
    return StudentProgress(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      totalLessons: totalLessons ?? this.totalLessons,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      averageScore: averageScore ?? this.averageScore,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
