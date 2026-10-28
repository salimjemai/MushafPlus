/// The on-device voice model of the installed apps (Android, iOS): Tarteel
/// AI's `whisper-base-ar-quran` (Apache-2.0) exported to the sherpa-onnx
/// layout and quantised to int8 by the "Voice model" GitHub Actions workflow
/// (`.github/workflows/voice-model.yml`), published as assets of a GitHub
/// Release. The files are downloaded once, on consent, into the app's
/// documents folder (`Downloads.cacheModel`) and never bundled in the store
/// binaries.
///
/// Pure Dart: shared by the native engine, the offline sync and the tests.
library;

class VoiceModelFile {
  const VoiceModelFile(this.name, this.bytes);

  /// Asset name in the release.
  final String name;

  /// Approximate size, for the consent dialog and the progress bar before
  /// the server has told us the real one.
  final int bytes;
}

class VoiceModelPack {
  const VoiceModelPack({required this.variant, required this.releaseTag, required this.files});

  /// `base` or `tiny`: which fine-tune the app uses.
  final String variant;
  final String releaseTag;
  final List<VoiceModelFile> files;

  String get modelId => 'whisper-$variant-ar-quran';

  /// Folder under the app's model store; holds one release tag so a new tag
  /// means a fresh download rather than mixed files.
  String get folder => '$modelId-$releaseTag';

  String get baseUrl => 'https://github.com/salimjemai/MushafPlus/releases/download/$releaseTag/';

  String urlFor(VoiceModelFile f) => '$baseUrl${f.name}';

  VoiceModelFile get encoder => files.firstWhere((f) => f.name.endsWith('-encoder.int8.onnx'));
  VoiceModelFile get decoder => files.firstWhere((f) => f.name.endsWith('-decoder.int8.onnx'));
  VoiceModelFile get tokens => files.firstWhere((f) => f.name.endsWith('-tokens.txt'));

  int get totalBytes => files.fold(0, (a, f) => a + f.bytes);
}

/// The pack the apps download. Sizes are those of the `voice-model-v1`
/// release assets (see the workflow's run summary).
const voiceModelPack = VoiceModelPack(
  variant: 'base',
  releaseTag: 'voice-model-v1',
  files: [
    VoiceModelFile('whisper-base-ar-quran-encoder.int8.onnx', 21 * 1000 * 1000),
    VoiceModelFile('whisper-base-ar-quran-decoder.int8.onnx', 62 * 1000 * 1000),
    VoiceModelFile('whisper-base-ar-quran-tokens.txt', 800 * 1000),
  ],
);
