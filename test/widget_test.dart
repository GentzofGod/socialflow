import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow/main.dart';

void main() {
  testWidgets('OmniFlowApp launches and renders Studio', (WidgetTester tester) async {
    await tester.pumpWidget(const OmniFlowApp());
    await tester.pump();

    // Verify app brand appears
    expect(find.text('OmniFlow Studio'), findsOneWidget);
    expect(find.text('Source Anchor Content'), findsOneWidget);
  });
}
