import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../core/di/app_dependency_provider.dart';
import 'common/form_dialog_shell.dart';
import 'common/form_submit_helper.dart';

class StudentDialog extends StatefulWidget {
  final Student? student;
  final List<String> departments;
  final Function(Student) onSave;

  const StudentDialog({
    super.key,
    this.student,
    required this.departments,
    required this.onSave,
  });

  @override
  State<StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<StudentDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _studentIdController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _yearController;
  late String _selectedDepartment;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.student != null;
    _studentIdController = TextEditingController(
      text: isEditing
          ? widget.student!.studentId
          : 'BCI-2026-00${DateTime.now().millisecond % 100}',
    );
    _nameController = TextEditingController(
      text: isEditing ? widget.student!.name : '',
    );
    _emailController = TextEditingController(
      text: isEditing ? widget.student!.email : '',
    );
    _phoneController = TextEditingController(
      text: isEditing ? widget.student!.phone : '',
    );
    _yearController = TextEditingController(
      text: isEditing ? widget.student!.enrollmentYear : '2026',
    );

    final validDepts = widget.departments.where((d) => d != 'All').toList();
    _selectedDepartment =
        isEditing && validDepts.contains(widget.student!.department)
        ? widget.student!.department
        : (validDepts.isNotEmpty ? validDepts.first : 'Computer Science');
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submit() {
    // Single Responsibility & Dependency Inversion: Delegate domain validation to StudentValidator
    submitValidatedForm<Student>(
      context,
      formKey: _formKey,
      buildModel: () => Student(
        id:
            widget.student?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: _studentIdController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        department: _selectedDepartment,
        enrollmentYear: _yearController.text.trim(),
        enrolledCourseIds: widget.student?.enrolledCourseIds ?? [],
      ),
      validator: AppDependencyProvider.of(context).studentValidator,
      onSave: widget.onSave,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    final validDepts = widget.departments.where((d) => d != 'All').toList();

    return FormDialogShell(
      icon: isEditing ? Icons.edit_note : Icons.person_add,
      title: isEditing ? 'Edit Student Record' : 'Add New Student',
      formKey: _formKey,
      onSubmit: _submit,
      submitLabel: isEditing ? 'Save Changes' : 'Add Student',
      fields: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _studentIdController,
            decoration: const InputDecoration(
              labelText: 'Student ID',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Student ID is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Full Name is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Phone number is required'
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedDepartment,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items: validDepts.map((d) {
              return DropdownMenuItem(
                value: d,
                child: Text(d, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedDepartment = val);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enrollment Year',
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Year is required';
              if (int.tryParse(v.trim()) == null) return 'Must be a valid year';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
