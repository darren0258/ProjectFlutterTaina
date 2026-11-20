import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// One translated subtitle line kept in the on-screen history.
class TranslationEntry {
  TranslationEntry(this.source, this.translated) : time = DateTime.now();
  final String source;
  final String translated;
  final DateTime time;
}

/// Offline English -> Thai translation (Google ML Kit) plus optional Thai
/// text-to-speech. Everything runs on the phone, so it is fast and works
/// without internet once the language model is downloaded.
class TranslatorService {
  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.thai,
  );
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  static final _modelManager = OnDeviceTranslatorModelManager();

  static Future<bool> isModelReady() async {
    return await _modelManager
            .isModelDownloaded(TranslateLanguage.english.bcpCode) &&
        await _modelManager.isModelDownloaded(TranslateLanguage.thai.bcpCode);
  }

  /// Downloads the ~30 MB English/Thai models (only needed once).
  static Future<bool> downloadModels() async {
    final en = await _modelManager.downloadModel(
      TranslateLanguage.english.bcpCode,
      isWifiRequired: false,
    );
    final th = await _modelManager.downloadModel(
      TranslateLanguage.thai.bcpCode,
      isWifiRequired: false,
    );
    return en && th;
  }

  Future<String> translate(String text) => _translator.translateText(text);

  Future<void> speak(String thai) async {
    if (!_ttsReady) {
      await _tts.setLanguage('th-TH');
      await _tts.setSpeechRate(0.55);
      _ttsReady = true;
    }
    await _tts.stop();
    await _tts.speak(thai);
  }

  Future<void> stopSpeaking() => _tts.stop();

  Future<void> dispose() async {
    await _tts.stop();
    await _translator.close();
  }
}

/// Lower-cases and strips punctuation so OCR noise does not count as a
/// "new" subtitle.
String normalizeText(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Similarity between 0 (different) and 1 (identical), Levenshtein based.
double similarity(String a, String b) {
  if (a == b) return 1;
  if (a.isEmpty || b.isEmpty) return 0;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  var cur = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    cur[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      final del = prev[j] + 1;
      final ins = cur[j - 1] + 1;
      final sub = prev[j - 1] + cost;
      cur[j] = del < ins ? (del < sub ? del : sub) : (ins < sub ? ins : sub);
    }
    final t = prev;
    prev = cur;
    cur = t;
  }
  final maxLen = a.length > b.length ? a.length : b.length;
  return 1 - prev[b.length] / maxLen;
}
