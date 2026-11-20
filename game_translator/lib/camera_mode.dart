import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'history_view.dart';
import 'translator_service.dart';

/// Point the phone at the TV: the app reads the subtitle area of the camera
/// image every ~0.4 s and translates automatically whenever the text changes.
class CameraModePage extends StatefulWidget {
  const CameraModePage({super.key});

  @override
  State<CameraModePage> createState() => _CameraModePageState();
}

class _CameraModePageState extends State<CameraModePage> {
  static const _scanInterval = Duration(milliseconds: 400);

  CameraController? _controller;
  CameraDescription? _camera;
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _translator = TranslatorService();

  final List<TranslationEntry> _history = [];
  String _lastNormalized = '';
  bool _busy = false;
  DateTime _lastScan = DateTime.fromMillisecondsSinceEpoch(0);
  String? _error;

  /// Vertical part of the picture (0 = top, 1 = bottom) that contains the
  /// game subtitles. Only text inside it is translated.
  RangeValues _band = const RangeValues(0.65, 0.98);
  bool _speak = false;
  bool _paused = false;
  double _zoom = 1, _minZoom = 1, _maxZoom = 1;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    WakelockPlus.enable();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        _camera!,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
      _minZoom = await controller.getMinZoomLevel();
      _maxZoom = await controller.getMaxZoomLevel();
      if (_maxZoom > 5) _maxZoom = 5;
      _zoom = _minZoom;
      await controller.startImageStream(_onFrame);
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (e) {
      if (mounted) setState(() => _error = 'เปิดกล้องไม่ได้: $e');
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_busy || _paused) return;
    final now = DateTime.now();
    if (now.difference(_lastScan) < _scanInterval) return;
    _busy = true;
    _lastScan = now;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final result = await _recognizer.processImage(input);
      final text = _subtitleText(result, input);
      if (text.isEmpty) return;

      final norm = normalizeText(text);
      if (norm.length < 3) return;
      // Same subtitle as before (or OCR jitter of it) -> skip.
      if (similarity(norm, _lastNormalized) > 0.8) return;
      _lastNormalized = norm;

      final thai = await _translator.translate(text);
      if (!mounted) return;
      setState(() {
        _history.insert(0, TranslationEntry(text, thai));
        if (_history.length > 100) _history.removeLast();
      });
      if (_speak) unawaited(_translator.speak(thai));
    } catch (_) {
      // A single bad frame is not a problem; keep scanning.
    } finally {
      _busy = false;
    }
  }

  static const _orientationDegrees = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _toInputImage(CameraImage image) {
    final controller = _controller;
    final camera = _camera;
    if (controller == null || camera == null) return null;
    final deviceDeg =
        _orientationDegrees[controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation] ??
        90;
    final rotationDeg = camera.lensDirection == CameraLensDirection.front
        ? (camera.sensorOrientation + deviceDeg) % 360
        : (camera.sensorOrientation - deviceDeg + 360) % 360;
    final rotation = InputImageRotationValue.fromRawValue(rotationDeg);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null ||
        format != InputImageFormat.nv21 ||
        image.planes.length != 1) {
      return null;
    }
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Joins the recognised lines whose centre lies inside the subtitle band.
  String _subtitleText(RecognizedText result, InputImage input) {
    final meta = input.metadata!;
    final rotated =
        meta.rotation == InputImageRotation.rotation90deg ||
        meta.rotation == InputImageRotation.rotation270deg;
    final height = rotated ? meta.size.width : meta.size.height;
    final lines = <TextLine>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final y = line.boundingBox.center.dy / height;
        if (y >= _band.start && y <= _band.end) lines.add(line);
      }
    }
    lines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));
    return lines
        .map((l) => l.text.trim())
        // Ignore HUD fragments such as "$" or "12".
        .where((t) => RegExp(r'[A-Za-z]{2,}').hasMatch(t))
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    final c = _controller;
    _controller = null;
    if (c != null) {
      c.stopImageStream().catchError((_) {}).whenComplete(c.dispose);
    }
    _recognizer.close();
    _translator.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(child: Center(child: _preview(controller))),
                  _controls(),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: TranslationPanel(
                history: _history,
                placeholder: _error ??
                    'เล็งกล้องไปที่ทีวี ให้ซับอยู่ในกรอบสีเหลือง',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview(CameraController? controller) {
    if (controller == null || !controller.value.isInitialized) {
      return _error == null
          ? const CircularProgressIndicator()
          : const Icon(Icons.no_photography, color: Colors.white54, size: 48);
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          LayoutBuilder(
            builder: (context, box) => Stack(
              children: [
                Positioned(
                  left: 4,
                  right: 4,
                  top: box.maxHeight * _band.start,
                  height: box.maxHeight * (_band.end - _band.start),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellowAccent, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controls() {
    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'กลับ',
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            tooltip: _paused ? 'เริ่มแปลต่อ' : 'หยุดชั่วคราว',
            icon: Icon(
              _paused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _paused = !_paused),
          ),
          IconButton(
            tooltip: 'อ่านออกเสียงภาษาไทย',
            icon: Icon(
              _speak ? Icons.volume_up : Icons.volume_off,
              color: _speak ? Colors.yellowAccent : Colors.white,
            ),
            onPressed: () {
              setState(() => _speak = !_speak);
              if (!_speak) _translator.stopSpeaking();
            },
          ),
          const Icon(Icons.zoom_in, color: Colors.white54, size: 18),
          SizedBox(
            width: 90,
            child: Slider(
              value: _zoom,
              min: _minZoom,
              max: _maxZoom > _minZoom ? _maxZoom : _minZoom + 1,
              onChanged: _maxZoom > _minZoom
                  ? (v) {
                      setState(() => _zoom = v);
                      _controller?.setZoomLevel(v);
                    }
                  : null,
            ),
          ),
          const Icon(Icons.subtitles, color: Colors.white54, size: 18),
          Expanded(
            child: RangeSlider(
              values: _band,
              min: 0,
              max: 1,
              onChanged: (v) {
                if (v.end - v.start < 0.08) return;
                setState(() => _band = v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
