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
