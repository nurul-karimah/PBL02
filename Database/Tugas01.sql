-- 1. Buat Database
DROP DATABASE IF EXISTS warung;
CREATE DATABASE warung;
USE warung;

/*-----------------------------------------------------*/
-- Buat tabel referensi terlebih dahulu
-- Jenis Kelamin
CREATE TABLE jenis_kelamin (
    kode_kelamin CHAR(1) PRIMARY KEY,
    nama_kelamin VARCHAR(20) NOT NULL
);
INSERT INTO jenis_kelamin VALUES
('1', 'Pria'),
('2', 'Wanita');

-- Kota
CREATE TABLE kota (
    kode_kota VARCHAR(10) PRIMARY KEY,
    nama_kota VARCHAR(50) NOT NULL
);
INSERT INTO kota VALUES
('BDG', 'Bandung'),
('JKT', 'Jakarta'),
('SBY', 'Surabaya'),
('DIY', 'Yogyakarta'),
('SMG', 'Semarang'),
('MDN', 'Medan');

-- Satuan
CREATE TABLE satuan (
    kode_satuan VARCHAR(10) PRIMARY KEY,
    nama_satuan VARCHAR(20) NOT NULL
);
INSERT INTO satuan VALUES
('BKS', 'Bungkus'),
('PAK', 'Pak'),
('BTL', 'Botol'),
('PCS', 'Pieces'),
('KG', 'Kilogram');

-- 2. Buat Tabel dengan normalisasi yang benar
CREATE TABLE pelanggan (
    kode_pelanggan VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(50),
    kode_kelamin CHAR(1),
    alamat VARCHAR(100),
    kode_kota VARCHAR(10),
    FOREIGN KEY (kode_kelamin) REFERENCES jenis_kelamin(kode_kelamin),
    FOREIGN KEY (kode_kota) REFERENCES kota(kode_kota)
);

CREATE TABLE produk (
    kode_produk VARCHAR(10) PRIMARY KEY,
    nama_produk VARCHAR(50),
    kode_satuan VARCHAR(10),
    stok INT,
    harga INT,
    FOREIGN KEY (kode_satuan) REFERENCES satuan(kode_satuan)
);

-- Tabel Penjualan (header)
CREATE TABLE penjualan (
    no_jual VARCHAR(10) PRIMARY KEY,
    tgl_jual DATE,
    kode_pelanggan VARCHAR(10),
    FOREIGN KEY (kode_pelanggan) REFERENCES pelanggan(kode_pelanggan)
);

-- Tabel Detail Penjualan (child)
CREATE TABLE detail_penjualan (
    no_jual VARCHAR(10),
    kode_produk VARCHAR(10),
    jumlah INT,
    harga INT,
    PRIMARY KEY (no_jual, kode_produk),
    FOREIGN KEY (no_jual) REFERENCES penjualan(no_jual),
    FOREIGN KEY (kode_produk) REFERENCES produk(kode_produk)
);

-- 3. Insert Data Pelanggan (disesuaikan dengan struktur baru)
INSERT INTO pelanggan VALUES
('PLG01','Mohamad','1','Priok','JKT'),
('PLG02','Naufal','1','Cilincing','JKT'),
('PLG03','Atila','1','Bojongsoang','BDG'),
('PLG04','Tsalsa','2','Buah Batu','BDG'),
('PLG05','Damay','2','Gubeng','SBY'),
('PLG06','Tsany','1','Darmo','SBY'),
('PLG07','Nabila','2','Lebak Bulus','JKT');

-- 4. Insert Data Produk (disesuaikan dengan struktur baru)
INSERT INTO produk VALUES
('P001','Indomie','BKS',10,3000),
('P002','Roti','PAK',6,7000),
('P003','Kecap','BTL',2,18000),
('P004','Saos Tomat','BTL',8,5800),
('P005','Bihun','BKS',8,3500),
('P006','Sikat Gigi','PAK',3,7000),
('P007','Pasta Gigi','PAK',6,9500),
('P008','Saos Sambal','BTL',5,7300);

-- 5. Insert Data Penjualan (header)
INSERT INTO penjualan VALUES
('J001','2025-09-08','PLG03'),
('J002','2025-09-08','PLG07'),
('J003','2025-09-09','PLG02'),
('J004','2025-09-10','PLG05');

-- Insert Data Detail Penjualan
INSERT INTO detail_penjualan VALUES
('J001','P001',2,3000),
('J001','P003',1,18000),
('J001','P004',1,5800),

('J002','P006',1,7000),
('J002','P007',1,9500),

('J003','P001',5,3000),
('J003','P004',2,5800),
('J003','P008',2,7300),
('J003','P003',1,18000),

