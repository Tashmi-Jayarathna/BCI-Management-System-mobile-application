import 'package:flutter/material.dart';
import 'theme/bci_theme.dart';
import 'services/bci_repository.dart';
import 'screens/dashboard_screen.dart';
import 'screens/students_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/enrollment_screen.dart';

void main() {
  runApp(const BCIManagementApp());
}

class BCIManagementApp extends StatelessWidget {
  const BCIManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BCI Management System',
      debugShowCheckedModeBanner: false,
      theme: BCITheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final BCIRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = BCIRepository();
    _repository.addListener(_onRepositoryChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    _repository.dispose();
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
      DashboardScreen(
        repository: _repository,
        onNavigateToTab: _onTabSelected,
      ),
      StudentsScreen(repository: _repository),
      CoursesScreen(repository: _repository),
      EnrollmentScreen(repository: _repository),
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
            Text(titles[_currentIndex]),
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
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.school, size: 48, color: Color(0xFF1E3A8A)),
                children: [
                  const SizedBox(height: 12),
                  const Text('Comprehensive Mobile Academic Management System for Benedict XVI Catholic International Institute of Higher Education, (BCI).'),
                  const SizedBox(height: 8),
                  Text('Total Students: ${_repository.totalStudents}'),
                  Text('Total Courses: ${_repository.totalCourses}'),
                  Text('Total Enrollments: ${_repository.totalEnrollments}'),
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
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
