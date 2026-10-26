import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

AudioPlayer? _player;

AudioPlayer _get() => _player ??= AudioPlayer()..setReleaseMode(ReleaseMode.stop);

void unlock() {}

void _play(String asset) {
  try {
    _get().play(AssetSource(asset), volume: 0.8);
  } catch (_) {}
}

void wrong() {
  HapticFeedback.heavyImpact();
  HapticFeedback.vibrate();
  _play('sounds/wrong.wav');
}

void success() {
  HapticFeedback.lightImpact();
  _play('sounds/success.wav');
}
