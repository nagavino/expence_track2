import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/expense_model.dart';
import '../../provider/expense_provider.dart';

/// Horizontal scrollable filter chips for category filtering
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 63,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              // "All" filter chip
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: _buildChip(
                  context: context,
                  label: 'All',
                  icon: Icons.dashboard_rounded,
                  isSelected: provider.selectedCategory == null,
                  onTap: () => provider.clearFilter(),
                  count: provider.allExpenses.length,
                ),
              ),
              const SizedBox(width: 10),
              // Category chips
              ...ExpenseCategory.values.map((category) {
                return Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildChip(
                      context: context,
                      label: category.displayName,
                      icon: category.icon,
                      color: category.color,
                      isSelected: provider.selectedCategory == category,
                      onTap: () => provider.setFilter(category),
                      count: provider.getCountForCategory(category),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
    required int count,
  }) {
    final chipColor = color ?? AppColors.primaryStart;
    
    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? chipColor 
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isSelected 
                      ? chipColor 
                      : AppColors.surfaceVariant,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? chipColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.02),
                    blurRadius: isSelected ? 12 : 4,
                    offset: isSelected ? const Offset(0, 5) : const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected 
                        ? Colors.white 
                        : chipColor.withOpacity(0.85),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? Colors.white 
                          : AppColors.textPrimary.withOpacity(0.85),
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.2) 
                            : chipColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected 
                              ? Colors.white 
                              : chipColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
