import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Enum representing expense categories
enum ExpenseCategory {
  food,
  travel,
  shopping,
  bills,
  other;

  /// Display name for the category
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  /// Icon for the category
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.travel:
        return Icons.flight_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.bills:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  /// Color associated with the category
  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.foodColor;
      case ExpenseCategory.travel:
        return AppColors.travelColor;
      case ExpenseCategory.shopping:
        return AppColors.shoppingColor;
      case ExpenseCategory.bills:
        return AppColors.billsColor;
      case ExpenseCategory.other:
        return AppColors.otherColor;
    }
  }

  /// Convert category to API/string value
  String toApiString() => name;

  /// Parse category from string value
  static ExpenseCategory fromApiString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}

/// Model class representing an expense entry
class Expense {
  final String id;
  final int userId;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Expense({
    required this.id,
    this.userId = 1,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Expense from JSON/Map
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id']?.toString() ?? '',
      userId: _parseInt(json['user_id'] ?? json['userId']),
      title: json['title'] as String? ?? '',
      amount: _parseDouble(json['amount']),
      category: ExpenseCategory.fromApiString(json['category'] as String? ?? 'other'),
      date: _parseDate(json['expense_date'] ?? json['date']),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  /// Convert Expense to Map for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category.toApiString(),
      'expense_date': date.toIso8601String(),
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Convert Expense to JSON with ID
  Map<String, dynamic> toJsonWithId() {
    return toJson();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  /// Parse double from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Parse date from string
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Create a copy of the expense with optional new values
  Expense copyWith({
    String? id,
    int? userId,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, userId: $userId, title: $title, amount: $amount, category: ${category.displayName}, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
