# Pantryon

A clean, minimalist, and highly functional mobile application built with **Flutter** to help users manage their kitchen inventory, track expiration dates, and minimize food waste. Powered by **Supabase** for real-time database and authentication.

---

## ✨ Main Feature

* **Manajemen Inventaris Real-Time:** Tambah, edit, dan hapus item pantry dengan mudah. Data tersinkronisasi secara *real-time* menggunakan Supabase.
* **Smart Expiration Tracker:** * Perhitungan sisa waktu otomatis (mendukung format hari, bulan, dan tahun).
    * Indikator visual yang intuitif (Hijau untuk aman, Kuning untuk hampir kedaluwarsa, Merah untuk kedaluwarsa).
* **Pencarian & Filter Cerdas:** Cari barang berdasarkan nama atau filter berdasarkan kategori spesifik (Sayuran, Buah, Daging, dll).
* **Custom Sorting:** Urutkan barang berdasarkan waktu kedaluwarsa terdekat, abjad (A-Z), kategori, atau tanggal ditambahkan.
* **Clean & Minimalist UI:** Antarmuka pengguna yang modern, responsif, dan mudah dinavigasi.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **State Management:** Provider
* **Backend / BaaS:** Supabase (PostgreSQL, Auth)
* **Tools Tambahan:** `intl` (untuk formatting tanggal)

---

## 📸 Screenshots

*(Tambahkan tangkapan layar aplikasi Anda di sini untuk mempercantik README)*

| Home / Inventory List | Add/Edit Item | Empty State |
| :---: | :---: | :---: |
| `<img src="link_ke_gambar_1" width="250">` | `<img src="link_ke_gambar_2" width="250">` | `<img src="link_ke_gambar_3" width="250">` |

---

## 🚀 Getting Started

### Prasyarat
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi terbaru)
* Akun [Supabase](https://supabase.com/)

### Instalasi

1.  **Clone repositori ini:**
    ```bash
    git clone [https://github.com/username_anda/nama_repo_anda.git](https://github.com/username_anda/nama_repo_anda.git)
    cd nama_repo_anda
    ```

2.  **Install semua dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Setup Supabase:**
    * Buat proyek baru di Supabase.
    * Jalankan query SQL berikut di SQL Editor Supabase untuk membuat tabel `pantry_items`:
        ```sql
        create table pantry_items (
          id uuid default uuid_generate_v4() primary key,
          user_id uuid references auth.users not null,
          name text not null,
          category text not null,
          quantity integer not null,
          unit text not null,
          expiry_date timestamp with time zone not null,
          added_date timestamp with time zone default now()
        );
        ```
    * Atur RLS (Row Level Security) agar *user* hanya bisa mengakses datanya sendiri.

4.  **Konfigurasi Environment Variables:**
    * Buat file `.env` di *root directory* atau atur langsung di fungsi inisialisasi Supabase Anda pada file `main.dart`.
    * Masukkan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` milik Anda.

5.  **Jalankan Aplikasi:**
    ```bash
    flutter run
    ```

---

## 📂 Folder Structure

```text
lib/
│
├── models/         # Data models (pantry_item.dart)
├── providers/      # State management logic (pantry_provider.dart)
├── screens/        # UI Screens (inventory.dart)
├── styles/         # Global styles, colors, and themes
├── widgets/        # Reusable UI components (alter_item.dart)
└── main.dart       # Entry point & Supabase initialization
