import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../core/di/app_dependency_provider.dart';
import '../widgets/course_dialog.dart';
import '../widgets/course_detail_dialog.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Course "${newCourse.title}" added successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green.shade700,
            ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Course "${updatedCourse.title}" updated successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.blue.shade700,
            ),
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirm Deletion'),
          ],
        ),
        content: Text('Are you sure you want to delete course "${course.courseCode} - ${course.title}"?\n\nNote: All student enrollments for this course will also be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              deps.managementService.deleteCourse(course.id);
              setState(() {});
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Course "${course.courseCode}" deleted.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red.shade700,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
    final isNarrow = MediaQuery.of(context).size.width < 450;

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
            if (isNarrow) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by title, code, instructor...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDeptFilter,
                    isExpanded: true,
                    icon: const Icon(Icons.filter_list),
                    items: availableDepts.map((dept) {
                      return DropdownMenuItem(
                        value: dept,
                        child: Text(dept == 'All' ? 'All Departments' : dept),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDeptFilter = val);
                    },
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by title, code, instructor...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDeptFilter,
                        icon: const Icon(Icons.filter_list),
                        items: availableDepts.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept == 'All' ? 'All Depts' : dept),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDeptFilter = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No course records found',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try adjusting your search query or department filter.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredCourses.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final course = filteredCourses[i];
                        final enrolledStudentsCount = deps.enrollmentService.getStudentsForCourse(course.id).length;

                        return Card(
                          child: InkWell(
                            onTap: () => _openCourseDetail(course),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      course.courseCode,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${course.department} • ${course.credits} Credits',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Instructor: ${course.instructor}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Chip(
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        label: Text(
                                          '$enrolledStudentsCount Enrolled',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                            onPressed: () => _openEditCourseDialog(course),
                                            tooltip: 'Edit Course',
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                            onPressed: () => _confirmDeleteCourse(course),
                                            tooltip: 'Delete Course',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
