import 'package:intl/intl.dart';

class AppFormatters {
  // Format amount in Ariary
  // 5000.0 → "5,000 Ar"
  static String currency(double amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return '${formatter.format(amount)} Ar';
  }

  // Format amount with sign — for transactions
  // income  5000.0 → "+ 5,000 Ar"
  // expense 5000.0 → "- 5,000 Ar"
  static String currencyWithSign(double amount, String type) {
    final formatted = currency(amount);
    return type == 'income' ? '+ $formatted' : '- $formatted';
  }

  // Format date — short version
  // DateTime(2026, 3, 28) → "Mar 28"
  static String dateShort(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  // Format date — full version
  // DateTime(2026, 3, 28) → "March 28, 2026"
  static String dateFull(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  // Format month and year — for history header
  // DateTime(2026, 3, 1) → "March 2026"
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Format time
  // DateTime(2026, 3, 28, 14, 30) → "14:30"
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  // Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year;
  }

  // Smart date label — used in history list
  // Today     → "Today"
  // Yesterday → "Yesterday"
  // Other     → "March 28, 2026"
  static String smartDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return dateFull(date);
  }
}
