import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../core/di/app_dependency_provider.dart';
import '../widgets/student_dialog.dart';
import '../widgets/student_detail_dialog.dart';
import '../widgets/common/app_snackbar.dart';
import '../widgets/common/confirm_delete_dialog.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/entity_list_card.dart';
import '../widgets/common/search_filter_bar.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDeptFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddStudentDialog() {
    final deps = AppDependencyProvider.of(context);

    showDialog(
      context: context,
      builder: (ctx) => StudentDialog(
        departments: deps.studentRepository.availableDepartments,
        onSave: (newStudent) {
          deps.managementService.addStudent(newStudent);
          setState(() {});
          AppSnackBar.success(
            context,
            'Student "${newStudent.name}" added successfully!',
          );
        },
      ),
    );
  }

  void _openEditStudentDialog(Student student) {
    final deps = AppDependencyProvider.of(context);

    showDialog(
      context: context,
      builder: (ctx) => StudentDialog(
        student: student,
        departments: deps.studentRepository.availableDepartments,
        onSave: (updatedStudent) {
          deps.managementService.updateStudent(updatedStudent);
          setState(() {});
          AppSnackBar.info(
            context,
            'Student "${updatedStudent.name}" updated successfully!',
          );
        },
      ),
    );
  }

  void _openStudentDetail(Student student) {
    showDialog(
      context: context,
      builder: (ctx) => StudentDetailDialog(
        student: student,
        onEdit: () => _openEditStudentDialog(student),
      ),
    );
  }

  void _confirmDeleteStudent(Student student) {
    final deps = AppDependencyProvider.of(context);

    ConfirmDeleteDialog.show(
      context,
      message:
          'Are you sure you want to delete student record for "${student.name}" (${student.studentId})?',
      onConfirm: () {
        deps.managementService.deleteStudent(student.id);
        setState(() {});
        AppSnackBar.error(context, 'Student "${student.name}" deleted.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Open/Closed & Dependency Inversion: Perform filtering via DIP strategy provider
    final deps = AppDependencyProvider.of(context);
    final allStudents = deps.studentRepository.getAllStudents();
    final filteredStudents = deps.studentSearchStrategy.filter(
      allStudents,
      _searchController.text,
      _selectedDeptFilter,
    );

    final availableDepts = deps.studentRepository.availableDepartments;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddStudentDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchFilterBar(
              searchController: _searchController,
              searchHint: 'Search by name, ID, or email...',
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
                  'Showing ${filteredStudents.length} of ${allStudents.length} Students',
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
              child: filteredStudents.isEmpty
                  ? const EmptyState(
                      icon: Icons.person_search,
                      title: 'No student records found',
                      subtitle:
                          'Try adjusting your search query or department filter.',
                    )
                  : ListView.separated(
                      itemCount: filteredStudents.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final student = filteredStudents[i];
                        final enrolledCount = student.enrolledCourseIds.length;

                        return EntityListCard(
                          onTap: () => _openStudentDetail(student),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Text(
                              student.name.isNotEmpty
                                  ? student.name[0].toUpperCase()
                                  : 'S',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: student.name,
                          subtitleLine1:
                              '${student.studentId} • ${student.department}',
                          subtitleLine2: student.email,
                          badgeLabel: '$enrolledCount Courses',
                          badgeBackgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          onEdit: () => _openEditStudentDialog(student),
                          onDelete: () => _confirmDeleteStudent(student),
                          editTooltip: 'Edit Student',
                          deleteTooltip: 'Delete Student',
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
