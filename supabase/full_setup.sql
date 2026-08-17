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
    deskripsi TEXT,
    durasi_tambahan_menit INT NOT NULL DEFAULT 0 CHECK (durasi_tambahan_menit >= 0),
    status_tersedia BOOLEAN NOT NULL DEFAULT TRUE,
    status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Migrasi Kolom Tambahan data_produk
ALTER TABLE data_produk ADD COLUMN IF NOT EXISTS deskripsi TEXT;
ALTER TABLE data_produk ADD COLUMN IF NOT EXISTS status_tersedia BOOLEAN NOT NULL DEFAULT TRUE;

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
        UNION
        SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()
    ))
    WITH CHECK (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
        UNION
        SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()
    ));

CREATE POLICY "Pengguna terautentikasi dapat mengelola data sesi meja kafe mereka" ON data_sesi_meja
    FOR ALL TO authenticated
    USING (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
        UNION
        SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()
    ))
    WITH CHECK (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
        UNION
        SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()
    ));

CREATE POLICY "Pengguna terautentikasi dapat mengelola data produk kafe mereka" ON data_produk
    FOR ALL TO authenticated
    USING (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
        UNION
        SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()
    ))
    WITH CHECK (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
        UNION
        SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()
    ));

CREATE POLICY "Pengguna terautentikasi dapat mengelola data pesanan kafe mereka" ON data_pesanan
    FOR ALL TO authenticated
    USING (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
        UNION
        SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()
    ))
    WITH CHECK (id_kafe IN (
        SELECT id_kafe FROM data_pegawai_kafe WHERE id_pengguna = auth.uid() AND status_aktif = TRUE
        UNION
        SELECT id_kafe FROM data_pengguna WHERE id_pengguna = auth.uid()
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

-- ====================================================================
-- FUNGSI ATOMIK PL/PGSQL: buat_pesanan_awal_dan_mulai_sesi
-- Menghitung total belanja, me-reverifikasi harga produk dari DB,
-- menentukan menit Comfort Time, membuat data_sesi_meja, data_pesanan, 
-- data_detail_pesanan, serta memperbarui status_meja menjadi 'terisi' secara atomik.
-- ====================================================================
CREATE OR REPLACE FUNCTION public.buat_pesanan_awal_dan_mulai_sesi(
    p_id_kafe UUID,
    p_id_meja UUID,
    p_id_pelanggan UUID,
    p_items JSONB
)
RETURNS JSONB AS $$
DECLARE
    v_id_pesanan UUID := gen_random_uuid();
    v_id_sesi UUID := gen_random_uuid();
    v_nomor_pesanan VARCHAR(50);
    v_seq INT;
    v_item JSONB;
    v_id_produk UUID;
    v_jumlah INT;
    v_catatan TEXT;
    v_harga NUMERIC(12, 2);
    v_durasi_produk INT;
    v_subtotal NUMERIC(12, 2);
    v_total_belanja NUMERIC(12, 2) := 0.00;
    v_total_menit INT := 60; -- Default 60 menit jika tidak ada rule
    v_rule_menit INT;
    v_bonus_menit INT := 0;
    v_waktu_mulai TIMESTAMPTZ := NOW();
    v_waktu_berakhir TIMESTAMPTZ;
BEGIN
    -- 1. Generate Nomor Pesanan mudah dibaca manusia (Contoh: CF-20260817-0001)
    SELECT COALESCE(COUNT(*), 0) + 1 INTO v_seq 
    FROM data_pesanan 
    WHERE id_kafe = p_id_kafe AND DATE(waktu_pesanan) = CURRENT_DATE;
    
    v_nomor_pesanan := 'CF-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(v_seq::TEXT, 4, '0');

    -- 2. Validasi & Kalkulasi Ulang Harga Produk langsung dari database
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_id_produk := (v_item->>'id_produk')::UUID;
        v_jumlah := (v_item->>'jumlah')::INT;
        
        SELECT harga, durasi_tambahan_menit INTO v_harga, v_durasi_produk 
        FROM data_produk 
        WHERE id_produk = v_id_produk AND id_kafe = p_id_kafe AND status_aktif = TRUE;

        IF v_harga IS NULL THEN
            RAISE EXCEPTION 'Produk % tidak ditemukan atau nonaktif pada kafe ini.', v_id_produk;
        END IF;

        v_subtotal := v_harga * v_jumlah;
        v_total_belanja := v_total_belanja + v_subtotal;
        v_bonus_menit := v_bonus_menit + (v_durasi_produk * v_jumlah);
    END LOOP;

    -- 3. Cari aturan waktu Comfort Time di data_aturan_waktu berdasarkan min_belanja
    SELECT durasi_menit INTO v_rule_menit 
    FROM data_aturan_waktu 
    WHERE id_kafe = p_id_kafe AND status_aktif = TRUE AND min_belanja <= v_total_belanja 
    ORDER BY min_belanja DESC LIMIT 1;

    IF v_rule_menit IS NOT NULL THEN
        v_total_menit := v_rule_menit + v_bonus_menit;
    ELSE
        v_total_menit := v_total_menit + v_bonus_menit;
    END IF;

    v_waktu_berakhir := v_waktu_mulai + (v_total_menit || ' minutes')::INTERVAL;

    -- 4. Buat data_sesi_meja
    INSERT INTO data_sesi_meja (
        id_sesi_meja, id_kafe, id_meja, id_pelanggan,
        waktu_mulai, waktu_berakhir, durasi_awal_menit, total_durasi_menit, total_belanja, status_sesi
    ) VALUES (
        v_id_sesi, p_id_kafe, p_id_meja, p_id_pelanggan,
        v_waktu_mulai, v_waktu_berakhir, v_total_menit, v_total_menit, v_total_belanja, 'aktif'
    );

    -- 5. Buat data_pesanan
    INSERT INTO data_pesanan (
        id_pesanan, id_kafe, id_meja, id_sesi_meja, nomor_pesanan,
        total_belanja, status_pesanan, waktu_pesanan
    ) VALUES (
        v_id_pesanan, p_id_kafe, p_id_meja, v_id_sesi, v_nomor_pesanan,
        v_total_belanja, 'selesai', v_waktu_mulai
    );

    -- 6. Buat detail pesanan di data_detail_pesanan
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_id_produk := (v_item->>'id_produk')::UUID;
        v_jumlah := (v_item->>'jumlah')::INT;
        v_catatan := v_item->>'catatan';

        SELECT harga INTO v_harga FROM data_produk WHERE id_produk = v_id_produk;
        v_subtotal := v_harga * v_jumlah;

        INSERT INTO data_detail_pesanan (
            id_pesanan, id_produk, jumlah, harga_satuan, subtotal, catatan
        ) VALUES (
            v_id_pesanan, v_id_produk, v_jumlah, v_harga, v_subtotal, v_catatan
        );
    END LOOP;

    -- 7. Ubah status meja menjadi 'terisi'
    UPDATE data_meja SET status_meja = 'terisi' WHERE id_meja = p_id_meja AND id_kafe = p_id_kafe;

    -- Return JSON metadata hasil pembuatan pesanan atomik
    RETURN jsonb_build_object(
        'id_pesanan', v_id_pesanan,
        'nomor_pesanan', v_nomor_pesanan,
        'id_sesi_meja', v_id_sesi,
        'total_belanja', v_total_belanja,
        'durasi_menit', v_total_menit,
        'waktu_berakhir', v_waktu_berakhir,
        'is_perpanjangan', FALSE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Migrasi Kolom total_belanja pada data_sesi_meja
ALTER TABLE data_sesi_meja ADD COLUMN IF NOT EXISTS total_belanja NUMERIC(12, 2) NOT NULL DEFAULT 0.00;

-- ====================================================================
-- FUNGSI ATOMIK PL/PGSQL: tambah_pesanan_dan_perpanjang_sesi
-- Memproses order tambahan untuk meja terisi & sesi aktif,
-- menghitung tambahan waktu berdasarkan data_aturan_waktu dinamis,
-- dan meng-update total_belanja, total_durasi_menit, waktu_berakhir secara atomik.
-- ====================================================================
CREATE OR REPLACE FUNCTION public.tambah_pesanan_dan_perpanjang_sesi(
    p_id_kafe UUID,
    p_id_meja UUID,
    p_id_sesi_meja UUID,
    p_items JSONB
)
RETURNS JSONB AS $$
DECLARE
    v_id_pesanan UUID := gen_random_uuid();
    v_nomor_pesanan VARCHAR(50);
    v_seq INT;
    v_item JSONB;
    v_id_produk UUID;
    v_jumlah INT;
    v_catatan TEXT;
    v_harga NUMERIC(12, 2);
    v_durasi_produk INT;
    v_subtotal NUMERIC(12, 2);
    v_total_belanja_tambahan NUMERIC(12, 2) := 0.00;
    v_tambahan_menit INT := 0;
    v_rule_menit INT;
    v_bonus_menit INT := 0;
    v_sesi RECORD;
    v_waktu_berakhir_lama TIMESTAMPTZ;
    v_waktu_berakhir_baru TIMESTAMPTZ;
    v_now TIMESTAMPTZ := NOW();
BEGIN
    -- 1. Ambil data sesi meja aktif
    SELECT * INTO v_sesi FROM data_sesi_meja 
    WHERE id_sesi_meja = p_id_sesi_meja AND id_kafe = p_id_kafe
    FOR UPDATE;

    IF v_sesi.id_sesi_meja IS NULL THEN
        RAISE EXCEPTION 'Sesi meja % tidak ditemukan pada kafe ini.', p_id_sesi_meja;
    END IF;

    -- 2. Generate Nomor Pesanan mudah dibaca manusia (Contoh: CF-20260817-0002)
    SELECT COALESCE(COUNT(*), 0) + 1 INTO v_seq 
    FROM data_pesanan 
    WHERE id_kafe = p_id_kafe AND DATE(waktu_pesanan) = CURRENT_DATE;
    
    v_nomor_pesanan := 'CF-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(v_seq::TEXT, 4, '0');

    -- 3. Validasi & Kalkulasi Ulang Harga Produk langsung dari DB
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_id_produk := (v_item->>'id_produk')::UUID;
        v_jumlah := (v_item->>'jumlah')::INT;
        
        SELECT harga, durasi_tambahan_menit INTO v_harga, v_durasi_produk 
        FROM data_produk 
        WHERE id_produk = v_id_produk AND id_kafe = p_id_kafe AND status_aktif = TRUE;

        IF v_harga IS NULL THEN
            RAISE EXCEPTION 'Produk % tidak ditemukan atau nonaktif pada kafe ini.', v_id_produk;
        END IF;

        v_subtotal := v_harga * v_jumlah;
        v_total_belanja_tambahan := v_total_belanja_tambahan + v_subtotal;
        v_bonus_menit := v_bonus_menit + (v_durasi_produk * v_jumlah);
    END LOOP;

    -- 4. Cari aturan waktu Comfort Time berdasarkan total belanja pesanan tambahan ini
    SELECT durasi_menit INTO v_rule_menit 
    FROM data_aturan_waktu 
    WHERE id_kafe = p_id_kafe AND status_aktif = TRUE AND min_belanja <= v_total_belanja_tambahan 
    ORDER BY min_belanja DESC LIMIT 1;

    IF v_rule_menit IS NOT NULL THEN
        v_tambahan_menit := v_rule_menit + v_bonus_menit;
    ELSE
        v_tambahan_menit := v_bonus_menit;
    END IF;

    -- 5. Hitung perpanjangan waktu_berakhir
    v_waktu_berakhir_lama := v_sesi.waktu_berakhir;

    IF v_waktu_berakhir_lama > v_now THEN
        -- Kasus A: Jika waktu_berakhir masih di masa depan -> Tambahkan dari waktu_berakhir_lama
        v_waktu_berakhir_baru := v_waktu_berakhir_lama + (v_tambahan_menit || ' minutes')::INTERVAL;
    ELSE
        -- Kasus B: Jika sudah melewati waktu (masa tenggang) -> Tambahkan dari NOW() agar waktu terpakai saat tenggang tidak memotong waktu perpanjangan baru
        v_waktu_berakhir_baru := v_now + (v_tambahan_menit || ' minutes')::INTERVAL;
    END IF;

    -- 6. Buat data_pesanan tambahan terhubung ke sesi yang sama
    INSERT INTO data_pesanan (
        id_pesanan, id_kafe, id_meja, id_sesi_meja, nomor_pesanan,
        total_belanja, status_pesanan, waktu_pesanan
    ) VALUES (
        v_id_pesanan, p_id_kafe, p_id_meja, p_id_sesi_meja, v_nomor_pesanan,
        v_total_belanja_tambahan, 'selesai', v_now
    );

    -- 7. Buat detail pesanan di data_detail_pesanan
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_id_produk := (v_item->>'id_produk')::UUID;
        v_jumlah := (v_item->>'jumlah')::INT;
        v_catatan := v_item->>'catatan';

        SELECT harga INTO v_harga FROM data_produk WHERE id_produk = v_id_produk;
        v_subtotal := v_harga * v_jumlah;

        INSERT INTO data_detail_pesanan (
            id_pesanan, id_produk, jumlah, harga_satuan, subtotal, catatan
        ) VALUES (
            v_id_pesanan, v_id_produk, v_jumlah, v_harga, v_subtotal, v_catatan
        );
    END LOOP;

    -- 8. Perbarui data_sesi_meja secara atomik
    UPDATE data_sesi_meja SET
        total_belanja = COALESCE(total_belanja, 0.00) + v_total_belanja_tambahan,
        total_durasi_menit = total_durasi_menit + v_tambahan_menit,
        waktu_berakhir = v_waktu_berakhir_baru,
        status_sesi = 'aktif',
        diubah_pada = v_now
    WHERE id_sesi_meja = p_id_sesi_meja AND id_kafe = p_id_kafe;

    -- Return Metadata JSON Hasil Transaksi Atomik
    RETURN jsonb_build_object(
        'id_pesanan', v_id_pesanan,
        'nomor_pesanan', v_nomor_pesanan,
        'id_sesi_meja', p_id_sesi_meja,
        'total_belanja', v_total_belanja_tambahan,
        'total_belanja_sesi', COALESCE(v_sesi.total_belanja, 0.00) + v_total_belanja_tambahan,
        'durasi_menit', v_tambahan_menit,
        'total_durasi_menit', v_sesi.total_durasi_menit + v_tambahan_menit,
        'waktu_berakhir_lama', v_waktu_berakhir_lama,
        'waktu_berakhir', v_waktu_berakhir_baru,
        'is_perpanjangan', TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ====================================================================
-- FUNGSI AMAN PUBLIK: get_public_meja_status
-- Mengakses data status meja & sesi aktif secara aman tanpa login
-- HANYA mengembalikan data publik aman tanpa mengekspos data internal/pegawai/transaksi
-- ====================================================================
CREATE OR REPLACE FUNCTION public.get_public_meja_status(p_kode_qr TEXT)
RETURNS JSONB AS $$
DECLARE
    v_meja RECORD;
    v_kafe RECORD;
    v_sesi RECORD;
    v_total_meja INT := 0;
    v_meja_terisi INT := 0;
    v_rasio_okupansi NUMERIC := 0;
    v_tingkat_keramaian TEXT := 'normal';
    v_sisa_menit INT := 0;
    v_pesan_customer TEXT := NULL;
    v_now TIMESTAMPTZ := NOW();
BEGIN
    -- 1. Cari meja berdasarkan kode_qr
    SELECT id_meja, id_kafe, nomor_meja, nama_meja, status_meja, status_aktif
    INTO v_meja
    FROM data_meja
    WHERE kode_qr = p_kode_qr AND status_aktif = TRUE;

    IF v_meja.id_meja IS NULL THEN
        RETURN jsonb_build_object(
            'valid', FALSE,
            'pesan', 'QR Code meja tidak valid atau meja telah dinonaktifkan.'
        );
    END IF;

    -- 2. Ambil data kafe publik
    SELECT nama_kafe INTO v_kafe FROM data_kafe WHERE id_kafe = v_meja.id_kafe;

    -- 3. Hitung tingkat keramaian kafe dari rasio okupansi meja aktif
    SELECT COUNT(*) INTO v_total_meja FROM data_meja WHERE id_kafe = v_meja.id_kafe AND status_aktif = TRUE;
    SELECT COUNT(*) INTO v_meja_terisi FROM data_meja WHERE id_kafe = v_meja.id_kafe AND status_aktif = TRUE AND status_meja = 'terisi';

    IF v_total_meja > 0 THEN
        v_rasio_okupansi := (v_meja_terisi::NUMERIC / v_total_meja::NUMERIC) * 100;
    END IF;

    IF v_rasio_okupansi >= 75 THEN
        v_tingkat_keramaian := 'ramai';
    ELSIF v_rasio_okupansi >= 40 THEN
        v_tingkat_keramaian := 'normal';
    ELSE
        v_tingkat_keramaian := 'sepi';
    END IF;

    -- 4. Cari sesi aktif untuk meja ini
    SELECT id_sesi_meja, waktu_mulai, waktu_berakhir, total_belanja, status_sesi
    INTO v_sesi
    FROM data_sesi_meja
    WHERE id_meja = v_meja.id_meja AND status_sesi = 'aktif'
    ORDER BY dibuat_pada DESC
    LIMIT 1;

    -- 5. Jika ada sesi aktif, hitung sisa menit & pesan reminder ramah
    IF v_sesi.id_sesi_meja IS NOT NULL THEN
        v_sisa_menit := EXTRACT(EPOCH FROM (v_sesi.waktu_berakhir - v_now)) / 60;

        IF v_sisa_menit <= 15 AND v_tingkat_keramaian IN ('ramai', 'normal') THEN
            v_pesan_customer := 'Cafe sedang cukup ramai. Tambahkan pesanan jika ingin menikmati waktu lebih lama.';
        END IF;

        RETURN jsonb_build_object(
            'valid', TRUE,
            'nama_kafe', v_kafe.nama_kafe,
            'nomor_meja', v_meja.nomor_meja,
            'nama_meja', v_meja.nama_meja,
            'status_meja', v_meja.status_meja,
            'ada_sesi_aktif', TRUE,
            'waktu_mulai', v_sesi.waktu_mulai,
            'waktu_berakhir', v_sesi.waktu_berakhir,
            'total_belanja', COALESCE(v_sesi.total_belanja, 0.00),
            'tingkat_keramaian', v_tingkat_keramaian,
            'pesan_customer', v_pesan_customer
        );
    ELSE
        RETURN jsonb_build_object(
            'valid', TRUE,
            'nama_kafe', v_kafe.nama_kafe,
            'nomor_meja', v_meja.nomor_meja,
            'nama_meja', v_meja.nama_meja,
            'status_meja', v_meja.status_meja,
            'ada_sesi_aktif', FALSE,
            'waktu_mulai', NULL,
            'waktu_berakhir', NULL,
            'total_belanja', 0.00,
            'tingkat_keramaian', v_tingkat_keramaian,
            'pesan_customer', 'Meja ini belum memiliki sesi aktif.'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Berikan izin EXECUTE ke role publik anon dan authenticated
GRANT EXECUTE ON FUNCTION public.get_public_meja_status(TEXT) TO anon, authenticated;

-- ====================================================================
-- EKSIBIT SUPABASE REALTIME (PUBLICATION)
-- Mengaktifkan pengiriman data otomatis via WebSocket tanpa polling
-- ====================================================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE data_meja, data_sesi_meja, data_pesanan;
    END IF;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;



