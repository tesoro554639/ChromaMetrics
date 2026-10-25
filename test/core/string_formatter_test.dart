import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/core/utils/string_formatter.dart';

void main() {
  group('StringFormatter', () {
    test('maskEmail obfuscates local email part while keeping domain visible', () {
      expect(StringFormatter.maskEmail('alex.chen@acme.com'), equals('a***n@acme.com'));
      expect(StringFormatter.maskEmail('me@startup.io'), equals('me***@startup.io'));
      expect(StringFormatter.maskEmail('plainstring'), equals('plainstring'));
    });

    test('toSlug creates lowercase hyphenated URL friendly strings', () {
      expect(StringFormatter.toSlug('Starlight AI & Robotics'), equals('starlight-ai-robotics'));
      expect(StringFormatter.toSlug('Acme Corp 2026!'), equals('acme-corp-2026'));
    });

    test('truncate shortens strings with ellipsis', () {
      expect(StringFormatter.truncate('Very long organization title', 9), equals('Very long...'));
      expect(StringFormatter.truncate('Short', 10), equals('Short'));
    });

    test('capitalize converts first character to upper case', () {
      expect(StringFormatter.capitalize('active'), equals('Active'));
      expect(StringFormatter.capitalize(''), equals(''));
      expect(StringFormatter.capitalize('hello world'), equals('Hello world'));
    });

    test('maskApiKey hides middle characters safely', () {
      expect(StringFormatter.maskApiKey('sk_live_998877665544'), equals('sk_live_...5544'));
      expect(StringFormatter.maskApiKey('short'), equals('****'));
    });
  });
}
