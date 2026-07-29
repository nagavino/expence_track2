import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../model/expense_model.dart';
import '../provider/expense_provider.dart';

/// Enum for analytics report timeframes
enum AnalyticsTimeframe {
  today,
  weekly,
  monthly,
}

/// Ultra-Promax Professional Fintech Analytics Page
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  AnalyticsTimeframe _selectedTimeframe = AnalyticsTimeframe.weekly;
  int? _hoveredBarIndex;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final allExpenses = provider.allExpenses;
        final reportData = _generateReportData(allExpenses, _selectedTimeframe);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics & Reports',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Financial overview & spending trends',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Timeframe Filter Selector Pills
                  _buildTimeframeSelector(),

                  const SizedBox(height: 20),

                  // 2. High-Level Metrics Summary Banner
                  _buildMetricsBanner(reportData),

                  const SizedBox(height: 24),

                  // 3. Ultra-Promax Interactive Chart Card
                  _buildChartCard(reportData),

                  const SizedBox(height: 24),

                  // 4. Financial Health & Insights Tip Card
                  _buildFinancialInsightCard(reportData),

                  const SizedBox(height: 24),

                  // 5. Category Breakdown Section
                  _buildCategoryBreakdown(reportData),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Segmented Timeframe Selector (Today, Weekly, Monthly)
  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTimeframePill('Today', AnalyticsTimeframe.today),
          _buildTimeframePill('Weekly', AnalyticsTimeframe.weekly),
          _buildTimeframePill('Monthly', AnalyticsTimeframe.monthly),
        ],
      ),
    );
  }

  Widget _buildTimeframePill(String label, AnalyticsTimeframe timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeframe = timeframe;
            _hoveredBarIndex = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primaryStart : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// High-Level Metrics Banner Card
  Widget _buildMetricsBanner(_ReportData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStart.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_graph_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${data.timeframeTitle} Total Spending',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.itemsCount} Transactions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            Formatters.formatCurrency(data.totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStatTile('Avg per day', Formatters.formatCurrency(data.avgPerDay), Icons.speed_rounded),
              const SizedBox(width: 12),
              _buildMiniStatTile('Peak Period', data.peakPeriodLabel, Icons.trending_up_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatTile(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ultra-Promax Interactive Chart Card
  Widget _buildChartCard(_ReportData data) {
    final maxAmount = data.chartPoints.fold<double>(0.0, (max, pt) => pt.amount > max ? pt.amount : max);
    final effectiveMax = maxAmount == 0 ? 1000.0 : maxAmount * 1.2;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: AppColors.primaryStart, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Spending Chart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_hoveredBarIndex != null && _hoveredBarIndex! < data.chartPoints.length)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${data.chartPoints[_hoveredBarIndex!].label}: ${Formatters.formatCurrency(data.chartPoints[_hoveredBarIndex!].amount)}',
                    style: const TextStyle(
                      color: AppColors.primaryStart,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom Chart Canvas Container
          SizedBox(
            height: 200,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    final itemWidth = constraints.maxWidth / data.chartPoints.length;
                    final index = (details.localPosition.dx / itemWidth).floor().clamp(0, data.chartPoints.length - 1);
                    setState(() {
                      _hoveredBarIndex = index;
                    });
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _ModernBarSplineChartPainter(
                      points: data.chartPoints,
                      maxAmount: effectiveMax,
                      hoveredIndex: _hoveredBarIndex,
                      primaryColor: AppColors.primaryStart,
                      secondaryColor: AppColors.primaryEnd,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '💡 Tap on any bar/point to inspect exact spend details',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Financial Health Tip Card
  Widget _buildFinancialInsightCard(_ReportData data) {
    String tipText;
    IconData iconData = Icons.lightbulb_outline_rounded;
    Color color = AppColors.primaryStart;

    if (data.totalAmount == 0) {
      tipText = "No expenses recorded for this timeframe. Great time to save!";
    } else if (data.topCategory != null) {
      tipText = "Your highest spending category in this period is ${data.topCategory!.displayName} (${Formatters.formatCurrency(data.topCategoryAmount)}).";
      color = data.topCategory!.color;
    } else {
      tipText = "Keep monitoring your expenses daily to stay within your monthly budget target.";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Health Insight',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tipText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Category Breakdown List
  Widget _buildCategoryBreakdown(_ReportData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (data.totalAmount == 0)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No expenses available for category breakdown.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          ...ExpenseCategory.values.map((category) {
            final amount = data.categoryTotals[category] ?? 0.0;
            final percentage = data.totalAmount > 0 ? (amount / data.totalAmount) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(category.icon, color: category.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${(percentage * 100).toStringAsFixed(1)}% of timeframe spend',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 6,
                      backgroundColor: category.color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(category.color),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  /// Helper to calculate Today, Weekly, and Monthly data points
  _ReportData _generateReportData(List<Expense> allExpenses, AnalyticsTimeframe timeframe) {
    final now = DateTime.now();
    List<Expense> filteredList = [];
    List<_ChartDataPoint> chartPoints = [];
    String timeframeTitle = '';
    String peakLabel = 'N/A';

    final Map<ExpenseCategory, double> catTotals = {};
    for (var c in ExpenseCategory.values) {
      catTotals[c] = 0.0;
    }

    if (timeframe == AnalyticsTimeframe.today) {
      timeframeTitle = "Today's";
      filteredList = allExpenses.where((e) =>
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day).toList();

      final slots = ['Morning', 'Noon', 'Eve', 'Night'];
      final Map<String, double> slotMap = {for (var s in slots) s: 0.0};

      for (var e in filteredList) {
        final hour = e.date.hour;
        if (hour < 11) {
          slotMap['Morning'] = (slotMap['Morning'] ?? 0) + e.amount;
        } else if (hour < 15) {
          slotMap['Noon'] = (slotMap['Noon'] ?? 0) + e.amount;
        } else if (hour < 19) {
          slotMap['Eve'] = (slotMap['Eve'] ?? 0) + e.amount;
        } else {
          slotMap['Night'] = (slotMap['Night'] ?? 0) + e.amount;
        }
      }

      chartPoints = slots.map((s) => _ChartDataPoint(label: s, amount: slotMap[s] ?? 0)).toList();

    } else if (timeframe == AnalyticsTimeframe.weekly) {
      timeframeTitle = "This Week's";
      // Last 7 days including today
      final weekStart = now.subtract(const Duration(days: 6));
      final startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

      filteredList = allExpenses.where((e) => e.date.isAfter(startDate.subtract(const Duration(seconds: 1)))).toList();

      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayName = _getDayAbbreviation(date.weekday);
        final dayTotal = filteredList
            .where((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day)
            .fold(0.0, (sum, item) => sum + item.amount);

        chartPoints.add(_ChartDataPoint(label: dayName, amount: dayTotal));
      }

    } else {
      timeframeTitle = "This Month's";
      filteredList = allExpenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();

      // 4 Weeks breakdown
      final Map<String, double> weekMap = {'Wk 1': 0.0, 'Wk 2': 0.0, 'Wk 3': 0.0, 'Wk 4': 0.0};

      for (var e in filteredList) {
        final day = e.date.day;
        if (day <= 7) {
          weekMap['Wk 1'] = (weekMap['Wk 1'] ?? 0) + e.amount;
        } else if (day <= 14) {
          weekMap['Wk 2'] = (weekMap['Wk 2'] ?? 0) + e.amount;
        } else if (day <= 21) {
          weekMap['Wk 3'] = (weekMap['Wk 3'] ?? 0) + e.amount;
        } else {
          weekMap['Wk 4'] = (weekMap['Wk 4'] ?? 0) + e.amount;
        }
      }

      chartPoints = weekMap.entries.map((e) => _ChartDataPoint(label: e.key, amount: e.value)).toList();
    }

    // Populate category totals & peak period
    double totalAmount = 0.0;
    for (var e in filteredList) {
      totalAmount += e.amount;
      catTotals[e.category] = (catTotals[e.category] ?? 0.0) + e.amount;
    }

    ExpenseCategory? topCat;
    double topCatAmt = 0.0;
    catTotals.forEach((cat, amt) {
      if (amt > topCatAmt) {
        topCatAmt = amt;
        topCat = cat;
      }
    });

    if (chartPoints.isNotEmpty) {
      final peakPt = chartPoints.reduce((a, b) => a.amount > b.amount ? a : b);
      if (peakPt.amount > 0) {
        peakLabel = peakPt.label;
      }
    }

    final double avgPerDay = timeframe == AnalyticsTimeframe.today
        ? totalAmount
        : (timeframe == AnalyticsTimeframe.weekly ? totalAmount / 7 : totalAmount / 30);

    return _ReportData(
      timeframeTitle: timeframeTitle,
      totalAmount: totalAmount,
      itemsCount: filteredList.length,
      avgPerDay: avgPerDay,
      peakPeriodLabel: peakLabel,
      chartPoints: chartPoints,
      categoryTotals: catTotals,
      topCategory: topCat,
      topCategoryAmount: topCatAmt,
    );
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      case DateTime.sunday: return 'Sun';
      default: return '';
    }
  }
}

class _ChartDataPoint {
  final String label;
  final double amount;
  _ChartDataPoint({required this.label, required this.amount});
}

class _ReportData {
  final String timeframeTitle;
  final double totalAmount;
  final int itemsCount;
  final double avgPerDay;
  final String peakPeriodLabel;
  final List<_ChartDataPoint> chartPoints;
  final Map<ExpenseCategory, double> categoryTotals;
  final ExpenseCategory? topCategory;
  final double topCategoryAmount;

  _ReportData({
    required this.timeframeTitle,
    required this.totalAmount,
    required this.itemsCount,
    required this.avgPerDay,
    required this.peakPeriodLabel,
    required this.chartPoints,
    required this.categoryTotals,
    this.topCategory,
    required this.topCategoryAmount,
  });
}

/// Ultra-Promax Custom Painter for Curved Gradient Area Chart & Interactive Bars
class _ModernBarSplineChartPainter extends CustomPainter {
  final List<_ChartDataPoint> points;
  final double maxAmount;
  final int? hoveredIndex;
  final Color primaryColor;
  final Color secondaryColor;

  _ModernBarSplineChartPainter({
    required this.points,
    required this.maxAmount,
    this.hoveredIndex,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double bottomPadding = 28.0;
    final double chartHeight = size.height - bottomPadding;
    final double itemWidth = size.width / points.length;

    // 1. Draw horizontal dashed background grid lines
    final gridPaint = Paint()
      ..color = AppColors.surfaceVariant.withOpacity(0.9)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = chartHeight * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Compute Bar positions and Spline curve points
    final List<Offset> chartOffsets = [];
    for (int i = 0; i < points.length; i++) {
      final x = itemWidth * i + itemWidth / 2;
      final normalizedAmount = (points[i].amount / maxAmount).clamp(0.05, 1.0);
      final y = chartHeight - (normalizedAmount * chartHeight);
      chartOffsets.add(Offset(x, y));
    }

    // 3. Draw Spline Area Gradient Fill under curve
    final path = Path();
    final fillPath = Path();

    if (chartOffsets.isNotEmpty) {
      path.moveTo(chartOffsets[0].dx, chartOffsets[0].dy);
      fillPath.moveTo(chartOffsets[0].dx, chartHeight);
      fillPath.lineTo(chartOffsets[0].dx, chartOffsets[0].dy);

      for (int i = 0; i < chartOffsets.length - 1; i++) {
        final p0 = chartOffsets[i];
        final p1 = chartOffsets[i + 1];
        final controlPt1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPt2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

        path.cubicTo(controlPt1.dx, controlPt1.dy, controlPt2.dx, controlPt2.dy, p1.dx, p1.dy);
        fillPath.cubicTo(controlPt1.dx, controlPt1.dy, controlPt2.dx, controlPt2.dy, p1.dx, p1.dy);
      }

      fillPath.lineTo(chartOffsets.last.dx, chartHeight);
      fillPath.close();

      // Area gradient fill
      final fillGradient = LinearGradient(
        colors: [
          primaryColor.withOpacity(0.28),
          primaryColor.withOpacity(0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

      final fillPaint = Paint()
        ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));
      canvas.drawPath(fillPath, fillPaint);

      // Spline line stroke
      final linePaint = Paint()
        ..shader = LinearGradient(colors: [primaryColor, secondaryColor]).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight))
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, linePaint);
    }

    // 4. Draw Interactive Rounded Bars & Touch Points
    final textStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondary,
    );

    for (int i = 0; i < points.length; i++) {
      final offset = chartOffsets[i];
      final isHovered = hoveredIndex == i;

      // Draw subtle vertical bar container
      final barWidth = 14.0;
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx - barWidth / 2,
          offset.dy,
          barWidth,
          chartHeight - offset.dy,
        ),
        const Radius.circular(8),
      );

      final barPaint = Paint()
        ..color = isHovered
            ? primaryColor.withOpacity(0.85)
            : primaryColor.withOpacity(0.12);

      canvas.drawRRect(barRect, barPaint);

      // Glowing touch point node on spline curve
      final nodePaint = Paint()
        ..color = isHovered ? Colors.white : primaryColor
        ..style = PaintingStyle.fill;

      final outerNodePaint = Paint()
        ..color = isHovered ? primaryColor : Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(offset, isHovered ? 7.0 : 4.5, outerNodePaint);
      canvas.drawCircle(offset, isHovered ? 4.0 : 2.5, nodePaint);

      // X-Axis Text Label
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: points[i].label,
          style: isHovered
              ? textStyle.copyWith(color: primaryColor, fontWeight: FontWeight.w900)
              : textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offset.dx - textPainter.width / 2, chartHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ModernBarSplineChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.points != points ||
        oldDelegate.maxAmount != maxAmount;
  }
}
