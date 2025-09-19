DROP DATABASE IF EXISTS pbl2;
CREATE DATABASE pbl2;
USE pbl2;

CREATE TABLE siswa (
    nis VARCHAR(10),
    nama VARCHAR(50),
    alamat VARCHAR(100),
    kd_kota VARCHAR(1)
);

CREATE TABLE kota (
    kode VARCHAR(1) PRIMARY KEY,
    namakota VARCHAR(25)
);

INSERT INTO siswa VALUES
('1234567890', 'Septiawan', 'Ciganitri', NULL),
('1234567891', 'Irine', 'TKI', NULL),
('1234567892', 'Dzakiy', 'Gubeng', NULL),
('1234567893', 'Dzaka', 'Ciganitri', NULL),
('1234567894', 'Nabila', 'Ciganitri', NULL);

INSERT INTO kota VALUES
('1', 'Bandung'),
('2', 'Jakarta'),
('3', 'Surabaya');

UPDATE siswa SET kd_kota = '2' WHERE alamat = 'Gubeng';
UPDATE siswa SET kd_kota = '1' WHERE alamat = 'Ciganitri';
UPDATE siswa SET kd_kota = '3' WHERE alamat = 'TKI';

ALTER TABLE siswa ADD PRIMARY KEY(nis);

ALTER TABLE siswa
ADD FOREIGN KEY (kd_kota) REFERENCES kota(kode);

CREATE OR REPLACE VIEW vw_jmlsiswa_kota AS
SELECT kota.namakota, COUNT(siswa.nis) AS Jumlah_siswa
FROM siswa
JOIN kota ON siswa.kd_kota = kota.kode
GROUP BY kota.namakota;

DELIMITER //

CREATE PROCEDURE sp_jmlsiswa_by_kota (
    IN sp_nama VARCHAR(25)
)
BEGIN
    SELECT * FROM vw_jmlsiswa_kota
    WHERE namakota = sp_nama;
END//

DELIMITER ;

CALL sp_jmlsiswa_by_kota('Bandung');
CALL sp_jmlsiswa_by_kota('Surabaya');
CALL sp_jmlsiswa_by_kota('Jakarta');

INSERT siswa VALUES ('7890123456', 'Anto', 'Ancol', '3');
INSERT siswa VALUES ('8901234567', 'Nela', 'Lebak Bulus', '3');