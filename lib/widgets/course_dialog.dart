import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../core/di/app_dependency_provider.dart';

class CourseDialog extends StatefulWidget {
  final Course? course;
  final List<String> departments;
  final Function(Course) onSave;

  const CourseDialog({
    super.key,
    this.course,
    required this.departments,
    required this.onSave,
  });

  @override
  State<CourseDialog> createState() => _CourseDialogState();
}

class _CourseDialogState extends State<CourseDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _titleController;
  late TextEditingController _creditsController;
  late TextEditingController _instructorController;
  late TextEditingController _descriptionController;
  late String _selectedDepartment;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.course != null;
    _codeController = TextEditingController(text: isEditing ? widget.course!.courseCode : 'CS102');
    _titleController = TextEditingController(text: isEditing ? widget.course!.title : '');
    _creditsController = TextEditingController(text: isEditing ? widget.course!.credits.toString() : '3');
    _instructorController = TextEditingController(text: isEditing ? widget.course!.instructor : '');
    _descriptionController = TextEditingController(text: isEditing ? widget.course!.description : '');

    final validDepts = widget.departments.where((d) => d != 'All').toList();
    _selectedDepartment = isEditing && validDepts.contains(widget.course!.department)
        ? widget.course!.department
        : (validDepts.isNotEmpty ? validDepts.first : 'Computer Science');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    _instructorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final course = Course(
        id: widget.course?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        courseCode: _codeController.text.trim(),
        title: _titleController.text.trim(),
        credits: int.parse(_creditsController.text.trim()),
        department: _selectedDepartment,
        instructor: _instructorController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      // Single Responsibility & Dependency Inversion: Delegate validation to CourseValidator
      final validator = AppDependencyProvider.of(context).courseValidator;
      final validationResult = validator.validate(course);

      if (!validationResult.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationResult.errors.join('\n')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      widget.onSave(course);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;
    final validDepts = widget.departments.where((d) => d != 'All').toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 400;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit_calendar : Icons.add_to_photos,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEditing ? 'Edit Course Record' : 'Add New Course',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Container(
          width: screenWidth * 0.85,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Course Code',
                    prefixIcon: Icon(Icons.code),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Course code is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Course Title',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Course title is required' : null,
                ),
                const SizedBox(height: 12),
                if (isNarrow) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.domain_outlined),
                    ),
                    items: validDepts.map((d) {
                      return DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDepartment = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _creditsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Credits',
                      prefixIcon: Icon(Icons.star_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final num = int.tryParse(v.trim());
                      if (num == null || num <= 0 || num > 12) return '1-12';
                      return null;
                    },
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedDepartment,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            prefixIcon: Icon(Icons.domain_outlined),
                          ),
                          items: validDepts.map((d) {
                            return DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDepartment = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _creditsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Credits',
                            prefixIcon: Icon(Icons.star_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final num = int.tryParse(v.trim());
                            if (num == null || num <= 0 || num > 12) return '1-12';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _instructorController,
                  decoration: const InputDecoration(
                    labelText: 'Instructor Name',
                    prefixIcon: Icon(Icons.person_pin_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Instructor is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save Changes' : 'Add Course'),
        ),
      ],
    );
  }
}
