import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'circle_list/circle_list_view.dart';
import 'grid_view/grid_view_container.dart';
import 'synchronized_content/content_state.dart';
import 'synchronized_content/pagination_manager.dart';
import 'synchronized_content/scroll_sync_manager.dart';
import '../constants/app_dimensions.dart';

/// Coordinates synchronized scrolling between circle list and grid view.
class SynchronizedContent extends StatefulWidget {
  final ScrollController globalScrollController;
  final double container1Height;
  final void Function(ContentState)? onStateCreated;

  const SynchronizedContent({
    super.key,
    required this.globalScrollController,
    required this.container1Height,
    this.onStateCreated,
  });

  @override
  State<SynchronizedContent> createState() => _SynchronizedContentState();
}

class _SynchronizedContentState extends State<SynchronizedContent> {
  late final ScrollController _circleListScrollController;
  late final ScrollController _gridScrollController;
  late final ContentState _contentState;
  late final PaginationManager _paginationHandler;
  late final ScrollSyncManager _scrollSyncHandler;

  @override
  void initState() {
    super.initState();

    _circleListScrollController = ScrollController();
    _gridScrollController = ScrollController();
    _contentState = ContentState();

    if (widget.onStateCreated != null) {
      widget.onStateCreated!(_contentState);
    }

    _paginationHandler = PaginationManager(
      state: _contentState,
      globalScrollController: widget.globalScrollController,
      circleListController: _circleListScrollController,
      gridScrollController: _gridScrollController,
      container1Height: widget.container1Height,
    );

    _scrollSyncHandler = ScrollSyncManager(
      state: _contentState,
      globalScrollController: widget.globalScrollController,
      circleListController: _circleListScrollController,
      gridScrollController: _gridScrollController,
      container1Height: widget.container1Height,
      paginationHandler: _paginationHandler,
    );

    widget.globalScrollController.addListener(_scrollSyncHandler.onGlobalScroll);
    _circleListScrollController.addListener(_scrollSyncHandler.onLeftScroll);
    _gridScrollController.addListener(_scrollSyncHandler.onRightScroll);

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    _contentState.circleItems.value = List.generate(12, (i) => i + 1);
    _contentState.gridItems.value = List.generate(8, (i) => i + 1);

    _contentState.isInitialLoading.value = false;
  }

