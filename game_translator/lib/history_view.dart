import 'package:material_ui/material_ui.dart';

import 'translator_service.dart';

/// Big "current" translation plus a scrollable list of earlier lines, so a
/// subtitle that disappeared too fast can still be read.
class TranslationPanel extends StatelessWidget {
  const TranslationPanel({
    super.key,
    required this.history,
    this.liveText,
    this.placeholder = 'รอข้อความ...',
  });

  /// Newest first.
  final List<TranslationEntry> history;

  /// Text that is still being recognised (voice mode partial results).
  final String? liveText;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final current = history.isNotEmpty ? history.first : null;
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (liveText != null && liveText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                liveText!,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          Text(
            current?.translated ?? placeholder,
            style: const TextStyle(
              color: Colors.yellowAccent,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          if (current != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                current.source,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ),
          const Divider(color: Colors.white24, height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: history.length > 1 ? history.length - 1 : 0,
              separatorBuilder: (_, _) =>
                  const Divider(color: Colors.white12, height: 12),
              itemBuilder: (context, i) {
                final e = history[i + 1];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.translated,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    Text(
                      e.source,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
