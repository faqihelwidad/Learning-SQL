-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022





SELECT * 
FROM world_layoffs.layoffs;


-- Hal pertama yang ingin kita lakukan adalah membuat tabel pementasan. Ini adalah tabel yang akan kita gunakan untuk bekerja dan membersihkan data. 
-- Kita ingin sebuah tabel dengan data mentah untuk berjaga-jaga jika terjadi sesuatu

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;


-- Sekarang, ketika kita membersihkan data, kita biasanya mengikuti beberapa langkah
-- 1. memeriksa duplikasi dan menghapusnya
-- 2. menstandarkan data dan memperbaiki kesalahan
-- 3. Lihatlah nilai nol dan lihat apa yang terjadi
-- 4. menghapus kolom dan baris yang tidak diperlukan - beberapa cara

-- 1. Menghapus Duplikat

# Pertama, mari kita periksa duplikatnya

-- menampilkan semua data, Mengambil dan menampilkan semua data dari tabel layoffs_staging. Ini berguna untuk melihat data awal sebelum melakukan pembersihan.
SELECT *
FROM world_layoffs.layoffs_staging;

-- menambahkan nomor baris
-- Mengambil kolom company, industry, total_laid_off, dan date, serta menambahkan kolom row_num yang berisi nomor urut untuk setiap 
-- grup yang dihasilkan berdasarkan kombinasi company, industry, total_laid_off, dan date. Ini membantu dalam mengidentifikasi duplikat.
SELECT company, industry, total_laid_off, `date`,
    ROW_NUMBER() OVER (
        PARTITION BY company, industry, total_laid_off, `date`) AS row_num
FROM 
    world_layoffs.layoffs_staging;
    
    
-- mengedintifikasi duplikat
-- Mengambil semua data yang memiliki row_num lebih dari 1, yang menunjukkan bahwa ada duplikat berdasarkan kombinasi yang ditentukan. 
-- Ini membantu dalam mengidentifikasi entri yang perlu dihapus.
SELECT *
FROM (
    SELECT company, industry, total_laid_off, `date`,
        ROW_NUMBER() OVER (
            PARTITION BY company, industry, total_laid_off, `date`
            ) AS row_num
    FROM 
        world_layoffs.layoffs_staging
) duplicates
WHERE 
    row_num > 1;
 
 
-- mari kita lihat oda untuk mengonfirmasi
-- Memeriksa Data untuk Perusahaan Tertentu, Mengambil semua data untuk perusahaan bernama 'Oda' untuk memastikan bahwa entri tersebut sah dan tidak perlu dihapus.

SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda'
;

-- Sepertinya ini semua adalah entri yang sah dan tidak boleh dihapus. Kita harus benar-benar melihat setiap baris agar akurat



-- Mengidentifikasi Duplikat yang Lebih Spesifik
-- Mengidentifikasi duplikat dengan lebih spesifik berdasarkan lebih banyak kolom (termasuk location, percentage_laid_off, 
-- stage, country, dan funds_raised_millions). Ini memberikan gambaran yang lebih akurat tentang entri yang perlu dihapus.
-- Ini adalah duplikat nyata kita 

SELECT *
FROM (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
            ) AS row_num
    FROM 
        world_layoffs.layoffs_staging
) duplicates
WHERE 
    row_num > 1;

-- ini adalah yang ingin kita hapus di mana nomor barisnya > 1 atau 2 atau lebih besar pada dasarnya

-- Menghapus Duplikat Menggunakan CTE, Menggunakan Common Table Expression (CTE) untuk mengidentifikasi dan menghapus duplikat dari tabel layoffs_staging. 
-- Namun, sintaks ini tidak valid di MySQL karena MySQL tidak mendukung penghapusan langsung dari CTE.
-- sekarang Anda mungkin ingin menuliskannya seperti ini:

WITH DELETE_CTE AS 
(
    SELECT *
    FROM (
        SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
            ROW_NUMBER() OVER (
                PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
                ) AS row_num
        FROM 
            world_layoffs.layoffs_staging
    ) duplicates
    WHERE 
        row_num > 1
)
DELETE
FROM DELETE_CTE;

