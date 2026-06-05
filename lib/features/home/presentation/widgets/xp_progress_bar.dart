import 'package:flutter/material.dart';
import 'package:gymbuddy_ai/core/constants/app_colors.dart';

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int totalXP;

  const XPProgressBar({
    super.key,
    required this.currentXP,
    required this.totalXP,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        totalXP == 0 ? 0 : currentXP / totalXP;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "LEVEL PROGRESS",
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            Text(
              "$currentXP / $totalXP XP",
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            color: AppColors.accentGreen,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}