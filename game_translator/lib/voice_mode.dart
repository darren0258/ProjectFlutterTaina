import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'history_view.dart';
import 'translator_service.dart';

/// Put the phone near the TV speaker: the app listens continuously and
/// translates every spoken sentence into Thai, restarting by itself.
class VoiceModePage extends StatefulWidget {
  const VoiceModePage({super.key});

  @override
  State<VoiceModePage> createState() => _VoiceModePageState();
}

class _VoiceModePageState extends State<VoiceModePage> {
  final _speech = SpeechToText();
  final _translator = TranslatorService();
  final List<TranslationEntry> _history = [];

  bool _running = false;
  bool _available = false;
  String? _localeId;
  String _live = '';
  String _liveThai = '';
  String _lastPartialTranslated = '';
  DateTime _lastPartialAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _partialBusy = false;
  Timer? _restartTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _init();
  }

  Future<void> _init() async {
    _available = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );
    if (!_available) {
      setState(
        () => _error =
            'มือถือเครื่องนี้ไม่รองรับการฟังเสียง หรือไม่ได้อนุญาตไมโครโฟน',
      );
      return;
    }
    final locales = await _speech.locales();
    final english = locales.where((l) => l.localeId.startsWith('en')).toList();
    _localeId = english
        .firstWhere(
          (l) => l.localeId == 'en_US',
          orElse: () => english.isNotEmpty ? english.first : locales.first,
        )
        .localeId;
    _start();
  }

  void _start() {
    setState(() {
      _running = true;
      _error = null;
    });
    _listen();
  }

  Future<void> _stop() async {
    _restartTimer?.cancel();
    setState(() => _running = false);
    await _speech.stop();
  }

  Future<void> _listen() async {
    if (!_running || !mounted || _speech.isListening) return;
    try {
      await _speech.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          localeId: _localeId,
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          listenFor: const Duration(minutes: 1),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      _scheduleRestart();
    }
  }

  /// Android stops listening after each sentence/silence; start again.
  void _scheduleRestart() {
    if (!_running) return;
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(milliseconds: 250), _listen);
  }

  void _onStatus(String status) {
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      _scheduleRestart();
    }
    if (mounted) setState(() {});
  }

  void _onError(SpeechRecognitionError error) {
    // "no match" / "speech timeout" just mean silence; keep listening.
    _scheduleRestart();
  }

  Future<void> _onResult(SpeechRecognitionResult result) async {
    final text = result.recognizedWords.trim();
    if (text.isEmpty) return;
    if (result.finalResult) {
      final thai = await _translator.translate(text);
      if (!mounted) return;
      setState(() {
        _history.insert(0, TranslationEntry(text, thai));
        if (_history.length > 100) _history.removeLast();
        _live = '';
        _liveThai = '';
        _lastPartialTranslated = '';
      });
      return;
    }
    // Translate the half-finished sentence too, at most ~2 times a second.
    setState(() => _live = text);
    final now = DateTime.now();
    if (_partialBusy ||
        text == _lastPartialTranslated ||
        now.difference(_lastPartialAt) < const Duration(milliseconds: 500)) {
      return;
    }
    _partialBusy = true;
    _lastPartialAt = now;
    _lastPartialTranslated = text;
    try {
      final thai = await _translator.translate(text);
      if (mounted && _live.isNotEmpty) setState(() => _liveThai = thai);
    } finally {
      _partialBusy = false;
    }
  }

  @override
  void dispose() {
    _running = false;
    _restartTimer?.cancel();
    _speech.cancel();
    _translator.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listening = _speech.isListening;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        title: const Text('โหมดฟังเสียง'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.mic,
              color: _running && listening ? Colors.redAccent : Colors.white38,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TranslationPanel(
              history: _history,
              liveText: _liveThai.isNotEmpty ? '$_liveThai …' : _live,
              placeholder:
                  _error ??
                  (_running
                      ? 'กำลังฟัง... วางมือถือไว้ใกล้ลำโพงทีวี'
                      : 'กดปุ่มด้านล่างเพื่อเริ่มฟัง'),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _running ? Colors.redAccent : Colors.green,
                  ),
                  onPressed: !_available ? null : (_running ? _stop : _start),
                  icon: Icon(_running ? Icons.stop : Icons.mic),
                  label: Text(
                    _running ? 'หยุดฟัง' : 'เริ่มฟังและแปล',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
