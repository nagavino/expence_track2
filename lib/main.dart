import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/storage/local_database_service.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/expense/provider/expense_provider.dart';

/// Application entry point - 100% Offline with Hive & Local Storage
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local offline database (Hive) & secure storage
  final localDb = LocalDatabaseService();
  await localDb.init();

  final tokenStorage = TokenStorage();
  await tokenStorage.init();
  
  runApp(
    MultiProvider(
      providers: [
        // Auth provider for local authentication state
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            dbService: localDb,
            tokenStorage: tokenStorage,
          ),
        ),
        // Expense provider for local offline expense state
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(
            dbService: localDb,
            tokenStorage: tokenStorage,
          ),
        ),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}
