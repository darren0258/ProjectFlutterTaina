import 'package:flutter_test/flutter_test.dart';
import 'package:game_translator/translator_service.dart';

void main() {
  test('normalizeText strips punctuation and case', () {
    expect(normalizeText("  Hey, MAN!  What's up? "), 'hey man what s up');
  });

  test('similarity treats OCR jitter as the same subtitle', () {
    expect(similarity('you better run', 'you better run'), 1);
    expect(similarity('you better run', 'you bettor run'), greaterThan(0.8));
    expect(similarity('you better run', 'get in the car'), lessThan(0.5));
  });
}
