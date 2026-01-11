import 'package:flutter/material.dart';
import 'content_state.dart';
import 'pagination_manager.dart';

/// Manages synchronized scrolling between circle list and grid view.
class ScrollSyncManager {
  final ContentState state;
  final ScrollController globalScrollController;
  final ScrollController circleListController;
  final ScrollController gridScrollController;
  final double container1Height;
  final PaginationManager paginationHandler;

  bool _isSyncingScroll = false;
  bool _isBringingContainerBack = false;
  bool isRefreshingFromCircleSelection = false;

  ScrollSyncManager({
    required this.state,
    required this.globalScrollController,
    required this.circleListController,
    required this.gridScrollController,
    required this.container1Height,
    required this.paginationHandler,
  });

  void onGlobalScroll() {
    if (_isSyncingScroll) return;
    if (!_isBringingContainerBack) {
      updateContainer1Visibility();
    }

    if (state.isContainer1Visible.value) {
      syncToGlobalScroll();
    }

    paginationHandler.checkPagination();
  }

  void syncToGlobalScroll() {
    if (!globalScrollController.hasClients) return;
    if (_isSyncingScroll) return;

    final globalOffset = globalScrollController.offset;
    final contentOffset = (globalOffset - container1Height).clamp(0.0, double.infinity);

    _isSyncingScroll = true;

    if (circleListController.hasClients) {
      final maxCircleListScroll = circleListController.position.maxScrollExtent;
      final targetCircleListOffset = contentOffset.clamp(0.0, maxCircleListScroll);
      if (circleListController.offset != targetCircleListOffset) {
        circleListController.jumpTo(targetCircleListOffset);
      }
    }

    if (gridScrollController.hasClients) {
      final maxGridScroll = gridScrollController.position.maxScrollExtent;
      final targetGridOffset = contentOffset.clamp(0.0, maxGridScroll);
      if (gridScrollController.offset != targetGridOffset) {
        gridScrollController.jumpTo(targetGridOffset);
      }
    }

    _isSyncingScroll = false;
  }

  void updateContainer1Visibility() {
    if (!globalScrollController.hasClients) return;

    final scrollOffset = globalScrollController.offset;
    final isTopContainerVisible = scrollOffset < container1Height;

    if (state.isContainer1Visible.value != isTopContainerVisible) {
      state.isContainer1Visible.value = isTopContainerVisible;

      if (isTopContainerVisible) {
        _isSyncingScroll = true;
        if (circleListController.hasClients) {
          circleListController.jumpTo(0);
        }
        if (gridScrollController.hasClients) {
          gridScrollController.jumpTo(0);
        }
        
        _isSyncingScroll = false;
        state.leftPhysics.value = const NeverScrollableScrollPhysics();
        state.rightPhysics.value = const NeverScrollableScrollPhysics();
        state.globalPhysics.value = const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );
        syncToGlobalScroll();
      } else {
        final contentOffset = (scrollOffset - container1Height).clamp(0.0, double.infinity);
        
        _isSyncingScroll = true;
        if (circleListController.hasClients) {
          final maxCircleListScroll = circleListController.position.maxScrollExtent;
          final targetCircleListOffset = contentOffset.clamp(0.0, maxCircleListScroll);
          circleListController.jumpTo(targetCircleListOffset);
        }
        if (gridScrollController.hasClients) {
          final maxGridScroll = gridScrollController.position.maxScrollExtent;
          final targetGridOffset = contentOffset.clamp(0.0, maxGridScroll);
          gridScrollController.jumpTo(targetGridOffset);
        }
        
        _isSyncingScroll = false;
        state.leftPhysics.value = ContentState.smoothScrollPhysics;
        state.rightPhysics.value = ContentState.smoothScrollPhysics;
        state.globalPhysics.value = const NeverScrollableScrollPhysics();
      }
    }
  }

  void onLeftScroll() {
    if (!state.isContainer1Visible.value) {
      return;
    }

    if (_isSyncingScroll) return;
    if (!circleListController.hasClients) return;

    final currentOffset = circleListController.offset;
    final globalTarget = container1Height + currentOffset;

    if (globalScrollController.hasClients) {
      final max = globalScrollController.position.maxScrollExtent;
      final target = globalTarget.clamp(0.0, max);
      if (globalScrollController.offset != target) {
        _isSyncingScroll = true;
        globalScrollController.jumpTo(target);
        _isSyncingScroll = false;
      }
    }

    if (gridScrollController.hasClients && !_isSyncingScroll) {
      final maxRight = gridScrollController.position.maxScrollExtent;
      final targetRight = currentOffset.clamp(0.0, maxRight);
      if (gridScrollController.offset != targetRight) {
        _isSyncingScroll = true;
        gridScrollController.jumpTo(targetRight);
        _isSyncingScroll = false;
      }
    }
  }

  void onRightScroll() {
    if (!state.isContainer1Visible.value) {
      paginationHandler.checkPagination();

      if (!isRefreshingFromCircleSelection &&
          gridScrollController.hasClients &&
          gridScrollController.offset <= 0.0 &&
          globalScrollController.hasClients) {
        _bringContainer1Back();
      }

      return;
    }

    if (_isSyncingScroll) return;
    if (!gridScrollController.hasClients) return;

    final currentOffset = gridScrollController.offset;
    final globalTarget = container1Height + currentOffset;

    if (globalScrollController.hasClients) {
      final max = globalScrollController.position.maxScrollExtent;
      final target = globalTarget.clamp(0.0, max);
      if (globalScrollController.offset != target) {
        _isSyncingScroll = true;
        globalScrollController.jumpTo(target);
        _isSyncingScroll = false;
      }
    }

    if (circleListController.hasClients && !_isSyncingScroll) {
      final maxLeft = circleListController.position.maxScrollExtent;
      final targetLeft = currentOffset.clamp(0.0, maxLeft);
      if (circleListController.offset != targetLeft) {
        _isSyncingScroll = true;
        circleListController.jumpTo(targetLeft);
        _isSyncingScroll = false;
      }
    }
  }

  void _bringContainer1Back() {
    if (_isBringingContainerBack) return;
    if (!globalScrollController.hasClients) return;
    
    final currentGlobalOffset = globalScrollController.offset;
    if (currentGlobalOffset <= 0.0) {
      _isBringingContainerBack = false;
      return;
    }
    
    _isBringingContainerBack = true;
    
    state.globalPhysics.value = const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
    
    globalScrollController.jumpTo(0.0);
    _isBringingContainerBack = false;
    
    updateContainer1Visibility();
  }
}
