import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'circle_list/circle_list_view.dart';
import 'grid_view/grid_view_container.dart';

/// Widget that keeps the circle list and grid view
/// scrolling together and sharing state
class SynchronizedContent extends StatefulWidget {
  final ScrollController globalScrollController;

  const SynchronizedContent({super.key, required this.globalScrollController});

  @override
  State<SynchronizedContent> createState() => _SynchronizedContentState();
}

class _SynchronizedContentState extends State<SynchronizedContent> {
  late final ScrollController _leftController;
  late final ScrollController _rightController;
  final ValueNotifier<List<int>> _circleItems = ValueNotifier([]);
  final ValueNotifier<List<int>> _gridItems = ValueNotifier([]);
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  final ValueNotifier<bool> _isInitialLoading = ValueNotifier(true);
  final ValueNotifier<bool> _isPaging = ValueNotifier(false);
  final ValueNotifier<bool> _isRefreshing = ValueNotifier(false);
  bool _isSyncingScroll = false;

  @override
  void initState() {
    super.initState();

    _leftController = ScrollController();
    _rightController = ScrollController();

    widget.globalScrollController.addListener(_onGlobalScroll);

    _loadInitialData();
  }

  /// Watches the global scroll to trigger pagination
  void _onGlobalScroll() {
    if (_isSyncingScroll) return;
    _checkPagination();
  }

