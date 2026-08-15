import 'package:flutter/material.dart';

/// Shared responsive search field + department-filter dropdown, used by
/// both the Students and Courses list screens.
class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchHint;
  final VoidCallback onChanged;
  final String selectedDepartment;
  final List<String> departments;
  final ValueChanged<String> onDepartmentChanged;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.searchHint,
    required this.onChanged,
    required this.selectedDepartment,
    required this.departments,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 450;

    final searchField = TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: searchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  onChanged();
                },
              )
            : null,
      ),
      onChanged: (val) => onChanged(),
    );

    if (isNarrow) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 8),
          _buildDropdown(context, isNarrow: true),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 12),
        _buildDropdown(context, isNarrow: false),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, {required bool isNarrow}) {
    final dropdown = DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedDepartment,
        isExpanded: isNarrow,
        icon: const Icon(Icons.filter_list),
        items: departments.map((dept) {
          return DropdownMenuItem(
            value: dept,
            child: Text(
              dept == 'All'
                  ? (isNarrow ? 'All Departments' : 'All Depts')
                  : dept,
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) onDepartmentChanged(val);
        },
      ),
    );

    return Container(
      width: isNarrow ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: dropdown,
    );
  }
}
