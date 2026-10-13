import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/core/widgets/metric_card.dart';

void main() {
  testWidgets('MetricCard displays title, value, subtitle and positive trend', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            title: 'Monthly Recurring Revenue',
            value: '\$48,500',
            subtitle: 'vs last month',
            percentageChange: 12.5,
            icon: Icons.attach_money,
          ),
        ),
      ),
    );

    // Verify Title & Value
    expect(find.text('Monthly Recurring Revenue'), findsOneWidget);
    expect(find.text('\$48,500'), findsOneWidget);
    expect(find.text('vs last month'), findsOneWidget);
    expect(find.text('+12.5%'), findsOneWidget);
    expect(find.byIcon(Icons.attach_money), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
  });

  testWidgets('MetricCard displays negative trend icon and percentage correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            title: 'User Churn',
            value: '2.4%',
            percentageChange: -0.8,
            icon: Icons.person_remove_outlined,
          ),
        ),
      ),
    );

    expect(find.text('User Churn'), findsOneWidget);
    expect(find.text('2.4%'), findsOneWidget);
    expect(find.text('-0.8%'), findsOneWidget);
    expect(find.byIcon(Icons.trending_down), findsOneWidget);
  });
}
