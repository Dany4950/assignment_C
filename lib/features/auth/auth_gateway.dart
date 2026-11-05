import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/app_exception.dart';

/// Anonymous Firebase sign-in. Needed only so the Firestore rules can say
/// `request.auth != null`; the user never sees it and no uid is stored in any document.
abstract interface class AuthGateway {
  Future<void> ensureSignedIn();
}

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway(this._auth);

  final FirebaseAuth _auth;
  Future<void>? _inFlight;

  @override
  Future<void> ensureSignedIn() {
    // Persisted session: works offline, no network round trip.
    if (_auth.currentUser != null) return Future<void>.value();
    return _inFlight ??= _signIn().whenComplete(() => _inFlight = null);
  }

  Future<void> _signIn() async {
    try {
      await _auth.signInAnonymously();
    } catch (error) {
      throw mapError(error);
    }
  }
}
