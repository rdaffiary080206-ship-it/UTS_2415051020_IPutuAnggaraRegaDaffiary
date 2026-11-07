import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/show_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/main_shell.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const CinemayApp());
}

class CinemayApp extends StatelessWidget {
  const CinemayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShowProvider()..loadShows()),
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
