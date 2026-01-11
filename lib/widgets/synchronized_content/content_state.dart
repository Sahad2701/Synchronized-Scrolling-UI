import 'package:flutter/material.dart';

/// Holds all reactive state for synchronized scrolling content
class ContentState {
  final circleItems = ValueNotifier<List<int>>([]);
  final gridItems = ValueNotifier<List<int>>([]);
  final selectedIndex = ValueNotifier<int>(0);

  // UI state
  final isInitialLoading = ValueNotifier<bool>(true);
  final isPaging = ValueNotifier<bool>(false);
  final isRefreshing = ValueNotifier<bool>(false);
  final isContainer1Visible = ValueNotifier<bool>(true);

  // Scroll behavior
  final leftPhysics = ValueNotifier<ScrollPhysics>(
    const NeverScrollableScrollPhysics(),
  );

  final rightPhysics = ValueNotifier<ScrollPhysics>(
    const NeverScrollableScrollPhysics(),
  );

  final globalPhysics = ValueNotifier<ScrollPhysics>(
    const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
  );

  /// Used when list & grid scroll independently
  static const ScrollPhysics smoothScrollPhysics =
      BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );

  /// Clean up all notifiers
  void dispose() {
    circleItems.dispose();
    gridItems.dispose();
    selectedIndex.dispose();
    isInitialLoading.dispose();
    isPaging.dispose();
    isRefreshing.dispose();
    isContainer1Visible.dispose();
    leftPhysics.dispose();
    rightPhysics.dispose();
    globalPhysics.dispose();
  }
}
