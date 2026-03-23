import 'package:ava/screens/claims/claim_status_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatLKR formats 0 correctly', () {
    expect(ClaimStatusScreen.formatLKR(0), 'LKR 0');
  });

  test('formatLKR formats 125000 correctly', () {
    expect(ClaimStatusScreen.formatLKR(125000), 'LKR 125,000');
  });

  test('formatLKR formats 1000000 correctly', () {
    expect(ClaimStatusScreen.formatLKR(1000000), 'LKR 1,000,000');
  });
}