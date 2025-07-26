-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 26 Jul 2025 pada 15.19
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pdf_qa_app`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `document`
--

CREATE TABLE `document` (
  `id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `upload_date` datetime DEFAULT NULL,
  `uploaded_by` int(11) DEFAULT NULL,
  `file_size` int(11) NOT NULL,
  `num_pages` int(11) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `document`
--

INSERT INTO `document` (`id`, `filename`, `upload_date`, `uploaded_by`, `file_size`, `num_pages`, `description`) VALUES
(1, 'Juknis TIF.pdf', '2025-04-29 13:01:14', 1, 7598413, 249, NULL),
(2, 'Juknis PMB.pdf', '2025-04-29 03:41:52', 1, 3786104, 51, NULL),
(6, 'JuknisFix.pdf', '2025-04-29 13:14:34', 1, 164567, 6, NULL),
(8, 'JuknisTIF_2025.pdf', '2025-05-23 10:06:10', 1, 7599210, 249, NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `feedback`
--

CREATE TABLE `feedback` (
  `id` int(11) NOT NULL,
  `query_id` int(11) NOT NULL,
  `feedback_type` varchar(20) NOT NULL,
  `message` text DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `query`
--

CREATE TABLE `query` (
  `id` int(11) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `document_id` int(11) NOT NULL,
  `question` text NOT NULL,
  `answer` text NOT NULL,
  `language` varchar(10) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `query`
--

INSERT INTO `query` (`id`, `session_id`, `document_id`, `question`, `answer`, `language`, `timestamp`) VALUES
(145, '33084bab-51a4-4da0-9174-9d65d920ef6e', 8, 'ipk saya 2 berapa sks yang bisa saya ambil di semester berikutnya', 'Berdasarkan dokumen yang diberikan, khususnya pada bagian [Bagian 1] yang membahas Program Studi Sistem Informasi di Universitas Trisakti, informasi mengenai jumlah SKS yang dapat diambil berdasarkan IPK adalah sebagai berikut:\n\n*   **Beban belajar maksimal per semester adalah 24 SKS.**\n*   **Minimal IPK 2.00 untuk dapat melanjutkan studi.**\n\nNamun, dokumen ini juga memberikan informasi lebih detail mengenai beban belajar berdasarkan IPK yang diperoleh. Berikut adalah tabel yang relevan:\n\n| Perolehan IPS | Maksimum Beban Belajar Semester (SKS) |\n|---|---|\n| ≥ 3,00 | 24 |\n| 2,50 - 2,99 | 22 |\n| 2,00 - 2,49 | 20 |\n| 1,50 - 1,99 | 18 |\n| 1,00 - 1,49 | 16 |\n| < 1,00 | 14 |\n\nKarena IPK Anda adalah 2.00, maka berdasarkan tabel di atas, jumlah SKS yang bisa Anda ambil di semester berikutnya adalah **20 SKS**.', 'id', '2025-05-23 10:07:02'),
(146, '33084bab-51a4-4da0-9174-9d65d920ef6e', 8, 'kalau ingin mengambil 20 sks berapa ipk nya', 'Berdasarkan dokumen yang diberikan, mahasiswa dapat mengambil maksimal 24 SKS per semester jika memiliki IPK tertentu yang memenuhi syarat. Untuk mengetahui IPK yang dibutuhkan untuk mengambil 20 SKS, lihat tabel berikut:\n\n**Tabel 3.2 Maksimum Beban Belajar Terhadap IPS**\n\n| Perolehan IPS | Maksimum Beban Belajar Semester (sks) |\n|---|---|\n| ≥ 3,00 | 24 |\n| 2,50 - 2,99 | 22 |\n| 2,00 - 2,49 | 20 |\n| 1,50 - 1,99 | 18 |\n| 1,00 - 1,49 | 16 |\n| < 1,00 | 14 |\n\nDari tabel tersebut, dapat disimpulkan bahwa untuk dapat mengambil 20 SKS, mahasiswa harus memiliki IPK antara **2.00 - 2.49**.', 'id', '2025-05-23 10:07:47'),
(147, '33084bab-51a4-4da0-9174-9d65d920ef6e', 8, 'coba sarankan matakuliah pilihan apa yang harus saya ambil kalau mau fokus pada data analyst', 'Berdasarkan dokumen yang diberikan, jika Anda ingin fokus pada data analyst, berikut adalah saran mata kuliah pilihan yang bisa Anda ambil di Program Studi Sistem Informasi Universitas Trisakti:\n\n*   **ISA6303 Analitik Data (Semester 2):** Mata kuliah ini memberikan dasar-dasar tentang analisis data.\n*   **ISD6301 Data Warehouse (Semester 4):** Mata kuliah ini akan memberikan pengetahuan tentang bagaimana data disimpan dan dikelola dalam skala besar untuk keperluan analisis.\n*   **ISS6305 Analitik Bisnis (Semester 5):** Mata kuliah ini akan memberikan pemahaman tentang bagaimana analisis data dapat digunakan untuk mendukung pengambilan keputusan bisnis.\n*   **IKD6313 Manajemen Data dan Informasi Lanjut (Semester 3):** Mata kuliah ini akan memberikan pengetahuan tentang bagaimana data disimpan dan dikelola dalam skala besar untuk keperluan analisis.\n*   **IKS6334 Machine Learning (Semester 6):** Mata kuliah ini akan memberikan pengetahuan tentang bagaimana data disimpan dan dikelola dalam skala besar untuk keperluan analisis.\n\nSelain itu, Anda juga bisa mempertimbangkan mata kuliah pilihan berikut:\n\n*   **IKS6316 Pemrograman Berorientasi Objek (3 SKS)**\n*   **IKS6337 Pemrograman Berorientasi Objek Lanjut (3 SKS)**\n*   **IKP6303 Pemrograman Mobile (3 SKS)**\n*   **IKG6310 Pemrograman Game**\n*   **ISS6303 Kompetensi Keahlian**\n*   **ISP6202 Rantai Pasok Digital**\n*   **ISW6201 Web Content Management**\n\n**Pertimbangan Tambahan:**\n\n*   **Minat dan Tujuan Karir:** Pertimbangkan bidang spesifik dalam analisis data yang paling menarik bagi Anda. Apakah Anda lebih tertarik pada analisis bisnis, data mining, atau visualisasi data? Pilihlah mata kuliah yang sesuai dengan minat Anda.\n*   **Prasyarat:** Periksa apakah ada prasyarat yang harus dipenuhi sebelum mengambil mata kuliah pilihan tertentu. Pastikan Anda telah mengambil mata kuliah prasyarat atau memiliki pengetahuan yang diperlukan.\n*   **Konsultasi dengan Dosen:** Diskusikan pilihan Anda dengan dosen pembimbing akademik atau dosen yang ahli di bidang analisis data. Mereka dapat memberikan saran yang lebih spesifik berdasarkan latar belakang dan tujuan karir Anda.\n\nDengan mempertimbangkan faktor-faktor ini, Anda dapat memilih mata kuliah pilihan yang paling relevan dan bermanfaat untuk karir Anda sebagai seorang data analyst.', 'id', '2025-05-23 10:09:59'),
(148, 'e0afb286-b6e8-47c3-bb4e-ff8da8383e79', 8, 'ipk saya 2 berapa sks yang bisa saya ambil di semester berikutnya', 'Berdasarkan dokumen tersebut, mahasiswa dengan IPK 2.00 dapat mengambil maksimal 20 SKS per semester. (lihat Tabel 3.2)', 'id', '2025-06-26 15:46:35'),
(149, 'e0afb286-b6e8-47c3-bb4e-ff8da8383e79', 8, 'coba lihat tabelnya', 'Tentu, saya akan melihat tabel-tabel yang ada dalam dokumen yang Anda berikan dan memberikan deskripsi detail tentang isinya. Berikut adalah ringkasan tabel-tabel tersebut:\n\n**Tabel 1.1 Status Akreditasi Prodi**\n\n*   **Isi:** Daftar program studi di Fakultas Teknologi Industri (FTI) Universitas Trisakti, jenjang pendidikannya (Sarjana, Magister, Doktor, Profesi), kode program studi, status akreditasi nasional, dan masa berlaku akreditasi.\n*   **Informasi Penting:** Menunjukkan peringkat akreditasi yang diperoleh setiap program studi dari BAN-PT atau LAM Teknik, yang merupakan indikator kualitas program studi tersebut.\n\n**Tabel 2.1 Program Studi dan Peringkat Akreditasi**\n\n*   **Isi:** Daftar program studi di Fakultas Teknologi Industri (FTI) Universitas Trisakti, jenjang pendidikannya (Sarjana, Magister, Doktor, Profesi), kode program studi, status akreditasi nasional, dan akreditasi internasional.\n*   **Informasi Penting:** Menunjukkan peringkat akreditasi yang diperoleh setiap program studi dari BAN-PT atau LAM Teknik, yang merupakan indikator kualitas program studi tersebut.\n\n**Tabel 2.2 Nama Program Studi dan Gelar Lulusan**\n\n*   **Isi:** Daftar program studi di Fakultas Teknologi Industri (FTI) Universitas Trisakti, jenjang pendidikannya, nama program studi dalam Bahasa Indonesia dan Bahasa Inggris, serta gelar lulusan yang diberikan dalam Bahasa Indonesia dan Bahasa Inggris.\n*   **Informasi Penting:** Memberikan informasi mengenai gelar yang akan diperoleh mahasiswa setelah menyelesaikan studi di program studi tertentu.\n\n**Tabel 3.1 Padanan Beban Belajar 1 sks dan Estimasi Waktu Pembelajaran**\n\n*   **Isi:** Menjelaskan padanan beban belajar 1 SKS (Satuan Kredit Semester) dengan estimasi waktu pembelajaran untuk berbagai bentuk kegiatan pembelajaran, seperti kuliah, responsi, tutorial, seminar, praktikum, praktik studio, praktik bengkel, praktik lapangan, praktik kerja, penelitian, perancangan, atau pengembangan.\n*   **Informasi Penting:** Memberikan panduan mengenai bagaimana SKS dihitung berdasarkan waktu yang dialokasikan untuk berbagai kegiatan pembelajaran.\n\n**Tabel 3.2 Maksimum Beban Belajar Terhadap IPS**\n\n*   **Isi:** Menunjukkan hubungan antara Indeks Prestasi Semester (IPS) yang diperoleh mahasiswa dengan maksimum beban belajar (jumlah SKS) yang dapat diambil pada semester berikutnya.\n*   **Informasi Penting:** Menjelaskan bagaimana prestasi akademik mahasiswa (IPS) mempengaruhi kemampuan mereka untuk mengambil mata kuliah di semester berikutnya.\n\n**Tabel 3.3.a Jumlah Beban Belajar dan Masa Belajar (Masa Studi)**\n\n*   **Isi:** Menunjukkan jumlah beban belajar minimum (dalam SKS) dan masa studi maksimum (dalam semester dan tahun) untuk berbagai jenjang program pendidikan di Universitas Trisakti.\n*   **Informasi Penting:** Memberikan batasan mengenai berapa lama mahasiswa dapat menyelesaikan studi di jenjang pendidikan tertentu.\n\n**Tabel 3.3.b Jumlah Beban Belajar, Masa Tempuh Kurikulum, dan Masa Studi Maksimum Setiap Jenjang Program Pendidikan Tahun 2025/2026**\n\n*   **Isi:** Menunjukkan jumlah beban belajar minimum (dalam SKS), masa tempuh kurikulum (dalam semester), dan masa studi maksimum (dalam semester) untuk berbagai jenjang program pendidikan di Universitas Trisakti.\n*   **Informasi Penting:** Memberikan batasan mengenai berapa lama mahasiswa dapat menyelesaikan studi di jenjang pendidikan tertentu.\n\n**Tabel 3.4 Standar Penyetaraan untuk Nilai Akhir Semester dalam Huruf, Bobot, dan Angka**\n\n*   **Isi:** Menjelaskan standar penyetaraan nilai akhir semester dalam bentuk huruf (A, B, C, D, E), bobot nilai (4.00, 3.00, dst.), dan nilai angka (80-100, 68-73.99, dst.) untuk program Diploma & Sarjana dan Pasca Sarjana.\n*   **Informasi Penting:** Memberikan panduan mengenai bagaimana nilai akhir semester dikonversi ke dalam bentuk huruf dan bobot nilai, yang digunakan untuk menghitung IPK.\n\n**Tabel 3.5 Status Nilai**\n\n*   **Isi:** Menjelaskan berbagai status nilai yang mungkin diperoleh mahasiswa (CO, IN, MG, NR, FR) dan kondisi yang menyebabkan status tersebut.\n*   **Informasi Penting:** Memberikan informasi mengenai arti dari berbagai status nilai dan implikasinya terhadap kelulusan mata kuliah.\n\n**Tabel 3.6 Contoh Penentuan Bobot Penilaian SCL**\n\n*   **Isi:** Menunjukkan contoh penentuan bobot penilaian untuk berbagai komponen penilaian dalam pembelajaran Student Centered Learning (SCL), seperti tugas kelompok, praktikum, presentasi, kuis, tugas, dan ujian.\n*   **Informasi Penting:** Memberikan contoh bagaimana bobot penilaian dapat didistribusikan untuk berbagai komponen penilaian dalam pembelajaran SCL.\n\n**Tabel 3.7 Padanan antara IPK Kelulusan dengan Peringkat Predikat Kelulusan**\n\n*   **Isi:** Menjelaskan hubungan antara Indeks Prestasi Kumulatif (IPK) kelulusan dengan peringkat predikat kelulusan (Memuaskan, Sangat Memuaskan, Pujian) untuk berbagai tingkat pendidikan (Diploma, Sarjana, Magister, Doktor, Profesi, Spesialis).\n*   **Informasi Penting:** Memberikan informasi mengenai bagaimana IPK kelulusan mempengaruhi predikat kelulusan yang akan diperoleh mahasiswa.\n\n**Tabel 3.8 Masa Studi Tepat Waktu**\n\n*   **Isi:** Menjelaskan lama masa studi tepat waktu untuk berbagai tingkat pendidikan (Sarjana Reguler, Ekstensi, Magister, Doktor, Profesi Insinyur).\n*   **Informasi Penting:** Memberikan informasi mengenai berapa lama mahasiswa dapat menyelesaikan studi tepat waktu di jenjang pendidikan tertentu.\n\n**Tabel 3.9 Tata Tertib dan Sanksi Akademik**\n\n*   **Isi:** Menjelaskan berbagai pelanggaran tata tertib dan sanksi akademik yang dapat dikenakan kepada mahasiswa.\n*   **Informasi Penting:** Memberikan informasi mengenai konsekuensi dari pelanggaran tata tertib dan etika akademik.\n\n**Tabel 4.1 Contoh Pemilihan Bentuk, Metode, dan Penugasan Pembelajaran**\n\n*   **Isi:** Menunjukkan contoh pemilihan bentuk pembelajaran (kegiatan proses belajar, kegiatan penugasan terstruktur, kegiatan mandiri, praktikum), metode pembelajaran (presentasi mahasiswa, diskusi kelompok, debat, pembelajaran berbasis proyek, pembelajaran berbasis kasus, pembelajaran kolaboratif), dan contoh penugasan (tugas pemecahan masalah, tugas kesenjangan informasi, tugas kesenjangan penalaran, tugas kesenjangan pendapat, minute paper, membuat proyek, mendiskusikan kasus tertentu, membuat portfolio aktivitas mandiri, melaksanakan kegiatan dan pelaporan hasil kerja praktikum).\n*   **Informasi Penting:** Memberikan contoh bagaimana bentuk pembelajaran, metode pembelajaran, dan penugasan dapat dipilih untuk mencapai capaian pembelajaran yang diinginkan.\n\n**Tabel 4.2 Teknik dan Instrumen Penilaian**\n\n*   **Isi:** Menjelaskan teknik penilaian (observasi, partisipasi, unjuk kerja, tes tertulis, tes lisan, angket) dan instrumen penilaian (rubrik untuk penilaian proses, portofolio atau karya desain untuk penilaian hasil) untuk sikap dan keterampilan umum dan khusus dan pengetahuan.\n*   **Informasi Penting:** Memberikan contoh bagaimana teknik dan instrumen penilaian dapat dipilih untuk mengukur capaian pembelajaran yang diinginkan.\n\n**Tabel 6.1 Mata Kuliah Wajib Umum Nasional Program Sarjana**\n\n*   **Isi:** Daftar mata kuliah wajib umum nasional untuk program Sarjana, termasuk Pendidikan Agama, Pancasila, Kewarganegaraan dan Kadeham, dan Bahasa Indonesia, beserta kode mata kuliah dan jumlah SKS.\n*   **Informasi Penting:** Menjelaskan mata kuliah yang wajib diambil oleh semua mahasiswa Sarjana di Universitas Trisakti.\n\n**Tabel 6.1a Nama Dosen Pengampu MKWU**\n\n*   **Isi:** Daftar nama dosen pengampu MKWU, pendidikan, dan bidang ilmu.\n*   **Informasi Penting:** Menjelaskan dosen yang mengampu mata kuliah wajib umum.\n\n**Tabel 6.2 Evaluasi Keberlangsungan Studi Program Sarjana**\n\n*   **Isi:** Menjelaskan evaluasi keberlangsungan studi program Sarjana berdasarkan jumlah SKS yang lulus dan IPK pada setiap semester, serta tindakan yang akan diambil jika mahasiswa tidak memenuhi ketentuan.\n*   **Informasi Penting:** Memberikan panduan mengenai bagaimana keberhasilan studi mahasiswa dievaluasi dan konsekuensi jika tidak memenuhi standar yang ditetapkan.\n\n**Tabel 6.1b Dosen Koordinator MK -MLF**\n\n*   **Isi:** Daftar dosen koordinator MK -MLF, pendidikan, dan bidang ilmu.\n*   **Informasi Penting:** Menjelaskan dosen yang mengkoordinasi mata kuliah muatan lokal fakultas.\n\nSemoga deskripsi ini membantu! Jika Anda memiliki pertanyaan lebih lanjut tentang tabel-tabel ini, jangan ragu untuk bertanya.\n', 'id', '2025-06-26 15:46:56'),
(150, 'e0afb286-b6e8-47c3-bb4e-ff8da8383e79', 8, 'ada di halaman berapa', 'Berdasarkan informasi yang diberikan, pertanyaan \"ada di halaman berapa\" tidak dapat dijawab.', 'id', '2025-06-26 15:47:20'),
(151, 'e0afb286-b6e8-47c3-bb4e-ff8da8383e79', 8, 'saya mahasiswa sistem informasi, apa matakuliah yang dapat diambil semester 7', 'Berdasarkan dokumen yang diberikan, mahasiswa Sistem Informasi di semester 7 memiliki beberapa pilihan mata kuliah. Berikut rinciannya:\n\n**Mata Kuliah Wajib:**\n\n*   IKB6210 - Bahasa Inggris Lanjut (2 SKS)\n*   UKD6200 - Kewarganegaraan dan Kadeham (2 SKS)\n*   IKB6208 - Pra Tugas Akhir (2 SKS)\n*   ISM6312 - Manajemen Pengetahuan (3 SKS)\n\n**Mata Kuliah Pilihan:**\n\n*   Mata Kuliah Pilihan (6 SKS)\n\n**Total SKS yang diambil di semester 7 adalah 15 SKS**\n\n**Catatan Penting:**\n\n*   **Mata Kuliah Pilihan:** Mahasiswa dapat memilih mata kuliah pilihan yang tersedia. Daftar mata kuliah pilihan yang tersedia untuk program studi Sistem Informasi dapat dilihat pada bagian 9.2 dokumen.\n*   **Konsultasi dengan Dosen Wali:** Sangat disarankan untuk berkonsultasi dengan Dosen Wali sebelum memilih mata kuliah, terutama mata kuliah pilihan, agar sesuai dengan minat dan rencana karir mahasiswa.', 'id', '2025-06-26 15:47:55'),
(152, 'e0afb286-b6e8-47c3-bb4e-ff8da8383e79', 8, 'sebutkan matakuliah pilihan', 'Berdasarkan dokumen tersebut, mata kuliah pilihan untuk Program Studi Informatika dan Sistem Informasi adalah sebagai berikut:\n\n**Program Studi Informatika:**\n\nTidak ada daftar mata kuliah pilihan yang eksplisit disebutkan dalam bagian yang diberikan. Namun, disebutkan bahwa mata kuliah pilihan dapat diambil dari mata kuliah yang ditawarkan di program studi Sistem Informasi atau Program Studi yang ada di lingkup Universitas Trisakti.\n\n**Program Studi Sistem Informasi:**\n\nBerikut adalah daftar mata kuliah pilihan yang ditawarkan:\n\n1.  IKS6316 - Pemrograman Berorientasi Objek (3 SKS)\n2.  IKS6337 - Pemrograman Berorientasi Objek Lanjut (3 SKS)\n3.  IKP6303 - Pemrograman Mobile (3 SKS)\n4.  IKG6310 - Pemrograman Game (3 SKS)\n5.  ISS6303 - Kompetensi Keahlian (3 SKS)\n6.  ISP6202 - Rantai Pasok Digital (2 SKS)\n7.  ISW6201 - Web Content Management (2 SKS)\n\nSelain itu, mahasiswa juga dapat mengambil mata kuliah pilihan dari program studi lain di Universitas Trisakti.', 'id', '2025-06-26 15:48:32'),
(153, 'e0afb286-b6e8-47c3-bb4e-ff8da8383e79', 8, 'give me a recomendation if i wanna be data analyst', 'Okay, based on the provided document, here\'s a detailed recommendation for becoming a Data Analyst, specifically tailored to the context of the Sistem Informasi (Information Systems) program at Universitas Trisakti:\n\n**1. Focus on Core Skills and Knowledge:**\n\n*   **Master the Fundamentals:** The document emphasizes the importance of a strong foundation in:\n    *   **Data Management and Information:** Take courses like \"Manajemen Data dan Informasi\" (Management of Data and Information) and \"Manajemen Data dan Informasi Lanjut\" (Advanced Management of Data and Information). These will provide the necessary background for data storage, retrieval, and organization.\n    *   **Analitik Data:** Prioritize courses like \"Analitik Data\" (Data Analytics) and \"Analitik Data Lanjut\" (Advanced Data Analytics). These courses are crucial for developing the core analytical skills needed for a data analyst role.\n    *   **Probabilitas dan Statistika:** Take courses like \"Probabilitas dan Statistika\" (Probability and Statistics) to understand statistical concepts and techniques.\n    *   **Basis Data:** The document mentions \"Basis Data\" as a wajib (required) course. Ensure you have a solid understanding of database principles and SQL.\n    *   **Algoritma dan Pemrograman:** While not explicitly stated as a core data analytics skill, a foundation in programming (e.g., Python, R) is highly beneficial for data manipulation and analysis. The \"Algoritma dan Pemrograman\" course is a good starting point.\n\n*   **Develop Strong Analytical Skills:**\n    *   **Data Mining/Business Intelligence:** The document mentions \"Data Mining/Business Intelligence\" as a course. This is directly relevant to a data analyst role.\n    *   **Machine Learning:** Consider taking \"Machine Learning\" to expand your analytical toolkit and explore predictive modeling.\n    *   **Data Warehouse:** The \"Data Warehouse\" course will teach you about data warehousing concepts, which are essential for storing and analyzing large datasets.\n\n**2. Choose Relevant Electives:**\n\n*   **Data-Focused Electives:** The document lists several elective courses that can enhance your data analysis skills:\n    *   \"Pemrograman Berorientasi Objek\" (Object-Oriented Programming): Useful for building data processing pipelines and applications.\n    *   \"Pemrograman Mobile\" (Mobile Programming) and \"Pemrograman Web\" (Web Programming): These can be helpful if you want to analyze data from mobile or web applications.\n    *   \"Web Content Management\" (ISW6201): If you\'re interested in web analytics, this course could be beneficial.\n\n**3. Gain Practical Experience:**\n\n*   **Capstone Project:** The \"Capstone\" course is an excellent opportunity to apply your knowledge to a real-world data analysis project.\n*   **Magang (Internship):** The document strongly emphasizes the importance of internships. Look for internships that involve data analysis, business intelligence, or data science. Consider both:\n    *   **Magang Bersertifikat:** PMMB (Program Magang Mahasiswa Bersertifikat) and MSIB (Magang Studi Independen Bersertifikat) are good options.\n    *   **Magang Mandiri:** If you can find an internship at a company that\'s not a partner of the university, you can still pursue it with the program\'s approval.\n*   **Proyek Rekayasa Sistem Informasi:** The \"Proyek Rekayasa Sistem Informasi\" course provides practical experience in systems development.\n\n**4. Develop Soft Skills:**\n\n*   **Communication:** The document mentions the importance of communication skills. Take courses that improve your presentation and communication abilities.\n*   **Teamwork:** Participate in group projects and extracurricular activities to develop your teamwork skills.\n\n**5. Leverage University Resources:**\n\n*   **Pusat Bimbingan Karir (Career Center):** The document highlights the career center\'s role in providing job information, career counseling, and job preparation training.\n*   **Jaringan Alumni (Alumni Network):** Connect with alumni who are working as data analysts. They can provide valuable advice and insights.\n*   **Laboratorium Komputer (Computer Labs):** Utilize the computer labs to practice your data analysis skills and work on projects.\n\n**6. Consider Further Education:**\n\n*   **Magister (Master\'s Degree):** If you want to specialize in a particular area of data analysis, consider pursuing a master\'s degree in a related field.\n\n**7. Stay Updated:**\n\n*   **Teknologi Terkini:** The field of data analysis is constantly evolving. Stay up-to-date with the latest tools, techniques, and trends.\n*   **Pelatihan Sertifikasi:** Consider pursuing certifications in data analysis tools or techniques.\n\n**In summary, to become a Data Analyst within the Sistem Informasi program at Universitas Trisakti, focus on building a strong foundation in core data analysis skills, choosing relevant electives, gaining practical experience through internships and projects, developing soft skills, and leveraging the university\'s resources.**\n', 'en', '2025-06-26 15:49:16'),
(154, '807bf7e3-c981-42aa-b66f-c8e7fbeec5b8', 8, 'kapan pengisian sks semester gasal', 'Informasi mengenai jadwal pengisian KRS (Kartu Rencana Studi) semester gasal tidak terdapat secara spesifik dalam dokumen yang diberikan. Namun, dokumen tersebut menyebutkan beberapa hal terkait KRS dan registrasi yang relevan:\n\n*   Jadwal pengisian KRS diumumkan oleh pihak akademik setiap semester dan dilakukan secara online melalui portal mahasiswa.\n*   Pengisian KRS harus mendapatkan persetujuan dari dosen wali.\n*   Mahasiswa yang tidak mengisi KRS pada jadwal yang ditentukan dapat mengalami keterlambatan dalam registrasi dan mengikuti perkuliahan.\n*   Jadwal pengisian KRS diumumkan oleh pihak akademik setiap semester dan dilakukan secara online melalui portal mahasiswa.\n\nUntuk mengetahui jadwal pengisian KRS semester gasal secara pasti, mahasiswa perlu memantau pengumuman resmi dari pihak akademik Universitas Trisakti melalui portal mahasiswa atau sumber informasi resmi lainnya.', 'id', '2025-07-24 09:17:03'),
(155, '807bf7e3-c981-42aa-b66f-c8e7fbeec5b8', 8, 'tanggal berapa?', 'Karena pertanyaan tidak spesifik, saya akan memberikan beberapa tanggal yang relevan dari dokumen tersebut:\n\n*   **Tanggal pendirian Universitas Trisakti:** 29 November 1965\n*   **Tanggal pendirian Fakultas Teknologi Industri:** Tahun 1982\n*   **Tanggal pembukaan Program Studi Teknik Informatika:** Tahun 1996\n*   **Tanggal pembukaan Program Studi Sistem Informasi:** Tahun akademik 2002/2003\n*   **Tanggal Surat Keputusan Dekan tentang Buku Petunjuk Teknis:** 21 Agustus 2024\n*   **Tanggal mulai berlakunya Buku Petunjuk Teknis:** 2 September 2024\n*   **Tanggal Surat Keputusan Menteri Pendidikan, Kebudayaan, Riset dan Teknologi Republik Indonesia No.644/E/O/2023 tentang Program Studi Doktor Teknik Industri:** 1 Agustus 2023\n*   **Tanggal Keputusan Menteri Pendidikan, Kebudayaan, Riset, Dan Teknologi Republik Indonesia Nomor 668/E/O/2023 tentang Program Studi Program Profesi Insinyur:** 16 Agustus 2023', 'id', '2025-07-24 09:17:25'),
(156, '807bf7e3-c981-42aa-b66f-c8e7fbeec5b8', 8, 'tanggal berapa pengisian krs semester gasal', 'Untuk mengetahui tanggal pengisian KRS semester gasal, Anda perlu merujuk ke **Kalender Akademik** yang terdapat pada bagian lampiran dokumen. Kalender akademik tersebut akan memberikan informasi detail mengenai jadwal pengisian KRS untuk setiap semester.\n', 'id', '2025-07-24 09:18:31'),
(157, '807bf7e3-c981-42aa-b66f-c8e7fbeec5b8', 8, 'apa matkul pilihan', 'Berikut adalah daftar mata kuliah pilihan yang ditawarkan oleh Program Studi Sistem Informasi, berdasarkan dokumen yang diberikan:\n\n*   Pemrograman Berorientasi Objek (IKS6316)\n*   Pemrograman Berorientasi Objek Lanjut (IKS6337)\n*   Pemrograman Mobile (IKP6303)\n*   Pemrograman Game (IKG6310)\n*   Kompetensi Keahlian (ISS6303)\n*   Rantai Pasok Digital (ISP6202)\n*   Web Content Management (ISW6201)', 'id', '2025-07-24 09:22:35'),
(158, '807bf7e3-c981-42aa-b66f-c8e7fbeec5b8', 8, 'kalau matkul pilihan teknik informatika', 'Berdasarkan dokumen yang diberikan, berikut adalah daftar mata kuliah pilihan untuk program studi Teknik Informatika:\n\n*   Pemrograman Berorientasi Objek (IKS6316)\n*   Pemrograman Berorientasi Objek Lanjut (IKS6337)\n*   Pemrograman Mobile (IKP6303)\n*   Pemrograman Game (IKG6310)\n*   Kompetensi Keahlian (ISS6303)\n*   Rantai Pasok Digital (ISP6202)\n*   Web Content Management (ISW6201)\n\nSelain itu, mahasiswa juga dapat mengambil mata kuliah pilihan dari program studi lain di Fakultas Teknologi Industri, seperti Teknik Informatika, untuk memperkaya pengetahuan mereka dalam bidang teknologi informasi.', 'id', '2025-07-24 09:23:12'),
(159, '807bf7e3-c981-42aa-b66f-c8e7fbeec5b8', 8, 'apa matakuliah semester 7 teknik informatika', 'Berdasarkan dokumen tersebut, mata kuliah semester 7 untuk program studi Teknik Informatika adalah:\n\n*   IKB6303 Metodologi Penelitian dan Penulisan Ilmiah (3 SKS)\n*   UKD6200 Kewarganegaraan dan Kadeham (2 SKS)\n*   UPA6200 Pancasila (2 SKS)\n*   IKL6331 Metode Numerik (3 SKS)\n*   UAG620.. Pendidikan Agama (2 SKS)\n*   IKS6443 Capstone* (4 SKS)\n\nTotal SKS: 16', 'id', '2025-07-24 09:23:44'),
(160, '807bf7e3-c981-42aa-b66f-c8e7fbeec5b8', 8, 'apak matakuliah semester 7 sistem informasi', 'Berdasarkan dokumen yang diberikan, mata kuliah di semester 7 Program Studi Sistem Informasi adalah:\n\n1.  IKB6210 - Bahasa Inggris Lanjut (2 SKS)\n2.  UKD6200 - Kewarganegaraan dan Kadeham (2 SKS)\n3.  IKB6208 - Pra Tugas Akhir (2 SKS)\n4.  ISM6312 - Manajemen Pengetahuan (3 SKS)\n5.  Mata Kuliah Pilihan (6 SKS)', 'id', '2025-07-24 09:24:08');

-- --------------------------------------------------------

--
-- Struktur dari tabel `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `username` varchar(64) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password_hash` varchar(128) NOT NULL,
  `is_admin` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_login` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user`
--

INSERT INTO `user` (`id`, `username`, `email`, `password_hash`, `is_admin`, `created_at`, `last_login`) VALUES
(1, 'Heru', 'heruputra1954@gmail.com', 'c77635f56cb0588704b614e1af35f1173de4a310c667322d575883ce380fcf6f', 1, '2025-04-29 03:32:30', '2025-07-24 09:15:40'),
(2, 'admin5', 'chaerudin@gmail.com', 'b925861fd29a92311cdf0bdf5d8e54d5b10d44042eebfebe5a7bbbbbb7e52241', 0, '2025-04-29 03:50:07', '2025-04-29 03:50:45'),
(3, 'Heru2', 'heruputra19@gmail.com', '56861077896b5e33a64644f83f1841e3ae38c5d7d5662e40be43e34206a09f96', 0, '2025-04-29 05:37:57', '2025-04-29 05:38:19'),
(4, 'admin1', 'admin@gmail.com', '4429f702260179f0611a1a0ae9d2b65869418962d5f8b0b14b9f13249dc91cb6', 0, '2025-04-29 05:55:55', '2025-05-02 09:06:38'),
(5, 'admin3', 'adada@gmail.com', '4429f702260179f0611a1a0ae9d2b65869418962d5f8b0b14b9f13249dc91cb6', 0, '2025-04-29 05:59:56', '2025-04-29 12:52:57'),
(7, 'satria', 'satria223403@gmail.com', '1230511f20bef2f9f87e0ffce2d81a66d489b4aaf09760de0cde592dae1942cd', 0, '2025-04-29 13:34:04', '2025-04-29 13:34:18'),
(8, 'nadine', 'affitranadinedewi@gmail.com', '14c184607ced1ec04b4b78573f3349f02c3412913940ae3426c85ae96d03527b', 0, '2025-04-29 13:43:53', '2025-04-29 13:43:57'),
(9, 'hasnamicha', 'hasnachoirunnisa04@gmail.com', '33da772525c1dc7b26582c210601d9f2cbd75d3db4f5a9c611623c9e576a212e', 0, '2025-04-29 14:12:19', '2025-04-29 14:12:29'),
(10, 'odilxxa', 'odi@email.com', 'a073d5f14e2a17d0e1af614a665f17be3053c3cfed6eb89a6a41cfa01836ab5c', 0, '2025-05-14 08:23:50', '2025-05-14 08:23:59'),
(11, 'elita', 'elitawf24@gmail.com', '83b10075b60a5102f53998f497d376706d25af6cbaa42ae8d5815e692f17560f', 0, '2025-05-14 08:25:00', '2025-05-14 08:25:09'),
(12, 'Fathur', 'fathurrahman2830@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 0, '2025-05-14 08:25:45', '2025-05-14 08:28:06'),
(13, 'nazriganteng', 'nazrihasby2003@gmail.com', '91e6e3235c778d3bbf9ab454659d2149d4717256eeace24109e2c1900e4d540b', 0, '2025-05-14 08:34:52', '2025-05-14 08:35:02'),
(14, 'shilaa', 'nil-snoozes-4o@icloud.com', 'cdb60b97f7dbb8b7dccb47673cafec84e4396e70f7cbca338b8dcdf06096df97', 0, '2025-05-14 08:45:36', '2025-05-14 08:46:05'),
(15, 'arhanif11', 'arhanif11@gmail.com', 'bfad385edeb57705dc03c1611929ce450845b8fef8b771e9e70324ba08d159d9', 0, '2025-05-14 08:59:01', '2025-05-14 08:59:24'),
(16, 'parss', 'farizanadyar@gmail.com', '4ae9262e13483bd04be86c15abef5a13f79a0bef3e2da66fbf8d0de2eeece40a', 0, '2025-05-14 09:04:26', '2025-05-14 09:04:37'),
(17, 'bismilah', '123@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 0, '2025-05-14 09:23:41', '2025-05-14 09:24:27'),
(18, 'Stevanio', 'stvanio99@gmail.com', '44c89bd34abbf8c66d15dfb96643c68e7f4933fd5d1aae60bba3c85d6e6849df', 0, '2025-05-14 11:03:52', '2025-05-14 11:04:13'),
(19, 'Ryandra Rafa Aditya ', 'ryandra2704@gmail.com', '2862fb6836d2b225c737b8a24dfb6ff4f775384992904dec8f4b8a47c9e68ffc', 0, '2025-05-14 15:22:25', '2025-05-14 15:22:39'),
(20, 'Admin11', 'Admin11@gmail.com', '3b612c75a7b5048a435fb6ec81e52ff92d6d795a8b5a9c17070f6a63c97a53b2', 0, '2025-05-23 08:58:46', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `user_session`
--

CREATE TABLE `user_session` (
  `id` int(11) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_activity` datetime DEFAULT NULL,
  `active_pdf` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user_session`
--

INSERT INTO `user_session` (`id`, `session_id`, `user_id`, `created_at`, `last_activity`, `active_pdf`) VALUES
(50, 'ec0ee0c8-86be-46ae-900b-31908294dde4', 1, '2025-05-20 12:57:08', '2025-05-20 12:57:08', NULL),
(53, '33084bab-51a4-4da0-9174-9d65d920ef6e', 1, '2025-05-23 10:01:34', '2025-05-23 10:06:43', 'JuknisTIF_2025.pdf'),
(54, 'e0afb286-b6e8-47c3-bb4e-ff8da8383e79', 1, '2025-06-26 15:44:58', '2025-06-26 15:46:14', 'JuknisTIF_2025.pdf'),
(56, '807bf7e3-c981-42aa-b66f-c8e7fbeec5b8', 1, '2025-07-24 09:15:40', '2025-07-24 09:16:46', 'JuknisTIF_2025.pdf');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `document`
--
ALTER TABLE `document`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `filename` (`filename`),
  ADD KEY `uploaded_by` (`uploaded_by`);

--
-- Indeks untuk tabel `feedback`
--
ALTER TABLE `feedback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `query_id` (`query_id`);

--
-- Indeks untuk tabel `query`
--
ALTER TABLE `query`
  ADD PRIMARY KEY (`id`),
  ADD KEY `session_id` (`session_id`),
  ADD KEY `document_id` (`document_id`);

--
-- Indeks untuk tabel `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indeks untuk tabel `user_session`
--
ALTER TABLE `user_session`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_id` (`session_id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `document`
--
ALTER TABLE `document`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `feedback`
--
ALTER TABLE `feedback`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `query`
--
ALTER TABLE `query`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=161;

--
-- AUTO_INCREMENT untuk tabel `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT untuk tabel `user_session`
--
ALTER TABLE `user_session`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `document`
--
ALTER TABLE `document`
  ADD CONSTRAINT `document_ibfk_1` FOREIGN KEY (`uploaded_by`) REFERENCES `user` (`id`);

--
-- Ketidakleluasaan untuk tabel `feedback`
--
ALTER TABLE `feedback`
  ADD CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`query_id`) REFERENCES `query` (`id`);

--
-- Ketidakleluasaan untuk tabel `query`
--
ALTER TABLE `query`
  ADD CONSTRAINT `query_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `user_session` (`session_id`),
  ADD CONSTRAINT `query_ibfk_2` FOREIGN KEY (`document_id`) REFERENCES `document` (`id`);

--
-- Ketidakleluasaan untuk tabel `user_session`
--
ALTER TABLE `user_session`
  ADD CONSTRAINT `user_session_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
