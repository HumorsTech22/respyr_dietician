import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DietitianResultViewModel {
  final ScrollController scrollController = ScrollController();
  final ScrollController tabScrollController = ScrollController();

  // Section keys
  final gutKey = GlobalKey();
  final fatKey = GlobalKey();
  final liverKey = GlobalKey();

  // Tab keys
  final tabGutKey = GlobalKey();
  final tabFatKey = GlobalKey();
  final tabLiverKey = GlobalKey();

  bool isAnimating = false;

  /// Call this from screen when pinned tabs height changes / measured.
  /// Example: viewModel.setPinnedHeaderHeight(tabsHeight);
  double _pinnedHeaderHeight = 0;
  void setPinnedHeaderHeight(double height) {
    _pinnedHeaderHeight = height;
  }

  /// Scrolls the main CustomScrollView to reveal [key] top,
  /// keeping it visible below AppBar + pinned tabs.
  Future<void> scrollToSection(
      GlobalKey key, {
        double appBarHeight = kToolbarHeight,
        double extraTopPadding = 8, // small breathing space
      }) async {
    if (isAnimating) return;
    if (!scrollController.hasClients) return;

    final ctx = key.currentContext;
    if (ctx == null) return;

    final renderObject = ctx.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return;

    final reveal = viewport.getOffsetToReveal(renderObject, 0.0);
    final rawTarget = reveal.offset;

    final topBlocker = appBarHeight + _pinnedHeaderHeight + extraTopPadding;
    final target = (rawTarget - topBlocker).clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent,
    );

    isAnimating = true;
    try {
      await scrollController.animateTo(
        target.toDouble(),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    } finally {
      isAnimating = false;
    }
  }

  /// Center selected tab in horizontal scroll.
  Future<void> tabScrollTo(GlobalKey tabKey) async {
    if (!tabScrollController.hasClients) return;

    final ctx = tabKey.currentContext;
    if (ctx == null) return;

    final tabRender = ctx.findRenderObject();
    if (tabRender == null || tabRender is! RenderBox) return;

    // This is the render object of the scrollable viewport of the horizontal list
    final tabBarRender = tabScrollController.position.context.storageContext.findRenderObject();
    if (tabBarRender == null || tabBarRender is! RenderBox) return;

    final tabWidth = tabRender.size.width;
    final tabBarWidth = tabBarRender.size.width;

    // Find tab's left position relative to tabBar viewport
    final tabLeftInBar = tabRender.localToGlobal(Offset.zero, ancestor: tabBarRender).dx;

    // Current scroll offset + position inside viewport gives absolute position inside scroll content
    final tabOffsetInScroll = tabLeftInBar + tabScrollController.offset;

    // Center it
    final target = (tabOffsetInScroll - (tabBarWidth / 2) + (tabWidth / 2)).clamp(
      tabScrollController.position.minScrollExtent,
      tabScrollController.position.maxScrollExtent,
    );

    await tabScrollController.animateTo(
      target.toDouble(),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
    );
  }

  /// Optional utility: get section reveal offset (for auto-tab sync)
  double? getSectionRevealOffset(GlobalKey key) {
    if (!scrollController.hasClients) return null;
    final ctx = key.currentContext;
    if (ctx == null) return null;

    final renderObject = ctx.findRenderObject();
    if (renderObject == null) return null;

    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return null;

    return viewport.getOffsetToReveal(renderObject, 0.0).offset;
  }

  void dispose() {
    scrollController.dispose();
    tabScrollController.dispose();
  }
}
