import 'package:flutter/material.dart';

class Input8 extends StatefulWidget {
  TextEditingController controller;
  final Function(String) onSubmit;
  double fontSize;

  Input8(
    this.controller, {
    required this.onSubmit,
    super.key,
    this.fontSize = 12,
  });

  @override
  State<Input8> createState() => _Input8State();
}

class _Input8State extends State<Input8> {
  final focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      height: widget.fontSize + 10,
      child: TextFormField(
        focusNode: focusNode,
        autofocus: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: widget.fontSize,
        ),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.all(0),
          border: InputBorder.none,
        ),
        controller: widget.controller,
        onFieldSubmitted: (str) {
          widget.onSubmit(str);
          focusNode.requestFocus();
        },
      ),
    );
  }
}
