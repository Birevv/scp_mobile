# 📱 School Class Progress (SCP) Mobile - UKK 2026

![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-64%20Passed-success?style=for-the-badge&logo=flutter)
![Auth](https://img.shields.io/badge/Auth-Laravel%20Sanctum-FF2D20?style=for-the-badge&logo=laravel)

Aplikasi mobile resmi sistem **School Class Progress (SCP)** yang dibangun dengan Flutter untuk mendukung kegiatan belajar mengajar di Sekolah Menengah Kejuruan (SMK) dengan skema *Teaching Factory (TeFa)* dan sistem **Jadwal Blok 2-Mingguan (Putaran 1 & Putaran 2)**.

Aplikasi ini dikembangkan untuk memenuhi kualifikasi nilai tertinggi pada **Uji Kompetensi Keahlian (UKK) Rekayasa Perangkat Lunak (RPL) Tahun Ajaran 2026/2027 Paket 3**, terhubung secara realtime dengan backend Laravel 13 melalui REST API dan autentikasi token Laravel Sanctum.

---

## 🎯 5 Logika Bisnis Utama (Kunci Penilaian UKK)

Aplikasi mobile SCP mengimplementasikan 5 aturan bisnis inti yang menjadi tolok ukur pengujian UKK Paket 3:

1. **Saklar Putaran Blok (Cycle Toggle):**  
   Header dan kontrol putaran aktif (`Putaran 1` / `Putaran 2`) yang menyesuaikan jadwal pelajaran harian, agenda mengajar, dan filter rekap secara dinamis.
2. **Deteksi Bentrok Jadwal Mandiri (Conflict Prevention):**  
   Form tambah jadwal guru memvalidasi irisan jam (`start_a < end_b AND end_a > start_b`) pada hari, putaran, serta ruang, kelas, atau guru yang sama secara instan sebelum tersimpan.
3. **Mekanisme Kunci Jadwal (Schedule Lock Protection):**  
   Jika Waka Kurikulum mengaktifkan status kunci jadwal di backend, tombol penambahan dan pengubahan jadwal dinonaktifkan otomatis dengan peringatan informatif.
4. **Sinkronisasi Presensi Otomatis (Auto-Sync Approval):**  
   Surat izin siswa yang telah disetujui (`Approved`) oleh Wali Kelas atau Guru BK otomatis terisi berstatus `Sakit` atau `Izin` pada formulir presensi saat guru membuka jurnal kelas.
5. **Dashboard Alert Reminder (>30 Menit):**  
   Banner peringatan interaktif di dashboard guru jika jadwal mengajar telah selesai lebih dari 30 menit namun guru belum mengisi jurnal tatap muka, lengkap dengan tombol langsung ke formulir jurnal.

---

## 👥 Persona & Fitur Role-Based Mobile

Aplikasi menerapkan arsitektur **Single App Multi-Role**: antarmuka navigasi dan dashboard berganti otomatis sesuai hak akses pengguna:

### 1. Siswa & Orang Tua (`role: Siswa`)
- **Ringkasan Kehadiran:** Kartu metrik persentase kehadiran, total hadir, izin, sakit, dan alpa.
- **Jadwal Pelajaran:** Kalender timeline harian berbasis Putaran Blok aktif.
- **Pengajuan Izin Mandiri:** Formulir izin (Sakit, Izin, Dispensasi, Tugas Luar) dengan integrasi kamera dan galeri untuk upload bukti surat fisik atau surat dokter.
- **Riwayat Presensi:** Laporan rekap kehadiran per semester beserta riwayat status pengajuan izin.

### 2. Guru Pengajar (`role: Guru`)
- **Dashboard Hari Ini:** Kartu jam real-time (WIB) dan status jam mengajar aktif.
- **Input Jurnal & Foto Kelas:** Unggah 1 foto dokumentasi suasana kelas secara langsung (kamera/galeri) disertai ringkasan materi dan catatan kelas.
- **Presensi Terpadu:** Pengisian status hadir murid per siswa dengan indikator otomatis bagi siswa yang telah memiliki surat izin resmi.
- **Input Jadwal Mandiri:** Tambah agenda pelajaran baru dengan pengecekan validasi anti-bentrok.
- **Riwayat Jurnal:** Arsip rekap jurnal mengajar yang telah diisi sebelumnya.

### 3. Wali Kelas & Guru BK (`role: Wali Kelas` | `role: Guru BK`)
- **Monitoring Siswa Binaan:** Daftar seluruh siswa dalam kelas binaan lengkap dengan persentase absensi dan status kehadiran harian.
- **Filter Multi-Kelas (Khusus Guru BK):** Pilihan filter chip untuk berpindah kelas asuhan dengan cepat.
- **Verifikasi Perizinan:** Antrean perizinan masuk dengan fitur preview bukti foto surat, tombol *Approve* (Setujui), dan *Reject* (Tolak).
- **Agenda Mengajar & Jurnal:** Wali kelas dan Guru BK yang memiliki jadwal jam ajar tetap dapat mengisi jurnal layaknya guru mata pelajaran.

> **Catatan Akun Administrator / Waka Kurikulum:**  
> Akun dengan role non-mobile (seperti Waka Kurikulum dan Admin Web) diarahkan ke layar edukatif untuk mengakses panel administrasi melalui browser desktop.

---

## 🔐 Akun Default Pengujian

Akun berikut dapat digunakan langsung untuk menguji fitur aplikasi:

| Role | Username | Password | Deskripsi Pengujian |
| :--- | :--- | :--- | :--- |
| **Siswa & Orang Tua** | `siswa1` | `password` | Pengajuan izin, upload surat dokter, rekap absensi |
| **Guru Pengajar** | `guru1` | `password` | Agenda jadwal, input jurnal + kamera, alert reminder |
| **Wali Kelas** | `walikelas1` | `password` | Verifikasi/approve surat izin, monitoring murid binaan |
| **Guru BK** | `gurubk` | `password` | Filter multi-kelas binaan, verifikasi izin, input jurnal |

---

## 🏗️ Struktur Direktori Proyek

```text
scp_mobile/
├── assets/
│   └── images/                # Logo SMK, ikon, dan ilustrasi lokal
├── instructions/
│   ├── design.md              # Spesifikasi token desain & UI guidelines
│   └── PRD_MOBILE_SCP_SMK.md  # Product Requirement Document lengkap
├── lib/
│   ├── constants/             # Konstanta tema, warna, spasi, dan tipografi
│   ├── models/                # Model data & serialisasi JSON REST API
│   ├── screens/
│   │   ├── guru/              # Antarmuka dashboard, jadwal, dan jurnal guru
│   │   ├── shared/            # Splash screen, login, profil, dan kalender
│   │   ├── siswa/             # Dashboard, jadwal, formulir izin, dan riwayat
│   │   └── wali/              # Verifikasi izin dan pemantauan siswa binaan
│   ├── services/              # ApiService, TokenStorage, dan Notifikasi
│   ├── state/                 # Manajemen state aplikasi (AppState ChangeNotifier)
│   ├── theme/                 # Konfigurasi ThemeData terang dan gelap
│   ├── widgets/               # Komponen UI modular (cards, headers, buttons, dll.)
│   └── main.dart              # Entrypoint aplikasi Flutter
└── test/                      # 64 unit dan integration widget tests
```

---

## ⚙️ Panduan Instalasi & Menjalankan Aplikasi

### 1. Prasyarat Sistem
- **Flutter SDK:** versi `^3.9.0` atau yang kompatibel
- **Dart SDK:** versi `^3.9.0`
- **Android Studio** atau **VS Code** dengan ekstensi Flutter & Dart
- Emulator Android / iOS atau perangkat fisik dengan fitur *USB Debugging* aktif

### 2. Unduh Dependensi
Jalankan perintah berikut pada direktori root `scp_mobile`:

```bash
flutter pub get
```

### 3. Konfigurasi Endpoint Backend API
Aplikasi menggunakan environment flag `SCP_API_URL` untuk menentukan server backend target:

```bash
# Skenario 1: Server Production / Online Hosting
flutter run --dart-define=SCP_API_URL=https://progreskelas.my.id/api

# Skenario 2: Backend Lokal via Android Emulator (10.0.2.2 merujuk ke localhost host)
flutter run --dart-define=SCP_API_URL=http://10.0.2.2:8000/api

# Skenario 3: Backend Lokal via Perangkat Fisik (Gunakan IP LAN WiFi komputer)
flutter run --dart-define=SCP_API_URL=http://192.168.1.10:8000/api
```

> Jika `--dart-define=SCP_API_URL` tidak disertakan, aplikasi secara default mengarah ke `https://progreskelas.my.id/api`.

---

## 🧪 Pengujian Otomatis (Automated Testing)

Repositori ini dilengkapi dengan **64 pengujian otomatis** yang memvalidasi integritas logika, respon layout di berbagai resolusi layar (320px hingga 430px), dan konsistensi integrasi API:

```bash
flutter test
```

### Lingkup Pengujian:
- **Responsivitas Layar:** Pengujian render bebas overflow pada resolusi 320px, 360px, 375px, 390px, 412px, 414px, dan 430px.
- **Logika Presensi:** Verifikasi kalkulasi kehadiran (tampilan tanda strip saat data kosong, bukan angka 100% fiktif).
- **Notifikasi:** Pengujian `LocalNotificationService` dan in-app banner alert.
- **Filter Guru BK:** Pengujian filter perpindahan antar-kelas asuhan.
- **Kamera & Upload:** Pengujian alur pemilihan gambar kamera dan galeri untuk bukti presensi serta surat izin.
- **Wali Kelas:** Pengujian daftar murid binaan, persetujuan izin, dan jadwal ajar wali.

---

## 📦 Build Paket Rilis (Production APK)

Untuk menghasilkan berkas APK rilis yang siap diinstal di perangkat Android:

```bash
flutter build apk --release --dart-define=SCP_API_URL=https://progreskelas.my.id/api
```

Berkas APK akan tersedia di:
`build/app/outputs/flutter-apk/app-release.apk`
