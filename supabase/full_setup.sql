-- ====================================================================
-- FULL SETUP DATABASE CAFEFLOW (PRODUCTION-GRADE SCHEMA + AUTOMATIC USER TRIGGER)
-- Jalankan di Supabase Dashboard -> SQL Editor
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

DROP TRIGGER IF EXISTS trg_data_kafe_diubah_pada ON data_kafe;
CREATE TRIGGER trg_data_kafe_diubah_pada
BEFORE UPDATE ON data_kafe
FOR EACH ROW EXECUTE FUNCTION perbarui_diubah_pada();

-- Inisialisasi Kafe Default jika belum ada
INSERT INTO data_kafe (nama_kafe, alamat, nomor_telepon, email_kafe)
VALUES ('CafeFlow Central', 'Jl. Sudirman No. 1, Jakarta Pusat', '081234567890', 'central@cafeflow.com')
ON CONFLICT DO NOTHING;

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

CREATE INDEX IF NOT EXISTS idx_data_pengguna_kafe ON data_pengguna(id_kafe);
DROP TRIGGER IF EXISTS trg_data_pengguna_diubah_pada ON data_pengguna;
CREATE TRIGGER trg_data_pengguna_diubah_pada
BEFORE UPDATE ON data_pengguna
FOR EACH ROW EXECUTE FUNCTION perbarui_diubah_pada();

-- ====================================================================
-- TABEL: data_pegawai_kafe (Relasi Many-to-Many Pengguna <-> Kafe)
-- ====================================================================
CREATE TABLE IF NOT EXISTS data_pegawai_kafe (
    id_pegawai_kafe UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_pengguna UUID NOT NULL REFERENCES data_pengguna(id_pengguna) ON DELETE CASCADE,
    id_kafe UUID NOT NULL REFERENCES data_kafe(id_kafe) ON DELETE CASCADE,
    peran VARCHAR(30) NOT NULL CHECK (peran IN ('pemilik', 'manajer', 'kasir', 'staf')),
    status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id_pengguna, id_kafe)
);

CREATE INDEX IF NOT EXISTS idx_data_pegawai_kafe_pengguna ON data_pegawai_kafe(id_pengguna);
CREATE INDEX IF NOT EXISTS idx_data_pegawai_kafe_kafe ON data_pegawai_kafe(id_kafe);
DROP TRIGGER IF EXISTS trg_data_pegawai_kafe_diubah_pada ON data_pegawai_kafe;
CREATE TRIGGER trg_data_pegawai_kafe_diubah_pada
BEFORE UPDATE ON data_pegawai_kafe
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
    urutan_tampilan INT NOT NULL DEFAULT 0,
    kode_qr VARCHAR(255),
    status_meja VARCHAR(30) NOT NULL DEFAULT 'tersedia' CHECK (status_meja IN ('tersedia', 'terisi', 'dipesan', 'nonaktif')),
    status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id_kafe, nomor_meja)
);

-- Pengamanan Tambahan Kolom Baru pada data_meja
ALTER TABLE data_meja ADD COLUMN IF NOT EXISTS urutan_tampilan INT NOT NULL DEFAULT 0;
ALTER TABLE data_meja ADD COLUMN IF NOT EXISTS kode_qr VARCHAR(255);
ALTER TABLE data_meja ADD COLUMN IF NOT EXISTS status_aktif BOOLEAN NOT NULL DEFAULT TRUE;

CREATE INDEX IF NOT EXISTS idx_data_meja_kafe ON data_meja(id_kafe);
CREATE INDEX IF NOT EXISTS idx_data_meja_status ON data_meja(status_meja);
DROP TRIGGER IF EXISTS trg_data_meja_diubah_pada ON data_meja;
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

CREATE INDEX IF NOT EXISTS idx_data_pelanggan_kafe ON data_pelanggan(id_kafe);

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

CREATE INDEX IF NOT EXISTS idx_data_aturan_waktu_kafe ON data_aturan_waktu(id_kafe);

-- ====================================================================
-- TABEL: data_sesi_meja
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

CREATE INDEX IF NOT EXISTS idx_data_sesi_meja_kafe ON data_sesi_meja(id_kafe);
CREATE INDEX IF NOT EXISTS idx_data_sesi_meja_meja ON data_sesi_meja(id_meja);
CREATE INDEX IF NOT EXISTS idx_data_sesi_meja_status ON data_sesi_meja(status_sesi);
DROP TRIGGER IF EXISTS trg_data_sesi_meja_diubah_pada ON data_sesi_meja;
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

CREATE INDEX IF NOT EXISTS idx_data_produk_kafe ON data_produk(id_kafe);
DROP TRIGGER IF EXISTS trg_data_produk_diubah_pada ON data_produk;
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

