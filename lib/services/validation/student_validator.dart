import '../../models/student_model.dart';
import 'validator_interface.dart';

/// Single Responsibility Principle: Student model validator.
class StudentValidator implements IValidator<Student> {
  @override
  ValidationResult validate(Student student) {
    final errors = <String>[];

    if (student.name.trim().isEmpty) {
      errors.add('Student name is required.');
    }

    if (student.studentId.trim().isEmpty) {
      errors.add('Student ID is required.');
    }

    if (student.email.trim().isEmpty) {
      errors.add('Email address is required.');
    } else if (!_isValidEmail(student.email.trim())) {
      errors.add('Please enter a valid email address.');
    }

    if (student.department.trim().isEmpty || student.department == 'All') {
      errors.add('Please select a valid academic department.');
    }

    if (student.enrollmentYear.trim().isEmpty) {
      errors.add('Enrollment year is required.');
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
