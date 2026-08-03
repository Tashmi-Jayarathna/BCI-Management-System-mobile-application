import '../../models/student_model.dart';

/// Interface Segregation Principle (ISP): Granular read-only student contract.
abstract class IStudentReader {
  List<Student> getAllStudents();
  Student? getStudentById(String id);
  List<Student> getStudentsForDepartment(String department);
  int get totalStudents;
}

/// Interface Segregation Principle (ISP): Granular write-only student contract.
abstract class IStudentWriter {
  void addStudent(Student student);
  void updateStudent(Student student);
  void deleteStudent(String studentId);
}

/// Open/Closed & Dependency Inversion Principle: Combined Student Repository interface.
abstract class IStudentRepository implements IStudentReader, IStudentWriter {
  List<String> get availableDepartments;
}
