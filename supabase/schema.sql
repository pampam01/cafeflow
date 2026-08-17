-- ====================================================================
-- SKEMA DATABASE CAFEFLOW (SUPABASE POSTGRESQL)
-- Standard Production-Grade Schema
-- Aturan Wajib: Prefix `data_`, Bahasa Indonesia, UUID PK, RLS Enabled
-- ====================================================================

-- Extension untuk UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. FUNGSI UNTUK OTOMATIS UPDATE COLUMN diubah_pada
CREATE OR REPLACE FUNCTION perbarui_diubah_pada()
RETURNS TRIGGER AS $$
BEGIN
    NEW.diubah_pada = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ====================================================================
-- TABEL: data_kafe
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_kafe (
    id_kafe UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama_kafe VARCHAR(150) NOT NULL,
    alamat TEXT,
    nomor_telepon VARCHAR(20),
    email_kafe VARCHAR(100),
    zona_waktu VARCHAR(50) DEFAULT 'Asia/Jakarta',
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_data_kafe_diubah_pada
BEFORE UPDATE ON data_kafe
FOR EACH ROW EXECUTE FUNCTION perbarui_diubah_pada();

-- ====================================================================
-- TABEL: data_pengguna (Terhubung ke auth.users Supabase)
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_pengguna (
    id_pengguna UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    id_kafe UUID REFERENCES data_kafe(id_kafe) ON DELETE SET NULL,
    nama_lengkap VARCHAR(150) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    peran VARCHAR(30) NOT NULL CHECK (peran IN ('pemilik', 'manajer', 'kasir', 'staf')),
    status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_data_pengguna_kafe ON data_pengguna(id_kafe);
CREATE TRIGGER trg_data_pengguna_diubah_pada
BEFORE UPDATE ON data_pengguna
FOR EACH ROW EXECUTE FUNCTION perbarui_diubah_pada();

-- ====================================================================
-- TABEL: data_meja
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_meja (
    id_meja UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_kafe UUID NOT NULL REFERENCES data_kafe(id_kafe) ON DELETE CASCADE,
    nomor_meja VARCHAR(20) NOT NULL,
    nama_meja VARCHAR(50),
    kapasitas INT NOT NULL DEFAULT 2 CHECK (kapasitas > 0),
    status_meja VARCHAR(30) NOT NULL DEFAULT 'tersedia' CHECK (status_meja IN ('tersedia', 'terisi', 'dipesan', 'nonaktif')),
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id_kafe, nomor_meja)
);

CREATE INDEX idx_data_meja_kafe ON data_meja(id_kafe);
CREATE INDEX idx_data_meja_status ON data_meja(status_meja);
CREATE TRIGGER trg_data_meja_diubah_pada
BEFORE UPDATE ON data_meja
FOR EACH ROW EXECUTE FUNCTION perbarui_diubah_pada();

-- ====================================================================
-- TABEL: data_pelanggan
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_pelanggan (
    id_pelanggan UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_kafe UUID NOT NULL REFERENCES data_kafe(id_kafe) ON DELETE CASCADE,
    nama_pelanggan VARCHAR(150) NOT NULL,
    nomor_telepon VARCHAR(20),
    catatan TEXT,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_data_pelanggan_kafe ON data_pelanggan(id_kafe);

-- ====================================================================
-- TABEL: data_aturan_waktu
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_aturan_waktu (
    id_aturan_waktu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_kafe UUID NOT NULL REFERENCES data_kafe(id_kafe) ON DELETE CASCADE,
    min_belanja NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    durasi_menit INT NOT NULL CHECK (durasi_menit > 0),
    berlaku_saat_ramai BOOLEAN NOT NULL DEFAULT TRUE,
    status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_data_aturan_waktu_kafe ON data_aturan_waktu(id_kafe);

-- ====================================================================
-- TABEL: data_sesi_meja
-- Catatan: Countdown dihitung secara lokal oleh Flutter. 
-- Database hanya menyimpan waktu_mulai dan waktu_berakhir.
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_sesi_meja (
    id_sesi_meja UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_kafe UUID NOT NULL REFERENCES data_kafe(id_kafe) ON DELETE CASCADE,
    id_meja UUID NOT NULL REFERENCES data_meja(id_meja) ON DELETE CASCADE,
    id_pelanggan UUID REFERENCES data_pelanggan(id_pelanggan) ON DELETE SET NULL,
    waktu_mulai TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    waktu_berakhir TIMESTAMPTZ NOT NULL,
    durasi_awal_menit INT NOT NULL CHECK (durasi_awal_menit > 0),
    total_durasi_menit INT NOT NULL CHECK (total_durasi_menit >= durasi_awal_menit),
    status_sesi VARCHAR(30) NOT NULL DEFAULT 'aktif' CHECK (status_sesi IN ('aktif', 'selesai', 'dibatalkan', 'kedaluwarsa')),
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_data_sesi_meja_kafe ON data_sesi_meja(id_kafe);
CREATE INDEX idx_data_sesi_meja_meja ON data_sesi_meja(id_meja);
CREATE INDEX idx_data_sesi_meja_status ON data_sesi_meja(status_sesi);
CREATE TRIGGER trg_data_sesi_meja_diubah_pada
BEFORE UPDATE ON data_sesi_meja
FOR EACH ROW EXECUTE FUNCTION perbarui_diubah_pada();

-- ====================================================================
-- TABEL: data_produk
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_produk (
    id_produk UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_kafe UUID NOT NULL REFERENCES data_kafe(id_kafe) ON DELETE CASCADE,
    nama_produk VARCHAR(150) NOT NULL,
    kategori VARCHAR(50) NOT NULL DEFAULT 'makanan' CHECK (kategori IN ('makanan', 'minuman', 'snack', 'lainnya')),
    harga NUMERIC(12, 2) NOT NULL CHECK (harga >= 0),
    durasi_tambahan_menit INT NOT NULL DEFAULT 0 CHECK (durasi_tambahan_menit >= 0),
    status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_data_produk_kafe ON data_produk(id_kafe);
CREATE TRIGGER trg_data_produk_diubah_pada
BEFORE UPDATE ON data_produk
FOR EACH ROW EXECUTE FUNCTION perbarui_diubah_pada();

-- ====================================================================
-- TABEL: data_pesanan
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_pesanan (
    id_pesanan UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_kafe UUID NOT NULL REFERENCES data_kafe(id_kafe) ON DELETE CASCADE,
    id_meja UUID REFERENCES data_meja(id_meja) ON DELETE SET NULL,
    id_sesi_meja UUID REFERENCES data_sesi_meja(id_sesi_meja) ON DELETE SET NULL,
    nomor_pesanan VARCHAR(50) NOT NULL,
    total_belanja NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (total_belanja >= 0),
    status_pesanan VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status_pesanan IN ('pending', 'diproses', 'selesai', 'dibatalkan')),
    waktu_pesanan TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_data_pesanan_kafe ON data_pesanan(id_kafe);
CREATE INDEX idx_data_pesanan_sesi ON data_pesanan(id_sesi_meja);
CREATE TRIGGER trg_data_pesanan_diubah_pada
BEFORE UPDATE ON data_pesanan
FOR EACH ROW EXECUTE FUNCTION perbarui_diubah_pada();

-- ====================================================================
-- TABEL: data_detail_pesanan
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_detail_pesanan (
    id_detail_pesanan UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_pesanan UUID NOT NULL REFERENCES data_pesanan(id_pesanan) ON DELETE CASCADE,
    id_produk UUID NOT NULL REFERENCES data_produk(id_produk) ON DELETE RESTRICT,
    jumlah INT NOT NULL CHECK (jumlah > 0),
    harga_satuan NUMERIC(12, 2) NOT NULL CHECK (harga_satuan >= 0),
    subtotal NUMERIC(12, 2) NOT NULL CHECK (subtotal >= 0),
    catatan TEXT,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_detail_pesanan_pesanan ON data_detail_pesanan(id_pesanan);

-- ====================================================================
-- TABEL: data_notifikasi
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_notifikasi (
    id_notifikasi UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_kafe UUID NOT NULL REFERENCES data_kafe(id_kafe) ON DELETE CASCADE,
    id_pengguna UUID REFERENCES data_pengguna(id_pengguna) ON DELETE CASCADE,
    judul VARCHAR(150) NOT NULL,
    pesan TEXT NOT NULL,
    tipe VARCHAR(50) NOT NULL DEFAULT 'sistem' CHECK (tipe IN ('peringatan_waktu', 'pesanan_baru', 'sistem')),
    sudah_dibaca BOOLEAN NOT NULL DEFAULT FALSE,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_data_notifikasi_kafe ON data_notifikasi(id_kafe);

-- ====================================================================
-- TABEL: data_log_aktivitas
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_log_aktivitas (
    id_log_aktivitas UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_kafe UUID NOT NULL REFERENCES data_kafe(id_kafe) ON DELETE CASCADE,
    id_pengguna UUID REFERENCES data_pengguna(id_pengguna) ON DELETE SET NULL,
    jenis_aktivitas VARCHAR(100) NOT NULL,
    deskripsi TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_data_log_kafe ON data_log_aktivitas(id_kafe);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================
ALTER TABLE data_kafe ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_pengguna ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_meja ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_pelanggan ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_aturan_waktu ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_sesi_meja ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_produk ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_pesanan ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_detail_pesanan ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_notifikasi ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_log_aktivitas ENABLE ROW LEVEL SECURITY;

-- Policy RLS Pengguna Terautentikasi (Akses Berdasarkan id_kafe)
CREATE POLICY "Pengguna terautentikasi dapat membaca data kafe mereka" ON data_kafe
    FOR SELECT TO authenticated
    USING (id_kafe IN (SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()));

CREATE POLICY "Pengguna terautentikasi dapat membaca data pengguna satu kafe" ON data_pengguna
    FOR SELECT TO authenticated
    USING (id_kafe IN (SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()));

CREATE POLICY "Pengguna terautentikasi dapat megelola data meja kafe mereka" ON data_meja
    FOR ALL TO authenticated
    USING (id_kafe IN (SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()));

CREATE POLICY "Pengguna terautentikasi dapat mengelola data sesi meja kafe mereka" ON data_sesi_meja
    FOR ALL TO authenticated
    USING (id_kafe IN (SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()));

CREATE POLICY "Pengguna terautentikasi dapat mengelola data produk kafe mereka" ON data_produk
    FOR ALL TO authenticated
    USING (id_kafe IN (SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()));

CREATE POLICY "Pengguna terautentikasi dapat mengelola data pesanan kafe mereka" ON data_pesanan
    FOR ALL TO authenticated
    USING (id_kafe IN (SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()));

CREATE POLICY "Pengguna terautentikasi dapat mengelola detail pesanan kafe mereka" ON data_detail_pesanan
    FOR ALL TO authenticated
    USING (id_pesanan IN (
        SELECT id_pesanan FROM data_pesanan 
        WHERE id_kafe IN (SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid())
    ));
