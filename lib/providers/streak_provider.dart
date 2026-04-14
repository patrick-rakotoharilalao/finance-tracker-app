import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakProvider extends ChangeNotifier {
  static const String _streakCountKey = 'daily_streak_count';
  static const String _lastActiveDateKey = 'daily_streak_last_active_date';

  int _streakDays = 0;

  int get streakDays => _streakDays;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _streakDays = prefs.getInt(_streakCountKey) ?? 0;
    await markDailyUsage();
  }

  Future<void> markDailyUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastActiveRaw = prefs.getString(_lastActiveDateKey);
    final lastActive = lastActiveRaw == null ? null : DateTime.tryParse(lastActiveRaw);
    final normalizedLastActive = lastActive == null
        ? null
        : DateTime(lastActive.year, lastActive.month, lastActive.day);

    if (normalizedLastActive == null) {
      _streakDays = 1;
    } else {
      final difference = today.difference(normalizedLastActive).inDays;
      if (difference == 0) {
        // Already counted for today.
      } else if (difference == 1) {
        _streakDays += 1;
      } else {
        _streakDays = 1;
      }
    }

    await prefs.setInt(_streakCountKey, _streakDays);
    await prefs.setString(_lastActiveDateKey, today.toIso8601String());
    notifyListeners();
  }
}
