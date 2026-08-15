/// Single source of truth for the academic departments used across
/// repositories and search/filter strategies.
class Departments {
  Departments._();

  static const String all = 'All';

  static const List<String> values = [
    all,
    'Computer Science',
    'Business Administration',
    'Information Technology',
    'Data Science',
    'Software Engineering',
  ];

  static bool matches(String itemDepartment, String filter) =>
      filter.isEmpty || filter == all || itemDepartment == filter;
}
