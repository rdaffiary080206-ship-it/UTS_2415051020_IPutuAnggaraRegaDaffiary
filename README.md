# Cinemay — Movie & Series Explorer + Personal Watchlist

**Cinemay** adalah aplikasi mobile Flutter bergaya layanan streaming modern (*Netflix / IDLIX style*) untuk menjelajahi katalog film & serial televisi dari REST API publik serta mengelola daftar tontonan pribadi (*Watchlist*, progres episode/menit, rating pribadi, dan catatan review) yang tersimpan secara persisten pada database cloud **Supabase (PostgreSQL)**.

Project ini dikembangkan untuk memenuhi tugas **Ujian Tengah Semester (UTS) Pemrograman Mobile**.

---

## Identitas Mahasiswa

| Atribut | Keterangan |
| :--- | :--- |
| **Nama** | I Putu Anggara Rega Daffiary |
| **NIM** | 2415051020 |
| **Kelas** | PTI-5B |
| **Tema Project** | MovieExplorer (`Cinemay` — Streaming Catalog & Personal Watchlist) |
| **URL GitHub** | https://github.com/rdaffiary080206-ship-it/UTS_2415051020_IPutuAnggaraRegaDaffiary |

---

## Daftar Fitur

1. **Beranda Sinematik (*Home Screen*)**:
   - *Hero Featured Banner* tayangan unggulan dengan tombol **Lihat Detail**, **+ Daftar Saya (Quick Add)**, dan **Kejutkan Saya**.
   - Carousel horizontal **Sedang Trending**, **Rating Tertinggi**, **Sci-Fi Pilihan**, dan **Aksi & Petualangan**.
   - *Pull-to-refresh* serta penanganan state *Loading*, *Error* (dengan tombol *Coba Lagi*), dan *Empty*.
2. **Eksplorasi & Pencarian Katalog (*Explore / Catalog Screen*)**:
   - Pencarian judul *real-time* ke endpoint REST API (`/search/shows?q=...`) dengan *debounce* 500 ms.
   - Filter berdasarkan **Genre** dan pengurutan (*Terpopuler*, *Rating Tertinggi*, *Terbaru*, *Judul A–Z*).
   - Toggle tampilan **Responsive Grid** (2–6 kolom otomatis mengikuti lebar layar) dan **Detailed List**.
3. **Detail Tayangan (*Detail Screen*)**:
   - Menerima *passing data* objek `Show` dari Beranda maupun Eksplor.
   - Menampilkan poster/backdrop resolusi tinggi, rating, tahun rilis, durasi, platform/network, jadwal tayang, genre, dan sinopsis bersih.
   - Menampilkan kartu review pribadi jika tayangan sudah tersimpan di Watchlist.
4. **Manajemen Watchlist & Review (*CRUD Database Supabase*)**:
   - **Create (`AddWatchlistScreen` & Quick Add)**: Form tambah ke Watchlist dengan validasi input (judul wajib diisi, validasi progres saat status *Sedang Ditonton*, slider rating 1.0–10.0, dan validasi catatan).
   - **Read (`WatchlistScreen`)**: Menampilkan daftar tontonan dari Supabase dengan filter chip status (*Semua*, *Ingin Ditonton*, *Sedang Ditonton*, *Selesai*, *Berhenti*).
   - **Update (`EditWatchlistScreen`)**: Mengubah status tontonan, progres episode/menit terakhir, rating pribadi, dan catatan review.
   - **Delete (`ConfirmDialog` & Swipe-to-Delete)**: Menghapus item dari database menggunakan **AlertDialog Konfirmasi** terlebih dahulu.
5. **Fitur Kreatif — "Kejutkan Saya!" (*Random Show Picker*)**:
   - Memilih tayangan acak dari katalog menggunakan *Modal Bottom Sheet* interaktif untuk membantu pengguna yang bingung memilih tontonan.
