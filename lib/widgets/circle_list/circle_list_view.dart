import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import 'circle_list_item.dart';

/// Vertical list used to display selectable circle items
/// Scrolling is controlled by the parent widget
class CircleListView extends StatelessWidget {
  final ScrollController controller;
  final List<int> items;
  final int selectedIndex;
  final Function(int) onItemTap;

  const CircleListView({
    super.key,
    required this.controller,
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.circleListWidth,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: ListView.builder(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
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
