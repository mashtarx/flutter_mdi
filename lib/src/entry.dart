// ignore: must_be_immutable
import 'package:flutter/material.dart';

import 'mdi_window.dart';

enum MdiStackEntryStretch {
  horizontal,
  vertical,
  maximized,
  none,
}

// ignore: must_be_immutable
class MdiStackEntry extends StatelessWidget {
  final MdiWindow child;
  double x;
  double y;
  // bool maximized;
  bool shown;
  MdiStackEntryStretch stretch;
  MdiStackEntry({
    required this.child,
    this.x = 0,
    this.y = 0,
    this.stretch = MdiStackEntryStretch.none,
    // this.maximized = false,
    this.shown = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (stretch) {
      case MdiStackEntryStretch.none:
        return noneStretched();
      case MdiStackEntryStretch.horizontal:
        return horizontallyStretched();
      case MdiStackEntryStretch.vertical:
        return verticallyStretched();
      case MdiStackEntryStretch.maximized:
        return bothStretched();
    }
  }

  Widget horizontallyStretched() {
    return Positioned(
      top: y,
      left: 0,
      right: 0,
      child: Visibility(
        maintainState: true,
        visible: shown,
        child: child,
      ),
    );
  }

  Widget verticallyStretched() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: x,
      child: Visibility(
        maintainState: true,
        visible: shown,
        child: child,
      ),
    );
  }

  Widget bothStretched() {
    return Positioned.fill(
        child: Visibility(
      maintainState: true,
      visible: shown,
      child: child,
    ));
  }

  Widget noneStretched() {
    return Positioned(
      left: x,
      top: y,
      child: Visibility(
        maintainState: true,
        visible: shown,
        child: child,
      ),
    );
  }
}
