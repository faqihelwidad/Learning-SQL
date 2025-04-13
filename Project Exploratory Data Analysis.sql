-- EDA

-- Di sini kita hanya akan mengeksplorasi data dan menemukan tren atau pola atau apa pun yang menarik seperti pencilan

-- Biasanya ketika Anda memulai proses EDA, Anda memiliki gagasan tentang apa yang Anda cari

-- dengan info ini kita hanya akan melihat-lihat dan melihat apa yang kita temukan!

SELECT * 
FROM world_layoffs.layoffs_staging2;

-- EASIER QUERIES (-- PERTANYAAN YANG LEBIH MUDAH)
-- Mengambil Nilai Maksimum dari Total Pemecatan
-- Kode ini digunakan untuk mengambil nilai maksimum dari kolom total_laid_off dalam tabel layoffs_staging2. 
-- Ini memberikan informasi tentang jumlah tertinggi orang yang dipecat dari satu perusahaan dalam dataset.

SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;

-- Melihat Persentase untuk melihat seberapa besar PHK ini
-- Mengambil Persentase Pemecatan Tertinggi dan Terendah
-- Kode ini mencari nilai maksimum dan minimum dari kolom percentage_laid_off, yang menunjukkan persentase karyawan yang dipecat. 
-- Kondisi WHERE percentage_laid_off IS NOT NULL memastikan bahwa hanya nilai yang valid (tidak null) yang dihitung. 
-- Ini membantu untuk memahami seberapa besar dampak pemecatan di berbagai perusahaan.

SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- Perusahaan mana yang memiliki 1 yang pada dasarnya 100 persen perusahaannya di-PHK
-- Mencari Perusahaan dengan Pemecatan 100%
-- Kode ini mencari semua perusahaan yang memiliki persentase pemecatan sebesar 100% (atau 1 dalam format desimal). 
-- Ini menunjukkan perusahaan-perusahaan yang telah memecat seluruh karyawannya, yang sering kali menandakan bahwa perusahaan tersebut mungkin telah bangkrut.

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1;
-- ini sebagian besar adalah perusahaan rintisan yang sepertinya semuanya gulung tikar selama ini

-- jika kita mengurutkan berdasarkan funcs_raised_millions, kita dapat melihat seberapa besar beberapa perusahaan ini
--  Mengurutkan Perusahaan yang Dipecat 100% Berdasarkan Dana yang Dihimpun
-- Kode ini mirip dengan yang sebelumnya, tetapi kali ini hasilnya diurutkan berdasarkan kolom funds_raised_millions dalam urutan menurun. 
-- Ini memungkinkan kita untuk melihat perusahaan-perusahaan yang telah mengumpulkan dana terbesar tetapi masih mengalami pemecatan total. 
-- Ini memberikan wawasan tentang bagaimana beberapa perusahaan yang tampaknya sukses secara finansial (dari segi penggalangan dana) dapat mengalami kegagalan

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt terlihat seperti perusahaan mobil listrik, Quibi! Saya mengenali perusahaan itu - wow, mengumpulkan sekitar 2 miliar dolar dan bangkrut - aduh

-- Kesimpulan
-- Secara keseluruhan, kode-kode SQL ini digunakan untuk mengeksplorasi data terkait pemecatan di berbagai perusahaan, dengan fokus pada jumlah pemecatan, 
-- persentase pemecatan, dan hubungan antara pemecatan dan dana yang telah dihimpun. Ini memberikan gambaran tentang dampak pemecatan di industri dan membantu
-- mengidentifikasi pola atau tren yang mungkin ada.





-- AGAK LEBIH SULIT DAN SEBAGIAN BESAR MENGGUNAKAN GRUP BY --------------------------------------------------------------------------------------------------

-- Perusahaan dengan PHK tunggal terbesar
-- Kueri ini mengambil data dari tabel layoffs_staging untuk menampilkan perusahaan dan jumlah karyawan yang dipecat pada hari tertentu. 
-- Data diurutkan berdasarkan jumlah karyawan yang dipecat (total_laid_off) dalam urutan menurun, sehingga perusahaan dengan pemutusan hubungan kerja terbesar muncul di atas.
-- LIMIT 5 membatasi hasil hanya pada 5 perusahaan teratas. Ini memberikan gambaran tentang pemutusan hubungan kerja terbesar yang terjadi dalam satu hari.

SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;
-- sekarang ini hanya dalam satu hari

