import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../core/di/app_dependency_provider.dart';
import 'common/empty_state.dart';
import 'common/removable_list_tile_card.dart';

class StudentDetailDialog extends StatelessWidget {
  final Student student;
  final VoidCallback onEdit;

  const StudentDetailDialog({
    super.key,
    required this.student,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencyProvider.of(context);
    final currentStudent =
        deps.studentRepository.getStudentById(student.id) ?? student;
    final enrolledCourses = deps.enrollmentService.getCoursesForStudent(
      currentStudent.id,
    );

    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: screenWidth * 0.9,
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar & Name
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text(
                    currentStudent.name.isNotEmpty
                        ? currentStudent.name[0].toUpperCase()
                        : 'S',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStudent.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${currentStudent.studentId} • ${currentStudent.department}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onEdit();
                  },
                  tooltip: 'Edit Student',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Profile info grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.email_outlined, 'Email', currentStudent.email),
                  const SizedBox(height: 8),
                  _infoRow(Icons.phone_outlined, 'Phone', currentStudent.phone),
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.calendar_today_outlined,
                    'Enrollment Year',
                    currentStudent.enrollmentYear,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Enrolled courses header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned Courses (${enrolledCourses.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${enrolledCourses.length} Enrolled'),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Enrolled courses list
            Expanded(
              child: enrolledCourses.isEmpty
                  ? const EmptyState(
                      icon: Icons.menu_book,
                      iconSize: 40,
                      iconSpacing: 8,
                      titleFontSize: 14,
                      title: 'No courses currently assigned',
                    )
                  : ListView.separated(
                      itemCount: enrolledCourses.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final course = enrolledCourses[i];
                        return RemovableListTileCard(
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.courseCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          title: course.title,
                          subtitle:
                              '${course.credits} Credits • ${course.instructor}',
                          trailingIcon: Icons.remove_circle_outline,
                          trailingTooltip: 'Un-enrol from course',
                          onRemove: () {
                            final deps = AppDependencyProvider.of(context);
                            deps.managementService.unEnrolStudentFromCourse(
                              currentStudent.id,
                              course.id,
                            );
                            (context as Element).markNeedsBuild();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.indigo.shade700),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
