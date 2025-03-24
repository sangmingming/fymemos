import 'package:flutter/material.dart';

class BottomSheetPage<T> extends Page<T> {
  final Widget child;
  final bool showDragHandle;
  final bool useSafeArea;

  const BottomSheetPage({
    required this.child,
    this.showDragHandle = false,
    this.useSafeArea = true,
    super.key,
  });

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute<T>(
    settings: this,
    isScrollControlled: true,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    isDismissible: true,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
    ),
    builder:
        (context) => LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: constraints.maxHeight * 0.8, // 最大高度不超过屏幕80%
                ),
                child: IntrinsicHeight(child: child),
              ),
            );
          },
        ),
  );
}
