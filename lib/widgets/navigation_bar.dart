import 'package:flutter/material.dart';
import '../models/nav_tab.dart';

class AppNavigationBar extends StatelessWidget {
  final List<NavTab> navTabs;
  final String selectedTabId;
  final Function(String) onItemSelected;

  const AppNavigationBar({
    super.key,
    required this.navTabs,
    required this.selectedTabId,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: navTabs.map((tab) {
            final isSelected = tab.id == selectedTabId;
            return GestureDetector(
              onTap: () => onItemSelected(tab.id),
              child: Container(
                margin: const EdgeInsets.only(right: 24.0),
                padding: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  border: isSelected
                      ? const Border(
                          bottom: BorderSide(
                            color: Color(0xFFFF6B35),
                            width: 2.0,
                          ),
                        )
                      : null,
                ),
                child: Text(
                  tab.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
