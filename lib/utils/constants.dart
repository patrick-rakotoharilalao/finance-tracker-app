import 'package:flutter/material.dart';

class AppColors {
  // Primary color — used throughout the app
  static const Color primary = Color(0xFF1D9E75);
  static const Color primaryLight = Color(0xFF9FE1CB);

  // Category colors
  static const Color food = Color(0xFF1D9E75);
  static const Color transport = Color(0xFF378ADD);
  static const Color leisure = Color(0xFF7F77DD);
  static const Color health = Color(0xFFD85A30);
  static const Color housing = Color(0xFFBA7517);
  static const Color education = Color(0xFFD4537E);
  static const Color salary = Color(0xFF639922);
  static const Color other = Color(0xFF888780);

  // Transaction type colors
  static const Color income = Color(0xFF1D9E75);
  static const Color expense = Color(0xFFE24B4A);

  // Neutral
  static const Color grey = Color(0xFF888780);
  static const Color greyLight = Color(0xFFF1EFE8);
}

class AppSizes {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Font sizes
  static const double fontXS = 11.0;
  static const double fontS = 13.0;
  static const double fontM = 15.0;
  static const double fontL = 18.0;
  static const double fontXL = 24.0;
  static const double fontXXL = 32.0;

  // Icon sizes
  static const double iconS = 18.0;
  static const double iconM = 22.0;
  static const double iconL = 28.0;
}

class AppStrings {
  // App
  static const String appName = 'Finance Tracker';
  static const String currency = 'Ar';

  // Tab labels
  static const String home = 'Home';
  static const String history = 'History';
  static const String stats = 'Stats';
  static const String settings = 'Settings';

  // Transaction types
  static const String income = 'income';
  static const String expense = 'expense';

  // Hive box names — single source of truth
  static const String boxTransactions = 'transactions';
  static const String boxBudgets = 'budgets';
}
