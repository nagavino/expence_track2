import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../model/expense_model.dart';

/// Card widget displaying a single expense item
/// 
/// Supports:
/// - Swipe left-to-right (StartToEnd): Edit action
/// - Swipe right-to-left (EndToStart): Delete action with confirmation dialog
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onDelete,
    this.onEdit,
  });

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text(
                'Delete Expense',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${expense.title}" (${Formatters.formatCurrency(expense.amount)})?',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe Left -> Right = EDIT
          onEdit?.call();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // Swipe Right -> Left = DELETE (Confirm first)
          return await _showDeleteConfirmationDialog(context);
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      // Left-to-Right Background (Edit)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF6366F1),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 26,
            ),
            SizedBox(height: 2),
            Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // Right-to-Left Secondary Background (Delete)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.error,
              AppColors.error.withOpacity(0.6),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
            SizedBox(height: 2),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceVariant.withOpacity(0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              onEdit?.call();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category icon with colored soft background tint
                  _buildCategoryIcon(),
                  const SizedBox(width: 16),
                  // Title, Category Badge, Date and Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                expense.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              Formatters.formatCurrency(expense.amount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: expense.category.color.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                expense.category.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: expense.category.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Small Dot Separator
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Date metadata
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppColors.textSecondary.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Formatters.getRelativeDate(expense.date),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary.withOpacity(0.8),
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
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: expense.category.color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        expense.category.icon,
        color: expense.category.color,
        size: 20,
      ),
    );
  }
}
