import 'package:flutter/material.dart';

import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const CinemayApp());
}

class CinemayApp extends StatelessWidget {
  const CinemayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const Scaffold(
        body: Center(child: Text(AppConstants.appName)),
      ),
    );
  }
}
