import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/services/bci_repository.dart';
import 'package:flutter_application_1/models/student_model.dart';
import 'package:flutter_application_1/models/course_model.dart';
import 'package:flutter_application_1/services/implementations/in_memory_student_repository.dart';
import 'package:flutter_application_1/services/implementations/in_memory_course_repository.dart';
import 'package:flutter_application_1/services/implementations/enrollment_service.dart';
import 'package:flutter_application_1/services/implementations/dashboard_analytics_service.dart';
import 'package:flutter_application_1/services/validation/student_validator.dart';
import 'package:flutter_application_1/services/validation/course_validator.dart';
import 'package:flutter_application_1/services/strategies/search_filter_strategy.dart';

void main() {
  group('SOLID Principles Unit Tests', () {
    late InMemoryStudentRepository studentRepo;
    late InMemoryCourseRepository courseRepo;
    late EnrollmentService enrollmentService;
    late DashboardAnalyticsService analyticsService;
    late StudentValidator studentValidator;
    late CourseValidator courseValidator;

    setUp(() {
      studentRepo = InMemoryStudentRepository();
      courseRepo = InMemoryCourseRepository();
      enrollmentService = EnrollmentService(
        studentRepo: studentRepo,
        courseRepo: courseRepo,
      );
      analyticsService = DashboardAnalyticsService(
        studentRepo: studentRepo,
        courseRepo: courseRepo,
        enrollmentService: enrollmentService,
      );
      studentValidator = StudentValidator();
      courseValidator = CourseValidator();
    });

    test('Single Responsibility (SRP): StudentRepository handles only student operations', () {
      expect(studentRepo.totalStudents, greaterThanOrEqualTo(4));
      final newStudent = Student(
        id: 's_test_1',
        studentId: 'BCI-TEST-001',
        name: 'John SOLID',
        email: 'john@bci.edu',
        phone: '1234567890',
        department: 'Software Engineering',
        enrollmentYear: '2026',
      );
      studentRepo.addStudent(newStudent);
      expect(studentRepo.getStudentById('s_test_1')?.name, 'John SOLID');
    });

    test('Single Responsibility (SRP): CourseRepository handles only course operations', () {
      expect(courseRepo.totalCourses, greaterThanOrEqualTo(5));
      final newCourse = Course(
        id: 'c_test_1',
        courseCode: 'SOLID101',
        title: 'SOLID Design Patterns',
        credits: 4,
        department: 'Software Engineering',
        instructor: 'Dr. Martin',
        description: 'Clean Code Principles',
      );
      courseRepo.addCourse(newCourse);
      expect(courseRepo.getCourseById('c_test_1')?.title, 'SOLID Design Patterns');
    });

    test('Single Responsibility (SRP): StudentValidator & CourseValidator validate models correctly', () {
      final invalidStudent = Student(
        id: 'inv_1',
        studentId: '',
        name: '',
        email: 'invalid-email',
        phone: '',
        department: '',
        enrollmentYear: '',
      );
      final studentResult = studentValidator.validate(invalidStudent);
      expect(studentResult.isValid, isFalse);
      expect(studentResult.errors, hasLength(greaterThan(0)));

      final validCourse = Course(
        id: 'c_valid',
        courseCode: 'CS102',
        title: 'OOP in Dart',
        credits: 3,
        department: 'Computer Science',
        instructor: 'Prof. Alice',
        description: 'Object-oriented programming',
      );
      final courseResult = courseValidator.validate(validCourse);
      expect(courseResult.isValid, isTrue);
    });

    test('Open/Closed (OCP): Search strategies filter records flexibly', () {
      final studentStrategy = StudentSearchStrategy();
      final courseStrategy = CourseSearchStrategy();

      final students = studentRepo.getAllStudents();
      final courses = courseRepo.getAllCourses();

      final filteredStudents = studentStrategy.filter(students, 'Hasanthi', 'All');
      expect(filteredStudents.length, 1);

      final filteredCourses = courseStrategy.filter(courses, 'Cybersecurity', 'Information Technology');
      expect(filteredCourses.length, 1);
    });

    test('Interface Segregation & Dependency Inversion: EnrollmentService and AnalyticsService compute metrics', () {
      expect(analyticsService.totalStudents, studentRepo.totalStudents);
      expect(analyticsService.totalCourses, courseRepo.totalCourses);
      expect(analyticsService.totalEnrollments, enrollmentService.totalEnrollments);
      expect(analyticsService.averageCoursesPerStudent, greaterThan(0));

      final deptDistribution = analyticsService.getDepartmentStudentDistribution();
      expect(deptDistribution.keys, contains('Computer Science'));
    });
  });

  group('BCIRepository Facade Unit Tests', () {
    late BCIRepository repo;

    setUp(() {
      repo = BCIRepository();
    });

    test('Initial seed data is loaded correctly via facade', () {
      expect(repo.students.length, greaterThanOrEqualTo(4));
      expect(repo.courses.length, greaterThanOrEqualTo(5));
      expect(repo.totalEnrollments, greaterThan(0));
    });

    test('Student CRUD operations work as expected', () {
      final newStudent = Student(
        id: 'test_s1',
        studentId: 'BCI-TEST-001',
        name: 'Test Student',
        email: 'test@bci.edu',
        phone: '1234567890',
        department: 'Computer Science',
        enrollmentYear: '2026',
      );

      repo.addStudent(newStudent);
      expect(repo.students.any((s) => s.id == 'test_s1'), isTrue);

      final updatedStudent = newStudent.copyWith(name: 'Test Student Updated');
      repo.updateStudent(updatedStudent);
      expect(repo.getStudentById('test_s1')?.name, 'Test Student Updated');

      repo.deleteStudent('test_s1');
      expect(repo.getStudentById('test_s1'), isNull);
    });

    test('Course CRUD operations work as expected', () {
      final newCourse = Course(
        id: 'test_c1',
        courseCode: 'TEST101',
        title: 'Test Course Title',
        credits: 3,
        department: 'Software Engineering',
        instructor: 'Dr. Tester',
        description: 'Test course description',
      );

      repo.addCourse(newCourse);
      expect(repo.courses.any((c) => c.id == 'test_c1'), isTrue);

      final updatedCourse = newCourse.copyWith(title: 'Updated Test Title');
      repo.updateCourse(updatedCourse);
      expect(repo.getCourseById('test_c1')?.title, 'Updated Test Title');

      repo.deleteCourse('test_c1');
      expect(repo.getCourseById('test_c1'), isNull);
    });

    test('Enrollment operations enrol and un-enrol students correctly', () {
      final studentId = repo.students.first.id;
      final courseId = repo.courses.last.id;

      repo.enrolStudentInCourse(studentId, courseId);
      final student = repo.getStudentById(studentId);
      expect(student?.enrolledCourseIds.contains(courseId), isTrue);

      repo.unEnrolStudentFromCourse(studentId, courseId);
      final updatedStudent = repo.getStudentById(studentId);
      expect(updatedStudent?.enrolledCourseIds.contains(courseId), isFalse);
    });
  });

  group('BCI Management App Widget Tests', () {
    testWidgets('App renders main navigation and dashboard with SOLID provider', (WidgetTester tester) async {
      await tester.pumpWidget(const BCIManagementApp());
      await tester.pumpAndSettle();

      expect(find.text('BCI System Dashboard'), findsOneWidget);
      expect(find.text('Welcome to BCI Academic Portal'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
      expect(find.byIcon(Icons.assignment_turned_in_outlined), findsOneWidget);
    });

    testWidgets('Tapping tabs navigates between screens seamlessly', (WidgetTester tester) async {
      await tester.pumpWidget(const BCIManagementApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();
      expect(find.text('Student Records Management'), findsOneWidget);
      expect(find.text('Add Student'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Course Records Management'), findsOneWidget);
      expect(find.text('Add Course'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.assignment_turned_in_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Student Enrollment Hub'), findsOneWidget);
      expect(find.text('Select Student for Enrollment'), findsOneWidget);
    });
  });
}