CREATE INDEX IF NOT EXISTS idx_data_pesanan_kafe ON data_pesanan(id_kafe);
CREATE INDEX IF NOT EXISTS idx_data_pesanan_sesi ON data_pesanan(id_sesi_meja);
DROP TRIGGER IF EXISTS trg_data_pesanan_diubah_pada ON data_pesanan;
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

CREATE INDEX IF NOT EXISTS idx_detail_pesanan_pesanan ON data_detail_pesanan(id_pesanan);

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

CREATE INDEX IF NOT EXISTS idx_data_notifikasi_kafe ON data_notifikasi(id_kafe);

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

CREATE INDEX IF NOT EXISTS idx_data_log_kafe ON data_log_aktivitas(id_kafe);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================
ALTER TABLE data_kafe ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_pengguna ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_pegawai_kafe ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_meja ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_pelanggan ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_aturan_waktu ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_sesi_meja ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_produk ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_pesanan ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_detail_pesanan ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_notifikasi ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_log_aktivitas ENABLE ROW LEVEL SECURITY;

-- Reset policies untuk menghindari duplikasi
DROP POLICY IF EXISTS "Pengguna terautentikasi dapat membaca data kafe mereka" ON data_kafe;
DROP POLICY IF EXISTS "Pengguna terautentikasi dapat membaca data pengguna satu kafe" ON data_pengguna;
DROP POLICY IF EXISTS "Pengguna terautentikasi dapat membaca relasi pegawai kafe mereka" ON data_pegawai_kafe;
DROP POLICY IF EXISTS "Pengguna terautentikasi dapat mengelola data meja kafe mereka" ON data_meja;
DROP POLICY IF EXISTS "Pengguna terautentikasi dapat mengelola data sesi meja kafe mereka" ON data_sesi_meja;
DROP POLICY IF EXISTS "Pengguna terautentikasi dapat mengelola data produk kafe mereka" ON data_produk;
DROP POLICY IF EXISTS "Pengguna terautentikasi dapat mengelola data pesanan kafe mereka" ON data_pesanan;
DROP POLICY IF EXISTS "Pengguna terautentikasi dapat mengelola detail pesanan kafe mereka" ON data_detail_pesanan;

CREATE POLICY "Pengguna terautentikasi dapat membaca data kafe mereka" ON data_kafe
    FOR SELECT TO authenticated
    USING (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
        UNION
        SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()
    ));

CREATE POLICY "Pengguna terautentikasi dapat membaca data pengguna satu kafe" ON data_pengguna
    FOR SELECT TO authenticated
    USING (id_pengguna = auth.uid() OR id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
    ));

CREATE POLICY "Pengguna terautentikasi dapat membaca relasi pegawai kafe mereka" ON data_pegawai_kafe
    FOR SELECT TO authenticated
    USING (id_pengguna = auth.uid());

CREATE POLICY "Pengguna terautentikasi dapat mengelola data meja kafe mereka" ON data_meja
    FOR ALL TO authenticated
    USING (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
    ));

CREATE POLICY "Pengguna terautentikasi dapat mengelola data sesi meja kafe mereka" ON data_sesi_meja
    FOR ALL TO authenticated
    USING (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
    ));

CREATE POLICY "Pengguna terautentikasi dapat mengelola data produk kafe mereka" ON data_produk
    FOR ALL TO authenticated
    USING (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
    ));

CREATE POLICY "Pengguna terautentikasi dapat mengelola data pesanan kafe mereka" ON data_pesanan
    FOR ALL TO authenticated
    USING (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
    ));

CREATE POLICY "Pengguna terautentikasi dapat mengelola detail pesanan kafe mereka" ON data_detail_pesanan
    FOR ALL TO authenticated
    USING (id_pesanan IN (
        SELECT id_pesanan FROM data_pesanan 
        WHERE id_kafe IN (
            SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
        )
    ));

-- ====================================================================
-- FUNGSI & TRIGGER OTOMATIS SAAT USER DIBUAT DI SUPABASE AUTH UI/API
-- ====================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_kafe_id UUID;
BEGIN
    -- Ambil kafe pertama jika ada
    SELECT id_kafe INTO v_kafe_id FROM public.data_kafe LIMIT 1;
    
    -- Insert otomatis ke data_pengguna
    INSERT INTO public.data_pengguna (id_pengguna, id_kafe, nama_lengkap, email, peran)
    VALUES (
        NEW.id,
        v_kafe_id,
        COALESCE(NEW.raw_user_meta_data->>'nama_lengkap', SPLIT_PART(NEW.email, '@', 1)),
        NEW.email,
        'pemilik'
    ) ON CONFLICT (id_pengguna) DO UPDATE SET
        id_kafe = EXCLUDED.id_kafe;

    -- Insert otomatis ke data_pegawai_kafe
    IF v_kafe_id IS NOT NULL THEN
        INSERT INTO public.data_pegawai_kafe (id_pengguna, id_kafe, peran)
        VALUES (NEW.id, v_kafe_id, 'pemilik')
        ON CONFLICT (id_pengguna, id_kafe) DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
