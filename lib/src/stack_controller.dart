import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'entry.dart';
import 'mdi_window.dart';

class StackController extends ChangeNotifier {
  final List<MdiStackEntry> _windows = [];
  final List<MdiStackEntry> _minimized = [];
  var showStatusBar = true;
  late final MdiStackEntry statusBar;

  List<MdiStackEntry> get windows => _windows;
  List<MdiStackEntry> get minimized => _minimized;

  StackController({MdiWindow? child}) {
    var bar = MdiWindow(
      key: GlobalKey(),
      titleBar: false,
      iniHeight: 40,
      y: 580,
      child: const StatusBar(),
    );
    if (child != null) {
      _windows.add(MdiStackEntry(child: child));
    }
    statusBar = MdiStackEntry(
        y: 580, stretch: MdiStackEntryStretch.horizontal, child: bar);
    _windows.add(statusBar);
  }

  MdiStackEntry getEntry(MdiWindow window) {
    int ind = windows.indexWhere((win) => window == win.child);
    var entry = windows.removeAt(ind);
    return entry;
  }

  void _setStatusBar() {
    int ind = windows.indexWhere((win) => statusBar == win);
    var entry = windows.removeAt(ind);
    windows.add(entry);
  }

  void close(MdiWindow window) {
    if (!window.details.onClose()) {
      return;
    }
    int ind = windows.indexWhere((win) => window == win.child);
    windows.removeAt(ind);
    notifyListeners();
  }

  void addWindow({
    Widget? child,
    double? width,
    double? height,
    double? x,
    double? y,
    bool Function()? onClose,
    bool Function()? onMinimize,
    bool Function()? onMaximize,
  }) {
    var win = MdiWindow(
      key: GlobalKey(),
      iniWidth: width ?? 700,
      iniHeight: height ?? 500,
      x: x ?? 0,
      y: y ?? 0,
      onClose: onClose,
      onMaximize: onMaximize,
      onMinimize: onMinimize,
      child: child ?? const SizedBox(),
    );
    var det = win.details;
    var entry = MdiStackEntry(x: det.x, y: det.y, child: win);
    windows.add(entry);
    _setStatusBar();
    notifyListeners();
  }

  void getFocus(MdiWindow window) {
    var entry = getEntry(window);
    windows.add(entry);
    _setStatusBar();
    notifyListeners();
  }

  void minimize(MdiWindow window) {
    if (!window.details.onMinimize()) {
      return;
    }
    var entry = getEntry(window);
    window.details.shown = false;
    entry.shown = window.details.shown;
    windows.insert(0, entry);
    _minimized.add(entry);
    notifyListeners();
  }

  void move(MdiWindow window, DragUpdateDetails drag) {
    window.details.x += drag.delta.dx;
    window.details.y += drag.delta.dy;
    int ind = windows.indexWhere((win) => window == win.child);
    var entry = windows.removeAt(ind);
    entry.x = window.details.x;
    entry.y = window.details.y;
    windows.insert(ind, entry);
    notifyListeners();
  }

  void unMinimize(MdiWindow window) {
    int ind = windows.indexWhere((win) => window == win.child);
    var entry = windows.removeAt(ind);
    window.details.shown = true;
    entry.shown = window.details.shown;
    windows.add(entry);
    _setStatusBar();
    _minimized.remove(entry);
    notifyListeners();
  }

  void maximize(MdiWindow window) {
    if (!window.details.onMinimize()) {
      return;
    }
    window.details.maximized = true;
    int ind = windows.indexWhere((win) => window == win.child);
    var entry = windows.removeAt(ind);
    entry.stretch = MdiStackEntryStretch.maximized;
    windows.add(entry);
    _setStatusBar();
    notifyListeners();
  }

  void unMaximize(MdiWindow window) {
    window.details.maximized = true;
    int ind = windows.indexWhere((win) => window == win.child);
    var entry = windows[ind];
    entry.stretch = MdiStackEntryStretch.none;

    window.details.maximized = false;
    notifyListeners();
  }
}

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StackController>(
      builder: (context, value, child) {
        return Row(
          children: value.minimized.map((e) {
            return InkWell(
              onTap: () {
                value.unMinimize(e.child);
              },
              child: Container(
                width: 20,
                height: 20,
                color: Colors.blue,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