-- Menghapus Duplikat dengan Subquery, Maksud: Menggunakan CTE untuk mengidentifikasi duplikat dan kemudian menghapus entri dari tabel layoffs_staging berdasarkan hasil 
-- dari CTE. Namun, ini juga tidak valid di MySQL.

WITH DELETE_CTE AS (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
    FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
    FROM DELETE_CTE
) AND row_num > 1;

-- satu solusi, yang menurut saya adalah solusi yang bagus. Adalah dengan membuat kolom baru dan menambahkan nomor baris tersebut. Kemudian hapus di mana nomor baris 
-- lebih dari 2, lalu hapus kolom tersebut

-- jadi mari kita lakukan!!
-- Menambahkan Kolom untuk Nomor Baris, Menambahkan kolom baru bernama row_num ke tabel layoffs_staging untuk menyimpan nomor urut yang akan digunakan untuk 
-- mengidentifikasi duplikat.

ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;

-- Menampilkan Semua Data
-- Mengambil dan menampilkan semua data dari tabel layoffs_staging. Ini berguna untuk melihat data awal sebelum melakukan pembersihan dan untuk memastikan bahwa kolom 
-- row_num telah ditambahkan dengan benar.

SELECT *
FROM world_layoffs.layoffs_staging;

-- Membuat Tabel Baru layoffs_staging2
-- Membuat tabel baru bernama layoffs_staging2 dengan struktur yang sama dengan tabel layoffs_staging, ditambah kolom row_num. Tabel ini akan digunakan untuk menyimpan 
-- data yang telah diproses dan diidentifikasi duplikatnya.

CREATE TABLE `world_layoffs`.`layoffs_staging2` (
    `company` text,
    `location` text,
    `industry` text,
    `total_laid_off` INT,
    `percentage_laid_off` text,
    `date` text,
    `stage` text,
    `country` text,
    `funds_raised_millions` int,
    row_num INT
);

-- Memasukkan Data ke Tabel Baru
-- Memasukkan data dari tabel layoffs_staging ke dalam tabel layoffs_staging2. Selama proses ini, kolom row_num diisi dengan nomor urut yang dihasilkan oleh 
-- fungsi ROW_NUMBER(). Fungsi ini memberikan nomor urut untuk setiap grup yang dihasilkan berdasarkan kombinasi kolom yang ditentukan 
-- (yaitu company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, dan funds_raised_millions). Ini membantu dalam mengidentifikasi duplikat.

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
 `location`,
 `industry`,
 `total_laid_off`,
 `percentage_laid_off`,
 `date`,
 `stage`,
 `country`,
 `funds_raised_millions`,
 `row_num`)
SELECT `company`,
       `location`,
       `industry`,
       `total_laid_off`,
       `percentage_laid_off`,
       `date`,
       `stage`,
       `country`,
       `funds_raised_millions`,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM 
    world_layoffs.layoffs_staging;
    
-- sekarang setelah kita memiliki ini, kita dapat menghapus baris yang row_num-nya lebih besar dari 2
-- Menghapus Duplikat dari Tabel Baru
-- Menghapus semua baris dari tabel layoffs_staging2 di mana row_num lebih besar atau sama dengan 2. Ini berarti bahwa hanya satu entri untuk setiap 
-- kombinasi unik dari kolom yang ditentukan akan dipertahankan, sementara semua duplikat (yang memiliki row_num 2 atau lebih) akan dihapus.

DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;

-- Ringkasan
-- Secara keseluruhan, kode ini bertujuan untuk membersihkan data dari tabel layoffs_staging dengan cara:
-- 1. Menambahkan kolom untuk menyimpan nomor urut.
-- 2. Membuat tabel baru untuk menyimpan data yang telah diproses.
-- 3. Memasukkan data dari tabel lama ke tabel baru sambil menghitung nomor urut untuk mengidentifikasi duplikat.
-- 4. Menghapus entri duplikat dari tabel baru berdasarkan nomor urut yang dihasilkan.
-- Dengan langkah-langkah ini, Anda dapat memastikan bahwa tabel layoffs_staging2 hanya berisi entri unik, yang sangat penting untuk analisis data yang akurat.


