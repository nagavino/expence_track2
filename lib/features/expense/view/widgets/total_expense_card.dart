import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../provider/expense_provider.dart';

/// Card widget displaying the total expense amount
/// 
/// Features a premium glassmorphic background design with a budget progress tracker.
class TotalExpenseCard extends StatelessWidget {
  const TotalExpenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final double monthlyBudget = provider.monthlyBudgetLimit;
        final isFiltered = provider.selectedCategory != null;
        final total = provider.totalExpense;
        final filterLabel = isFiltered 
            ? provider.selectedCategory!.displayName 
            : 'Total';
        
        final budgetProgress = (total / monthlyBudget).clamp(0.0, 1.0);
        final isOverBudget = total > monthlyBudget;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryStart.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Glassmorphic background decorative circles
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                // Card Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Month Navigation Control & Status Badge
                      Row(
                        children: [
                          // Translucent Month Navigation Bar
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Previous Month Button (<)
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => provider.previousMonth(),
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Padding(
                                        padding: EdgeInsets.all(3.0),
                                        child: Icon(
                                          Icons.chevron_left_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Month Selector Popup Trigger
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _showMonthPicker(context, provider),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_rounded,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                provider.isAllTime
                                                    ? 'All Time'
                                                    : Formatters.formatMonthYear(provider.selectedMonth!),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.1,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.white70,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Next Month Button (>)
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => provider.nextMonth(),
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Padding(
                                        padding: EdgeInsets.all(3.0),
                                        child: Icon(
                                          Icons.chevron_right_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isOverBudget
                                  ? AppColors.error.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOverBudget 
                                      ? Icons.warning_amber_rounded 
                                      : Icons.trending_down_rounded,
                                  color: isOverBudget 
                                      ? Colors.redAccent 
                                      : Colors.greenAccent,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOverBudget ? 'Over Limit' : 'On Track',
                                  style: TextStyle(
                                    color: isOverBudget 
                                        ? Colors.redAccent 
                                        : Colors.greenAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Animated Amount Display
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: total),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Text(
                            Formatters.formatCurrency(value),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.isAllTime
                            ? '${provider.expenses.length} transaction${provider.expenses.length == 1 ? "" : "s"} (All Time)'
                            : '${provider.expenses.length} transaction${provider.expenses.length == 1 ? "" : "s"} in ${Formatters.formatMonthYear(provider.selectedMonth!)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(
                        color: Colors.white.withOpacity(0.15),
                        height: 1,
                      ),
                      const SizedBox(height: 16),
                      // Budget progress bar section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Monthly Limit: ${Formatters.formatCurrency(monthlyBudget)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(budgetProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Linear progress bar
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: budgetProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isOverBudget ? Colors.redAccent : Colors.white,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: (isOverBudget ? Colors.redAccent : Colors.white).withOpacity(0.5),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isOverBudget
                                ? 'Over limit by ${Formatters.formatCurrency(total - monthlyBudget)}'
                                : '${Formatters.formatCurrency(monthlyBudget - total)} remaining',
                            style: TextStyle(
                              color: isOverBudget 
                                  ? Colors.redAccent 
                                  : Colors.white.withOpacity(0.6),
                              fontSize: 11,
                              fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show bottom sheet for selecting month or all time
  void _showMonthPicker(BuildContext context, ExpenseProvider provider) {
    final now = DateTime.now();
    final currentSelected = provider.selectedMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Expense Period',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryStart),
                ),
                title: const Text('Current Month', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(Formatters.formatMonthYear(now)),
                trailing: (currentSelected != null &&
                        currentSelected.year == now.year &&
                        currentSelected.month == now.month)
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryStart)
                    : null,
                onTap: () {
                  provider.setMonth(now);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEnd.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.all_inclusive_rounded, color: AppColors.primaryEnd),
                ),
                title: const Text('All Time Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Show expenses across all months'),
                trailing: provider.isAllTime
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryStart)
                    : null,
                onTap: () {
                  provider.showAllTime();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.travelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.date_range_rounded, color: AppColors.travelColor),
                ),
                title: const Text('Pick Specific Month & Year', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Select any month from calendar'),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: provider.selectedMonth ?? now,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    helpText: 'SELECT MONTH',
                  );
                  if (picked != null) {
                    provider.setMonth(picked);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
