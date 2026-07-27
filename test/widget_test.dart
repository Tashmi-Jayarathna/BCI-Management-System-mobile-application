import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/services/bci_repository.dart';
import 'package:flutter_application_1/models/student_model.dart';
import 'package:flutter_application_1/models/course_model.dart';

void main() {
  group('BCIRepository Unit Tests', () {
    late BCIRepository repo;

    setUp(() {
      repo = BCIRepository();
    });

    test('Initial seed data is loaded correctly', () {
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

      // Enrol
      repo.enrolStudentInCourse(studentId, courseId);
      final student = repo.getStudentById(studentId);
      expect(student?.enrolledCourseIds.contains(courseId), isTrue);

      // Un-enrol
      repo.unEnrolStudentFromCourse(studentId, courseId);
      final updatedStudent = repo.getStudentById(studentId);
      expect(updatedStudent?.enrolledCourseIds.contains(courseId), isFalse);
    });
  });

  group('BCI Management App Widget Tests', () {
    testWidgets('App renders main navigation and dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(const BCIManagementApp());
      await tester.pumpAndSettle();

      expect(find.text('BCI System Dashboard'), findsOneWidget);
      expect(find.text('Welcome to BCI Portal'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
      expect(find.byIcon(Icons.assignment_turned_in_outlined), findsOneWidget);
    });

    testWidgets('Tapping tabs navigates between screens', (WidgetTester tester) async {
      await tester.pumpWidget(const BCIManagementApp());
      await tester.pumpAndSettle();

      // Navigate to Students tab
      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();
      expect(find.text('Student Records Management'), findsOneWidget);
      expect(find.text('Add Student'), findsOneWidget);

      // Navigate to Courses tab
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Course Records Management'), findsOneWidget);
      expect(find.text('Add Course'), findsOneWidget);

      // Navigate to Enrollment tab
      await tester.tap(find.byIcon(Icons.assignment_turned_in_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Student Enrollment Hub'), findsOneWidget);
      expect(find.text('Select Student for Enrollment'), findsOneWidget);
    });
  });
}
