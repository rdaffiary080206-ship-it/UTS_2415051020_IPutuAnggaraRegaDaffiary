import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/watch_status.dart';
import '../providers/show_provider.dart';
import '../providers/watchlist_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../utils/env.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    final showsCount = context.watch<ShowProvider>().shows.length;
    final avgRating = watchlist.averageRating;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Informasi Aplikasi')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary,
                        child:
                            Icon(Icons.person, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        AppConstants.studentName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'NIM ${AppConstants.studentNim} • Kelas ${AppConstants.studentClass}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Project UTS Pemrograman Mobile',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Statistik Menonton',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    label: 'Total Watchlist',
                    value: '${watchlist.count}',
                    icon: Icons.bookmark_rounded,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    label: 'Sedang Ditonton',
                    value: '${watchlist.countByStatus(WatchStatus.watching)}',
                    icon: Icons.play_circle_outline,
                    color: AppColors.gold,
                  ),
                  _StatCard(
                    label: 'Selesai',
                    value: '${watchlist.countByStatus(WatchStatus.completed)}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                  _StatCard(
                    label: 'Rata-rata Rating',
                    value:
                        avgRating == null ? '-' : avgRating.toStringAsFixed(1),
                    icon: Icons.star_rounded,
                    color: AppColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Teknis & Arsitektur',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _infoRow('Nama Aplikasi', AppConstants.appName),
                      _infoRow('REST API', 'TVMaze Public API ($showsCount show)'),
                      _infoRow(
                        'Backend Database',
                        Env.isSupabaseConfigured
                            ? 'Supabase PostgreSQL (Terkonfigurasi)'
                            : 'Supabase PostgreSQL ( via env.json )',
                      ),
                      _infoRow('State Management', 'Provider + ChangeNotifier'),
                      _infoRow(
                        'Pola Arsitektur',
                        'UI → Provider → Repository → Service',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
