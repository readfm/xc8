import 'package:data8/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:regexpattern/regexpattern.dart';

import 'main.dart';

class FLine extends StatefulWidget {
  String content;
  Function(String)? onSelect;
  double fontSize;
  FLine(
    this.content, {
    super.key,
    this.onSelect,
    this.fontSize = 14,
  });

  @override
  State<FLine> createState() => _FLineState();
}

class _FLineState extends State<FLine> {
  String content = '';
  List<String> options = [];

  @override
  void initState() {
    final iFirstOpt = widget.content.indexOf('|');
    if (iFirstOpt > 0) {
      final iLastOpt = widget.content.lastIndexOf('|');
      final iLastWord = widget.content.indexOf(' ', iLastOpt);

      content = widget.content.substring(iLastWord);
      options = widget.content.substring(0, iLastWord).split('|');
    } else
      content = widget.content;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: options.length,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (options.isNotEmpty)
            Container(
              alignment: Alignment.center,
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontSize: widget.fontSize * 2,
                  color: Colors.black,
                ),
                onTap: (i) {
                  final option = options[i];
                  MyApp.fractal.post({
                    'content': '${option.toUpperCase()} $content',
                  });
                  MyApp.fractal.trigger();
                },
                //mainAxisAlignment: MainAxisAlignment.center,
                tabs: [
                  ...options.map(
                    (opt) => Tab(text: opt),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            height: widget.fontSize + 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...elements,
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get elements {
    final optFirst = content.indexOf('|');
    final optLast = content.lastIndexOf('|');
    final arr = <Object>[];
    if (optLast > optFirst) {
      final options = content.substring(optFirst + 1, optLast).split('|');

      arr.add(
        content.substring(0, optFirst),
      );
      for (var i = 0; i < options.length; i++) {
        final option = options[i];
        arr.add(
          InkWell(
            child: Padding(
              padding: EdgeInsets.only(right: i < options.length - 1 ? 4 : 0),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            onTap: () {
              final before = content.substring(0, optFirst),
                  after = content.substring(optLast + 1);

              widget.onSelect?.call(
                "$before $option $after",
              );
            },
          ),
        );
      }
      arr.add(
        content.substring(optLast + 1),
      );
    } else {
      arr.add(content);
    }

    // split into words

    final words = <Object>[];

    for (var i = 0; i < arr.length; i++) {
      final e = arr[i];
      if (e is String) {
        final split = e.split(' ');
        for (var j = 0; j < split.length; j++) {
          final word = split[j];
          words.add(word);
        }
      } else {
        words.add(e);
      }
    }
    return words
        .map((e) => e is String && e.isSHA256()
            ? JustTheTooltip(
                key: Key(e.trim()),
                tailLength: 10.0,
                preferredDirection: AxisDirection.down,
                isModal: false,
                hoverShowDuration: Duration(seconds: 1),
                backgroundColor: Colors.grey,
                margin: const EdgeInsets.all(20.0),
                child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text(
                    e,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 243, 184, 33),
                    ),
                    //style: linkStyle,
                    /*
                recognizer: onOpen != null
                    ? (TapGestureRecognizer()..onTap = () => onOpen(element))
                    : null,
              ),*/
                  ),
                ),
                content: tipImage(e.trim()),
              )
            : e)
        .map<Widget>((Object e) => e is Widget
            ? e
            : e is String
                ? Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text(
                      e,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                      ),
                      textAlign: TextAlign.center,
                      strutStyle: StrutStyle(),
                    ),
                  )
                : Placeholder())
        .toList();
  }

  tipImage(String val) {
    final bytes = FData.cache[val];
    return bytes != null
        ? Image.memory(bytes)
        : Image.network(
            //"${FData.getHttp}/uploads/${e.trim()}",
            "/uploads/$val",
          );
  }
}
