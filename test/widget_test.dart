import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:cinemay/main.dart';
import 'package:cinemay/repositories/show_repository.dart';
import 'package:cinemay/services/tvmaze_service.dart';

void main() {
  testWidgets('App shows shows from (mocked) REST API', (tester) async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {
            'id': 1,
            'name': 'Under the Dome',
            'genres': ['Drama'],
            'premiered': '2013-06-24',
            'rating': {'average': 6.5},
            'weight': 98,
          },
        ]),
        200,
      );
    });
    final repo = ShowRepository(TvMazeService(client: client));

    await tester.pumpWidget(CinemayApp(showRepository: repo));
    await tester.pumpAndSettle();

    expect(find.text('CINEMAY'), findsWidgets);
    expect(find.text('Under the Dome'), findsWidgets);
  });
}
