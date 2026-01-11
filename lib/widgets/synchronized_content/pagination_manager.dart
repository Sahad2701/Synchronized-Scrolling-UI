import 'package:flutter/material.dart';
import 'content_state.dart';

/// Manages pagination for grid items based on scroll position.
class PaginationManager {
  final ContentState state;
  final ScrollController globalScrollController;
  final ScrollController circleListController;
  final ScrollController gridScrollController;
  final double container1Height;

  PaginationManager({
    required this.state,
    required this.globalScrollController,
    required this.circleListController,
    required this.gridScrollController,
    required this.container1Height,
  });

  double _calculateGridContentHeight(int itemCount, double screenWidth) {
    const int columnCount = 2;
    const double circleListWidth = 95;
    const double horizontalPadding = 32;
    const double gridSpacing = 16;
    const double itemAspectRatio = 0.5;
    
    final int rowCount = (itemCount / columnCount).ceil();
    final double availableGridWidth = screenWidth - circleListWidth - horizontalPadding;
    final double gridItemWidth = (availableGridWidth - gridSpacing) / columnCount;
    final double gridItemHeight = gridItemWidth / itemAspectRatio;
    final double gridHeight = (rowCount * gridItemHeight) + ((rowCount - 1) * gridSpacing);
    
    return gridHeight;
  }

  void checkPagination() {
    if (state.isPaging.value) return;

    const double screenWidth = 400;
    final itemCount = state.gridItems.value.length;
    final gridContentHeight = _calculateGridContentHeight(itemCount, screenWidth);
    final viewportHeight = screenWidth * 1.5;

    if (state.isContainer1Visible.value) {
      if (globalScrollController.hasClients) {
        final globalOffset = globalScrollController.offset;
        
        if (gridContentHeight > viewportHeight && globalOffset >= container1Height) {
          final contentOffset = globalOffset - container1Height;
          final scrollableHeight = gridContentHeight - viewportHeight;
          
          if (scrollableHeight > 0) {
            final scrollProgress = contentOffset / scrollableHeight;
            if (scrollProgress >= 0.7) {
              loadMoreItems();
            }
          }
        }
      }
    } else {
      if (gridScrollController.hasClients && gridContentHeight > viewportHeight) {
        final gridScrollOffset = gridScrollController.offset;
        final scrollableHeight = gridContentHeight - viewportHeight;
        
        if (scrollableHeight > 0) {
          final scrollProgress = gridScrollOffset / scrollableHeight;
          if (scrollProgress >= 0.7) {
            loadMoreItems();
          }
        }
      }
    }
  }

  Future<void> loadMoreItems() async {
    if (state.isPaging.value) return;

    state.isPaging.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    double? currentGlobalOffset;
    double? currentGridOffset;

    if (state.isContainer1Visible.value) {
      if (globalScrollController.hasClients) {
        currentGlobalOffset = globalScrollController.offset;
      }
    } else {
      if (gridScrollController.hasClients) {
        currentGridOffset = gridScrollController.offset;
      }
    }

    final items = List<int>.from(state.gridItems.value);
    final startIndex = items.length + 1;
    items.addAll(List.generate(10, (i) => startIndex + i));
    state.gridItems.value = items;
    state.isPaging.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.isContainer1Visible.value) {
        if (currentGlobalOffset != null && globalScrollController.hasClients) {
          globalScrollController.jumpTo(currentGlobalOffset);
        }
      } else {
        if (currentGridOffset != null && gridScrollController.hasClients) {
          gridScrollController.jumpTo(currentGridOffset);
        }
      }
    });
  }
}