-- Perusahaan dengan Jumlah PHK Terbanyak
--  Kueri ini menghitung total pemutusan hubungan kerja untuk setiap perusahaan dengan menjumlahkan total_laid_off dari tabel layoffs_staging2. 
-- Data dikelompokkan berdasarkan nama perusahaan (GROUP BY company), diurutkan berdasarkan total pemutusan hubungan kerja dalam urutan menurun, 
-- dan hanya menampilkan 10 perusahaan teratas. Ini membantu mengidentifikasi perusahaan yang paling banyak melakukan pemutusan hubungan kerja secara keseluruhan.

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- berdasarkan lokasi
-- Kueri ini menghitung total pemutusan hubungan kerja berdasarkan lokasi. Data dikelompokkan berdasarkan lokasi (GROUP BY location), diurutkan berdasarkan 
-- total pemutusan hubungan kerja dalam urutan menurun, dan hanya menampilkan 10 lokasi teratas. Ini memberikan wawasan tentang lokasi mana yang paling 
-- terpengaruh oleh pemutusan hubungan kerja.

SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- ini total dalam 3 tahun terakhir atau dalam dataset

-- Total layoffs by country
-- Kueri ini menghitung total pemutusan hubungan kerja berdasarkan negara. Data dikelompokkan berdasarkan negara (GROUP BY country) dan diurutkan berdasarkan 
-- total pemutusan hubungan kerja dalam urutan menurun. Ini memberikan gambaran tentang negara mana yang mengalami pemutusan hubungan kerja terbesar.

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs by year
-- Kueri ini menghitung total pemutusan hubungan kerja berdasarkan tahun. Fungsi YEAR(date) digunakan untuk mengekstrak tahun dari kolom tanggal. 
-- Data dikelompokkan berdasarkan tahun dan diurutkan dalam urutan menaik (ASC) berdasarkan tahun. Ini membantu dalam menganalisis 
-- tren pemutusan hubungan kerja dari tahun ke tahun.

SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;

-- Total layoffs by industry
-- Kueri ini menghitung total pemutusan hubungan kerja berdasarkan industri. Data dikelompokkan berdasarkan industri (GROUP BY industry) dan 
-- diurutkan berdasarkan total pemutusan hubungan kerja dalam urutan menurun. Ini memberikan wawasan tentang industri mana yang paling 
-- banyak melakukan pemutusan hubungan kerja.

SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Total layoffs by stage
-- Kueri ini menghitung total pemutusan hubungan kerja berdasarkan tahap (stage) dari proses pemutusan hubungan kerja. Data dikelompokkan berdasarkan 
-- tahap (GROUP BY stage) dan diurutkan berdasarkan total pemutusan hubungan kerja dalam urutan menurun. Ini membantu dalam memahami di mana dalam proses
-- pemutusan hubungan kerja yang paling banyak terjadi.

SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Kesimpulan
-- Kumpulan kueri ini memberikan wawasan yang mendalam tentang pemutusan hubungan kerja di berbagai perusahaan, lokasi, negara, tahun, industri, dan tahap. 
-- Dengan menggunakan fungsi agregasi seperti SUM dan pengelompokan (GROUP BY), kita






-- PERTANYAAN YANG LEBIH SULIT ------------------------------------------------------------------------------------------------------------------------------------

-- Sebelumnya kita telah melihat Perusahaan dengan PHK terbanyak. Sekarang mari kita lihat per tahun. Ini sedikit lebih sulit.
-- Saya ingin melihat 

-- Analisis Pemecatan Per Perusahaan dan Tahun

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- 1. CTE Pertama: Company_Year
-- WITH Company_Year AS: Ini mendefinisikan CTE yang disebut Company_Year. CTE ini akan digunakan dalam query berikutnya.
-- SELECT company, YEAR(date) AS years: Memilih nama perusahaan dan tahun dari kolom date. Fungsi YEAR(date) digunakan untuk mengekstrak tahun dari tanggal.
-- SUM(total_laid_off) AS total_laid_off: Menghitung total pemecatan untuk setiap perusahaan per tahun.
-- FROM layoffs_staging2: Menunjukkan tabel sumber data yang digunakan, yaitu layoffs_staging2.
-- GROUP BY company, YEAR(date): Mengelompokkan hasil berdasarkan perusahaan dan tahun. Ini memastikan bahwa total pemecatan dihitung untuk setiap kombinasi perusahaan
-- dan tahun.

-- 2. CTE Kedua: Company_Year_Rank
-- , Company_Year_Rank AS: Ini mendefinisikan CTE kedua yang disebut Company_Year_Rank, yang menggunakan hasil dari CTE pertama (Company_Year).
-- SELECT company, years, total_laid_off: Memilih kolom perusahaan, tahun, dan total pemecatan dari CTE Company_Year.
-- DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking: Menghitung peringkat (ranking) untuk setiap perusahaan berdasarkan total pemecatan dalam
-- tahun yang sama.
	-- PARTITION BY years: Memisahkan perhitungan peringkat berdasarkan tahun.
	-- ORDER BY total_laid_off DESC: Mengurutkan perusahaan berdasarkan total pemecatan dari yang tertinggi ke terendah. 
    -- DENSE_RANK() memberikan peringkat yang sama untuk nilai yang sama, tanpa melewatkan angka peringkat.
    