-- 2. Standardize Data

-- Memeriksa Data Awal
-- Mengambil semua data dari tabel layoffs_staging2 untuk melihat isi tabel sebelum melakukan perubahan.

SELECT * 
FROM world_layoffs.layoffs_staging2;

-- jika kita melihat industri, sepertinya kita memiliki beberapa baris nol dan kosong, mari kita lihat ini
-- Memeriksa Nilai Unik di Kolom industry
-- Mengambil nilai unik dari kolom industry dan mengurutkannya. Ini membantu untuk mengidentifikasi nilai-nilai yang tidak konsisten atau kosong.

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

--  Memeriksa Baris dengan industry Null atau Kosong
-- Mengambil semua baris di mana kolom industry adalah NULL atau kosong. Ini membantu untuk melihat data yang perlu diperbaiki.

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- mari kita lihat ini
-- Memeriksa Data untuk Perusahaan Tertentu
-- Mengambil semua baris di mana nama perusahaan dimulai dengan "Bally". Ini untuk memeriksa apakah ada data yang relevan untuk perusahaan tersebut.
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';
-- Tidak ada yang salah di sini
-- Mengambil semua baris di mana nama perusahaan dimulai dengan "airbnb". Ini untuk memeriksa apakah ada data yang relevan untuk perusahaan tersebut.
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';


-- Sepertinya airbnb adalah sebuah perjalanan, tapi yang ini tidak berpenghuni.
-- Saya yakin itu sama untuk yang lain. Yang bisa kita lakukan adalah
-- menulis kueri yang jika ada baris lain dengan nama perusahaan yang sama, maka akan memperbaruinya dengan nilai industri yang bukan nol
-- membuatnya mudah sehingga jika ada ribuan kita tidak perlu memeriksa semuanya secara manual

-- kita harus mengatur bagian yang kosong menjadi null karena biasanya lebih mudah untuk dikerjakan
-- Memperbarui Nilai Kosong di Kolom industry Menjadi Null
-- Mengubah semua nilai kosong di kolom industry menjadi NULL. Ini membuat data lebih konsisten dan lebih mudah untuk diproses.

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- sekarang jika kita periksa, semuanya nol
-- Memeriksa Kembali Nilai Null di Kolom industry
-- Memeriksa kembali tabel untuk memastikan bahwa semua nilai kosong telah diubah menjadi NULL.

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;


-- sekarang kita perlu mengisi null tersebut jika memungkinkan
-- Memperbarui Nilai Null di Kolom industry Berdasarkan Perusahaan
-- Mengupdate kolom industry di tabel t1 (alias untuk layoffs_staging2) dengan nilai dari tabel t2 (alias untuk layoffs_staging2) jika perusahaan yang sama 
-- memiliki nilai industry yang tidak NULL. Ini membantu mengisi nilai industry yang hilang.

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Memeriksa Kembali Nilai Null di Kolom industry
-- Memeriksa kembali tabel untuk memastikan bahwa semua nilai NULL di kolom industry telah diisi.
-- dan jika kita periksa, sepertinya Bally adalah satu-satunya yang tidak memiliki baris yang terisi untuk mengisi nilai null ini

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- ---------------------------------------------------

-- Saya juga memperhatikan bahwa Crypto memiliki beberapa variasi yang berbeda. Kita perlu menstandarkannya - katakanlah semua ke Crypto
-- Menstandarisasi Nilai di Kolom `industry`
-- Mengambil nilai unik dari kolom industry untuk melihat variasi yang ada.

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

