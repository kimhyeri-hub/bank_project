import 'package:flutter_test/flutter_test.dart';

import 'package:claude_project/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('약관 분석'), findsWidgets);
    expect(find.text('피싱 탐지'), findsWidgets);
  });
}
