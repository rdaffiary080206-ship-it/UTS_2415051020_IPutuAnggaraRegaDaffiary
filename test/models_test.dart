import 'package:flutter_test/flutter_test.dart';

import 'package:cinemay/models/show.dart';
import 'package:cinemay/models/watch_status.dart';
import 'package:cinemay/models/watchlist_item.dart';

void main() {
  test('Show.fromJson parses TVMaze JSON', () {
    final show = Show.fromJson({
      'id': 1,
      'name': 'Under the Dome',
      'genres': ['Drama', 'Science-Fiction'],
      'status': 'Ended',
      'premiered': '2013-06-24',
      'runtime': 60,
      'rating': {'average': 6.5},
      'network': {'name': 'CBS'},
      'image': {'medium': 'm.jpg', 'original': 'o.jpg'},
      'summary': '<p><b>Under the Dome</b> is a story.</p>',
      'weight': 98,
    });

    expect(show.id, 1);
    expect(show.year, '2013');
    expect(show.rating, 6.5);
    expect(show.network, 'CBS');
    expect(show.posterUrl, 'm.jpg');
    expect(show.plainSummary, 'Under the Dome is a story.');
  });

  test('Show.fromJson tolerates null fields', () {
    final show = Show.fromJson({'id': 2, 'name': 'X', 'rating': {}});
    expect(show.rating, isNull);
    expect(show.genres, isEmpty);
    expect(show.posterUrl, isNull);
  });

  test('WatchlistItem map round trip', () {
    final item = WatchlistItem.fromMap({
      'id': 10,
      'show_id': 1,
      'title': 'Under the Dome',
      'status': 'watching',
      'personal_rating': 8,
      'progress': 'S1 E5',
      'note': 'Seru',
    });
    expect(item.status, WatchStatus.watching);
    expect(item.personalRating, 8.0);
    expect(item.toMap()['status'], 'watching');
    expect(item.toMap().containsKey('id'), isFalse);
  });
}
