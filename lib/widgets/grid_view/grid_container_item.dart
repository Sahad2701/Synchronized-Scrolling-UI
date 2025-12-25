import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../theme/app_typography.dart';

/// Single grid item displayed inside the grid view
/// Shows a simple card with the item index
class GridContainerItem extends StatelessWidget {
  final int itemNumber;

  const GridContainerItem({
    super.key,
    required this.itemNumber,
  });

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
      child: Center(
        child: Text(
          'Container-$itemNumber',
          style: AppTypography.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
