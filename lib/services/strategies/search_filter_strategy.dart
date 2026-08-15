import '../../core/constants/departments.dart';
import '../../models/student_model.dart';
import '../../models/course_model.dart';

/// Open/Closed Principle: Strategy interface for searching and filtering collections.
abstract class ISearchFilterStrategy<T> {
  List<T> filter(List<T> items, String query, String departmentFilter);
}

/// Strategy implementation for filtering Student records.
class StudentSearchStrategy implements ISearchFilterStrategy<Student> {
  @override
  List<Student> filter(
    List<Student> items,
    String query,
    String departmentFilter,
  ) {
    final cleanQuery = query.trim().toLowerCase();
    return items.where((s) {
      final matchesQuery =
          cleanQuery.isEmpty ||
          s.name.toLowerCase().contains(cleanQuery) ||
          s.studentId.toLowerCase().contains(cleanQuery) ||
          s.email.toLowerCase().contains(cleanQuery);

      final matchesDept = Departments.matches(s.department, departmentFilter);

      return matchesQuery && matchesDept;
    }).toList();
  }
}

/// Strategy implementation for filtering Course records.
class CourseSearchStrategy implements ISearchFilterStrategy<Course> {
  @override
  List<Course> filter(
    List<Course> items,
    String query,
    String departmentFilter,
  ) {
    final cleanQuery = query.trim().toLowerCase();
    return items.where((c) {
      final matchesQuery =
          cleanQuery.isEmpty ||
          c.title.toLowerCase().contains(cleanQuery) ||
          c.courseCode.toLowerCase().contains(cleanQuery) ||
          c.instructor.toLowerCase().contains(cleanQuery);

      final matchesDept = Departments.matches(c.department, departmentFilter);

      return matchesQuery && matchesDept;
    }).toList();
  }
}
