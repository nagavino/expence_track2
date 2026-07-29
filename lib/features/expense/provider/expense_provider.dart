import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/local_database_service.dart';
import '../../../core/storage/token_storage.dart';
import '../model/expense_model.dart';

/// Provider for managing expense state offline
class ExpenseProvider extends ChangeNotifier {
  static const String _budgetKey = 'user_monthly_budget_limit';

  final LocalDatabaseService _dbService;
  final TokenStorage _tokenStorage;

  List<Expense> _expenses = [];
  ExpenseCategory? _selectedCategory;
  DateTime? _selectedMonth = DateTime.now(); // Default to current month
  double _monthlyBudgetLimit = 25000.0;
  bool _isLoading = false;
  String? _errorMessage;

  ExpenseProvider({
    LocalDatabaseService? dbService,
    TokenStorage? tokenStorage,
  })  : _dbService = dbService ?? LocalDatabaseService(),
        _tokenStorage = tokenStorage ?? TokenStorage() {
    _loadBudgetLimit();
  }

  Future<void> _loadBudgetLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLimit = prefs.getDouble(_budgetKey);
      if (savedLimit != null && savedLimit > 0) {
        _monthlyBudgetLimit = savedLimit;
        notifyListeners();
      }
    } catch (_) {}
  }

  // ============ Getters ============

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  List<Expense> get allExpenses => List.unmodifiable(_expenses);
  DateTime? get selectedMonth => _selectedMonth;
  bool get isAllTime => _selectedMonth == null;
  double get monthlyBudgetLimit => _monthlyBudgetLimit;

  /// Get expenses filtered by selected month and selected category
  List<Expense> get expenses {
    Iterable<Expense> list = _expenses;
    if (_selectedMonth != null) {
      list = list.where((e) =>
          e.date.year == _selectedMonth!.year &&
          e.date.month == _selectedMonth!.month);
    }
    if (_selectedCategory != null) {
      list = list.where((e) => e.category == _selectedCategory);
    }
    final result = list.toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(result);
  }

  /// Get expenses for the selected month (regardless of category)
  List<Expense> get monthExpenses {
    if (_selectedMonth == null) return List.unmodifiable(_expenses);
    return List.unmodifiable(_expenses.where((e) =>
        e.date.year == _selectedMonth!.year &&
        e.date.month == _selectedMonth!.month));
  }

  ExpenseCategory? get selectedCategory => _selectedCategory;

  double get totalExpense {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get totalAllExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  int getCountForCategory(ExpenseCategory category) {
    Iterable<Expense> list = _expenses;
    if (_selectedMonth != null) {
      list = list.where((e) =>
          e.date.year == _selectedMonth!.year &&
          e.date.month == _selectedMonth!.month);
    }
    return list.where((e) => e.category == category).length;
  }

  double getTotalForCategory(ExpenseCategory category) {
    Iterable<Expense> list = _expenses;
    if (_selectedMonth != null) {
      list = list.where((e) =>
          e.date.year == _selectedMonth!.year &&
          e.date.month == _selectedMonth!.month);
    }
    return list
        .where((e) => e.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  bool get hasExpenses => _expenses.isNotEmpty;
  bool get isFilteredEmpty => expenses.isEmpty && (_selectedCategory != null || _selectedMonth != null);

  // ============ Month Navigation Methods ============

  void setMonth(DateTime? month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void previousMonth() {
    final current = _selectedMonth ?? DateTime.now();
    _selectedMonth = DateTime(current.year, current.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    final current = _selectedMonth ?? DateTime.now();
    _selectedMonth = DateTime(current.year, current.month + 1, 1);
    notifyListeners();
  }

  void showAllTime() {
    _selectedMonth = null;
    notifyListeners();
  }

  // ============ Local Data Methods ============

  /// Fetch expenses locally for current logged-in user
  Future<void> fetchExpenses({ExpenseCategory? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadBudgetLimit();
      final userId = await _tokenStorage.getUserId() ?? 1;
      _expenses = _dbService.getExpensesForUser(userId, category: category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load local expenses';
      notifyListeners();
    }
  }

  /// Add a new expense locally
  Future<bool> addExpense({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
  }) async {
    if (title.trim().isEmpty) {
      _errorMessage = 'Title cannot be empty';
      notifyListeners();
      return false;
    }
    if (amount <= 0) {
      _errorMessage = 'Amount must be greater than 0';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = await _tokenStorage.getUserId() ?? 1;
      await _dbService.createExpense(
        userId: userId,
        title: title,
        amount: amount,
        category: category,
        date: date,
      );

      await fetchExpenses();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to save expense locally';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing expense locally
  Future<bool> updateExpense(Expense expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _dbService.updateExpense(expense);
      if (success) {
        await fetchExpenses();
        return true;
      } else {
        _errorMessage = 'Expense not found in local storage';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update local expense';
      notifyListeners();
      return false;
    }
  }

  /// Delete an expense by ID locally with optimistic UI update
  Future<bool> deleteExpense(String id) async {
    // Find and remove item synchronously from memory first
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    final deletedExpense = _expenses.removeAt(index);
    _errorMessage = null;

    // Notify listeners immediately so Dismissible widget is removed from tree right away
    notifyListeners();

    try {
      final success = await _dbService.deleteExpense(id);
      if (!success) {
        // Rollback if DB deletion failed
        _expenses.insert(index, deletedExpense);
        _errorMessage = 'Failed to delete expense from storage';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      // Rollback on exception
      _expenses.insert(index, deletedExpense);
      _errorMessage = 'Failed to delete local expense';
      notifyListeners();
      return false;
    }
  }

  // ============ Filter Methods ============

  void setFilter(ExpenseCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilter() {
    _selectedCategory = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateBudgetLimit(double limit) async {
    _monthlyBudgetLimit = limit;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_budgetKey, limit);
    } catch (_) {}
  }
}
