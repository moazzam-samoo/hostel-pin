import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_dashboard_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.adminDashboardOverview,
                style: AppTextStyles.screenTitle),
            const SizedBox(height: 4),
            Obx(() => Text(
                  AppStrings.adminDashboardWelcome(controller.adminDisplayName),
                  style: AppTextStyles.screenSubtitle,
                )),
            const SizedBox(height: 24),
            _buildStatCards(context),
            const SizedBox(height: 32),
            Responsive.isDesktop(context)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildUserGrowthChart()),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildUserDistributionChart()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildUserGrowthChart(),
                      const SizedBox(height: 24),
                      _buildUserDistributionChart(),
                    ],
                  ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCards(BuildContext context) {
    final cards = [
      _StatCard(
        title: AppStrings.adminStatTotalStudents,
        value: controller.totalStudents.value.toString(),
        icon: Icons.person_outline,
        color: AppColors.primary,
      ),
      _StatCard(
        title: AppStrings.adminStatTotalOwners,
        value: controller.totalOwners.value.toString(),
        icon: Icons.storefront_outlined,
        color: AppColors.secondary,
      ),
      _StatCard(
        title: AppStrings.adminStatTotalHostels,
        value: controller.totalHostels.value.toString(),
        icon: Icons.domain,
        color: AppColors.primaryVariant,
      ),
      _StatCard(
        title: AppStrings.adminStatActiveListings,
        value: controller.activeListings.value.toString(),
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
    ];

    if (Responsive.isDesktop(context)) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
          const SizedBox(width: 16),
          Expanded(child: cards[2]),
          const SizedBox(width: 16),
          Expanded(child: cards[3]),
        ],
      );
    } else if (Responsive.isTablet(context)) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 16),
          cards[1],
          const SizedBox(height: 16),
          cards[2],
          const SizedBox(height: 16),
          cards[3],
        ],
      );
    }
  }

  Widget _buildUserGrowthChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.adminUserGrowthTitle,
              style: AppTextStyles.sectionHeader),
          Text(AppStrings.adminUserGrowthSubtitle,
              style: AppTextStyles.caption),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barTouchData: const BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ];
                        if (value.toInt() >= 1 && value.toInt() <= 12) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[value.toInt() - 1],
                              style: AppTextStyles.caption,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.caption,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                // Mockup shows a single series ("Monthly student
                // registrations", no legend) — not the two-series
                // students+owners chart this used to render. Owners have
                // their own real count via controller.ownerGrowth if a
                // later pass wants to add it back with a legend, but that
                // would be inventing UI the mockup doesn't show.
                barGroups: List.generate(12, (index) {
                  final month = index + 1;
                  final students =
                      controller.studentGrowth[month]?.toDouble() ?? 0.0;
                  return BarChartGroupData(
                    x: month,
                    barRods: [
                      BarChartRodData(
                        toY: students,
                        color: AppColors.primary,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    double maxVal = 10;
    for (int i = 1; i <= 12; i++) {
      final s = controller.studentGrowth[i]?.toDouble() ?? 0.0;
      if (s > maxVal) maxVal = s;
    }
    return maxVal * 1.2;
  }

  Widget _buildUserDistributionChart() {
    final students = controller.totalStudents.value.toDouble();
    final owners = controller.totalOwners.value.toDouble();
    final total = students + owners;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.adminUserDistributionTitle,
              style: AppTextStyles.sectionHeader),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: total == 0
                ? Center(
                    child: Text(AppStrings.adminNoData,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary)))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          color: AppColors.secondary,
                          value: owners,
                          title: '',
                          radius: 30,
                        ),
                        PieChartSectionData(
                          color: AppColors.primary,
                          value: students,
                          title: '',
                          radius: 30,
                        ),
                        PieChartSectionData(
                          color: AppColors.border, // Both
                          value: 0.0,
                          title: '',
                          radius: 30,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          _buildLegendItem(AppStrings.adminLegendOwners, AppColors.secondary),
          const SizedBox(height: 8),
          _buildLegendItem(AppStrings.adminLegendStudents, AppColors.primary),
          const SizedBox(height: 8),
          _buildLegendItem(AppStrings.adminLegendBoth, AppColors.border),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.screenTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
