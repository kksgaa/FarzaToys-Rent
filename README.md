# FarzaToys Rental

<div align="center">

<img width="120" height="120" alt="app_icon" src="https://github.com/user-attachments/assets/993b5916-ffe9-4fe2-bf7a-e866dae380bb" />

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Provider](https://img.shields.io/badge/Provider-FF6F00?style=for-the-badge&logo=flutter&logoColor=white)](https://pub.dev/packages/provider)

![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Version](https://img.shields.io/badge/Version-1.0.0-7B1FA2?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)

<br/>

> **Proyek Akhir Pemrograman Aplikasi Bergerak** · Flutter + Supabase · 2026

</div>

---
**Aplikasi manajemen penyewaan mobil mainan berbasis Flutter & Supabase**

*Kelola armada, transaksi sewa, dan antrian pelanggan — semuanya dalam satu aplikasi.*

</div>

---

## Profil Anggota

**Kelompok :** 7 Hara Hetta
**Kelas :** Sistem Informasi  
**Mata Kuliah :** Pemrograman Aplikasi Bergerak

| Nama | NIM | Kelas | GitHub |
|------|-----|-------|--------|
| Yulius Pune' | 2409116110 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/Oxcyy-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Oxcyy) |
| Muhammad Fakhri Al-Kautsar  | 2409116081 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/kksgaa-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/kksgaa) |
| Yudha Tri Atmaja  | 2409116095 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/Yudhatriatmajaa-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Yudhatriatmajaa) |
| Elvira Agustin  | 2409116109 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/elviraags-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/elviraags) |
| Rizky wahyu dina putri  | 2409116111 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/Dinaapp-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Dinaapp) |

---

## Deskripsi

**FarzaToys Rental** adalah aplikasi mobile manajemen penyewaan mobil mainan yang dibangun menggunakan Flutter dengan backend real-time Supabase. Aplikasi ini dirancang untuk memudahkan operator/pemilik usaha dalam mengelola stok unit, mencatat transaksi sewa, memantau pendapatan harian, hingga mengelola antrian pelanggan — semuanya secara digital dan efisien.

Aplikasi mendukung multi-akun dengan sistem autentikasi berbasis Supabase Auth, di mana admin memiliki akses penuh termasuk kelola akun pengguna lain.

---

## Fitur Utama

### Autentikasi & Manajemen Akun
- Login & logout menggunakan Supabase Auth
- Registrasi akun baru (khusus Admin)
- Role-based access: **Admin** (`admin@gmail.com`) memiliki menu tambahan untuk kelola akun
- Session persisten — pengguna tetap login setelah menutup aplikasi

### Manajemen Unit (Mobil Mainan)
- Tambah, edit, dan hapus unit mobil
- Upload foto unit menggunakan **Image Picker**
- Atur harga sewa per 15 menit secara individual
- Toggle ketersediaan unit (Tersedia / Disewa)
- Tampilkan warna, nama, catatan, dan gambar unit

### Manajemen Penyewaan
- Buat transaksi sewa baru dengan data penyewa lengkap:
  - Nama, nomor telepon, alamat
  - Pilih unit & durasi sewa
  - Status pembayaran (lunas / belum)
- Kembalikan unit dan otomatis tandai unit sebagai tersedia
- Perpanjang waktu sewa + tambah biaya
- Hapus transaksi (unit otomatis dikembalikan jika masih aktif)
- Filter: **Semua** / **Aktif** / **Selesai**

### Pembayaran & Pendapatan
- Tandai transaksi sebagai **Lunas** atau **Belum Dibayar**
- Dashboard pendapatan **hari ini** — otomatis dihitung dari transaksi yang selesai dan lunas
- Harga dihitung otomatis berdasarkan durasi dan tarif per unit

### Notifikasi Lokal
- Jadwalkan pengingat otomatis saat durasi sewa akan habis
- Notifikasi berbasis **flutter_local_notifications** dengan timezone lokal (Asia/Makassar)
- Dukungan alarm (Android)

### Antrian Pelanggan
- Tambah pelanggan ke daftar antrian jika unit sedang penuh
- Opsional: tentukan unit target yang ditunggu
- Hapus antrian saat pelanggan sudah mulai penyewaan

### Tampilan & Tema
- Desain **bold & playful** dengan warna kuning primer (`#FFEB3B`) dan ungu (`#7B1FA2`)
- Custom AppBar dengan bottom border tebal bergaya neo-brutalist
- SnackBar custom dengan border tebal dan aksi "OK"

---

## Struktur Widget Utama

