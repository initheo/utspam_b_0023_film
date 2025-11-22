# M-TIX - Aplikasi Pembelian Tiket Film

Aplikasi mobile untuk pembelian tiket film berbasis Flutter dengan database SQLite lokal. Proyek ini merupakan bagian dari Ujian Tengah Semester (UTS) Pemrograman Mobile.

## Informasi Proyek

- **Mata Kuliah**: Pemrograman Mobile
- **Kelas**: IF-5B
- **NIM**: 3012310023
- **Nama**: Muhammad Muqoffin Nuha
- **Kategori**: Aplikasi Film
- **Platform**: Android & iOS (Flutter)
- **Database**: SQLite (sqflite)

## Fitur Utama

### 1. Autentikasi

- **Login**: Masuk menggunakan username dan password
- **Register**: Pendaftaran pengguna baru dengan validasi lengkap
- **Forgot Password**: Reset password dengan verifikasi username dan email
- **Logout**: Keluar dari aplikasi dengan aman

### 2. Manajemen Film

- **Daftar Film**: Menampilkan semua film yang tersedia
- **Detail Film**: Informasi lengkap tentang film (judul, genre, poster, harga tiket)
- **Pencarian**: Filter film berdasarkan kriteria tertentu

### 3. Pembelian Tiket

- **Pilih Film & Jadwal**: Memilih film dan waktu tayang
- **Input Jumlah Tiket**: Menentukan jumlah tiket yang dibeli
- **Kalkulasi Harga Otomatis**: Total harga dihitung otomatis
- **Metode Pembayaran**: Pilihan antara Cash atau Card
- **Konfirmasi Pembelian**: Review detail sebelum konfirmasi

### 4. Riwayat Transaksi

- **Daftar Transaksi**: Melihat semua transaksi yang pernah dilakukan
- **Detail Transaksi**: Informasi lengkap setiap transaksi
- **Sensor Nomor Kartu**: Masking nomor kartu (menampilkan hanya 4 digit terakhir)
- **Edit Transaksi**: Mengubah detail transaksi yang sudah dibuat
- **Cancel Transaksi**: Membatalkan transaksi dengan konfirmasi

### 5. Manajemen Profil

- **View Profile**: Melihat informasi profil pengguna
- **Edit Profile**: Mengubah nama lengkap, nomor telepon, dan alamat
- **Change Password**: Mengganti password dengan verifikasi password lama
- **Validasi**: Validasi lengkap untuk semua input

## Arsitektur & Teknologi

### Struktur Proyek

```
lib/
├── main.dart                              # Entry point aplikasi
├── data/
│   ├── db/
│   │   ├── db_helper.dart                # Database Helper (SQLite)
│   │   └── mtix_dao.dart                 # Database Access Object
│   ├── model/
│   │   ├── user_model.dart               # Model User
│   │   ├── film_model.dart               # Model Film
│   │   ├── schedule_model.dart           # Model Jadwal
│   │   └── transaction_model.dart        # Model Transaksi
│   └── repository/
│       ├── user_repository.dart          # Repository User
│       ├── film_repository.dart          # Repository Film
│       ├── schedule_repository.dart      # Repository Jadwal
│       └── transaction_repository.dart   # Repository Transaksi
├── presentation/
│   └── screens/
│       ├── main_navigation.dart          # Bottom Navigation
│       ├── auth/                         # Screens Autentikasi
│       │   ├── onboarding_screen.dart
│       │   ├── login_screen.dart
│       │   ├── register_screen.dart
│       │   └── forgot_password_screen.dart
│       ├── home/                         # Screens Home
│       │   └── home_screen.dart
│       ├── films/                        # Screens Film
│       │   └── films_screen.dart
│       ├── tickets/                      # Screens Tiket
│       │   └── my_tickets_screen.dart
│       ├── transaction/                  # Screens Transaksi
│       │   ├── purchase_ticket_screen.dart
│       │   ├── transaction_success_screen.dart
│       │   ├── transaction_detail_screen.dart
│       │   └── edit_transaction_screen.dart
│       └── profile/                      # Screens Profil
│           ├── profile_screen.dart
│           ├── edit_profile_screen.dart
│           └── change_password_screen.dart
└── utils/                                # Utility Classes
    ├── app_colors.dart                   # Konstanta Warna
    ├── formatters.dart                   # Format Currency & DateTime
    ├── ui_helpers.dart                   # UI Helper Functions
    └── validators.dart                   # Form Validators
```

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.4.1 # Database SQLite lokal
  path: ^1.9.0 # Path utilities
  intl: ^0.19.0 # Format tanggal & currency
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### Manajemen Data Pengguna

Aplikasi ini menggunakan **Constructor Passing Pattern** untuk mengelola data pengguna yang sedang login:

- **Login Flow**: Login → MainNavigation (userId, userName, userEmail) → Semua screen child
- **Data Passing**: Data pengguna diteruskan melalui constructor dari parent ke child widget
- **Trade-off**: Pengguna harus login setiap kali membuka aplikasi (tidak ada auto-login)

## Database Schema

![ERD](./ERD.png)

### Tabel User

