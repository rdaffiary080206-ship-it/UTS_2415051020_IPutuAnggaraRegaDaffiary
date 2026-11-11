import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:cinemay/main.dart';
import 'package:cinemay/repositories/show_repository.dart';
import 'package:cinemay/repositories/watchlist_repository.dart';
import 'package:cinemay/services/tvmaze_service.dart';

import 'fakes.dart';

void main() {
  late ShowRepository showRepo;
  late WatchlistRepository watchlistRepo;

  setUp(() {
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
    showRepo = ShowRepository(TvMazeService(client: client));
    watchlistRepo = WatchlistRepository(
      FakeWatchlistDataSource([
        {'id': 1, 'show_id': 1, 'title': 'Under the Dome', 'status': 'watching'},
      ]),
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      CinemayApp(showRepository: showRepo, watchlistRepository: watchlistRepo),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Home shows data from (mocked) REST API', (tester) async {
    await pumpApp(tester);
    expect(find.text('CINEMAY'), findsWidgets);
    expect(find.text('Under the Dome'), findsWidgets);
  });

  testWidgets('Watchlist tab shows data from database', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pumpAndSettle();
    expect(find.text('Sedang Ditonton'), findsWidgets);
  });

  testWidgets('Home shows error state and retries on failure', (tester) async {
    var shouldFail = true;
    final flakyClient = MockClient((request) async {
      if (shouldFail) {
        return http.Response('Server error', 500);
      }
      return http.Response(
        jsonEncode([
          {'id': 2, 'name': 'Person of Interest', 'genres': ['Action']},
        ]),
        200,
      );
    });
    final flakyRepo = ShowRepository(TvMazeService(client: flakyClient));

    await tester.pumpWidget(
      CinemayApp(
        showRepository: flakyRepo,
        watchlistRepository: watchlistRepo,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal Memuat Katalog'), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Person of Interest'), findsWidgets);
  });
}
