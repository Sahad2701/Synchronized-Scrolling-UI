import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../theme/app_typography.dart';

/// Top content container shown below the app bar
/// Moves together with the main scroll content
class TopContainer extends StatelessWidget {
  const TopContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: AppSpacing.marginAllM,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingXXXL),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Container-1',
          style: AppTypography.textTheme.displayMedium,
        ),
      ),
    );
  }
}
