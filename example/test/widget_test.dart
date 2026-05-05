import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_text_example/main.dart';

void main() {
  testWidgets('demo app builds and shows expected text',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveTextExampleApp());
    expect(find.text('adaptive_text'), findsOneWidget);
    expect(find.textContaining('Auto-adaptive'), findsOneWidget);
  });
}
