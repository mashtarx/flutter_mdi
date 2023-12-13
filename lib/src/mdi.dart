import 'package:flutter/material.dart';
import 'package:flutter_mdi/src/stack_controller.dart';
import 'package:provider/provider.dart';

import 'mdi_window.dart';

class Mdi extends StatefulWidget {
  final Widget? child;
  const Mdi({this.child, super.key});

  @override
  State<Mdi> createState() => _MdiState();
}

class _MdiState extends State<Mdi> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => StackController(
          child: MdiWindow(
        key: GlobalKey(),
        iniHeight: 300,
        child: widget.child ?? const SizedBox(),
      )),
      builder: (context, child) {
        return Consumer<StackController>(
          builder: (context, value, child) {
            return Stack(
              key: UniqueKey(),
              children: value.windows,
            );
          },
        );
      },
    );
  }
}