('J004','P002',3,7000),
('J004','P004',2,5800),
('J004','P008',2,7300),
('J004','P006',2,7000),
('J004','P007',1,9500);

-- ============================================================
-- Procedure CRUD Pelanggan (diperbarui)
DROP PROCEDURE IF EXISTS tambah_pelanggan;
DROP PROCEDURE IF EXISTS ubah_pelanggan;
DROP PROCEDURE IF EXISTS hapus_pelanggan;

DELIMITER //

CREATE PROCEDURE tambah_pelanggan(
    IN p_kode VARCHAR(10), IN p_nama VARCHAR(50),
    IN p_kelamin CHAR(1), IN p_alamat VARCHAR(100), IN p_kode_kota VARCHAR(10)
)
BEGIN
    INSERT INTO pelanggan VALUES (p_kode, p_nama, p_kelamin, p_alamat, p_kode_kota);
END //

CREATE PROCEDURE ubah_pelanggan(
    IN p_kode VARCHAR(10), IN p_nama VARCHAR(50)
)
BEGIN
    UPDATE pelanggan SET nama = p_nama WHERE kode_pelanggan = p_kode;
END //

CREATE PROCEDURE hapus_pelanggan(
    IN p_kode VARCHAR(10)
)
BEGIN
    DELETE FROM pelanggan WHERE kode_pelanggan = p_kode;
END //

DELIMITER ;

-- ============================================================
-- PROCEDURE cari penjualan per pelanggan (detail + total) - DIPERBARUI
DROP PROCEDURE IF EXISTS cari_penjualan_by_pelanggan;

DELIMITER //
CREATE PROCEDURE cari_penjualan_by_pelanggan(
    IN kode_input VARCHAR(10)
)
BEGIN
    -- Detail transaksi
    SELECT 
        p.no_jual AS transaksi,
        p.tgl_jual,
        pr.nama_produk,
        d.jumlah,
        (d.jumlah * d.harga) AS total_harga
    FROM penjualan p
    JOIN detail_penjualan d ON p.no_jual = d.no_jual
    JOIN produk pr ON d.kode_produk = pr.kode_produk
    WHERE p.kode_pelanggan = kode_input

    UNION ALL
    
    -- Total agregasi
    SELECT 
        'TOTAL' AS transaksi,
        NULL,
        NULL,
        SUM(d.jumlah),
        SUM(d.jumlah * d.harga)
    FROM penjualan p
    JOIN detail_penjualan d ON p.no_jual = d.no_jual
    WHERE p.kode_pelanggan = kode_input;
END //
DELIMITER ;

-- ============================================================
-- VIEW untuk melihat penjualan lengkap
CREATE OR REPLACE VIEW vw_penjualan_lengkap AS
SELECT 
    p.no_jual,
    p.tgl_jual,
    pl.kode_pelanggan,
    pl.nama AS nama_pelanggan,
    jk.nama_kelamin,
    k.nama_kota,
    d.kode_produk,
    pr.nama_produk,
    s.nama_satuan,
    d.jumlah,
    d.harga,
    (d.jumlah * d.harga) AS total
FROM penjualan p
JOIN pelanggan pl ON p.kode_pelanggan = pl.kode_pelanggan
JOIN jenis_kelamin jk ON pl.kode_kelamin = jk.kode_kelamin
JOIN kota k ON pl.kode_kota = k.kode_kota
JOIN detail_penjualan d ON p.no_jual = d.no_jual
JOIN produk pr ON d.kode_produk = pr.kode_produk
JOIN satuan s ON pr.kode_satuan = s.kode_satuan
ORDER BY p.no_jual, d.kode_produk;

-- ============================================================
-- FUNCTION untuk menghitung total penjualan
DROP FUNCTION IF EXISTS total_penjualan;

DELIMITER //
CREATE FUNCTION total_penjualan(no_jual_param VARCHAR(10)) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT SUM(jumlah * harga) INTO total
    FROM detail_penjualan
    WHERE no_jual = no_jual_param;
    RETURN total;
END //
DELIMITER ;

-- ============================================================*/
-- TEST QUERY
SHOW TABLES;
SELECT * FROM satuan;
SELECT * FROM kota;
SELECT * FROM jenis_kelamin;
SELECT * FROM penjualan;
SELECT * FROM pelanggan;
SELECT * FROM produk;
SELECT * FROM detail_penjualan;
SELECT * FROM vw_penjualan_lengkap WHERE kode_pelanggan = 'PLG03';
SELECT total_penjualan('J001');
CALL cari_penjualan_by_pelanggan('PLG03');