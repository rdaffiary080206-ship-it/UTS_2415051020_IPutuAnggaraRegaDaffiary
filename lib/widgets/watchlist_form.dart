import 'package:flutter/material.dart';

import '../models/watch_status.dart';
import '../models/watchlist_item.dart';
import '../utils/app_theme.dart';

/// Form watchlist yang dipakai bersama oleh screen Tambah dan Edit.
/// Melakukan validasi input lalu mengirim [WatchlistItem] lewat [onSubmit].
class WatchlistForm extends StatefulWidget {
  const WatchlistForm({
    super.key,
    required this.initial,
    required this.submitLabel,
    required this.onSubmit,
    this.titleEditable = true,
  });

  final WatchlistItem initial;
  final String submitLabel;
  final Future<void> Function(WatchlistItem item) onSubmit;

  /// Judul dari API tidak perlu diubah; judul input manual boleh diubah.
  final bool titleEditable;

  @override
  State<WatchlistForm> createState() => _WatchlistFormState();
}

class _WatchlistFormState extends State<WatchlistForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _genres;
  late final TextEditingController _progress;
  late final TextEditingController _note;
  late WatchStatus _status;
  late bool _hasRating;
  late double _rating;
  bool _submitting = false;

  static const int maxTitle = 200;
  static const int maxProgress = 50;
  static const int maxNote = 500;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _title = TextEditingController(text: item.title);
    _genres = TextEditingController(text: item.genres);
    _progress = TextEditingController(text: item.progress);
    _note = TextEditingController(text: item.note);
    _status = item.status;
    _hasRating = item.personalRating != null;
    _rating = item.personalRating ?? 7;
  }

  @override
  void dispose() {
    _title.dispose();
    _genres.dispose();
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
      return 'Isi progres jika sedang ditonton (mis. S1 E5)';
    }
    if (text.length > maxProgress) {
      return 'Progres maksimal $maxProgress karakter';
    }
    return null;
  }

  String? _validateNote(String? value) {
    final text = value?.trim() ?? '';
    if (text.isNotEmpty && text.length < 3) {
      return 'Catatan minimal 3 karakter atau kosongkan';
    }
    if (text.length > maxNote) return 'Catatan maksimal $maxNote karakter';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final base = widget.initial;
    final item = WatchlistItem(
      id: base.id,
      showId: base.showId,
      title: _title.text.trim(),
      posterUrl: base.posterUrl,
      genres: _genres.text.trim(),
      status: _status,
      personalRating: _hasRating ? _rating : null,
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
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _title,
            enabled: widget.titleEditable,
            maxLength: maxTitle,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Judul film / series *',
              prefixIcon: Icon(Icons.movie_outlined),
            ),
            validator: _validateTitle,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _genres,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Genre',
              hintText: 'mis. Drama, Thriller',
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Status tontonan',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in WatchStatus.values)
                ChoiceChip(
                  avatar: Icon(status.icon, size: 18),
                  label: Text(status.label),
                  selected: _status == status,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => setState(() => _status = status),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _progress,
            maxLength: maxProgress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Progres terakhir',
              hintText: 'mis. Season 1 Episode 5 / Menit 45',
              prefixIcon: Icon(Icons.timelapse),
            ),
            validator: _validateProgress,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Beri rating pribadi'),
            value: _hasRating,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _hasRating = v),
          ),
          if (_hasRating)
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.gold),
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1,
                    max: 10,
                    divisions: 18,
                    label: _rating.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    _rating.toStringAsFixed(1),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _note,
            maxLength: maxNote,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Catatan / review pribadi',
              alignLabelWithHint: true,
            ),
            validator: _validateNote,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_submitting ? 'Menyimpan...' : widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
