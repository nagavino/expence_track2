import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../features/auth/model/user_model.dart';
import '../../features/expense/model/expense_model.dart';

/// Local Database Service using Hive for 100% offline dataflow
class LocalDatabaseService {
  static const String _usersBoxName = 'app_users_box';
  static const String _expensesBoxName = 'app_expenses_box';
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();

  Box<dynamic>? _usersBox;
  Box<dynamic>? _expensesBox;
  final Uuid _uuid = const Uuid();

  factory LocalDatabaseService() {
    return _instance;
  }

  LocalDatabaseService._internal();

  /// Initialize Hive boxes offline
  Future<void> init() async {
    await Hive.initFlutter();
    _usersBox = await Hive.openBox(_usersBoxName);
    _expensesBox = await Hive.openBox(_expensesBoxName);

    await _seedDefaultData();
  }

  /// Ensure boxes are open
  Box<dynamic> get _users {
    if (_usersBox == null || !_usersBox!.isOpen) {
      throw StateError('Users box is not initialized. Call init() first.');
    }
    return _usersBox!;
  }

  Box<dynamic> get _expenses {
    if (_expensesBox == null || !_expensesBox!.isOpen) {
      throw StateError('Expenses box is not initialized. Call init() first.');
    }
    return _expensesBox!;
  }

  /// Hash password using SHA-256 securely
  String hashPassword(String password) {
    final bytes = utf8.encode('salt_expense_app_$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Seed default user and sample expenses
  Future<void> _seedDefaultData() async {
    const defaultEmail = 'nagamani3vinoth@gmail.com';
    final existingUser = findUserByEmail(defaultEmail);

    if (existingUser == null) {
      final defaultUser = User(
        id: 1,
        name: 'Nagamani',
        email: defaultEmail,
        role: 'USER',
        passwordHash: hashPassword('naga2125vinoth'),
      );
      await _users.put(defaultUser.id, defaultUser.toJson());
    }

      // Seed sample expenses for demo user
      if (_expenses.isEmpty) {
        final now = DateTime.now();
        final sampleExpenses = [
          Expense(
            id: _uuid.v4(),
            userId: 1,
            title: 'Grocery Shopping',
            amount: 85.50,
            category: ExpenseCategory.food,
            date: now.subtract(const Duration(days: 1)),
          ),
          Expense(
            id: _uuid.v4(),
            userId: 1,
            title: 'Electricity Bill',
            amount: 120.00,
            category: ExpenseCategory.bills,
            date: now.subtract(const Duration(days: 3)),
          ),
          Expense(
            id: _uuid.v4(),
            userId: 1,
            title: 'Uber Ride',
            amount: 24.75,
            category: ExpenseCategory.travel,
            date: now.subtract(const Duration(days: 5)),
          ),
        ];

        for (final item in sampleExpenses) {
          await _expenses.put(item.id, item.toJson());
        }
      }
  }

  // ==================== AUTH METHODS ====================

  /// Find user by email
  User? findUserByEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    for (var key in _users.keys) {
      final data = _users.get(key);
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if ((map['email'] as String? ?? '').toLowerCase() == cleanEmail) {
          return User.fromJson(map);
        }
      }
    }
    return null;
  }

  /// Register a new local user account
  Future<LocalAuthResult> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final existingUser = findUserByEmail(email);
    if (existingUser != null) {
      return const LocalAuthResult(
        success: false,
        message: 'An account with this email already exists.',
      );
    }

    final newId = DateTime.now().millisecondsSinceEpoch;
    final hashedPassword = hashPassword(password);

    final user = User(
      id: newId,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: 'USER',
      passwordHash: hashedPassword,
    );

    await _users.put(user.id, user.toJson());

    final token = 'local_jwt_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

    return LocalAuthResult(
      success: true,
      message: 'Account registered successfully!',
      user: user,
      token: token,
    );
  }

  /// Authenticate user locally
  Future<LocalAuthResult> loginUser({
    required String email,
    required String password,
  }) async {
    final user = findUserByEmail(email);
    if (user == null) {
      return const LocalAuthResult(
        success: false,
        message: 'Invalid email or password.',
      );
    }

    final inputHash = hashPassword(password);
    if (user.passwordHash != inputHash) {
      return const LocalAuthResult(
        success: false,
        message: 'Invalid email or password.',
      );
    }

    final token = 'local_jwt_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

    return LocalAuthResult(
      success: true,
      message: 'Login successful',
      user: user,
      token: token,
    );
  }

  // ==================== EXPENSE METHODS ====================

  /// Get expenses for a specific local user ID
  List<Expense> getExpensesForUser(int userId, {ExpenseCategory? category}) {
    final List<Expense> list = [];
    for (var key in _expenses.keys) {
      final data = _expenses.get(key);
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final expense = Expense.fromJson(map);
        if (expense.userId == userId) {
          if (category == null || expense.category == category) {
            list.add(expense);
          }
        }
      }
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Create local expense
  Future<Expense> createExpense({
    required int userId,
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
  }) async {
    final newId = _uuid.v4();
    final expense = Expense(
      id: newId,
      userId: userId,
      title: title.trim(),
      amount: amount,
      category: category,
      date: date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _expenses.put(newId, expense.toJson());
    return expense;
  }

  /// Update local expense
  Future<bool> updateExpense(Expense expense) async {
    if (!_expenses.containsKey(expense.id)) {
      return false;
    }
    final updated = expense.copyWith(updatedAt: DateTime.now());
    await _expenses.put(expense.id, updated.toJson());
    return true;
  }

  /// Delete local expense
  Future<bool> deleteExpense(String id) async {
    if (_expenses.containsKey(id)) {
      await _expenses.delete(id);
      return true;
    }
    return false;
  }
}
