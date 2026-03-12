# 🚗 Rental Mobil Mainan
Aplikasi mobile berbasis Flutter untuk mengelola bisnis penyewaan mobil mainan. Dirancang khusus untuk penjual di lokasi ramai seperti alun-alun kota, dengan alur transaksi yang cepat dan sederhana.

---

## 📱 Deskripsi Aplikasi
**Rental Mobil Mainan** adalah sistem manajemen penyewaan mobil mainan yang memudahkan penjual mencatat dan memantau transaksi secara real-time. Sistem harga berbasis waktu, dengan durasi yang bisa disesuaikan. Data penyewa bersifat opsional (default titik ".") sehingga transaksi bisa diselesaikan dengan cepat saat kondisi ramai.

---

## 📸 Tampilan Aplikasi

**Tampilan Dashboard**

<img width="451" height="389" alt="homepage" src="https://github.com/user-attachments/assets/e4242b1f-6449-40b9-aa2a-0bd1b54786c8" />

---

**Tampilan Halaman Mobil**

<img width="452" height="425" alt="halaman mobil" src="https://github.com/user-attachments/assets/99712947-26a3-4db0-a162-f2288cdb9f11" />

---

**Tampilan Form Penyewaan**

<img width="450" height="407" alt="form penyewaan" src="https://github.com/user-attachments/assets/a4cc113c-1a08-4e8b-a2cc-242382ea66f2" />

---

**Tampilan Daftar Penyewaan**

<img width="451" height="424" alt="daftar penyewaan" src="https://github.com/user-attachments/assets/205b84f2-6a8d-4810-94bb-20fbcad99f02" />

---

**Tampilan Dashboard Ketika Darkmode**

<img width="450" height="450" alt="image" src="https://github.com/user-attachments/assets/87de86f6-afaf-4228-a94e-027e395e8d93" />

---
**Tampilan Halaman Mobil Ketika Darkmode**

<img width="450" height="450" alt="image" src="https://github.com/user-attachments/assets/e2cba43a-751a-447e-bccb-a43bbd36ad57" />

---
**Tampilan Halaman Penyewaan Ketika Darkmode**

<img width="450" height="450" alt="image" src="https://github.com/user-attachments/assets/8dd4a7c7-4976-4546-a62e-7458af8e9747" />

---

## ✨ Fitur Aplikasi

### CRUD Lengkap
| Fitur | Keterangan |
|-------|-----------|
| ➕ **Create** | Tambah data mobil baru & buat transaksi penyewaan ke database |
| 👁️ **Read** | Lihat daftar mobil, detail mobil, daftar & detail penyewaan, dashboard statistik |
| ✏️ **Update** | Edit informasi mobil (nama, warna, keterangan) |
| 🗑️ **Delete** | Hapus data mobil & batalkan/hapus penyewaan |

### Fitur Unggulan
- ☁️ **Integrasi Supabase** — Semua data (mobil dan transaksi) disimpan dengan aman menggunakan Supabase.
- 🔐 **Keamanan Kredensial** — Menggunakan file `.env` untuk menyimpan URL dan API Key secara aman.
- 🌓 **Light & Dark Mode** — Tema aplikasi bisa menyesuaikan mode terang atau gelap.
- ⏱️ **Sistem Harga Berbasis Waktu** — Rp 20.000 / 15 menit, otomatis dihitung.
- 🕐 **Tampil Jam Selesai Otomatis** — Langsung terlihat kapan waktu sewa berakhir.
- ⚡ **Form Cepat** — Data penyewa opsional (default "."), cocok saat kondisi antrean ramai.
- 📊 **Dashboard** — Ringkasan total mobil, unit tersedia, aktif disewa, dan total pendapatan.
- 🗂️ **Tab Penyewaan** — Tampilan terpisah antara penyewaan aktif dan riwayat transaksi.
- ✅ **Status Penyewaan** — Tandai selesai atau batalkan langsung dari detail penyewaan.

---

## 🧭 Navigasi Multi-Halaman
```
HomeScreen (BottomNavigationBar)
├── DashboardScreen         → Statistik & penyewaan terbaru
├── CarsScreen              → Daftar mobil
│   ├── CarDetailScreen     → Detail mobil + riwayat sewa
│   │   └── RentalFormScreen (pre-filled mobil)
│   └── CarFormScreen       → Tambah / Edit mobil
└── RentalsScreen           → Daftar penyewaan (Tab: Aktif | Riwayat)
    ├── RentalDetailScreen  → Detail penyewaan + tandai selesai/hapus
    └── RentalFormScreen    → Form buat penyewaan baru
```

---

## 🧩 Widget yang Digunakan

### Layout & Navigation

