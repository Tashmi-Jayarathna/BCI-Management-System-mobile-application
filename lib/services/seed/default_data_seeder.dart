import '../../models/student_model.dart';
import '../../models/course_model.dart';

abstract class IDataSeeder {
  List<Course> seedCourses();
  List<Student> seedStudents();
}

/// Single Responsibility Principle: Data seeder class exclusively responsible for initial mock datasets.
class DefaultDataSeeder implements IDataSeeder {
  @override
  List<Course> seedCourses() {
    return [
      Course(
        id: 'c1',
        courseCode: 'CS101',
        title: 'Introduction to Computer Science',
        credits: 4,
        department: 'Computer Science',
        instructor: 'Dr. Waruna',
        description: 'Foundations of computing, algorithms, and logic.',
      ),
      Course(
        id: 'c2',
        courseCode: 'BUS201',
        title: 'Principles of Management',
        credits: 3,
        department: 'Business Administration',
        instructor: 'Prof. Sujith',
        description: 'Core concepts in modern enterprise management.',
      ),
      Course(
        id: 'c3',
        courseCode: 'DS301',
        title: 'Data Structures & Algorithms',
        credits: 4,
        department: 'Data Science',
        instructor: 'Prof.Thushari',
        description:
            'Advanced trees, graphs, sorting, and dynamic programming.',
      ),
      Course(
        id: 'c4',
        courseCode: 'SE401',
        title: 'Mobile App Architecture',
        credits: 3,
        department: 'Software Engineering',
        instructor: 'Dr.Susara',
        description:
            'Cross-platform mobile design patterns and state management.',
      ),
      Course(
        id: 'c5',
        courseCode: 'IT105',
        title: 'Cybersecurity Fundamentals',
        credits: 3,
        department: 'Information Technology',
        instructor: 'Mr.Sohan',
        description: 'Network security, encryption, and threat vectors.',
      ),
    ];
  }

  @override
  List<Student> seedStudents() {
    return [
      Student(
        id: 's1',
        studentId: 'BCI-2024-001',
        name: 'Hasanthi Sandeepani',
        email: 'Hasanthisandeepani@bci.edu',
        phone: '+1 (555) 234-5678',
        department: 'Computer Science',
        enrollmentYear: '2024',
        enrolledCourseIds: ['c1', 'c3', 'c4'],
      ),
      Student(
        id: 's2',
        studentId: 'BCI-2024-002',
        name: 'Senal Navod',
        email: 'senalnavod@bci.edu',
        phone: '+1 (555) 876-5432',
        department: 'Business Administration',
        enrollmentYear: '2024',
        enrolledCourseIds: ['c2'],
      ),
      Student(
        id: 's3',
        studentId: 'BCI-2025-003',
        name: 'Tharindu Dilshan',
        email: 'Tharindudilshan@bci.edu',
        phone: '+1 (555) 345-6789',
        department: 'Software Engineering',
        enrollmentYear: '2025',
        enrolledCourseIds: ['c1', 'c4'],
      ),
      Student(
        id: 's4',
        studentId: 'BCI-2025-004',
        name: 'Kavindu Hasinsa',
        email: 'Kavinduhasinsa@bci.edu',
        phone: '+1 (555) 987-6543',
        department: 'Data Science',
        enrollmentYear: '2025',
        enrolledCourseIds: ['c3', 'c5'],
      ),
    ];
  }
}
