import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist Saya')),
      body: const Center(
        child: Text(
          'Watchlist masih kosong',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
