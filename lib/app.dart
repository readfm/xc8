import 'dart:async';
import 'package:data8/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_client/nostr_client.dart'
    show KeyPair, RandomKeyPairGenerator;
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'line.dart';
import 'models/app.dart';
import 'widgets/input.dart';
import 'widgets/time.dart';

class Oo8App extends StatefulWidget {
  Oo8Fractal app;

  Oo8App(this.app, {super.key});

  @override
  State<Oo8App> createState() => _Oo8AppState();
}

class _Oo8AppState extends State<Oo8App> {
  Oo8Fractal get app => widget.app;

  final list = <TextEditingController>[];

  List<Event> get events => app.events;

  @override
  void initState() {
    super.initState();

    _listener = app.listen(() {
      setState(() {});
    });

    urlCtrl.addListener(() {
      setState(() {});
    });

    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            urlCtrl.text = url;
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (false && request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );
  }

  final urlCtrl = TextEditingController();

  StreamSubscription<List<Event>>? _listener;
  var search = '';

  final focus = FocusNode();

  late final _ctrlPrvKey =
      TextEditingController(text: app.user.keyPair.privateKey);

  late final _ctrlPubKey =
      TextEditingController(text: app.user.keyPair.publicKey);

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..loadRequest(Uri.parse('https://nostrica.com'));

  // gravity is our present moment, everything else is electromagnetic potential synchronizing into

  int selected = 0;
  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: urlCtrl,
          onFieldSubmitted: (value) {
            if (!value.contains('://')) value = 'https://$value';
            controller.loadRequest(
              Uri.parse(value),
            );
          },
          decoration: InputDecoration(
            hintText: 'URL',
            border: InputBorder.none,
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  ...events
                      .where((ev) => !ev.content.contains('|'))
                      .map((event) => Input8Area(
                            key: ValueKey(event.id),
                            event: event,
                            editable: selected == ++i,
                          )),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(children: [
        Container(
          height: 40,
          child: Input8Area(
            editable: selected == 0,
            fontSize: 24,
            onSubmit: (m) {
              app.post(m);

              setState(() {});
              /*
                      if (value.startsWith('.') && search != value) {
                        filter(
                          value.substring(1),
                        );
                      } else if (search.isNotEmpty) {
                        filter();
                      }
                      */
            },
          ),
        ),
        Container(
          height: 80,
          color: Colors.black,
          child: SingleChildScrollView(
            child: RawKeyboardListener(
              onKey: keyboard,
              focusNode: focus,
              child: Column(
                children: [
                  ...events
                      .where((ev) => ev.content.contains('|'))
                      .map((event) => Input8Area(
                            key: ValueKey(event.id),
                            event: event,
                            editable: selected == ++i,
                          )),
                  /*
              QrImage(
                data: app.user.keyPair.publicKey,
                version: QrVersions.auto,
                size: 320,
                gapless: false,
              ),
              */
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: WebViewWidget(controller: controller),
        ),
      ]),
    );
  }

  keyboard(RawKeyEvent k) {
    // if u hold option key
    if (k.isAltPressed) {
      // if u press up or down
      if (k.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        if (selected == 0) return;
        setState(() {
          final index = selected - 1;
          final active = events[index];
          events[index] = events[index - 1];
          events[index - 1] = active;
          selected = index;
        });
      } else if (k.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        setState(() {
          final index = selected - 1;
          final active = events[index];
          events[index] = events[index + 1];
          events[index + 1] = active;
          selected = index + 2;
        });
      }
    } else if (k.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      if (selected > 0) {
        setState(() {
          selected--;
        });
      }
    } else if (k.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      if (selected < events.length) {
        setState(() {
          selected++;
        });
      }
    }
  }

/*
  ListView.builder(
  itemBuilder: (context, index) => buildRow(index),
  itemCount: trackList.length,
),
*/

/*
  Widget buildRow(int index) {
    final track = trackList[index];
    ListTile tile = ListTile(
      title: Text('${track.getName()}'),
    );
    Draggable draggable = LongPressDraggable<Track>(
      data: track,
      axis: Axis.vertical,
      maxSimultaneousDrags: 1,
      child: tile,
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: tile,
      ),
      feedback: Material(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          child: tile,
        ),
        elevation: 4.0,
      ),
    );

    return DragTarget<Track>(
      onWillAccept: (track) {
        return trackList.indexOf(track) != index;
      },
      onAccept: (track) {
        setState(() {
          int currentIndex = trackList.indexOf(track);
          trackList.remove(track);
          trackList.insert(currentIndex > index ? index : index - 1, track);
        });
      },
      builder: (BuildContext context, List<Track> candidateData,
          List<dynamic> rejectedData) {
        return Column(
          children: <Widget>[
            AnimatedSize(
              duration: Duration(milliseconds: 100),
              vsync: this,
              child: candidateData.isEmpty
                  ? Container()
                  : Opacity(
                      opacity: 0.0,
                      child: tile,
                    ),
            ),
            Card(
              child: candidateData.isEmpty ? draggable : tile,
            )
          ],
        );
      },
    );
  }
  */
}
