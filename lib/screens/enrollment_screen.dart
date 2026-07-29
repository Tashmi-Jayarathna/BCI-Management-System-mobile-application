import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/course_model.dart';
import '../services/bci_repository.dart';

class EnrollmentScreen extends StatefulWidget {
  final BCIRepository repository;

  const EnrollmentScreen({super.key, required this.repository});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  String? _selectedStudentId;
  final TextEditingController _studentSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.repository.students.isNotEmpty) {
      _selectedStudentId = widget.repository.students.first.id;
    }
  }

  @override
  void dispose() {
    _studentSearchController.dispose();
    super.dispose();
  }

  void _showBatchEnrollmentModal(Student student) {
    final enrolledIds = List<String>.from(student.enrolledCourseIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Text(student.name[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enrol Courses for ${student.name}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'ID: ${student.studentId} • Dept: ${student.department}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Courses (${widget.repository.courses.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${enrolledIds.length} Selected',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: widget.repository.courses.isEmpty
                        ? const Center(child: Text('No courses available in the system'))
                        : ListView.separated(
                            itemCount: widget.repository.courses.length,
                            separatorBuilder: (c, i) => const SizedBox(height: 8),
                            itemBuilder: (c, i) {
                              final course = widget.repository.courses[i];
                              final isEnrolled = enrolledIds.contains(course.id);

                              return Card(
                                color: isEnrolled ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
                                margin: EdgeInsets.zero,
                                elevation: isEnrolled ? 2 : 1,
                                child: CheckboxListTile(
                                  value: isEnrolled,
                                  title: Text(
                                    '${course.courseCode} - ${course.title}',
                                    style: TextStyle(
                                      fontWeight: isEnrolled ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${course.credits} Credits • Instructor: ${course.instructor}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  onChanged: (bool? checked) {
                                    setModalState(() {
                                      if (checked == true) {
                                        enrolledIds.add(course.id);
                                      } else {
                                        enrolledIds.remove(course.id);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.repository.updateStudentEnrollments(student.id, enrolledIds);
                            Navigator.of(ctx).pop();
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Enrollment updated for ${student.name}!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                          },
                          child: const Text('Save Enrollment'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = widget.repository.students;

    if (_selectedStudentId != null && !students.any((s) => s.id == _selectedStudentId)) {
      _selectedStudentId = students.isNotEmpty ? students.first.id : null;
    }

    final selectedStudent = _selectedStudentId != null
        ? widget.repository.getStudentById(_selectedStudentId!)
        : null;

    final enrolledCourses = selectedStudent != null
        ? widget.repository.getCoursesForStudent(selectedStudent.id)
        : <Course>[];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.how_to_reg, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Select Student for Enrollment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (students.isEmpty)
                      const Text('No students available. Please add students first.')
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStudentId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Choose Student',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: students.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(
                              '${s.name} (${s.studentId}) - ${s.department}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedStudentId = val;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (selectedStudent != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enrolled Courses for ${selectedStudent.name}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Total Assigned: ${enrolledCourses.length} Courses',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showBatchEnrollmentModal(selectedStudent),
                        icon: const Icon(Icons.edit_calendar),
                        label: const Text('Manage Courses'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: enrolledCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No courses currently assigned to ${selectedStudent.name}.',
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showBatchEnrollmentModal(selectedStudent),
                              icon: const Icon(Icons.add),
                              label: const Text('Enrol in Courses Now'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: enrolledCourses.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final course = enrolledCourses[i];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  course.courseCode,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${course.credits} Credits • Dept: ${course.department} • Instructor: ${course.instructor}'),
                              trailing: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                icon: const Icon(Icons.remove_circle_outline, size: 18),
                                label: const Text('Un-enrol'),
                                onPressed: () {
                                  widget.repository.unEnrolStudentFromCourse(selectedStudent.id, course.id);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Un-enrolled ${selectedStudent.name} from ${course.courseCode}'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.orange.shade700,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text('Please select or add a student to manage course enrollments.'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
