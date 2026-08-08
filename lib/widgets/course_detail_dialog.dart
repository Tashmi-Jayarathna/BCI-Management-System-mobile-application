import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../core/di/app_dependency_provider.dart';

class CourseDetailDialog extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;

  const CourseDetailDialog({
    super.key,
    required this.course,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencyProvider.of(context);
    final currentCourse = deps.courseRepository.getCourseById(course.id) ?? course;
    final enrolledStudents = deps.enrollmentService.getStudentsForCourse(currentCourse.id);

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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    currentCourse.courseCode,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentCourse.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${currentCourse.department} • ${currentCourse.credits} Credits',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
                  tooltip: 'Edit Course',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Course Info Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.teal),
                      const SizedBox(width: 8),
                      const Text('Instructor: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(currentCourse.instructor, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  if (currentCourse.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      currentCourse.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Enrolled Students list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enrolled Students (${enrolledStudents.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('${enrolledStudents.length} Active'),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Enrolled students list
            Expanded(
              child: enrolledStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No students enrolled yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: enrolledStudents.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final student = enrolledStudents[i];
                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 1,
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              child: Text(student.name[0].toUpperCase(), style: const TextStyle(fontSize: 12)),
                            ),
                            title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${student.studentId} • ${student.department}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent),
                              tooltip: 'Remove from course',
                              onPressed: () {
                                final deps = AppDependencyProvider.of(context);
                                deps.managementService.unEnrolStudentFromCourse(student.id, currentCourse.id);
                                (context as Element).markNeedsBuild();
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
