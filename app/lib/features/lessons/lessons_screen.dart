import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildLessonItem(
            title: '1. Introduction to Science',
            description: 'Learn the scientific method and basic principles.',
            isCompleted: true,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildLessonItem(
            title: '2. The Solar System',
            description: 'Explore planets, stars, and orbits in our cosmic neighborhood.',
            isCompleted: false,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildLessonItem(
            title: '3. Plant Biology & Photosynthesis',
            description: 'Understand how plants produce energy and oxygen.',
            isCompleted: false,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildLessonItem(
            title: '4. Basic Mathematics: Fractions',
            description: 'Master fraction additions, subtractions, and division.',
            isCompleted: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem({
    required String title,
    required String description,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success.withOpacity(0.1)
                : AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
