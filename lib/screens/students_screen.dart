import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/bci_repository.dart';
import '../widgets/student_dialog.dart';
import '../widgets/student_detail_dialog.dart';

class StudentsScreen extends StatefulWidget {
  final BCIRepository repository;

  const StudentsScreen({super.key, required this.repository});

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
    showDialog(
      context: context,
      builder: (ctx) => StudentDialog(
        departments: widget.repository.availableDepartments,
        onSave: (newStudent) {
          widget.repository.addStudent(newStudent);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Student "${newStudent.name}" added successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green.shade700,
            ),
          );
        },
      ),
    );
  }

  void _openEditStudentDialog(Student student) {
    showDialog(
      context: context,
      builder: (ctx) => StudentDialog(
        student: student,
        departments: widget.repository.availableDepartments,
        onSave: (updatedStudent) {
          widget.repository.updateStudent(updatedStudent);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Student "${updatedStudent.name}" updated successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.blue.shade700,
            ),
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
        repository: widget.repository,
        onEdit: () => _openEditStudentDialog(student),
      ),
    );
  }

  void _confirmDeleteStudent(Student student) {
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
        content: Text('Are you sure you want to delete student record for "${student.name}" (${student.studentId})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              widget.repository.deleteStudent(student.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Student "${student.name}" deleted.'),
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
    final filteredStudents = widget.repository.searchStudents(
      _searchController.text,
      _selectedDeptFilter,
    );

    final isNarrow = MediaQuery.of(context).size.width < 450;

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
            // Responsive Search Bar & Department Filter
            if (isNarrow) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, or email...',
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
                    items: widget.repository.availableDepartments.map((dept) {
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
                        hintText: 'Search by name, ID, or email...',
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
                        items: widget.repository.availableDepartments.map((dept) {
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

            // Student Count Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredStudents.length} of ${widget.repository.totalStudents} Students',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Student List
            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No student records found',
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
                      itemCount: filteredStudents.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final student = filteredStudents[i];
                        final enrolledCount = student.enrolledCourseIds.length;

                        return Card(
                          child: InkWell(
                            onTap: () => _openStudentDetail(student),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: Text(
                                      student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
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
                                          student.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${student.studentId} • ${student.department}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          student.email,
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
                                          '$enrolledCount Courses',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                            onPressed: () => _openEditStudentDialog(student),
                                            tooltip: 'Edit Student',
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                            onPressed: () => _confirmDeleteStudent(student),
                                            tooltip: 'Delete Student',
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
