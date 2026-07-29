import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget displayed when there are no expenses
class EmptyStateWidget extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onAddExpense;

  const EmptyStateWidget({
    super.key,
    this.isFiltered = false,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryStart.withOpacity(0.1),
                      AppColors.primaryEnd.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFiltered 
                      ? Icons.filter_alt_off_rounded 
                      : Icons.receipt_long_rounded,
                  size: 56,
                  color: AppColors.primaryStart.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltered 
                  ? 'No expenses in this category' 
                  : 'No expenses yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered 
                  ? 'Try selecting a different category\nor add a new expense' 
                  : 'Start tracking your expenses by\nadding your first one!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (!isFiltered)
              ElevatedButton.icon(
                onPressed: onAddExpense,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Expense'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
