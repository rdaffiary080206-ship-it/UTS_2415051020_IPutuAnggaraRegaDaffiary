import 'package:flutter/material.dart';

import '../models/watch_status.dart';
import '../models/watchlist_item.dart';
import '../utils/app_theme.dart';
import 'network_poster.dart';

/// Form watchlist untuk menyimpan atau memperbarui progress menonton,
/// rating bintang, dan catatan/review pribadi.
class WatchlistForm extends StatefulWidget {
  const WatchlistForm({
    super.key,
    required this.initial,
    required this.submitLabel,
    required this.onSubmit,
    this.titleEditable = false,
  });

  final WatchlistItem initial;
  final String submitLabel;
  final Future<void> Function(WatchlistItem item) onSubmit;

  /// Bernilai `false` jika film berasal dari API (judul & genre fix).
  final bool titleEditable;

  @override
  State<WatchlistForm> createState() => _WatchlistFormState();
}

class _WatchlistFormState extends State<WatchlistForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _progress;
  late final TextEditingController _note;
  late WatchStatus _status;

  /// Rating dalam skala 1–5 bintang (disimpan ke DB skala 2–10 agar kompatibel).
  late int _stars;
  bool _submitting = false;

  static const int maxTitle = 200;
  static const int maxProgress = 50;
  static const int maxNote = 500;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _title = TextEditingController(text: item.title);
    _progress = TextEditingController(text: item.progress);
    _note = TextEditingController(text: item.note);
    _status = item.status;
    _stars = item.personalRating == null
        ? 0
        : (item.personalRating! / 2).round().clamp(1, 5);
  }

  @override
  void dispose() {
    _title.dispose();
    _progress.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Judul wajib diisi';
    if (text.length > maxTitle) return 'Judul maksimal $maxTitle karakter';
    return null;
  }

  String? _validateProgress(String? value) {
    final text = value?.trim() ?? '';
    if (_status == WatchStatus.watching && text.isEmpty) {
      return 'Isi progress menonton (contoh: Episode 5 / Menit 45)';
    }
    if (text.length > maxProgress) {
      return 'Progress maksimal $maxProgress karakter';
    }
    return null;
  }

  String? _validateNote(String? value) {
    final text = value?.trim() ?? '';
    if (text.isNotEmpty && text.length < 3) {
      return 'Review minimal 3 karakter atau kosongkan';
    }
    if (text.length > maxNote) return 'Review maksimal $maxNote karakter';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final base = widget.initial;
    final item = WatchlistItem(
      id: base.id,
      showId: base.showId,
      title: widget.titleEditable ? _title.text.trim() : base.title,
      posterUrl: base.posterUrl,
      genres: base.genres,
      status: _status,
      personalRating: _stars == 0 ? null : (_stars * 2).toDouble(),
      progress: _progress.text.trim(),
      note: _note.text.trim(),
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
    );

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(item);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.initial;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header film (fix mengikuti API) atau input judul jika manual
          if (!widget.titleEditable && item.title.isNotEmpty)
            _LockedMovieHeader(item: item)
          else
            TextFormField(
              controller: _title,
              maxLength: maxTitle,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Judul film / series *',
                prefixIcon: Icon(Icons.movie_outlined),
              ),
              validator: _validateTitle,
            ),
          const SizedBox(height: 20),

          // Status tontonan
          const Text(
            'Status Tontonan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in WatchStatus.values)
                ChoiceChip(
                  avatar: Icon(status.icon, size: 18),
                  label: Text(status.label),
                  selected: _status == status,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => setState(() => _status = status),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress menonton
          const Text(
            'Progress Menonton',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _progress,
            maxLength: maxProgress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Contoh: Season 1 Episode 5 atau Menit 45',
              prefixIcon: Icon(Icons.play_circle_outline),
              counterText: '',
            ),
            validator: _validateProgress,
          ),
          const SizedBox(height: 20),

          // Bagian Rating Bintang (terpisah dari review)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rating Kamu',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    if (_stars > 0)
                      TextButton(
                        onPressed: () => setState(() => _stars = 0),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Reset'),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 1; i <= 5; i++)
                      IconButton(
                        onPressed: () => setState(() => _stars = i),
                        iconSize: 36,
                        icon: Icon(
                          i <= _stars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: i <= _stars
                              ? AppColors.gold
                              : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                Center(
                  child: Text(
                    _stars == 0
                        ? 'Ketuk bintang untuk memberi rating'
                        : '$_stars / 5 Bintang',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bagian Review / Catatan Pribadi (terpisah)
          const Text(
            'Catatan / Review Pribadi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _note,
            maxLength: maxNote,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tulis pendapat atau catatanmu tentang tayangan ini...',
              alignLabelWithHint: true,
            ),
            validator: _validateNote,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(_submitting ? 'Menyimpan...' : widget.submitLabel),
          ),
        ],
      ),
    );
  }
}

/// Kartu informasi film yang terkunci (judul & genre fix mengikuti API).
class _LockedMovieHeader extends StatelessWidget {
  const _LockedMovieHeader({required this.item});

  final WatchlistItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 80,
            child: NetworkPoster(imageUrl: item.posterUrl, borderRadius: 8),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.genres.isEmpty ? 'Tanpa genre' : item.genres,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