-- Mengupdate semua nilai di kolom industry yang merupakan variasi dari "Crypto" menjadi "Crypto". Ini membantu menstandarisasi data.

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Memeriksa Kembali Nilai Unik di Kolom industry
-- Memeriksa kembali nilai unik di kolom industry untuk memastikan bahwa semua variasi telah distandarisasi.
-- sekarang hal itu sudah teratasi:

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

-- --------------------------------------------------
-- kita juga perlu melihat 
-- Memeriksa Data di Tabel

SELECT *
FROM world_layoffs.layoffs_staging2;

-- semuanya terlihat bagus kecuali tampaknya kita memiliki beberapa “United States” dan beberapa “United States.” dengan titik di bagian akhir. Mari kita standarisasi ini.
-- Mengambil Daftar Negara yang Unik
-- Mengambil semua nilai unik dari kolom country dalam tabel layoffs_staging2 dan mengurutkannya secara alfabetis. Ini berguna untuk melihat semua negara yang 
-- tercantum dalam data dan untuk memeriksa apakah ada masalah dengan format atau nilai yang tidak konsisten.

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;

-- Memperbaiki Nilai Negara
-- Memperbarui kolom country dengan menghapus titik (.) yang mungkin ada di akhir nama negara. Fungsi TRIM digunakan untuk menghapus karakter tertentu dari awal atau 
-- akhir string. Ini membantu dalam memastikan bahwa tidak ada karakter yang tidak diinginkan yang dapat menyebabkan masalah dalam analisis data.

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Memeriksa Perubahan pada Kolom Negara
-- Mengambil kembali daftar nilai unik dari kolom country setelah pembaruan untuk memastikan bahwa perubahan telah diterapkan dengan benar. 
-- Ini membantu memverifikasi bahwa semua titik di akhir nama negara telah dihapus.
-- Sekarang jika kita menjalankannya lagi, ini sudah diperbaiki

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;

-- Memeriksa Semua Data
-- Mengambil dan menampilkan semua data dari tabel layoffs_staging2. Ini berguna untuk melihat data secara keseluruhan sebelum melakukan perubahan lebih lanjut, 
-- khususnya pada kolom date.
-- Mari kita juga perbaiki kolom tanggal:

SELECT *
FROM world_layoffs.layoffs_staging2;


-- Memperbaiki Format Tanggal
-- Memperbarui kolom date dengan mengonversi string tanggal yang ada ke format tanggal yang dapat dikenali oleh MySQL. Fungsi STR_TO_DATE digunakan untuk mengubah 
-- string tanggal yang diformat sebagai 'bulan/hari/tahun' menjadi tipe data DATE. Ini penting untuk memastikan bahwa data tanggal dapat digunakan dalam perhitungan 
-- dan analisis yang tepat.
-- kita dapat menggunakan str to date untuk memperbarui bidang ini

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- Mengubah Tipe Data Kolom Tanggal
-- Mengubah tipe data kolom date di tabel layoffs_staging2 menjadi tipe data DATE. Ini memastikan bahwa kolom tersebut hanya menyimpan nilai tanggal dan tidak ada 
-- lagi string atau format lain yang tidak konsisten.
-- sekarang kita dapat mengonversi tipe data dengan benar

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Memeriksa Data Setelah Perubahan
-- Maksud: Mengambil dan menampilkan semua data dari tabel layoffs_staging2 setelah semua perubahan telah dilakukan. Ini berguna untuk memverifikasi bahwa 
-- semua pembaruan dan perubahan tipe data telah diterapkan dengan benar dan untuk memastikan bahwa data sekarang dalam format yang konsisten dan siap untuk 
-- analisis lebih lanjut.

SELECT *
FROM world_layoffs.layoffs_staging2;

-- Ringkasan
-- Secara keseluruhan, kode ini bertujuan untuk:
-- 1. Mengidentifikasi dan memperbaiki nilai yang tidak konsisten dalam kolom country.
-- 2. Memperbaiki format tanggal dalam kolom date agar sesuai dengan tipe data DATE di MySQL.
-- 3. Memastikan bahwa semua perubahan telah diterapkan dengan benar dengan memeriksa data setelah setiap langkah.
-- Langkah-langkah ini penting untuk memastikan bahwa data dalam tabel layoffs_staging2 bersih, konsisten, dan siap untuk analisis lebih lanjut.


