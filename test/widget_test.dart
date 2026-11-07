import 'package:flutter_test/flutter_test.dart';

import 'package:cinemay/main.dart';

void main() {
  testWidgets('App starts and shows brand title', (WidgetTester tester) async {
    await tester.pumpWidget(const CinemayApp());
    expect(find.text('CINEMAY'), findsOneWidget);
  });
}
