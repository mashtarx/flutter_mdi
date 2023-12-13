import 'package:flutter/material.dart';
import 'package:flutter_mdi/src/stack_controller.dart';
import 'package:provider/provider.dart';

class MdiWindowDetails {
  double width;
  double height;
  double x;
  double y;
  bool shown = true;
  bool titleBar = true;
  bool maximized = false;
  late bool Function() onClose;
  late bool Function() onMinimize;
  late bool Function() onMaximize;

  MdiWindowDetails({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    this.titleBar = true,
    bool Function()? onClose,
    bool Function()? onMaximize,
    bool Function()? onMinimize,
  }) {
    this.onClose = onClose ?? () => true;
    this.onMinimize = onMinimize ?? () => true;
    this.onMaximize = onMaximize ?? () => true;
  }
}

class MdiWindowData extends InheritedWidget {
  final MdiWindow window;
  const MdiWindowData(this.window, {required super.child, super.key});

  static MdiWindowData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MdiWindowData>();
  }

  static MdiWindowData of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, "no window data");
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class MdiWindow extends StatelessWidget {
  final double iniHeight;
  final double iniWidth;
  final double minWidth;
  final double minHeight;
  late final MdiWindowDetails details;

  final Widget child;
  MdiWindow({
    required this.child,
    this.iniWidth = 700,
    this.iniHeight = 500,
    this.minWidth = 500,
    this.minHeight = 300,
    double x = 0,
    double y = 0,
    bool titleBar = true,
    bool Function()? onClose,
    bool Function()? onMinimize,
    bool Function()? onMaximize,
    super.key,
  }) {
    details = MdiWindowDetails(
      width: iniWidth,
      height: iniHeight,
      x: x,
      y: y,
      titleBar: titleBar,
      onClose: onClose,
      onMaximize: onMaximize,
      onMinimize: onMinimize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StackController>(
      builder: (context, value, chld) {
        return GestureDetector(
          onTap: () {
            value.getFocus(this);
          },
          child: Container(
            width: details.width,
            height: details.height,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x54000000),
                    spreadRadius: 4,
                    blurRadius: 5,
                  ),
                ],
                borderRadius: BorderRadius.all(
                    Radius.circular(details.maximized ? 0 : 5))),
            child: ClipRRect(
                borderRadius: BorderRadius.all(
                    Radius.circular(details.maximized ? 0 : 5)),
                child: MdiWindowData(
                  this,
                  child: Column(
                    children: [
                      getTitleBar(),
                      Expanded(child: child),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  Widget getTitleBar() {
    if (details.maximized && details.titleBar) {
      return MdiWindowMaximizedTitleBar(this);
    } else if (details.titleBar && !details.maximized) {
      return MdiWindowFloatingTitleBar(this);
    } else {
      return SizedBox();
    }
  }
}

class MdiWindowMaximizedTitleBar extends StatelessWidget {
  final MdiWindow window;
  const MdiWindowMaximizedTitleBar(this.window, {super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<StackController>(context, listen: false);
    return Container(
      color: Colors.blue,
      height: 20,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(),
          ),
          InkWell(
              onTap: () {},
              child: PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      onTap: () {
                        controller.unMaximize(window);
                      },
                      value: "unMaximize",
                      child: Icon(Icons.fullscreen_rounded),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        controller.close(window);
                      },
                      value: "unMaximize",
                      child: Icon(Icons.close),
                    )
                  ];
                },
                child: Icon(Icons.more_vert),
              )),
        ],
      ),
    );
  }
}

class MdiWindowFloatingTitleBar extends StatelessWidget {
  final MdiWindow window;
  const MdiWindowFloatingTitleBar(this.window, {super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<StackController>(context, listen: false);
    return GestureDetector(
      onPanUpdate: (details) {
        controller.move(window, details);
      },
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: Colors.cyan,
        ),
        child: Row(
          children: [
            Expanded(child: SizedBox()),
            InkWell(
              onTap: () {
                controller.minimize(window);
              },
              child: Icon(Icons.horizontal_rule),
            ),
            SizedBox(width: 5),
            InkWell(
              onTap: () {
                controller.maximize(window);
              },
              child: Icon(Icons.fullscreen),
            ),
            SizedBox(width: 5),
            InkWell(
              onTap: () {
                controller.close(window);
              },
              child: Icon(Icons.close),
            ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}

class MdiWindowProvider extends ChangeNotifier {}
