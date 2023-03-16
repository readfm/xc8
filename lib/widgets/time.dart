import 'dart:ui';

import 'package:flutter/material.dart';

class Time8Field extends StatelessWidget {
  int time;
  Time8Field(this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 1,
        right: 4,
      ),
      width: 98,
      height: 18,
      alignment: Alignment.centerRight,
      child: Text(
        time.toString(),
        style: const TextStyle(
          fontSize: 14,
          color: Color.fromARGB(255, 175, 175, 175),
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
