import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../theme/app_typography.dart';

/// Simple sticky app bar shown at the top of the screen
/// Contains a back button and a title
class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.appBarHeight,
      padding: AppSpacing.paddingHorizontalM,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back navigation button
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: AppDimensions.appBarIconSize,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              // Exit the current screen
              SystemNavigator.pop();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // App bar title
          Text('App bar', style: AppTypography.textTheme.displayMedium),
        ],
      ),
    );
  }
}