-- 3. Lihatlah Nilai Nol

-- Nilai-nilai null pada total_laid_off, persentase_laid_off, dan dana_yang_digalang_jutaan semuanya terlihat normal. Saya rasa saya tidak ingin mengubahnya
-- Saya suka dengan nilai null karena memudahkan perhitungan selama fase EDA

-- jadi tidak ada yang ingin saya ubah dengan nilai nol




-- 4. Hapus kolom dan baris yang perlu kita hapus

-- Memilih Data dengan total_laid_off NULL
-- Kueri ini mengambil semua kolom dari tabel layoffs_staging2 di mana kolom total_laid_off memiliki nilai NULL. Ini digunakan untuk mengidentifikasi baris yang 
-- tidak memiliki informasi tentang jumlah karyawan yang dipecat. Baris-baris ini mungkin tidak berguna untuk analisis lebih lanjut.

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;


-- Memilih Data dengan total_laid_off dan percentage_laid_off NULL
-- Kueri ini lebih spesifik, mengambil semua kolom dari tabel di mana baik total_laid_off maupun percentage_laid_off adalah NULL. Ini membantu dalam menemukan
-- baris yang tidak memiliki informasi yang berguna sama sekali terkait pemecatan. Baris-baris ini dianggap tidak memiliki nilai tambah untuk analisis.

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Menghapus data yang tidak berguna yang tidak dapat kita gunakan
-- Menghapus Data yang Tidak Berguna
-- Kueri ini menghapus semua baris dari tabel layoffs_staging2 di mana kedua kolom total_laid_off dan percentage_laid_off adalah NULL. Ini adalah langkah pembersihan untuk 
-- menghilangkan data yang tidak dapat digunakan dalam analisis lebih lanjut. Baris-baris ini dianggap "tidak berguna" karena tidak memberikan informasi yang relevan.

DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Memeriksa Data Setelah Penghapusan
-- Kueri ini mengambil semua kolom dari tabel layoffs_staging2 setelah penghapusan baris yang tidak berguna. Ini memungkinkan pengguna untuk memverifikasi bahwa 
-- penghapusan telah dilakukan dengan benar dan untuk melihat data yang tersisa. Dengan cara ini, Anda dapat memastikan bahwa hanya data yang relevan yang tersisa.

SELECT * 
FROM world_layoffs.layoffs_staging2;

-- Menghapus Kolom row_num
-- Kueri ini mengubah struktur tabel layoffs_staging2 dengan menghapus kolom row_num. Kolom ini mungkin tidak diperlukan untuk analisis lebih lanjut, 
-- atau mungkin tidak memberikan informasi yang berguna. Menghapus kolom yang tidak perlu membantu menyederhanakan tabel dan meningkatkan efisiensi.

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Memeriksa Data Setelah Menghapus Kolom
-- Kueri ini mengambil semua kolom dari tabel layoffs_staging2 setelah kolom row_num dihapus. Ini memungkinkan pengguna untuk memverifikasi bahwa kolom tersebut telah 
-- dihapus dan untuk melihat struktur tabel yang baru. Dengan cara ini, Anda dapat memastikan bahwa tabel sekarang hanya berisi kolom yang relevan untuk analisis.

SELECT * 
FROM world_layoffs.layoffs_staging2;


-- Kesimpulan
-- Secara keseluruhan, kode SQL di atas berfokus pada pembersihan data dengan mengidentifikasi dan menghapus baris yang tidak memiliki informasi yang berguna 
-- (yaitu, baris dengan nilai NULL di kolom total_laid_off dan percentage_laid_off) serta menghapus kolom yang tidak diperlukan (row_num). 
-- Proses ini penting untuk memastikan bahwa data yang tersisa adalah relevan dan dapat digunakan untuk analisis lebih lanjut.