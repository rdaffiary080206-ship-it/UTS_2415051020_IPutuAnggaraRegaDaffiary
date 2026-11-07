import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/show_provider.dart';
import 'providers/watchlist_provider.dart';
import 'repositories/show_repository.dart';
import 'screens/main_shell.dart';
import 'services/tvmaze_service.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(CinemayApp(showRepository: ShowRepository(TvMazeService())));
}

class CinemayApp extends StatelessWidget {
  const CinemayApp({super.key, required this.showRepository});

  final ShowRepository showRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ShowProvider(showRepository)..loadShows(),
        ),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
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