6. **Profil & Statistik Menonton (*Profile Screen*)**:
   - Menampilkan identitas mahasiswa, statistik koleksi Watchlist (*Total*, *Sedang Ditonton*, *Selesai*, *Rata-rata Rating Pribadi*), serta informasi arsitektur aplikasi.

---

## Tech Stack

- **Framework & Bahasa**: Flutter & Dart (`sdk: ^3.13.2`, Null Safety)
- **State Management**: `provider` (`ChangeNotifier`, `MultiProvider`)
- **HTTP Client**: `http`
- **Backend & Database**: `supabase_flutter` (Supabase PostgreSQL + Row Level Security)
- **Testing**: `flutter_test` (Unit Test Model & Widget Test CRUD/API)

---

## REST API yang Digunakan

Menggunakan **TVMaze Public REST API** (publik, gratis, tanpa API key rahasia):
- Base URL: `https://api.tvmaze.com`
- Endpoint Katalog (`GET`): `https://api.tvmaze.com/shows?page=0`
- Endpoint Pencarian (`GET`): `https://api.tvmaze.com/search/shows?q={query}`
- Response JSON dikonversi menjadi Dart Model [`Show`](lib/models/show.dart).

---

## Backend & Database yang Digunakan

Menggunakan **Supabase (PostgreSQL)** dengan tabel utama `public.watchlist`:

| Kolom | Tipe | Keterangan |
| :--- | :--- | :--- |
| `id` | `bigint` (PK) | Primary key otomatis (`generated always as identity`) |
| `show_id` | `integer` | ID tayangan dari TVMaze (unik bila diisi, `null` jika input manual) |
| `title` | `text` | Judul film/series (wajib, 1–200 karakter) |
| `poster_url` | `text` | URL gambar poster |
| `genres` | `text` | Daftar genre |
| `status` | `text` | `plan_to_watch`, `watching`, `completed`, atau `dropped` |
| `personal_rating` | `numeric(3,1)` | Rating pribadi pengguna (1.0–10.0) |
| `progress` | `text` | Progres terakhir (mis. `S1 E5` atau `Menit 45`) |
| `note` | `text` | Catatan/review pribadi |
| `created_at` | `timestamptz` | Waktu dibuat |
| `updated_at` | `timestamptz` | Waktu terakhir diperbarui (otomatis via trigger) |

Skema lengkap beserta kebijakan *Row Level Security (RLS)* tersedia pada file [`supabase/schema.sql`](supabase/schema.sql).

> **Catatan Keamanan**: Aplikasi hanya menggunakan Supabase URL dan *publishable (anon) key* yang disuplai saat runtime melalui `--dart-define-from-file=env.json`. File `env.json` diabaikan oleh Git (`.gitignore`) dan aplikasi **tidak pernah** menyimpan `service_role` key.

---

## Struktur Arsitektur Aplikasi

Mengikuti prinsip pemisahan lapisan **UI → State/Provider → Repository → Service/Data Source → REST API / Database**:

