import 'package:flutter/material.dart';
import 'theme/bci_theme.dart';
import 'services/bci_repository.dart';
import 'core/di/app_dependency_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/students_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/enrollment_screen.dart';

void main() {
  runApp(const BCIManagementApp());
}

class BCIManagementApp extends StatefulWidget {
  const BCIManagementApp({super.key});

  @override
  State<BCIManagementApp> createState() => _BCIManagementAppState();
}

class _BCIManagementAppState extends State<BCIManagementApp> {
  late final BCIRepository _repository;
  late final AppDependencies _appDependencies;

  @override
  void initState() {
    super.initState();
    _repository = BCIRepository();
    _appDependencies = AppDependencies(
      studentRepository: _repository.studentRepository,
      courseRepository: _repository.courseRepository,
      enrollmentService: _repository.enrollmentService,
      analyticsService: _repository.analyticsService,
      managementService: _repository,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDependencyProvider(
      dependencies: _appDependencies,
      child: MaterialApp(
        title: 'BCI Management System',
        debugShowCheckedModeBanner: false,
        theme: BCITheme.lightTheme,
        home: MainNavigationScreen(repository: _repository),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final BCIRepository repository;

  const MainNavigationScreen({super.key, required this.repository});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.repository.addListener(_onRepositoryChanged);
  }

  @override
  void dispose() {
    widget.repository.removeListener(_onRepositoryChanged);
    widget.repository.dispose();
    super.dispose();
  }

  void _onRepositoryChanged() {
    setState(() {});
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateToTab: _onTabSelected),
      const StudentsScreen(),
      const CoursesScreen(),
      const EnrollmentScreen(),
    ];

    final titles = [
      'BCI System Dashboard',
      'Student Records Management',
      'Course Records Management',
      'Student Enrollment Hub',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school, size: 26),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                titles[_currentIndex],
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'System Info',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'BCI Management System',
                applicationVersion: '2.0.0 (SOLID Refactored)',
                applicationIcon: const Icon(
                  Icons.school,
                  size: 48,
                  color: Color(0xFF1E3A8A),
                ),
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Comprehensive Academic Management System for Benedict XVI Catholic International Institute of Higher Education (BCI).',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Architecture: Built with SOLID Principles (SRP, OCP, LSP, ISP, DIP).',
                  ),
                  const SizedBox(height: 8),
                  Text('Total Students: ${widget.repository.totalStudents}'),
                  Text('Total Courses: ${widget.repository.totalCourses}'),
                  Text(
                    'Total Enrollments: ${widget.repository.totalEnrollments}',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_outlined),
              activeIcon: Icon(Icons.assignment_turned_in),
              label: 'Enrollment',
            ),
          ],
        ),
      ),
    );
  }
}
