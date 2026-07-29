import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/expense_provider.dart';
import 'add_expense_sheet.dart';
import 'analytics_page.dart';
import 'settings_page.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/expense_card.dart';
import 'widgets/total_expense_card.dart';

/// Main home page for the expense tracker app with modern glass bottom navigation bar
class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch expenses on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Screen views for each navigation tab
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(),
              _buildExpenseTab(),
              const AnalyticsPage(),
              const SettingsPage(),
            ],
          ),
          // Modern Glass Effect Floating Bottom Navigation Bar
          _buildGlassBottomNavBar(),
        ],
      ),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 78),
              child: _buildFAB(context),
            )
          : null,
    );
  }

  /// Modern, attractive glass effect bottom navigation bar
  Widget _buildGlassBottomNavBar() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primaryStart.withOpacity(0.12),
              blurRadius: 30,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.82),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.65),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.grid_view_rounded, Icons.grid_view_outlined, 'Home'),
                  _buildNavItem(1, Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Expense'),
                  _buildNavItem(2, Icons.insights_rounded, Icons.insights_outlined, 'Analytics'),
                  _buildNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build animated individual bottom navigation item
  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryStart.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Home Tab - Main Dashboard
  Widget _buildHomeTab() {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: _buildHomeBody(),
        ),
      ],
    );
  }

  /// Expense Tab - Dedicated Expense Manager
  Widget _buildExpenseTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Manage & view all recorded expenses',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const CategoryFilterChips(),
          Expanded(
            child: _buildHomeBody(hideHeaderCard: true),
          ),
        ],
      ),
    );
  }

  /// Build app bar with greeting, user info and logout
  Widget _buildAppBar(BuildContext context) {
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good Morning 🌅';
      } else if (hour < 17) {
        return 'Good Afternoon ☀️';
      } else {
        return 'Good Evening 🌙';
      }
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 20,
        right: 20,
      ),
      color: AppColors.background,
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final user = auth.user;
          final userName = user?.name ?? 'Guest';
          final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
          final isAdmin = user?.role.toUpperCase() == 'ADMIN';

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryStart.withOpacity(0.1),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.primaryStart,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getGreeting(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryStart.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                color: AppColors.primaryStart,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('No new notifications'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Notifications',
                    ),
                  ),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: AppColors.error.withOpacity(0.1),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: IconButton(
                  //     icon: const Icon(
                  //       Icons.logout_rounded,
                  //       color: AppColors.error,
                  //       size: 22,
                  //     ),
                  //     onPressed: _handleLogout,
                  //     tooltip: 'Logout',
                  //   ),
                  // ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build main expense list body content
  Widget _buildHomeBody({bool hideHeaderCard = false}) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.expenses.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.hasError && provider.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.error.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage ?? 'Failed to load expenses',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchExpenses(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchExpenses(),
          color: AppColors.primaryStart,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (!hideHeaderCard) ...[
                const SliverToBoxAdapter(
                  child: TotalExpenseCard(),
                ),
                const SliverToBoxAdapter(
                  child: CategoryFilterChips(),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            provider.selectedCategory != null
                                ? '${provider.selectedCategory!.displayName} Expenses'
                                : (hideHeaderCard ? 'All Expenses' : 'Recent Expenses'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${provider.expenses.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (provider.selectedCategory != null)
                        TextButton(
                          onPressed: () => provider.clearFilter(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryStart,
                            backgroundColor: AppColors.primaryStart.withOpacity(0.08),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.clear_rounded, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Clear Filter',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading && provider.expenses.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              if (provider.expenses.isEmpty && !provider.isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    isFiltered: provider.isFilteredEmpty,
                    onAddExpense: () => AddExpenseSheet.show(context),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = provider.expenses[index];
                      return ExpenseCard(
                        expense: expense,
                        onEdit: () {
                          AddExpenseSheet.show(context, expense: expense);
                        },
                        onDelete: () {
                          provider.deleteExpense(expense.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${expense.title} deleted'),
                                ],
                              ),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: provider.expenses.length,
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        );
      },
    );
  }

  /// Build premium floating action button
  Widget _buildFAB(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStart.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AddExpenseSheet.show(context),
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
