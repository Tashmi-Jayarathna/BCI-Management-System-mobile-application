import 'package:flutter/material.dart';
import '../services/bci_repository.dart';

class DashboardScreen extends StatelessWidget {
  final BCIRepository repository;
  final Function(int tabIndex) onNavigateToTab;

  const DashboardScreen({
    super.key,
    required this.repository,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final totalStudents = repository.totalStudents;
    final totalCourses = repository.totalCourses;
    final totalEnrollments = repository.totalEnrollments;
    final avgCourses = totalStudents > 0
        ? (totalEnrollments / totalStudents).toStringAsFixed(1)
        : '0.0';

    final deptStats = repository.getDepartmentStudentCount();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to BCI Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Benedict XVI Catholic International Institute of Higher Education, Institute Academic Management System',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => onNavigateToTab(1), // Students tab
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Manage Students'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => onNavigateToTab(2), // Courses tab
                      icon: const Icon(Icons.book),
                      label: const Text('Manage Courses'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Overview Metrics Header
          const Text(
            'System Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Stats Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallMobile = constraints.maxWidth < 360;
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : (isSmallMobile ? 1 : 2);
              final aspectRatio = constraints.maxWidth > 600 ? 1.4 : (isSmallMobile ? 2.5 : 1.3);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: aspectRatio,
                children: [
                  _statCard(
                    context,
                    title: 'Total Students',
                    value: totalStudents.toString(),
                    icon: Icons.people_alt,
                    color: Colors.blue.shade700,
                    onTap: () => onNavigateToTab(1),
                  ),
                  _statCard(
                    context,
                    title: 'Active Courses',
                    value: totalCourses.toString(),
                    icon: Icons.school,
                    color: Colors.teal.shade700,
                    onTap: () => onNavigateToTab(2),
                  ),
                  _statCard(
                    context,
                    title: 'Enrollments',
                    value: totalEnrollments.toString(),
                    icon: Icons.assignment_turned_in,
                    color: Colors.indigo.shade700,
                    onTap: () => onNavigateToTab(3),
                  ),
                  _statCard(
                    context,
                    title: 'Avg. Enrolled',
                    value: avgCourses,
                    icon: Icons.analytics,
                    color: Colors.amber.shade800,
                    onTap: () => onNavigateToTab(3),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Department Breakdown Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Department Breakdown',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.pie_chart_outline, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (deptStats.isEmpty)
                    const Text('No department data available')
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: deptStats.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Recent Students List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Students',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => onNavigateToTab(1),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (repository.students.isEmpty)
                    const Text('No students registered')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: repository.students.length > 3 ? 3 : repository.students.length,
                      separatorBuilder: (ctx, i) => const Divider(),
                      itemBuilder: (ctx, i) {
                        final s = repository.students[i];
                        final coursesCount = s.enrolledCourseIds.length;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              s.name[0].toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${s.studentId} • ${s.department}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: coursesCount > 0 ? Colors.teal.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: coursesCount > 0 ? Colors.teal.shade300 : Colors.orange.shade300,
                              ),
                            ),
                            child: Text(
                              '$coursesCount ${coursesCount == 1 ? "Course" : "Courses"}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: coursesCount > 0 ? Colors.teal.shade800 : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
