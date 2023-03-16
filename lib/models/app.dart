import 'dart:convert';

import 'package:data8/data.dart';
import 'package:data8/index.dart';
import 'package:data8/tables/events.dart';
import 'package:drift/drift.dart';
import 'package:nostr_client/nostr_client.dart' hide Relay, Event;
/*
import 'package:oo8/models/repo.dart';
import 'package:oo8/models/user.dart';
import 'package:oo8/utils.dart';
import '../db/shared.dart';
import '../db/main.dart';
*/
import 'package:crypto/crypto.dart';
import '../relay.dart';
import 'package:bip340/bip340.dart' as bip340;
import 'package:convert/convert.dart';

import 'user.dart';

class Oo8Fractal {
  late final UserNostr user;

  final events = <Event>[];
  late Relay relay;

  Oo8Fractal() {
    //String host = 'localhost:8080';
//        Uri.base.authority.isEmpty ? 'localhost:8080' : Uri.base.authority;

    relay =
        Relay('ws${FData.isSecure ? 's' : ''}://${FData.host}', onReady: () {
      //synch();
    });
    user = UserNostr();
    //_listen();

    load();
  }

  final listeners = <Function>[];
  listen(Function() fb) {
    listeners.add(fb);
  }

  trigger() {
    for (var fb in listeners) {
      fb();
    }
  }

  _listen() async {
    //final lastSyncAt = await Events.lastSync();
    relay.stream.listen((Message m) {
      if (m.isEvent) {
        //m[2]['createdAt'] = m[2]['created_at'];
        final event = Event.fromJson(m[2]);
        //containts
        if (events.any((e) => e.id == event.id)) return;
        events.insert(0, event);
      }
    });
    relay.req(
      Filter(
        limit: 100,
        /*
        since: lastSyncAt > 0
            ? DateTime.fromMillisecondsSinceEpoch(lastSyncAt * 1000)
            : null,
          */
      ),
    );
  }

  Stream<List<Event>>? stream;
  load() {
    final select = db.select(db.events);
    //select.where((tbl) => tbl.syncAt.equals(0));
    select.orderBy(
      [
        (tbl) => OrderingTerm(
              expression: tbl.createdAt,
              mode: OrderingMode.desc,
            )
      ],
    );
    stream = select.watch();
    stream!.listen((list) {
      events.clear();
      for (final row in list) {
        final event = Events.map[row.id] ??= row;
        events.add(event);
      }

      trigger();
    });
    /*
    (rows) {
      rows.forEach((row) {
        final m = row.toJson();
        m.remove('syncAt');
        m.remove('i');
        m['created_at'] = m['createdAt'];
        m['tags'] = [];
        m.remove('createdAt');
        //relay.send(m);
      });

      if (rows.isNotEmpty) Events.synched();
    };
    */
  }

  Map<String, dynamic> make(Map<String, dynamic> m) {
    final now = DateTime.now(), nowSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final kind = 1;
    final tags = <List<String>>[];
    final key = user.keyPair.publicKey.toLowerCase();

    List data = [0, key, nowSeconds, kind, tags, m['content']];
    String serializedEvent = json.encode(data);
    List<int> hash = sha256.convert(utf8.encode(serializedEvent)).bytes;
    final id = hex.encode(hash);

    final sig = const Signer().sign(
      privateKey: user.keyPair.privateKey,
      message: id,
    );

    final map = {
      //'i': 0,
      'id': id,
      'pubkey': key,
      'createdAt': nowSeconds,
      'kind': kind,
      'tags': tags,
      'sig': sig,
      'file': '',
      'content': '',
      ...m,
    };
    return map;
  }

  void search(String term) {
    //repo.relay.req(Filter());
  }

  synch() {
    if (relay.isConnected) {
      (db.select(db.events)..where((tbl) => tbl.syncAt.equals(0)))
          .get()
          .then((rows) {
        rows.forEach((row) {
          final m = row.toJson();
          m.remove('syncAt');
          //m.remove('i');
          m['created_at'] = m['createdAt'];
          m['tags'] = [];
          m.remove('createdAt');
          relay.send(m);
        });

        if (rows.isNotEmpty) Events.synched();
      });
    }
  }

  Map<String, dynamic> transform(Map<String, dynamic> m) {
    m.remove('syncAt');
    m.remove('i');
    m['created_at'] = m['createdAt'];
    m['tags'] = [];
    m.remove('createdAt');
    return m;
  }

  void post(Map<String, dynamic> m) async {
    final ev = make(m);
    ev['syncAt'] =
        relay.isConnected ? DateTime.now().millisecondsSinceEpoch ~/ 1000 : 0;

    final event = Event.fromJson(ev);

    events.insert(0, event);

    await db.into(db.events).insert(event);

    distribute(ev);
  }

  distribute(Map<String, dynamic> m) {
    if (relay.isConnected) {
      //final ev = transform(m);
      relay.send(m);
    }
  }
}
