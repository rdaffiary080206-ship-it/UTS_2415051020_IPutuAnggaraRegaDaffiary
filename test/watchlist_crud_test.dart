import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:cinemay/models/watch_status.dart';
import 'package:cinemay/providers/watchlist_provider.dart';
import 'package:cinemay/repositories/watchlist_repository.dart';
import 'package:cinemay/screens/add_watchlist_screen.dart';
import 'package:cinemay/screens/edit_watchlist_screen.dart';
import 'package:cinemay/screens/watchlist_screen.dart';

import 'fakes.dart';

void main() {
  late FakeWatchlistDataSource dataSource;
  late WatchlistProvider provider;

  setUp(() {
    dataSource = FakeWatchlistDataSource();
    provider = WatchlistProvider(WatchlistRepository(dataSource));
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(home: screen),
      ),
    );
  }

  Future<void> tapSave(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('Create form validates empty title', (tester) async {
    await pumpScreen(tester, const AddWatchlistScreen());
    await tapSave(tester, 'Simpan ke Watchlist');

    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(dataSource.rows, isEmpty);
  });

  testWidgets('Create form saves valid data to database', (tester) async {
    await pumpScreen(tester, const AddWatchlistScreen());
    await tester.enterText(find.byType(TextFormField).first, 'Interstellar');
    await tapSave(tester, 'Simpan ke Watchlist');

    expect(dataSource.rows, hasLength(1));
    expect(dataSource.rows.first['title'], 'Interstellar');
    expect(provider.count, 1);
  });

  testWidgets('Edit form updates existing data', (tester) async {
    dataSource.rows.add({
      'id': 7,
      'show_id': 1,
      'title': 'Under the Dome',
      'status': 'plan_to_watch',
    });
    await provider.loadItems();
    final item = provider.items.single;

    await pumpScreen(tester, EditWatchlistScreen(item: item));
    await tester.tap(find.text('Selesai'));
    await tester.pump();
    await tapSave(tester, 'Simpan Perubahan');

    expect(dataSource.rows.single['status'], 'completed');
    expect(provider.items.single.status, WatchStatus.completed);
  });

  testWidgets('Delete asks for confirmation first', (tester) async {
    dataSource.rows.add({'id': 9, 'show_id': 2, 'title': 'Arrow'});
    await provider.loadItems();

    await pumpScreen(tester, const WatchlistScreen());
    await tester.pumpAndSettle();

    // Batal: data tetap ada.
    await tester.tap(find.byTooltip('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus dari Watchlist?'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(dataSource.rows, hasLength(1));

    // Konfirmasi: data terhapus dari database dan state.
    await tester.tap(find.byTooltip('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();
    expect(dataSource.rows, isEmpty);
    expect(provider.count, 0);
    expect(find.text('"Arrow" dihapus dari watchlist'), findsOneWidget);
  });
}
