import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Single selectable item inside the circle list
/// Highlights itself when selected
class CircleListItem extends StatelessWidget {
  final int itemNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const CircleListItem({
    super.key,
    required this.itemNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.marginBottomS,
        height: AppDimensions.circleItemHeight,
        child: Row(
          children: [
            // Selection indicator bar
            Container(
              width: AppDimensions.circleIndicatorWidth,
              height: AppDimensions.circleIndicatorHeight,
              color: isSelected ? AppColors.accentBlue : AppColors.transparent,
            ),

            // Main circle content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: AppDimensions.circleSize,
                    height: AppDimensions.circleSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightGray,
                    ),
                  ),
                  SizedBox(height: AppSpacing.gapXS),
                  Text(
                    'Circle-$itemNumber',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
