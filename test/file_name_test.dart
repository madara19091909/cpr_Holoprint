import 'package:cpr_holoprint/utils/file_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sanitizeDownloadName', () {
    test('adds mcpack extension when missing', () {
      expect(sanitizeDownloadName('my house'), 'my house.mcpack');
    });

    test('preserves mcaddon extension', () {
      expect(sanitizeDownloadName('pack.mcaddon'), 'pack.mcaddon');
    });

    test('replaces invalid file name characters', () {
      expect(sanitizeDownloadName('house/name?.zip'), 'house_name_.zip.mcpack');
    });

    test('uses a safe default for empty names', () {
      expect(sanitizeDownloadName('   '), 'CPR-Holoprint.mcpack');
    });
  });
}