-- 3. Query Utama
-- SELECT company, years, total_laid_off, ranking: Memilih kolom perusahaan, tahun, total pemecatan, dan peringkat dari CTE Company_Year_Rank.
-- FROM Company_Year_Rank: Mengambil data dari CTE Company_Year_Rank.
-- WHERE ranking <= 3: Memfilter hasil untuk hanya menampilkan perusahaan dengan peringkat 1, 2, atau 3 (yaitu, tiga perusahaan teratas dengan pemecatan terbanyak per tahun).
-- AND years IS NOT NULL: Memastikan bahwa hanya tahun yang valid (tidak null) yang disertakan dalam hasil.
-- ORDER BY years ASC, total_laid_off DESC: Mengurutkan hasil berdasarkan tahun secara ascending (menaik) dan kemudian berdasarkan total pemecatan secara descending (menurun).
-- Ini berarti hasil akan ditampilkan dari tahun terendah ke tertinggi, dan dalam setiap tahun, perusahaan dengan pemecatan tertinggi akan muncul terlebih dahulu.

-- Kesimpulan
-- Secara keseluruhan, kode SQL ini bertujuan untuk menganalisis data pemecatan dengan cara berikut:
-- 1. Menghitung total pemecatan per perusahaan untuk setiap tahun.
-- 2. Memberikan peringkat kepada perusahaan berdasarkan total pemecatan dalam setiap tahun.
-- 3. Mengambil tiga perusahaan teratas dengan pemecatan terbanyak untuk setiap tahun dan menampilkan hasilnya dalam urutan yang terstruktur.


-- Jumlah PHK Bergilir Per Bulan
-- Menghitung Total Pemutusan Hubungan Kerja per Bulan

SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;
-- SELECT SUBSTRING(date,1,7) as dates: Mengambil substring dari kolom date yang berisi tanggal. SUBSTRING(date,1,7) mengambil karakter dari posisi 1 hingga 7, 
-- yang biasanya mencakup tahun dan bulan (format YYYY-MM). Hasilnya disimpan dalam alias dates.
-- SUM(total_laid_off) AS total_laid_off: Menghitung total jumlah pemutusan hubungan kerja (layoffs) untuk setiap bulan. total_laid_off adalah kolom yang berisi jumlah orang yang di-PHK.
-- FROM layoffs_staging2: Menunjukkan tabel sumber data yang digunakan, yaitu layoffs_staging2.
-- GROUP BY dates:Mengelompokkan hasil berdasarkan bulan yang telah diekstrak sebelumnya. Ini memungkinkan kita untuk mendapatkan total pemutusan hubungan kerja per bulan.
-- ORDER BY dates ASC: Mengurutkan hasil berdasarkan kolom dates dalam urutan menaik (ascending).


-- sekarang gunakan dalam CTE sehingga kita dapat melakukan kueri darinya

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

-- Menggunakan CTE untuk Menghitung Total Pemutusan Hubungan Kerja Secara Bergulir
-- WITH DATE_CTE AS (...): Mendefinisikan Common Table Expression (CTE) yang disebut DATE_CTE. CTE ini berfungsi sebagai tabel sementara yang dapat digunakan dalam query utama.
-- SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off: Sama seperti sebelumnya, ini menghitung total pemutusan hubungan kerja per bulan.
-- FROM layoffs_staging2: Mengambil data dari tabel yang sama.
-- GROUP BY dates: Mengelompokkan hasil berdasarkan bulan.
-- ORDER BY dates ASC: Mengurutkan hasil berdasarkan bulan.

-- Menghitung Total Pemutusan Hubungan Kerja Secara Bergulir
-- SELECT dates: Memilih kolom dates dari CTE DATE_CTE.
-- SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs: Menghitung total pemutusan hubungan kerja secara bergulir (rolling total). 
-- Fungsi SUM() OVER (ORDER BY dates ASC) menghitung jumlah kumulatif dari total_laid_off berdasarkan urutan tanggal. Ini memberikan gambaran tentang bagaimana 
-- jumlah pemutusan hubungan kerja berkembang seiring waktu.
-- FROM DATE_CTE: Mengambil data dari CTE yang telah didefinisikan sebelumnya.
-- ORDER BY dates ASC: Mengurutkan hasil akhir berdasarkan kolom dates dalam urutan menaik.

-- Kesimpulan
-- Secara keseluruhan, kode SQL ini digunakan untuk menganalisis data pemutusan hubungan kerja dengan cara menghitung total pemutusan hubungan kerja per bulan dan
-- kemudian menghitung total kumulatif dari pemutusan hubungan kerja tersebut. Ini memberikan wawasan yang lebih baik tentang tren pemutusan hubungan kerja dari
-- waktu ke waktu, yang sangat berguna dalam analisis data eksploratif (EDA).