  Future<void> _onCircleSelected(int index) async {
    if (!mounted) return;
    
    _contentState.selectedIndex.value = index;
    _contentState.isRefreshing.value = true;
    _scrollSyncHandler.isRefreshingFromCircleSelection = true;
    _contentState.gridItems.value = List.generate(6, (i) => i + 1);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    _contentState.isRefreshing.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      if (_gridScrollController.hasClients) {
        _gridScrollController.jumpTo(0);
      }

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _scrollSyncHandler.isRefreshingFromCircleSelection = false;
      });

      if (_circleListScrollController.hasClients) {
        final itemHeight = AppDimensions.circleItemHeight;
        final itemOffset = index * itemHeight;
        final viewportHeight = _circleListScrollController.position.viewportDimension;
        final maxOffset = _circleListScrollController.position.maxScrollExtent;
        final targetOffset = (itemOffset - viewportHeight / 2 + itemHeight / 2).clamp(0.0, maxOffset);

        _circleListScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    widget.globalScrollController.removeListener(_scrollSyncHandler.onGlobalScroll);
    _circleListScrollController.removeListener(_scrollSyncHandler.onLeftScroll);
    _gridScrollController.removeListener(_scrollSyncHandler.onRightScroll);
    _circleListScrollController.dispose();
    _gridScrollController.dispose();
    _contentState.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _contentState.isInitialLoading,
      builder: (context, loading, _) {
        if (loading) {
          return const SizedBox(
            height: 600,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ValueListenableBuilder<List<int>>(
          valueListenable: _contentState.gridItems,
          builder: (context, items, _) {
            const int columnCount = 2;
            const double circleListWidth = 95;
            const double horizontalPadding = 32;
            const double gridSpacing = 16;
            const double itemAspectRatio = 0.5;
            const double extraBottomSpace = 100;

            final int rowCount = (items.length / columnCount).ceil();
            final double screenWidth = MediaQuery.of(context).size.width;
            final double availableGridWidth =
                screenWidth - circleListWidth - horizontalPadding;
            final double gridItemWidth =
                (availableGridWidth - gridSpacing) / columnCount;
            final double gridItemHeight = gridItemWidth / itemAspectRatio;
            final double gridHeight =
                (rowCount * gridItemHeight) +
                    ((rowCount - 1) * gridSpacing) +
                    extraBottomSpace;

            final int listItemCount = _contentState.circleItems.value.length;
            final double listItemHeight = AppDimensions.circleItemHeight;
            final double listContentHeight = listItemCount * listItemHeight;

            final double screenHeight = MediaQuery.of(context).size.height;
            final double viewportHeight = screenHeight - AppDimensions.appBarHeight - 50;

            return ValueListenableBuilder<bool>(
              valueListenable: _contentState.isContainer1Visible,
              builder: (_, isContainerVisible, __) {
                final contentHeight = isContainerVisible
                    ? gridHeight
                    : viewportHeight;

                return SizedBox(
                  height: contentHeight,
                  child: Stack(
                    children: [
                      if (!isContainerVisible)
                        Positioned(
                          left: 0,
                          top: 0,
                          child: RepaintBoundary(
                            child: ValueListenableBuilder<ScrollPhysics>(
                              valueListenable: _contentState.leftPhysics,
                              builder: (_, physics, __) {
                                return ValueListenableBuilder<List<int>>(
                                  valueListenable: _contentState.circleItems,
                                  builder: (_, circles, ___) {
                                    return ValueListenableBuilder<int>(
                                      valueListenable: _contentState.selectedIndex,
                                      builder: (_, selected, ____) {
                                        return SizedBox(
                                          width: AppDimensions.circleListWidth,
                                          height: viewportHeight,
                                          child: CircleListView(
                                            controller: _circleListScrollController,
                                            items: circles,
                                            selectedIndex: selected,
                                            onItemTap: _onCircleSelected,
                                            physics: physics,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isContainerVisible)
                            RepaintBoundary(
                              child: ValueListenableBuilder<ScrollPhysics>(
                                valueListenable: _contentState.leftPhysics,
                                builder: (_, physics, __) {
                                  return ValueListenableBuilder<List<int>>(
                                    valueListenable: _contentState.circleItems,
                                    builder: (_, circles, ___) {
                                      return ValueListenableBuilder<int>(
                                        valueListenable: _contentState.selectedIndex,
                                        builder: (_, selected, ____) {
                                          return CircleListView(
                                            controller: _circleListScrollController,
                                            items: circles,
                                            selectedIndex: selected,
                                            onItemTap: _onCircleSelected,
                                            physics: physics,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: !isContainerVisible ? AppDimensions.circleListWidth : 0,
                              ),
                              child: RepaintBoundary(
                                child: ValueListenableBuilder<ScrollPhysics>(
                                  valueListenable: _contentState.rightPhysics,
                                  builder: (_, physics, __) {
                                    return ValueListenableBuilder<bool>(
                                      valueListenable: _contentState.isPaging,
                                      builder: (_, isPaging, __) {
                                        return GridViewContainer(
                                          controller: _gridScrollController,
                                          items: items,
                                          isPaging: isPaging,
                                          physics: physics,
                                          shrinkWrap: isContainerVisible,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _contentState.isPaging,
                        builder: (_, paging, __) {
                          if (!paging) return const SizedBox.shrink();
                          return Positioned(
                            bottom: 0,
                            left: circleListWidth + 16,
                            right: 16,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _contentState.isRefreshing,
                        builder: (_, refreshing, __) {
                          if (!refreshing) return const SizedBox.shrink();
                          return Positioned.fill(
                            child: Container(
                              color: Colors.white.withValues(alpha: 0.9),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(strokeWidth: 3),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
