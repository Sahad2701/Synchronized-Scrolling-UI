import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';

/// Placeholder card shown while grid data is loading
/// Uses the same styling as grid items for visual consistency
class GridLoadingPlaceholder extends StatelessWidget {
  const GridLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: AppDimensions.loadingIndicatorSize,
          height: AppDimensions.loadingIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: AppDimensions.loadingIndicatorStrokeWidth,
          ),
        ),
      ),
    );
  }
}
