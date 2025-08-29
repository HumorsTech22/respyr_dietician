import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DietitianResultViewModel {
  final ScrollController scrollController = ScrollController();
  final ScrollController tabScrollController = ScrollController();
  final gutKey = GlobalKey();
  final fatKey = GlobalKey();
  final liverKey = GlobalKey();

  final tabGutKey = GlobalKey();
  final tabFatKey = GlobalKey();
  final tabLiverKey = GlobalKey();
  bool isAnimating = false;

  Future<void> scrollTo(GlobalKey key) async {
    if (isAnimating) return;
    isAnimating = true;

    final ctx = key.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox;
      final viewport = RenderAbstractViewport.of(box);
      final offset = viewport.getOffsetToReveal(box, 0.5).offset;

      await scrollController.animateTo(
        offset - 10,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    isAnimating = false;
  }

  void tabScrollTo(GlobalKey tabKey) {
    final ctx = tabKey.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final tabBarBox =
        tabScrollController.position.context.storageContext.findRenderObject()
            as RenderBox;

    final tabWidth = box.size.width;
    final tabBarWidth = tabBarBox.size.width;

    final tabOffset =
        box.localToGlobal(Offset.zero, ancestor: tabBarBox).dx +
        tabScrollController.offset;

    final target = tabOffset - (tabBarWidth / 2) + (tabWidth / 2);

    tabScrollController.animateTo(
      target.clamp(
        tabScrollController.position.minScrollExtent,
        tabScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}
