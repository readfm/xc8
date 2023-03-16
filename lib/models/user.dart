import 'package:nostr_client/nostr_client.dart';

import 'app.dart';

class UserNostr {
  late KeyPair keyPair;

  UserNostr() {
    keyPair = RandomKeyPairGenerator().generate();
    // upload key pair to server

    // download key pair from server
  }
}
