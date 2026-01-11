import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import 'circle_list_item.dart';

/// Vertical list of selectable circles
class CircleListView extends StatelessWidget {
  final ScrollController controller;
  final List<int> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final ScrollPhysics physics;

  const CircleListView({
    super.key,
    required this.controller,
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.circleListWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusS,
          ),
        ),
        child: ListView.builder(
          controller: controller,
          physics: physics,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (_, index) {
            return CircleListItem(
              itemNumber: items[index],
              isSelected: index == selectedIndex,
              onTap: () => onItemTap(index),
            );
          },
        ),
      ),
    );
  }
}