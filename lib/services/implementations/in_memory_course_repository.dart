import '../../models/course_model.dart';
import '../interfaces/course_repository_interface.dart';
import '../seed/default_data_seeder.dart';

/// Single Responsibility & Liskov Substitution Principle: In-Memory Course Repository implementation.
class InMemoryCourseRepository implements ICourseRepository {
  final List<Course> _courses = [];

  InMemoryCourseRepository({IDataSeeder? seeder}) {
    final initialData = seeder?.seedCourses() ?? DefaultDataSeeder().seedCourses();
    _courses.addAll(initialData);
  }

  @override
  List<String> get availableDepartments => [
        'All',
        'Computer Science',
        'Business Administration',
        'Information Technology',
        'Data Science',
        'Software Engineering',
      ];

  @override
  List<Course> getAllCourses() {
    return List.unmodifiable(_courses);
  }

  @override
  Course? getCourseById(String id) {
    try {
      return _courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Course> getCoursesForDepartment(String department) {
    if (department == 'All' || department.isEmpty) return getAllCourses();
    return _courses.where((c) => c.department == department).toList();
  }

  @override
  int get totalCourses => _courses.length;

  @override
  void addCourse(Course course) {
    _courses.add(course);
  }

  @override
  void updateCourse(Course course) {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
    }
  }

  @override
  void deleteCourse(String courseId) {
    _courses.removeWhere((c) => c.id == courseId);
  }
}
