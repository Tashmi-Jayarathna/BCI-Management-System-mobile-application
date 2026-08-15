import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../core/di/app_dependency_provider.dart';
import '../widgets/course_dialog.dart';
import '../widgets/course_detail_dialog.dart';
import '../widgets/common/app_snackbar.dart';
import '../widgets/common/confirm_delete_dialog.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/entity_list_card.dart';
import '../widgets/common/search_filter_bar.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDeptFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddCourseDialog() {
    final deps = AppDependencyProvider.of(context);

    showDialog(
      context: context,
      builder: (ctx) => CourseDialog(
        departments: deps.courseRepository.availableDepartments,
        onSave: (newCourse) {
          deps.managementService.addCourse(newCourse);
          setState(() {});
          AppSnackBar.success(
            context,
            'Course "${newCourse.title}" added successfully!',
          );
        },
      ),
    );
  }

  void _openEditCourseDialog(Course course) {
    final deps = AppDependencyProvider.of(context);

    showDialog(
      context: context,
      builder: (ctx) => CourseDialog(
        course: course,
        departments: deps.courseRepository.availableDepartments,
        onSave: (updatedCourse) {
          deps.managementService.updateCourse(updatedCourse);
          setState(() {});
          AppSnackBar.info(
            context,
            'Course "${updatedCourse.title}" updated successfully!',
          );
        },
      ),
    );
  }

  void _openCourseDetail(Course course) {
    showDialog(
      context: context,
      builder: (ctx) => CourseDetailDialog(
        course: course,
        onEdit: () => _openEditCourseDialog(course),
      ),
    );
  }

  void _confirmDeleteCourse(Course course) {
    final deps = AppDependencyProvider.of(context);

    ConfirmDeleteDialog.show(
      context,
      message:
          'Are you sure you want to delete course "${course.courseCode} - ${course.title}"?\n\nNote: All student enrollments for this course will also be removed.',
      onConfirm: () {
        deps.managementService.deleteCourse(course.id);
        setState(() {});
        AppSnackBar.error(context, 'Course "${course.courseCode}" deleted.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Open/Closed & Dependency Inversion: Perform course filtering via DIP strategy provider
    final deps = AppDependencyProvider.of(context);
    final allCourses = deps.courseRepository.getAllCourses();
    final filteredCourses = deps.courseSearchStrategy.filter(
      allCourses,
      _searchController.text,
      _selectedDeptFilter,
    );

    final availableDepts = deps.courseRepository.availableDepartments;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCourseDialog,
        icon: const Icon(Icons.add_to_photos),
        label: const Text('Add Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchFilterBar(
              searchController: _searchController,
              searchHint: 'Search by title, code, instructor...',
              onChanged: () => setState(() {}),
              selectedDepartment: _selectedDeptFilter,
              departments: availableDepts,
              onDepartmentChanged: (val) =>
                  setState(() => _selectedDeptFilter = val),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredCourses.length} of ${allCourses.length} Courses',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Expanded(
              child: filteredCourses.isEmpty
                  ? const EmptyState(
                      icon: Icons.library_books_outlined,
                      title: 'No course records found',
                      subtitle:
                          'Try adjusting your search query or department filter.',
                    )
                  : ListView.separated(
                      itemCount: filteredCourses.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final course = filteredCourses[i];
                        final enrolledStudentsCount = deps.enrollmentService
                            .getStudentsForCourse(course.id)
                            .length;

                        return EntityListCard(
                          onTap: () => _openCourseDetail(course),
                          leading: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              course.courseCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          title: course.title,
                          subtitleLine1:
                              '${course.department} • ${course.credits} Credits',
                          subtitleLine2: 'Instructor: ${course.instructor}',
                          badgeLabel: '$enrolledStudentsCount Enrolled',
                          badgeBackgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          onEdit: () => _openEditCourseDialog(course),
                          onDelete: () => _confirmDeleteCourse(course),
                          editTooltip: 'Edit Course',
                          deleteTooltip: 'Delete Course',
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