| Widget | Penggunaan |
| --- | --- |
| `Scaffold` | Kerangka dasar setiap halaman |
| `NavigationBar` | Bottom navigation 3 tab utama |
| `TabBar` & `TabBarView` | Tab Aktif / Riwayat di halaman penyewaan |
| `CustomScrollView` & `SliverAppBar` | App bar yang bisa di-scroll di dashboard |
| `SliverList` | List konten di dalam CustomScrollView |

### Input & Form

| Widget | Penggunaan |
| --- | --- |
| `BottomNavigationBar` | Navigasi utama antar halaman |
| `TextFormField` | Input nama, warna, keterangan, nama penyewa, telepon, alamat |
| `Form` & `GlobalKey<FormState>` | Validasi form |
| `DropdownButtonFormField` | Pilih mobil yang tersedia saat membuat penyewaan |
| `Slider` | Atur durasi sewa secara interaktif |

### Styling & State Management

| Widget / Class | Penggunaan |
| --- | --- |
| `ChangeNotifierProvider` | State management global untuk data & tema aplikasi |
| `BoxDecoration` | Border radius, warna, & gradient custom |
| `context.watch` & `context.read` | Interaksi reaktif dengan AppStore dan ThemeProvider |
| `GestureDetector` | Tombol preset durasi (15m, 30m, 45m, dst.) |

### Display
| Widget | Penggunaan |
|--------|-----------|
| `Card` | Kartu informasi mobil & penyewaan |
| `ListTile` | Item list penyewaan & riwayat |
| `CircleAvatar` | Avatar ikon penyewaan di dashboard |
| `Container` | Box styling kustom dengan dekorasi |
| `Row` & `Column` | Layout horizontal & vertikal |
| `Expanded` | Flex layout responsif |
| `ListView.builder` | Daftar dinamis mobil & penyewaan |
| `AlertDialog` | Konfirmasi hapus & selesai |
| `SnackBar` | Notifikasi aksi berhasil |
| `Wrap` | Tombol preset durasi yang otomatis wrap |

### Styling & Decoration
| Widget | Penggunaan |
|--------|-----------|
| `BoxDecoration` | Border radius, warna, & gradient |
| `LinearGradient` | Gradient ungu di header & kartu biaya |
| `Icon` | Ikon berbagai elemen UI |
| `FloatingActionButton.extended` | Tombol tambah mobil & buat penyewaan |
| `ElevatedButton` | Tombol aksi utama |
| `OutlinedButton` | Tombol aksi sekunder (batalkan) |
| `NavigationDestination` | Item destinasi bottom navigation |

### State Management
| Widget / Class | Penggunaan |
|--------|-----------|
| `ChangeNotifier` & `ChangeNotifierProvider` | State management global seluruh aplikasi |
| `context.watch<AppStore>()` | Reactif terhadap perubahan data |
| `context.read<AppStore>()` | Aksi tanpa trigger rebuild |
| `StatefulWidget` | State lokal untuk form & tab controller |
| `TextEditingController` | Kontrol & default value TextField |

---

## 📁 Struktur Proyek
```
lib/
├── main.dart                      # Entry point, inisialisasi Supabase & .env
├── app_store.dart                 # State management global (ChangeNotifier)
├── models/
│   ├── car.dart                   # Model data mobil
│   └── rental.dart                # Model data penyewaan
├── providers/
│   └── theme_provider.dart        # Pengatur state Light / Dark Mode
├── services/
│   └── supabase_service.dart      # Fungsi untuk interaksi CRUD dengan Supabase
└── screens/
    ├── home_screen.dart           # Shell NavigationBar utama
    ├── dashboard_screen.dart      # Statistik & penyewaan terbaru
    ├── cars_screen.dart           # Daftar semua mobil
    ├── car_form_screen.dart       # Form tambah / edit mobil
    ├── car_detail_screen.dart     # Detail mobil + riwayat penyewaan
    ├── rentals_screen.dart        # Daftar penyewaan (TabBar)
    ├── rental_form_screen.dart    # Form buat penyewaan
    └── rental_detail_screen.dart  # Detail penyewaan + aksi selesai/hapus
```

---

## 🚀 Cara Menjalankan

**1. Clone repository**
```
git clone https://github.com/kksgaa/Mini-Project-2-PAB.git
cd Mini-Project-2-PAB
```


**2. Siapkan file environment (.env)**
Buat file bernama `.env` di dalam folder utama proyek (selevel dengan `pubspec.yaml`), lalu masukkan konfigurasi Supabase berikut:
```
SUPABASE_URL=masukkan_url_supabase_anda
SUPABASE_ANON_KEY=masukkan_anon_key_anda
```


**3. Install dependencies**
```
flutter pub get
```

**4. Jalankan aplikasi**
```
flutter run
```
