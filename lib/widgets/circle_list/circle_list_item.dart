import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Single selectable circle item with press + selection animations
class CircleListItem extends StatefulWidget {
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
  State<CircleListItem> createState() => _CircleListItemState();
}

class _CircleListItemState extends State<CircleListItem> {
  final _pressed = ValueNotifier<bool>(false);

  void _handleTapDown(_) => _pressed.value = true;

  void _handleTapUp(_) {
    _pressed.value = false;
    widget.onTap();
  }

  void _handleTapCancel() => _pressed.value = false;

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ValueListenableBuilder<bool>(
          valueListenable: _pressed,
          builder: (_, pressed, __) {
            return AnimatedScale(
              scale: pressed ? 0.95 : 1,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: widget.isSelected ? 1 : 0.7,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: Container(
                  margin: AppSpacing.marginBottomS,
                  height: AppDimensions.circleItemHeight,
                  child: Row(
                    children: [
                      _SelectionIndicator(isSelected: widget.isSelected),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CircleAvatar(),
                            SizedBox(height: AppSpacing.gapXS),
                            _Label(
                              index: widget.itemNumber,
                              isSelected: widget.isSelected,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Animated left selection bar
class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: AppDimensions.circleIndicatorWidth,
      height: AppDimensions.circleIndicatorHeight,
      decoration: BoxDecoration(
        color:
            isSelected ? AppColors.accentBlue : AppColors.transparent,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
    );
  }
}

/// Static circle
class _CircleAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: AppDimensions.circleSize,
      height: AppDimensions.circleSize,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGray,
      ),
    );
  }
}

/// Label below the circle
class _Label extends StatelessWidget {
  final int index;
  final bool isSelected;

  const _Label({
    required this.index,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      style: AppTypography.textTheme.bodyLarge!.copyWith(
        fontSize: 14,
        fontWeight:
            isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected
            ? AppColors.accentBlue
            : AppColors.primaryText,
      ),
      child: Text('Circle-$index'),
    );
  }
}