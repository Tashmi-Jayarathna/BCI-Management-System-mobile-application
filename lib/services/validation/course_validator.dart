import '../../models/course_model.dart';
import 'validator_interface.dart';

/// Single Responsibility Principle: Course model validator.
class CourseValidator implements IValidator<Course> {
  @override
  ValidationResult validate(Course course) {
    final errors = <String>[];

    if (course.courseCode.trim().isEmpty) {
      errors.add('Course code is required.');
    }

    if (course.title.trim().isEmpty) {
      errors.add('Course title is required.');
    }

    if (course.credits <= 0 || course.credits > 6) {
      errors.add('Credits must be between 1 and 6.');
    }

    if (course.department.trim().isEmpty || course.department == 'All') {
      errors.add('Please select a valid department.');
    }

    if (course.instructor.trim().isEmpty) {
      errors.add('Instructor name is required.');
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}
