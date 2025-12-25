import 'package:flutter/material.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_spacing.dart';
import 'grid_container_item.dart';
import 'grid_loading_placeholder.dart';

/// Grid container used to display items in a fixed 2-column layout
/// Scrolling is handled by the parent; this grid only builds content
class GridViewContainer extends StatelessWidget {
  final ScrollController controller;
  final List<int> items;
  final bool isPaging;

  const GridViewContainer({
    super.key,
    required this.controller,
    required this.items,
    required this.isPaging,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.marginHorizontalM,
      child: GridView.builder(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          bottom: isPaging
              ? AppDimensions.loadingIndicatorSize + AppSpacing.paddingM * 2
              : 0,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppDimensions.gridCrossAxisCount,
          crossAxisSpacing: AppDimensions.gridCrossAxisSpacing,
          mainAxisSpacing: AppDimensions.gridMainAxisSpacing,
          childAspectRatio: AppDimensions.gridChildAspectRatio,
        ),
        itemCount: items.isEmpty ? 2 : items.length,
        itemBuilder: (context, index) {
          if (items.isEmpty) {
            return const GridLoadingPlaceholder();
          }
          return GridContainerItem(itemNumber: items[index]);
        },
      ),
    );
  }
}