```sql
CREATE TABLE User (
  user_id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama_lengkap VARCHAR NOT NULL,
  email VARCHAR NOT NULL UNIQUE,
  alamat TEXT,
  nomor_telepon VARCHAR NOT NULL,
  username VARCHAR NOT NULL UNIQUE,
  password VARCHAR NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### Tabel Film

```sql
CREATE TABLE Film (
  film_id INTEGER PRIMARY KEY AUTOINCREMENT,
  judul_film VARCHAR NOT NULL,
  genre_film VARCHAR NOT NULL,
  harga_tiket INTEGER NOT NULL,
  poster_film TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### Tabel Jadwal

```sql
CREATE TABLE Jadwal (
  jadwal_id INTEGER PRIMARY KEY AUTOINCREMENT,
  film_id INTEGER NOT NULL,
  waktu_tayang DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (film_id) REFERENCES Film (film_id)
)
```

### Tabel Transaksi

```sql
CREATE TABLE Transaksi (
  transaksi_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  jadwal_id INTEGER NOT NULL,
  nama_pembeli VARCHAR NOT NULL,
  jumlah_tiket INTEGER NOT NULL,
  tanggal_pembelian VARCHAR NOT NULL,
  total_harga INTEGER NOT NULL,
  metode_pembayaran VARCHAR NOT NULL,
  nomor_kartu VARCHAR,
  status VARCHAR NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES User (user_id),
  FOREIGN KEY (jadwal_id) REFERENCES Jadwal (jadwal_id)
)
```

## Cara Menjalankan

### Prerequisites

- Flutter SDK (>=3.5.4 <4.0.0)
- Dart SDK
- Android Studio / VS Code
- Android Emulator / iOS Simulator / Physical Device

### Instalasi

1. Clone repository

```bash
git clone https://github.com/initheo/utspam_b_0023_film.git
cd utspam_b_0023_film
```

2. Install dependencies

```bash
flutter pub get
```

3. Jalankan aplikasi

```bash
flutter run
```

## Video Demonstrasi


https://github.com/user-attachments/assets/f769ea41-af25-48d8-ad36-86c952b892ad

**Isi Video:**

1. Onboarding
   
   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 22 52" src="https://github.com/user-attachments/assets/dc63e15c-f327-4b76-973e-9aa68883436b" />


2. Register & Login
   
   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 23 10" src="https://github.com/user-attachments/assets/10024b94-ad0e-472d-9b46-fb6fc7c8e7a9" />
   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 23 21" src="https://github.com/user-attachments/assets/f21bfd76-ae3d-4dac-a3cc-b9e5a2cfb599" />


3. Home Dashboard

   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 23 47" src="https://github.com/user-attachments/assets/4003c078-cc21-4382-b73f-47d128ddef34" />


4. Browse Films

   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 23 53" src="https://github.com/user-attachments/assets/2d59b47a-5c4e-433b-b7f7-823ac742ae6e" />


5. Purchase Ticket Flow (Pilih film → jadwal → jumlah tiket → pembayaran)

   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 24 13" src="https://github.com/user-attachments/assets/70836d0b-2db5-4492-85df-905205c70ec9" />
   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 24 29" src="https://github.com/user-attachments/assets/ed1a736c-f2d8-4dd7-9d90-6b5a71497027" />
   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 24 40" src="https://github.com/user-attachments/assets/1626c064-c19a-41f3-99bd-3cdc3d140593" />


6. Transaction History

   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 23 59" src="https://github.com/user-attachments/assets/d2fac315-c055-49da-a847-a57c41bbca38" />


7. Transaction Detail dengan Card Masking

   <img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/25fd46b2-07de-4f4d-8298-b5074d63cd78" />


8. Edit Transaction

   <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 25 39" src="https://github.com/user-attachments/assets/80274f0e-c02c-4c45-9977-8bb6f615f79a" />


9. Cancel Transaction

   <img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/ef27f66b-613d-42b5-9ed5-a099b5166c57" />
   <img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/0b3f4591-6589-4f2b-ac72-f9e3a7b90c54" />

    
10. Profile Management (View, Edit, Change Password)

    <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 24 04" src="https://github.com/user-attachments/assets/7a0cd5a9-c628-4377-9a05-3570e158be14" />
    <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 25 52" src="https://github.com/user-attachments/assets/901f2c24-8823-4898-9fdd-5216f812e291" />
    <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 Pro Max - 2025-11-22 at 21 25 58" src="https://github.com/user-attachments/assets/3989bfab-edca-473a-be60-5b568ccb52bb" />


11. Forgot Password

    <img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/bc6262f3-312c-4a3b-a110-083b06728474" />
    <img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/1fe776f1-dce3-4496-84b4-dfce8078d26f" />

    
12. Logout

    <img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/bd0c6a1a-771c-4885-8c47-8c15bf007ce2" />


---

## 🎨 Credits & References

### UI Design Template

- **Source**: [Superwrapper](https://superwrapper.in/)
- **Usage**: Template UI dan inspirasi desain interface aplikasi

Proyek ini menggunakan referensi dan template UI dari Superwrapper untuk mempercepat pengembangan dan memastikan desain yang modern dan user-friendly.

## 📄 License

This project is created for educational purposes as part of Mobile Programming course requirements.
