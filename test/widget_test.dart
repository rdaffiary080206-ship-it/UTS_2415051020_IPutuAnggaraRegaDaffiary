import 'package:flutter_test/flutter_test.dart';

import 'package:cinemay/main.dart';

void main() {
  testWidgets('App starts and shows brand title', (WidgetTester tester) async {
    await tester.pumpWidget(const CinemayApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('CINEMAY'), findsWidgets);
  });
}