| Widget / Screen | Deskripsi |
|---|---|
| `AuthWrapper` | StreamBuilder yang memantau sesi auth Supabase dan mengarahkan ke HomeScreen atau LoginScreen |
| `HomeScreen` | Halaman utama berisi dashboard, daftar unit, dan transaksi aktif |
| `LoginScreen` | Form login dengan Supabase Auth |
| `RegisterScreen` | Form registrasi akun baru (hanya admin) |
| `CustomAppBar` | AppBar reusable dengan aksi menu (kelola akun & logout), role-aware |
| `CarCard` | Kartu unit mobil dengan gambar, status, dan tombol aksi |
| `RentalCard` | Kartu transaksi sewa dengan info penyewa, durasi, dan status bayar |
| `QueueList` | Daftar antrian pelanggan yang menunggu unit |
| `AddCarDialog` | Dialog tambah/edit unit mobil |
| `AddRentalSheet` | Bottom sheet form transaksi sewa baru |
| `ExtendTimeDialog` | Dialog perpanjangan waktu sewa |

---

## Arsitektur & State Management

```
lib/
├── main.dart                  # Entry point, inisialisasi Supabase & Provider
├── app_store.dart             # State management global (ChangeNotifier)
├── notification_service.dart  # Layanan notifikasi lokal
├── models/
│   ├── car.dart               # Model data unit mobil
│   ├── rental.dart            # Model data transaksi sewa
│   └── queue_item.dart        # Model data antrian
├── services/
│   └── supabase_service.dart  # Abstraksi operasi database Supabase
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── register_screen.dart
└── widgets/
    └── custom_app_bar.dart
```

**State Management:** Provider (`ChangeNotifier`) melalui `AppStore` — satu sumber kebenaran untuk data unit, sewa, dan antrian.

---

## Skema Database (Supabase)

### Tabel `cars`
 
> Menyimpan data seluruh unit mobil mainan yang dimiliki.
 
| Kolom | Tipe | Default | Keterangan |
|---|---|---|---|
| `id` | `uuid` | `gen_random_uuid()` | Primary key, otomatis di-generate |
| `created_at` | `timestamptz` | `now()` | Waktu data dibuat |
| `name` | `text` | `NULL` | Nama unit mobil |
| `color` | `text` | `NULL` | Warna unit |
| `is_available` | `bool` | `true` | Status ketersediaan unit |
| `status` | `text` | `'available'` | Status detail: `available` / `rented` |
| `note` | `text` | `NULL` | Catatan tambahan unit |
| `image_url` | `text` | `NULL` | URL foto unit (dari Supabase Storage) |
| `price_per_15_mins` | `int4` | `20000` | Tarif sewa per 15 menit (Rupiah) |


### Tabel `rentals`
 
> Menyimpan seluruh riwayat dan transaksi sewa aktif.
 
| Kolom | Tipe | Default | Keterangan |
|---|---|---|---|
| `id` | `uuid` | `gen_random_uuid()` | Primary key |
| `created_at` | `timestamptz` | `now()` | Waktu transaksi dibuat |
| `car_id` | `uuid` | — | FK → `cars.id` |
| `car_name` | `text` | — | Snapshot nama unit saat sewa |
| `renter_name` | `text` | — | Nama penyewa |
| `renter_phone` | `text` | — | Nomor telepon penyewa |
| `renter_address` | `text` | — | Alamat penyewa |
| `start_time` | `timestamptz` | — | Waktu mulai sewa |
| `end_time` | `timestamptz` | — | Waktu selesai sewa |
| `duration_minutes` | `int4` | — | Total durasi dalam menit |
| `total_price` | `int4` | — | Total biaya sewa (Rupiah) |
| `is_paid` | `bool` | `false` | Status pembayaran |
| `status` | `text` | `'active'` | Status sewa: `active` / `returned` |


## Dependencies

| Package | Versi | Fungsi |
|---|---|---|
| `provider` | ^6.1.1 | State management |
| `supabase_flutter` | ^2.3.4 | Backend & Auth |
| `flutter_dotenv` | ^5.1.0 | Konfigurasi environment |
| `intl` | ^0.18.1 | Format tanggal & angka (Bahasa Indonesia) |
| `flutter_local_notifications` | ^21.0.0 | Notifikasi lokal terjadwal |
| `timezone` | ^0.11.0 | Zona waktu (Asia/Makassar) |
| `image_picker` | ^1.2.1 | Upload foto dari galeri/kamera |
| `flutter_launcher_icons` | ^0.14.1 | Generate ikon aplikasi |

---


## Akun Default

| Role | Email | Akses |
|---|---|---|
| **Admin** | `admin@gmail.com` | Semua fitur + kelola akun pengguna |
| **Operator** | *(akun lain)* | Fitur operasional standar |

> Admin dapat membuat akun operator melalui menu **Kelola Akun** di AppBar.

---
