import 'package:material_ui/material_ui.dart';

import 'camera_mode.dart';
import 'translator_service.dart';
import 'voice_mode.dart';

void main() {
  runApp(const GameTranslatorApp());
}

class GameTranslatorApp extends StatelessWidget {
  const GameTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'แปลเกม',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _ModelState { checking, missing, downloading, ready, failed }

class _HomePageState extends State<HomePage> {
  _ModelState _state = _ModelState.checking;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ready = await TranslatorService.isModelReady();
    if (mounted) {
      setState(() => _state = ready ? _ModelState.ready : _ModelState.missing);
    }
  }

  Future<void> _download() async {
    setState(() => _state = _ModelState.downloading);
    try {
      final ok = await TranslatorService.downloadModels();
      if (mounted) {
        setState(() => _state = ok ? _ModelState.ready : _ModelState.failed);
      }
    } catch (_) {
      if (mounted) setState(() => _state = _ModelState.failed);
    }
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final ready = _state == _ModelState.ready;
    return Scaffold(
      appBar: AppBar(title: const Text('แปลเกมแบบ Real-time')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!ready) _modelCard(),
            _ModeCard(
              icon: Icons.mic,
              title: 'โหมดฟังเสียง',
              description: 'วางมือถือไว้ใกล้ลำโพงทีวี แอปจะฟังบทพูด'
                  'ภาษาอังกฤษแล้วแปลเป็นไทยให้ตลอด ไม่ต้องกดอะไร',
              enabled: ready,
              onTap: () => _open(const VoiceModePage()),
            ),
            _ModeCard(
              icon: Icons.camera_alt,
              title: 'โหมดกล้องอ่านซับ',
              description: 'ตั้งมือถือ (แนวนอน) เล็งไปที่ทีวี ให้ซับอยู่'
                  'ในกรอบสีเหลือง แอปจะอ่านและแปลให้อัตโนมัติ '
                  'พร้อมเก็บประวัติให้อ่านย้อนหลัง',
              enabled: ready,
              onTap: () => _open(const CameraModePage()),
            ),
            const SizedBox(height: 12),
            const Text(
              'เคล็ดลับ:\n'
              '• ในเกมให้เปิดซับไตเติล (Subtitles) และตั้งขนาดใหญ่สุด\n'
              '• โหมดเสียง: ลดเสียงเพลง/เอฟเฟกต์ในเกม เพิ่มเสียงบทพูด\n'
              '• โหมดกล้อง: ใช้ขาตั้งมือถือ แล้วซูมให้เห็นแค่บริเวณซับ\n'
              '• การแปลทำในเครื่อง ไม่ต้องใช้เน็ต (หลังโหลดภาษาครั้งแรก)',
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modelCard() {
    switch (_state) {
      case _ModelState.checking:
        return const Card(
          child: ListTile(
            leading: CircularProgressIndicator(),
            title: Text('กำลังตรวจสอบภาษา...'),
          ),
        );
      case _ModelState.downloading:
        return const Card(
          child: ListTile(
            leading: CircularProgressIndicator(),
            title: Text('กำลังดาวน์โหลดภาษาอังกฤษ-ไทย (~30 MB)'),
            subtitle: Text('ทำครั้งเดียว อาจใช้เวลา 1-2 นาที'),
          ),
        );
      default:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _state == _ModelState.failed
                      ? 'ดาวน์โหลดไม่สำเร็จ ตรวจสอบอินเทอร์เน็ตแล้วลองใหม่'
                      : 'ต้องดาวน์โหลดชุดภาษาอังกฤษ-ไทยก่อนใช้งาน '
                            '(ครั้งเดียว ประมาณ 30 MB แนะนำใช้ Wi-Fi)',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _download,
                  icon: const Icon(Icons.download),
                  label: const Text('ดาวน์โหลดภาษา'),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(description),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
