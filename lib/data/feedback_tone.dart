import 'feedback_tone_stub.dart'
    if (dart.library.js_interop) 'feedback_tone_web.dart'
    if (dart.library.io) 'feedback_tone_native.dart' as impl;

/// Short audible and haptic cues for the recitation checker.
class FeedbackTone {
  FeedbackTone._();

  /// Call inside a user tap once, so browsers allow sound later.
  static void unlock() => impl.unlock();

  /// A low buzz plus vibration: a word was recited wrongly.
  static void wrong() => impl.wrong();

  /// A soft high tick: the passage was completed.
  static void success() => impl.success();
}
