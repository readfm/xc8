import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nostr_client/nostr_client.dart' hide Event;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Relay {
  Relay(this._url, {Function? onReady}) {
    _onReady = onReady;
    connect();
  }

  Function? _onReady;

  connect() {
    final uri = Uri.parse(_url);
    try {
      _channel = WebSocketChannel.connect(uri)
        ..ready.then((_) {
          isConnected = true;
          _onReady?.call();
        });
    } catch (e) {
      isConnected = false;
    }
  }

  bool isConnected = false;

  final String _url;
  late final WebSocketChannel _channel;

  /// The relay information document of the relay.
  Future<RelayInformationDocument> get informationDocument async {
    final url = Uri.parse(_url).replace(scheme: 'https');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/nostr+json'},
    );
    return RelayInformationDocument.fromJsonString(response.body);
  }

  /// A stream which emits all messages sent by the relay.
  Stream<Message> get stream {
    return _channel.stream.map((data) => jsonDecode(data) as Message);
  }

  /// Send the given [event] to the realy.
  void send(Map<String, dynamic> m) {
    final message = ['EVENT', m];
    final request = jsonEncode(message);
    _channel.sink.add(request);
  }

  post(Map<String, dynamic> m) {
    final request = jsonEncode(m);
    _channel.sink.add(request);
  }

  /// Subscribe to events that match the given [filter].
  ///
  /// Returns the id of the subscription.
  String req(Filter filter, {String? subscriptionId}) {
    final sid = subscriptionId ?? Uuid().v4();
    final message = ['REQ', sid, filter.toJson()];
    final request = jsonEncode(message);
    _channel.sink.add(request);
    return sid;
  }

  /// Close the subscription with the given [subscriptionId].
  void close(String subscriptionId) {
    final message = ['CLOSE', subscriptionId];
    final messageJson = jsonEncode(message);
    _channel.sink.add(messageJson);
    isConnected = false;
  }

  /// Terminates the connection to the relay.
  ///
  /// Returns a future which is completed as soon as the connection is
  /// terminated. If cleaning up can fail, the error may be reported in the
  /// returned future.
  Future<void> disconnect() async {
    await _channel.sink.close();
  }
}
