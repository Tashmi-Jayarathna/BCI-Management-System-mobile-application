import '../../models/student_model.dart';
import '../interfaces/student_repository_interface.dart';
import '../seed/default_data_seeder.dart';

/// Single Responsibility & Liskov Substitution Principle: In-Memory Student Repository implementation.
class InMemoryStudentRepository implements IStudentRepository {
  final List<Student> _students = [];

  InMemoryStudentRepository({IDataSeeder? seeder}) {
    final initialData = seeder?.seedStudents() ?? DefaultDataSeeder().seedStudents();
    _students.addAll(initialData);
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
  List<Student> getAllStudents() {
    return List.unmodifiable(_students);
  }

  @override
  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Student> getStudentsForDepartment(String department) {
    if (department == 'All' || department.isEmpty) return getAllStudents();
    return _students.where((s) => s.department == department).toList();
  }

  @override
  int get totalStudents => _students.length;

  @override
  void addStudent(Student student) {
    _students.add(student);
  }

  @override
  void updateStudent(Student student) {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
    }
  }

  @override
  void deleteStudent(String studentId) {
    _students.removeWhere((s) => s.id == studentId);
  }
}
