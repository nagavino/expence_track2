import 'package:intl/intl.dart';

/// Utility class for formatting values throughout the app
class Formatters {
  Formatters._();

  /// Currency formatter for Indian Rupees
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format amount as currency string
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Date formatter for display (e.g., "Dec 28, 2025")
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  /// Format date for display
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Short date format (e.g., "Dec 28")
  static final DateFormat _shortDateFormat = DateFormat('MMM dd');

  /// Format date in short form
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Get relative date string (Today, Yesterday, or formatted date)
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }

  /// Month & Year formatter (e.g., "July 2026")
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  /// Format date as month and year
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }
}
