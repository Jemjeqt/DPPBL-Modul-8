# Screenshot Praktikum 8 — SQLite CRUD

Diambil dari proyek `kantin_kampus_sqlite` yang ada di folder induk.
Hasil uji: emulator Android **Pixel 10a** (1080 x 2424), build debug.
Screenshot kode dirender bergaya editor (tab file, breadcrumb, nomor baris, indent guide).

## Isi folder

| Folder | Isi | Jumlah |
|---|---|---|
| `kode-final/` | kode tiap file di `lib/`, versi akhir | 14 |
| `hasil/` | tangkapan layar aplikasi saat dijalankan | 8 |

Lampiran siap pakai: `Lampiran_Kode_dan_Screenshot.md` (kode + screenshot berurutan).

## `kode-final/` — isi akhir file

| File | Isi |
|---|---|
| `01_lib-models-produk.png` | `models/produk.dart` |
| `02_lib-models-pesanan.png` | `models/pesanan.dart` |
| `03_lib-cubit-keranjang_cubit.png` | `cubit/keranjang_cubit.dart` |
| `04_lib-cubit-theme_cubit.png` | `cubit/theme_cubit.dart` |
| `05_lib-theme-app_theme.png` | `theme/app_theme.dart` |
| `06_lib-db-database_helper.png` | `db/database_helper.dart` |
| `07_lib-widgets-primary_button.png` | `widgets/primary_button.dart` |
| `08_lib-widgets-theme_toggle_button.png` | `widgets/theme_toggle_button.dart` |
| `09_lib-widgets-product_card.png` | `widgets/product_card.dart` |
| `10_lib-widgets-cart_summary_bar.png` | `widgets/cart_summary_bar.dart` |
| `11_lib-pages-halaman_produk.png` | `pages/halaman_produk.dart` |
| `12_lib-pages-halaman_keranjang.png` | `pages/halaman_keranjang.dart` |
| `13_lib-pages-halaman_riwayat.png` | `pages/halaman_riwayat.dart` |
| `14_lib-main.png` | `main.dart` |

## `hasil/` — aplikasi berjalan

| File | Isi |
|---|---|
| `01_halaman-produk.png` | halaman Produk (a) |
| `02_halaman-keranjang.png` | keranjang berisi 3 item + tombol Checkout (a, d) |
| `03_checkout-snackbar.png` | setelah Checkout: SnackBar dan keranjang kosong (d) |
| `04_halaman-riwayat.png` | riwayat 3 pesanan, terbaru di atas (e) |
| `05_dialog-ubah-jumlah.png` | dialog ubah jumlah item (f) |
| `06_setelah-ubah-jumlah.png` | jumlah berubah 2 → 5 tanpa buka ulang halaman (f) |
| `07_setelah-hapus.png` | satu baris hilang setelah digeser ke kiri (g) |
| `08_riwayat-setelah-app-dibuka-ulang.png` | data tetap ada setelah aplikasi ditutup dan dibuka lagi (uji persistensi) |

## Catatan kecil

- `cart_summary_bar.dart` di modul memakai satu `Row` berisi teks + dua tombol.
  Di layar 411 dp tombol Checkout terpotong (RenderFlex overflow 33 piksel),
  jadi di proyek ini tombol ditumpuk di bawah teks (`Column` + dua `Expanded`).
- `if (!context.mounted) return;` dan `if (!mounted) return;` ditambahkan setelah
  `await` supaya analyzer bersih.
- `sqflite` tidak jalan di Chrome/Windows. Semua screenshot hasil diambil di emulator Android.
