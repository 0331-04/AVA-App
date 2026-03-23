import 'package:ava/screens/claims/claim_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleClaim = ClaimStatusData(
    claimId: '#AVA-CLM-2026-000101',
    vehicle: 'Toyota Corolla 2020',
    licensePlate: 'CAB-1234',
    damageType: 'Front bumper and headlight damage',
    submittedDate: 'Mar 23, 2026',
    estimatedCompletion: 'Pending',
    estimateLKR: 120000,
    labourLKR: 30000,
    partsLKR: 70000,
    otherLKR: 20000,
    aiConfidence: 0.8,
    currentStatus: 'Assessment',
    currentStepIndex: 2,
    assessorNotes: [
      'Status: Assessment',
      'AI severity: Severe',
      'Detected damages: broken_part',
      'Estimated repair cost: LKR 108,000 - LKR 230,000',
    ],
    photosUploaded: 1,
  );

  test('ClaimStatusScreen.formatLKR formats currency correctly', () {
    expect(ClaimStatusScreen.formatLKR(125000), 'LKR 125,000');
  });

  testWidgets('Claim Status screen renders supplied claim content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ClaimStatusScreen(claim: sampleClaim)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toyota Corolla 2020'), findsOneWidget);
    expect(find.textContaining('CAB-1234'), findsWidgets);
    expect(find.textContaining('AI severity: Severe'), findsOneWidget);
    expect(find.textContaining('Detected damages: broken_part'), findsOneWidget);
  });

  testWidgets('Claim Status screen shows fallback state without token', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClaimStatusScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('No Claims'), findsWidgets);
  });
}