import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_adaptive_text_example/main.dart';

void main() {
  testWidgets('demo app builds and shows expected text',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveTextExampleApp());
    expect(find.text('flutter_adaptive_text'), findsOneWidget);
    expect(
      find.textContaining('WCAG 2.1 & APCA'),
      findsOneWidget,
    );
  });
}
