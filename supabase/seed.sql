-- ====================================================================
-- SEED DATA AWAL CAFEFLOW
-- Gunakan script ini di SQL Editor Supabase setelah menjalankan schema.sql
-- Kredensial Login:
-- Email    : admin@gmail.com
-- Password : admin123
-- ====================================================================

-- 1. Buat Extension pgcrypto jika belum ada
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
    v_user_id UUID := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::UUID;
    v_kafe_id UUID := 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'::UUID;
    v_encrypted_pw TEXT;
BEGIN
    -- Hitung hash password 'admin123'
    v_encrypted_pw := crypt('admin123', gen_salt('bf'));

    -- 2. Insert User ke auth.users Supabase (jika belum ada)
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@gmail.com') THEN
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            aud,
            role,
            created_at,
            updated_at
        ) VALUES (
            v_user_id,
            '00000000-0000-0000-0000-000000000000',
            'admin@gmail.com',
            v_encrypted_pw,
            NOW(),
            '{"provider":"email","providers":["email"]}',
            '{"nama_lengkap":"Admin Utama"}',
            'authenticated',
            'authenticated',
            NOW(),
            NOW()
        );
    ELSE
        SELECT id INTO v_user_id FROM auth.users WHERE email = 'admin@gmail.com';
    END IF;

    -- 3. Insert Kafe ke data_kafe
    INSERT INTO data_kafe (
        id_kafe,
        nama_kafe,
        alamat,
        nomor_telepon,
        email_kafe,
        zona_waktu
    ) VALUES (
        v_kafe_id,
        'CafeFlow Central',
        'Jl. Sudirman No. 1, Jakarta Pusat',
        '081234567890',
        'central@cafeflow.com',
        'Asia/Jakarta'
    ) ON CONFLICT (id_kafe) DO NOTHING;

    -- 4. Insert Profil Pengguna ke data_pengguna
    INSERT INTO data_pengguna (
        id_pengguna,
        id_kafe,
        nama_lengkap,
        email,
        peran,
        status_aktif
    ) VALUES (
        v_user_id,
        v_kafe_id,
        'Admin Utama',
        'admin@gmail.com',
        'pemilik',
        TRUE
    ) ON CONFLICT (id_pengguna) DO UPDATE SET
        id_kafe = EXCLUDED.id_kafe,
        peran = EXCLUDED.peran;

    -- 5. Insert Relasi Pegawai Kafe ke data_pegawai_kafe
    INSERT INTO data_pegawai_kafe (
        id_pengguna,
        id_kafe,
        peran,
        status_aktif
    ) VALUES (
        v_user_id,
        v_kafe_id,
        'pemilik',
        TRUE
    ) ON CONFLICT (id_pengguna, id_kafe) DO NOTHING;

END $$;
