import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/show_provider.dart';
import 'providers/watchlist_provider.dart';
import 'repositories/show_repository.dart';
import 'repositories/watchlist_repository.dart';
import 'screens/main_shell.dart';
import 'services/supabase_service.dart';
import 'services/tvmaze_service.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  runApp(
    CinemayApp(
      showRepository: ShowRepository(TvMazeService()),
      watchlistRepository: WatchlistRepository(SupabaseService.instance),
    ),
  );
}

class CinemayApp extends StatelessWidget {
  const CinemayApp({
    super.key,
    required this.showRepository,
    required this.watchlistRepository,
  });

  final ShowRepository showRepository;
  final WatchlistRepository watchlistRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ShowProvider(showRepository)..loadShows(),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchlistProvider(watchlistRepository)..loadItems(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainShell(),
      ),
    );
  }
}
