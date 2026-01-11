import 'package:flutter/material.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_spacing.dart';
import 'grid_container_item.dart';
import 'grid_loading_placeholder.dart';

/// Stateless grid used by the synchronized layout
class GridViewContainer extends StatelessWidget {
  final ScrollController controller;
  final List<int> items;
  final bool isPaging;
  final ScrollPhysics physics;
  final bool shrinkWrap;

  const GridViewContainer({
    super.key,
    required this.controller,
    required this.items,
    required this.isPaging,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.marginHorizontalM,
      child: GridView.builder(
        controller: controller,
        physics: physics,
        shrinkWrap: shrinkWrap,
        cacheExtent: 500,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,
        padding: EdgeInsets.only(
          bottom: isPaging
              ? AppDimensions.loadingIndicatorSize +
                  AppSpacing.paddingM * 2
              : 0,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppDimensions.gridCrossAxisCount,
          crossAxisSpacing: AppDimensions.gridCrossAxisSpacing,
          mainAxisSpacing: AppDimensions.gridMainAxisSpacing,
          childAspectRatio: AppDimensions.gridChildAspectRatio,
        ),
        itemCount: items.isEmpty ? 2 : items.length,
        itemBuilder: (_, index) {
          if (items.isEmpty) {
            return const GridLoadingPlaceholder();
          }
          return GridContainerItem(
            itemNumber: items[index],
          );
        },
      ),
    );
  }
}