```text
lib/
├── models/
│   ├── show.dart                # Model data REST API TVMaze
│   ├── watch_status.dart        # Enum status tontonan
│   └── watchlist_item.dart      # Model data tabel watchlist Supabase
├── services/
│   ├── app_exception.dart       # Hierarki exception (Network, API, Database)
│   ├── tvmaze_service.dart      # HTTP GET client ke TVMaze REST API
│   ├── watchlist_data_source.dart # Kontrak abstrak data source database
│   └── supabase_service.dart    # Query CRUD ke tabel watchlist Supabase
├── repositories/
│   ├── show_repository.dart     # Konversi JSON API -> List<Show>
│   └── watchlist_repository.dart # Konversi Map DB -> WatchlistItem
├── providers/
│   ├── show_provider.dart       # State katalog, search, filter genre, sort, view mode
│   └── watchlist_provider.dart  # Shared state watchlist, CRUD, filter status, statistik
├── screens/
│   ├── main_shell.dart          # Navigasi responsif (NavigationBar vs NavigationRail)
│   ├── home_screen.dart         # Screen 1: Beranda + Featured Banner + Kejutkan Saya
│   ├── explore_screen.dart      # Screen 2: Katalog + Search + Filter + Grid/List
│   ├── detail_screen.dart       # Screen 3: Detail tayangan + status Watchlist
│   ├── watchlist_screen.dart    # Screen 4: Daftar Watchlist dari Supabase
│   ├── add_watchlist_screen.dart # Screen 5: Form Create Watchlist + validasi
│   ├── edit_watchlist_screen.dart # Screen 6: Form Update Watchlist + validasi
│   └── profile_screen.dart      # Screen 7: Profil mahasiswa & statistik menonton
├── widgets/
│   ├── confirm_dialog.dart      # Reusable AlertDialog konfirmasi hapus
│   ├── featured_banner.dart     # Hero banner utama di Beranda
│   ├── network_poster.dart      # Gambar poster dengan fallback error/loading
│   ├── poster_card.dart         # Kartu poster untuk Grid & Carousel
│   ├── rating_badge.dart        # Badge skor rating bintang emas
│   ├── section_header.dart      # Header seksi dengan tombol aksi
│   ├── show_carousel.dart       # List horizontal poster tayangan
│   ├── show_list_tile.dart      # Kartu tayangan untuk mode tampilan List
│   ├── state_views.dart         # Reusable Loading, Error, dan Empty state
│   ├── watchlist_actions.dart   # Helper aksi quick toggle & konfirmasi hapus
│   ├── watchlist_form.dart      # Reusable Form + validasi untuk Create & Update
│   └── watchlist_tile.dart      # Kartu item Watchlist
├── utils/
│   ├── app_constants.dart       # Konstanta identitas & endpoint
│   ├── app_theme.dart           # Tema gelap sinematik (Material 3)
│   ├── env.dart                 # Pembaca variabel --dart-define
│   └── responsive.dart          # Helper breakpoint compact/medium/expanded
└── main.dart                    # Entry point & konfigurasi MultiProvider
```

---

## Screenshot Aplikasi

Letakkan hasil tangkapan layar pada folder `screenshots/` sesuai daftar berikut:

| Tampilan | File |
| :--- | :--- |
| Beranda (*Home Screen*) | `screenshots/01_home.png` |
| Eksplorasi & Katalog (*List/Grid*) | `screenshots/02_explore.png` |
| Detail Tayangan (*Detail Screen*) | `screenshots/03_detail.png` |
| Tambah Watchlist (*Create Screen*) | `screenshots/04_create.png` |
| Edit Watchlist (*Update Screen*) | `screenshots/05_edit.png` |
| Watchlist & Konfirmasi Hapus (*Database Data*) | `screenshots/06_watchlist.png` |
| Tampilan Responsif (*Wide / NavigationRail*) | `screenshots/07_responsive.png` |
| Profil & Statistik (*Profile Screen*) | `screenshots/08_profile.png` |

---

## Cara Menjalankan Project

1. **Clone repository**:
   ```bash
   git clone https://github.com/rdaffiary080206-ship-it/UTS_2415051020_IPutuAnggaraRegaDaffiary.git
   cd UTS_2415051020_IPutuAnggaraRegaDaffiary
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Siapkan Database Supabase**:
   - Buka project Supabase Anda dan jalankan isi file [`supabase/schema.sql`](supabase/schema.sql) pada menu **SQL Editor**.
   - Salin file `env.example.json` menjadi `env.json`, lalu isi dengan `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY` (*anon public key*) milik Anda:
     ```json
     {
       "SUPABASE_URL": "https://YOUR-PROJECT-REF.supabase.co",
       "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_YOUR-KEY"
     }
     ```

4. **Jalankan aplikasi**:
   ```bash
   flutter run --dart-define-from-file=env.json
   ```

5. **Build APK Release**:
   ```bash
   flutter build apk --release --dart-define-from-file=env.json
   ```

6. **Jalankan Pengujian (Unit & Widget Test)**:
   ```bash
   flutter test
   ```
