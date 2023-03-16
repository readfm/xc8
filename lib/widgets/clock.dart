import 'dart:async';

import 'package:flutter/material.dart';

import 'time.dart';

class ClockField extends StatefulWidget {
  int time;
  ClockField({super.key, this.time = 0});

  @override
  State<ClockField> createState() => _ClockFieldState();
}

class _ClockFieldState extends State<ClockField> {
  Timer? timer;
  @override
  void initState() {
    super.initState();

    if (widget.time == 0) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {});
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //seconds
    return Time8Field(
      widget.time == 0
          ? (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          : widget.time,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