  /// Initial fake API load
  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(seconds: 1));

    _circleItems.value = List.generate(10, (i) => i + 1);
    _gridItems.value = List.generate(6, (i) => i + 1);

    _isInitialLoading.value = false;
  }

  /// Sync left list scroll to right grid
  bool _onLeftScroll(ScrollNotification notification) {
    if (_isSyncingScroll) return false;
    if (notification is! ScrollUpdateNotification &&
        notification is! ScrollEndNotification) {
      return false;
    }

    if (!_leftController.hasClients || !_rightController.hasClients) {
      return false;
    }

    _isSyncingScroll = true;

    final offset = _leftController.offset;
    final max = _rightController.position.maxScrollExtent;
    final min = _rightController.position.minScrollExtent;

    if (max > min) {
      final target = offset.clamp(min, max);
      if ((_rightController.offset - target).abs() > 0.1) {
        _rightController.jumpTo(target);
      }
    }

    _isSyncingScroll = false;
    return false;
  }

  /// Sync right grid scroll to left list
  bool _onRightScroll(ScrollNotification notification) {
    if (_isSyncingScroll) return false;
    if (notification is! ScrollUpdateNotification &&
        notification is! ScrollEndNotification) {
      return false;
    }

    if (!_leftController.hasClients || !_rightController.hasClients) {
      return false;
    }

    _isSyncingScroll = true;

    final offset = _rightController.offset;
    final max = _leftController.position.maxScrollExtent;
    final min = _leftController.position.minScrollExtent;

    if (max > min) {
      final target = offset.clamp(min, max);
      if ((_leftController.offset - target).abs() > 0.1) {
        _leftController.jumpTo(target);
      }
    }

    _isSyncingScroll = false;
    return false;
  }

  /// Checks if we are close enough to the bottom to load more
  void _checkPagination() {
    if (_isPaging.value || !widget.globalScrollController.hasClients) return;

    final position = widget.globalScrollController.position;
    if (position.maxScrollExtent == 0) return;

    final progress = position.pixels / position.maxScrollExtent;

    if (progress >= 0.8) {
      _loadMoreItems();
    }
  }

  /// Loads more grid items and keeps scroll position stable
  Future<void> _loadMoreItems() async {
    if (_isPaging.value) return;

    _isPaging.value = true;

    await Future.delayed(const Duration(seconds: 1));

    final currentOffset = widget.globalScrollController.hasClients
        ? widget.globalScrollController.offset
        : 0.0;

    final items = List<int>.from(_gridItems.value);
    final start = items.length + 1;

    items.addAll(List.generate(6, (i) => start + i));
    _gridItems.value = items;

    _isPaging.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.globalScrollController.hasClients) {
        widget.globalScrollController.jumpTo(currentOffset);
      }
    });
  }

  /// Handles circle selection and refreshes grid content
  Future<void> _onCircleSelected(int index) async {
    _selectedIndex.value = index;
    _isRefreshing.value = true;

    if (widget.globalScrollController.hasClients) {
      widget.globalScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));

    _gridItems.value = List.generate(6, (i) => i + 1);
    _isRefreshing.value = false;

    _leftController.jumpTo(0);
    _rightController.jumpTo(0);
  }

  @override
  void dispose() {
    widget.globalScrollController.removeListener(_onGlobalScroll);
    _leftController.dispose();
    _rightController.dispose();

    _circleItems.dispose();
    _gridItems.dispose();
    _selectedIndex.dispose();
    _isInitialLoading.dispose();
    _isPaging.dispose();
    _isRefreshing.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isInitialLoading,
      builder: (context, loading, _) {
        if (loading) {
          return const SizedBox(
            height: 600,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ValueListenableBuilder<List<int>>(
          valueListenable: _gridItems,
          builder: (context, items, _) {
            // Grid layout assumptions
            const int columnCount = 2;
            const double circleListWidth = 95;
            const double horizontalPadding = 32;
            const double gridSpacing = 16;
            const double itemAspectRatio = 0.5;
            const double extraBottomSpace = 100;

            // Calculate number of rows needed
            final int rowCount = (items.length / columnCount).ceil();

            // Available width for the grid area
            final double screenWidth = MediaQuery.of(context).size.width;
            final double availableGridWidth =
                screenWidth - circleListWidth - horizontalPadding;

            // Calculate item size
            final double gridItemWidth =
                (availableGridWidth - gridSpacing) / columnCount;
            final double gridItemHeight = gridItemWidth / itemAspectRatio;

            // Final grid height including spacing and padding
            final double gridHeight =
                (rowCount * gridItemHeight) +
                ((rowCount - 1) * gridSpacing) +
                extraBottomSpace;

            return SizedBox(
              height: gridHeight,
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circle list
                      Listener(
                        onPointerSignal: (event) {
                          if (event is PointerScrollEvent) {
                            final offset =
                                widget.globalScrollController.offset +
                                event.scrollDelta.dy;
                            widget.globalScrollController.jumpTo(
                              offset.clamp(
                                0.0,
                                widget
                                    .globalScrollController
                                    .position
                                    .maxScrollExtent,
                              ),
                            );
                          }
                        },
                        child: NotificationListener<ScrollNotification>(
                          onNotification: _onLeftScroll,
                          child: ValueListenableBuilder<List<int>>(
                            valueListenable: _circleItems,
                            builder: (_, circles, __) {
                              return ValueListenableBuilder<int>(
                                valueListenable: _selectedIndex,
                                builder: (_, selected, __) {
                                  return CircleListView(
                                    controller: _leftController,
                                    items: circles,
                                    selectedIndex: selected,
                                    onItemTap: _onCircleSelected,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // Grid view
                      Expanded(
                        child: Listener(
                          onPointerSignal: (event) {
                            if (event is PointerScrollEvent) {
                              final offset =
                                  widget.globalScrollController.offset +
                                  event.scrollDelta.dy;
                              widget.globalScrollController.jumpTo(
                                offset.clamp(
                                  0.0,
                                  widget
                                      .globalScrollController
                                      .position
                                      .maxScrollExtent,
                                ),
                              );
                            }
                          },
                          child: NotificationListener<ScrollNotification>(
                            onNotification: _onRightScroll,
                            child: GridViewContainer(
                              controller: _rightController,
                              items: items,
                              isPaging: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom pagination loader
                  ValueListenableBuilder<bool>(
                    valueListenable: _isPaging,
                    builder: (_, paging, __) {
                      if (!paging) return const SizedBox.shrink();
                      return const Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),

                  // Full screen refresh overlay
                  ValueListenableBuilder<bool>(
                    valueListenable: _isRefreshing,
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
  }
}
