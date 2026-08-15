import 'package:flutter/material.dart';
import '../../services/interfaces/management_service_interface.dart';
import '../../services/interfaces/student_repository_interface.dart';
import '../../services/interfaces/course_repository_interface.dart';
import '../../services/interfaces/enrollment_service_interface.dart';
import '../../services/interfaces/dashboard_analytics_service_interface.dart';
import '../../services/validation/student_validator.dart';
import '../../services/validation/course_validator.dart';
import '../../services/strategies/search_filter_strategy.dart';

/// Dependency Inversion Principle (DIP): Dependency Provider Container.
class AppDependencies {
  final IStudentRepository studentRepository;
  final ICourseRepository courseRepository;
  final IEnrollmentService enrollmentService;
  final IDashboardAnalyticsService analyticsService;
  final IManagementService managementService;

  final StudentValidator studentValidator = StudentValidator();
  final CourseValidator courseValidator = CourseValidator();
  final StudentSearchStrategy studentSearchStrategy = StudentSearchStrategy();
  final CourseSearchStrategy courseSearchStrategy = CourseSearchStrategy();

  AppDependencies({
    required this.studentRepository,
    required this.courseRepository,
    required this.enrollmentService,
    required this.analyticsService,
    required this.managementService,
  });
}

/// InheritedWidget facilitating Dependency Injection throughout the widget tree.
class AppDependencyProvider extends InheritedWidget {
  final AppDependencies dependencies;

  const AppDependencyProvider({
    super.key,
    required this.dependencies,
    required super.child,
  });

  static AppDependencies of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AppDependencyProvider>();
    assert(provider != null, 'No AppDependencyProvider found in context');
    return provider!.dependencies;
  }

  @override
  bool updateShouldNotify(covariant AppDependencyProvider oldWidget) {
    return dependencies != oldWidget.dependencies;
  }
}
