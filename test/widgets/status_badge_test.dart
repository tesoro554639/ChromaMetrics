import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/core/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge renders PAID status with default label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: BadgeStatus.paid),
        ),
      ),
    );

    expect(find.text('PAID'), findsOneWidget);
  });

  testWidgets('StatusBadge renders custom label when provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(
            status: BadgeStatus.active,
            label: 'LIVE PLAN',
          ),
        ),
      ),
    );

    expect(find.text('LIVE PLAN'), findsOneWidget);
  });

  testWidgets('StatusBadge renders PAST DUE and CANCELED statuses', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge(status: BadgeStatus.pastDue),
              StatusBadge(status: BadgeStatus.canceled),
            ],
          ),
        ),
      ),
    );

    expect(find.text('PAST DUE'), findsOneWidget);
    expect(find.text('CANCELED'), findsOneWidget);
  });

  testWidgets('StatusBadge renders TRIALING and PENDING statuses accurately', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge(status: BadgeStatus.trialing),
              StatusBadge(status: BadgeStatus.pending),
            ],
          ),
        ),
      ),
    );

    expect(find.text('TRIAL'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
  });
}
