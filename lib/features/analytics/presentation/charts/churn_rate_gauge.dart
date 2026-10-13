import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ChurnRateGauge extends StatelessWidget {
  final double churnRate;

  const ChurnRateGauge({
    super.key,
    required this.churnRate,
  });

  @override
  Widget build(BuildContext context) {
    // Normal healthy SaaS churn benchmark is < 5%
    final bool isHealthy = churnRate <= 3.0;
    final Color indicatorColor = isHealthy ? AppColors.success : AppColors.error;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: 180,
                  sectionsSpace: 0,
                  centerSpaceRadius: 52,
                  sections: [
                    PieChartSectionData(
                      value: churnRate,
                      color: indicatorColor,
                      radius: 14,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: (10.0 - churnRate).clamp(0.0, 10.0),
                      color: AppColors.surfaceElevated,
                      radius: 14,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${churnRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'MONTHLY',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isHealthy ? 'Healthy Benchmark (<3%)' : 'Attention Needed (>3%)',
              style: TextStyle(
                color: indicatorColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
