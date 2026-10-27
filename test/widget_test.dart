import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow/main.dart';

void main() {
  testWidgets('SocialFlowApp launches and renders Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SocialFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify app brand and welcome title appear
    expect(find.text('SocialFlow AI'), findsWidgets);
    expect(find.text('Welcome to SocialFlow AI'), findsOneWidget);
    expect(find.text('Live Pipeline Telemetry'), findsOneWidget);
  });
}
