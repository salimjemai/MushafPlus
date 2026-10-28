import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mushaf_plus/data/downloads_io.dart' as downloads;
import 'package:mushaf_plus/data/voice_model.dart';

void main() {
  group('VoiceModelPack', () {
    test('names the three sherpa-onnx files of the release', () {
      expect(voiceModelPack.encoder.name, 'whisper-base-ar-quran-encoder.int8.onnx');
      expect(voiceModelPack.decoder.name, 'whisper-base-ar-quran-decoder.int8.onnx');
      expect(voiceModelPack.tokens.name, 'whisper-base-ar-quran-tokens.txt');
      expect(voiceModelPack.urlFor(voiceModelPack.tokens),
          'https://github.com/salimjemai/MushafPlus/releases/download/voice-model-v1/whisper-base-ar-quran-tokens.txt');
      expect(voiceModelPack.folder, 'whisper-base-ar-quran-voice-model-v1');
      expect(voiceModelPack.totalBytes, greaterThan(50 * 1000 * 1000));
      expect(voiceModelPack.totalBytes, lessThan(200 * 1000 * 1000));
    });
  });

  group('model store', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('mushaf-models');
      downloads.modelStoreOverride = root;
    });

    tearDown(() {
      downloads.modelStoreOverride = null;
      downloads.httpClientFactory = null;
      root.deleteSync(recursive: true);
    });

    MockClient streaming(List<List<int>> chunks, {int? contentLength, int status = 200}) => MockClient.streaming((request, body) async {
          return http.StreamedResponse(Stream.fromIterable(chunks), status,
              contentLength: contentLength, request: request);
        });

    test('streams to a temporary file, reports progress and keeps the file only when complete', () async {
      final a = List<int>.generate(1000, (i) => i % 251);
      final b = List<int>.generate(500, (i) => (i * 7) % 251);
      downloads.httpClientFactory = () => streaming([a, b], contentLength: 1500);
      final progress = <(int, int)>[];
      final path = await downloads.cacheModel('pack', 'enc.onnx', 'https://example.test/enc.onnx',
          onProgress: (r, t) => progress.add((r, t)));
      expect(File(path).lengthSync(), 1500);
      expect(File(path).readAsBytesSync().sublist(0, 1000), a);
      expect(progress, [(1000, 1500), (1500, 1500)]);
      expect(File('$path.part').existsSync(), isFalse);
      expect(await downloads.cachedModelPath('pack', 'enc.onnx'), path);
      expect(path, contains('models'));
    });

    test('a second call does not download again', () async {
      downloads.httpClientFactory = () => streaming([List.filled(10, 1)], contentLength: 10);
      final first = await downloads.cacheModel('pack', 'tok.txt', 'https://example.test/tok.txt');
      var calls = 0;
      downloads.httpClientFactory = () {
        calls++;
        return streaming([], contentLength: 0);
      };
      final second = await downloads.cacheModel('pack', 'tok.txt', 'https://example.test/tok.txt');
      expect(second, first);
      expect(calls, 0);
    });

    test('a truncated transfer leaves nothing behind', () async {
      downloads.httpClientFactory = () => streaming([List.filled(100, 1)], contentLength: 300);
      await expectLater(downloads.cacheModel('pack', 'dec.onnx', 'https://example.test/dec.onnx'), throwsException);
      expect(await downloads.cachedModelPath('pack', 'dec.onnx'), isNull);
      final dir = Directory('${root.path}${Platform.pathSeparator}models${Platform.pathSeparator}pack');
      expect(dir.listSync().where((f) => f.path.endsWith('.part')), isEmpty);
    });

    test('an HTTP error is reported', () async {
      downloads.httpClientFactory = () => streaming([], status: 404);
      await expectLater(downloads.cacheModel('pack', 'enc.onnx', 'https://example.test/missing'), throwsException);
      expect(await downloads.cachedModelPath('pack', 'enc.onnx'), isNull);
    });

    test('an unknown length is accepted when the stream ends normally', () async {
      downloads.httpClientFactory = () => streaming([List.filled(40, 2), List.filled(2, 3)]);
      final progress = <(int, int)>[];
      await downloads.cacheModel('pack', 'x.bin', 'https://example.test/x', onProgress: (r, t) => progress.add((r, t)));
      expect(progress.last, (42, 0));
      expect(File((await downloads.cachedModelPath('pack', 'x.bin'))!).lengthSync(), 42);
    });
  });
}
