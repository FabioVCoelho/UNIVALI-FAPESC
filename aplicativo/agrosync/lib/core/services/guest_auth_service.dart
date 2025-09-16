import 'package:hive/hive.dart';

/// Lightweight guest session helper backed by Hive so it works fully offline.
class GuestAuthService {
  static const String _metaBox = 'plant_meta_box';
  static const String _guestKey = 'guest_mode_enabled';

  /// Returns true if a guest session is active (even without internet).
  static bool isGuest() {
    try {
      final box = Hive.box(_metaBox);
      return box.get(_guestKey, defaultValue: false) == true;
    } catch (_) {
      return false;
    }
  }

  /// Enable guest session flag.
  static Future<void> signInAsGuest() async {
    try {
      final box = Hive.box(_metaBox);
      await box.put(_guestKey, true);
    } catch (_) {}
  }

  /// Clear guest session flag.
  static Future<void> signOutGuest() async {
    try {
      final box = Hive.box(_metaBox);
      await box.delete(_guestKey);
    } catch (_) {}
  }
}
