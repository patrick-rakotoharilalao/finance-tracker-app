import 'package:flutter/material.dart';

enum Category {
  food,
  transport,
  leisure,
  health,
  housing,
  education,
  salary,
  other,
}

// Extension to add helper properties to each category
extension CategoryExtension on Category {
  // Display name shown in the UI
  String get label {
    switch (this) {
      case Category.food:
        return 'Food';
      case Category.transport:
        return 'Transport';
      case Category.leisure:
        return 'Leisure';
      case Category.health:
        return 'Health';
      case Category.housing:
        return 'Housing';
      case Category.education:
        return 'Education';
      case Category.salary:
        return 'Salary';
      case Category.other:
        return 'Other';
    }
  }

  // Icon associated with each category
  IconData get icon {
    switch (this) {
      case Category.food:
        return Icons.restaurant;
      case Category.transport:
        return Icons.directions_car;
      case Category.leisure:
        return Icons.sports_esports;
      case Category.health:
        return Icons.favorite;
      case Category.housing:
        return Icons.home;
      case Category.education:
        return Icons.school;
      case Category.salary:
        return Icons.work;
      case Category.other:
        return Icons.category;
    }
  }

  // Color associated with each category
  Color get color {
    switch (this) {
      case Category.food:
        return const Color(0xFF1D9E75);
      case Category.transport:
        return const Color(0xFF378ADD);
      case Category.leisure:
        return const Color(0xFF7F77DD);
      case Category.health:
        return const Color(0xFFD85A30);
      case Category.housing:
        return const Color(0xFFBA7517);
      case Category.education:
        return const Color(0xFFD4537E);
      case Category.salary:
        return const Color(0xFF639922);
      case Category.other:
        return const Color(0xFF888780);
    }
  }

  // Convert category to a storable string for Hive
  String get value => name;

  // Convert a string back to a Category enum
  static Category fromString(String value) {
    return Category.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Category.other,
    );
  }
}
