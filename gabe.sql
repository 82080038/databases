-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Waktu pembuatan: 24 Mar 2026 pada 22.19
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
-- Database: `gabe`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `account_number` varchar(20) NOT NULL,
  `account_type` enum('simpanan','pinjaman') NOT NULL,
  `account_name` varchar(100) NOT NULL,
  `balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `status` enum('active','inactive','closed','frozen') NOT NULL DEFAULT 'active',
  `opened_date` date NOT NULL,
  `closed_date` date DEFAULT NULL,
  `last_transaction_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `accounts`
--

INSERT INTO `accounts` (`id`, `member_id`, `account_number`, `account_type`, `account_name`, `balance`, `interest_rate`, `status`, `opened_date`, `closed_date`, `last_transaction_date`, `created_at`, `updated_at`) VALUES
(1, 1, 'A001', 'simpanan', 'Tabungan Wajib - Ahmad Wijaya', 500000.00, 3.00, 'active', '2024-01-15', NULL, '2024-03-01', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(2, 1, 'A002', 'simpanan', 'Tabungan Sukarela - Ahmad Wijaya', 1000000.00, 2.50, 'active', '2024-01-15', NULL, '2024-03-01', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(3, 2, 'A003', 'simpanan', 'Tabungan Wajib - Siti Nurhaliza', 500000.00, 3.00, 'active', '2024-02-20', NULL, '2024-03-05', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(4, 2, 'A004', 'simpanan', 'Tabungan Sukarela - Siti Nurhaliza', 750000.00, 2.50, 'active', '2024-02-20', NULL, '2024-03-05', '2026-03-22 03:15:36', '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `table_name`, `record_id`, `old_values`, `new_values`, `ip_address`, `user_agent`, `session_id`, `created_at`) VALUES
(1, 1, 'CREATE', 'users', 1, NULL, '{\"username\":\"bos\",\"role\":\"bos\",\"status\":\"active\"}', '127.0.0.1', 'Mozilla/5.0 (System Initializer)', 'session_001', '2026-03-22 03:15:36'),
(2, 1, 'CREATE', 'users', 2, NULL, '{\"username\":\"admin\",\"role\":\"admin\",\"status\":\"active\"}', '127.0.0.1', 'Mozilla/5.0 (System Initializer)', 'session_001', '2026-03-22 03:15:36'),
(3, 1, 'CREATE', 'members', 1, NULL, '{\"member_number\":\"M001\",\"full_name\":\"Ahmad Wijaya\",\"status\":\"active\"}', '127.0.0.1', 'Mozilla/5.0 (System Initializer)', 'session_001', '2026-03-22 03:15:36'),
(4, 1, 'CREATE', 'accounts', 1, NULL, '{\"account_number\":\"A001\",\"account_type\":\"simpanan\",\"balance\":500000}', '127.0.0.1', 'Mozilla/5.0 (System Initializer)', 'session_001', '2026-03-22 03:15:36'),
(5, 1, 'CREATE', 'loans', 1, NULL, '{\"loan_number\":\"L001\",\"loan_amount\":5000000,\"status\":\"active\"}', '127.0.0.1', 'Mozilla/5.0 (System Initializer)', 'session_001', '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `daily_transactions`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `daily_transactions` (
`transaction_date` date
,`total_transactions` bigint(21)
,`total_credits` decimal(22,0)
,`total_debits` decimal(22,0)
,`net_amount` decimal(37,2)
,`total_credits_amount` decimal(37,2)
,`total_debits_amount` decimal(37,2)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `loans`
--

CREATE TABLE `loans` (
  `id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `loan_number` varchar(20) NOT NULL,
  `loan_amount` decimal(15,2) NOT NULL,
  `interest_rate` decimal(5,2) NOT NULL,
  `loan_term` int(11) NOT NULL COMMENT 'jangka waktu dalam bulan',
  `monthly_payment` decimal(15,2) DEFAULT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `collateral` text DEFAULT NULL,
  `guarantor` varchar(100) DEFAULT NULL,
  `status` enum('pending','approved','rejected','active','completed','defaulted') NOT NULL DEFAULT 'pending',
  `application_date` date NOT NULL,
  `approval_date` date DEFAULT NULL,
  `disbursement_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `disbursed_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `loans`
--

INSERT INTO `loans` (`id`, `member_id`, `loan_number`, `loan_amount`, `interest_rate`, `loan_term`, `monthly_payment`, `purpose`, `collateral`, `guarantor`, `status`, `application_date`, `approval_date`, `disbursement_date`, `due_date`, `approved_by`, `disbursed_by`, `created_at`, `updated_at`) VALUES
(1, 1, 'L001', 5000000.00, 12.00, 12, 466666.67, 'Modal usaha kecil', NULL, 'Ahmad Wijaya', 'active', '2024-02-01', '2024-02-05', '2024-02-06', '2025-02-05', 2, 3, '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(2, 2, 'L002', 3000000.00, 10.00, 6, 516666.67, 'Biaya pendidikan', NULL, 'Siti Nurhaliza', 'active', '2024-03-01', '2024-03-03', '2024-03-04', '2024-09-03', 2, 3, '2026-03-22 03:15:36', '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `loan_payments`
--

CREATE TABLE `loan_payments` (
  `id` int(11) NOT NULL,
  `loan_id` int(11) NOT NULL,
  `payment_number` int(11) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `principal_amount` decimal(15,2) NOT NULL,
  `interest_amount` decimal(15,2) NOT NULL,
  `late_fee` decimal(15,2) DEFAULT 0.00,
  `payment_date` date NOT NULL,
  `payment_time` time DEFAULT NULL,
  `payment_method` enum('cash','transfer','bank_deposit','digital_payment') NOT NULL DEFAULT 'cash',
  `received_by` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('pending','completed','failed','cancelled') NOT NULL DEFAULT 'completed',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `loan_payments`
--

INSERT INTO `loan_payments` (`id`, `loan_id`, `payment_number`, `amount`, `principal_amount`, `interest_amount`, `late_fee`, `payment_date`, `payment_time`, `payment_method`, `received_by`, `notes`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 466666.67, 416666.67, 50000.00, 0.00, '2024-03-06', '10:30:00', 'cash', 3, 'Angsuran bulan Maret', 'completed', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(2, 2, 1, 516666.67, 500000.00, 16666.67, 0.00, '2024-04-04', '14:15:00', 'transfer', 3, 'Angsuran bulan April', 'completed', '2026-03-22 03:15:36', '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `loan_performance`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `loan_performance` (
`id` int(11)
,`loan_number` varchar(20)
,`member_name` varchar(100)
,`loan_amount` decimal(15,2)
,`interest_rate` decimal(5,2)
,`loan_term` int(11)
,`status` enum('pending','approved','rejected','active','completed','defaulted')
,`application_date` date
,`disbursement_date` date
,`total_paid` decimal(37,2)
,`remaining_balance` decimal(38,2)
,`payment_status` varchar(9)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `login_attempts`
--

CREATE TABLE `login_attempts` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `success` tinyint(1) NOT NULL DEFAULT 0,
  `failure_reason` varchar(100) DEFAULT NULL,
  `attempt_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `login_attempts`
--

INSERT INTO `login_attempts` (`id`, `username`, `ip_address`, `user_agent`, `success`, `failure_reason`, `attempt_time`) VALUES
(1, 'bos', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 1, NULL, '2026-03-22 03:27:22'),
(2, 'admin', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 1, NULL, '2026-03-22 03:27:52'),
(3, 'teller', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 1, NULL, '2026-03-22 03:28:06'),
(4, 'wrong', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 0, 'Invalid credentials', '2026-03-22 03:29:01'),
(5, '<script>', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 0, 'SQL Injection attempt', '2026-03-22 03:54:59');

-- --------------------------------------------------------

--
-- Struktur dari tabel `members`
--

CREATE TABLE `members` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `member_number` varchar(20) NOT NULL,
  `nik` varchar(16) DEFAULT NULL,
  `full_name` varchar(100) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `birth_place` varchar(100) DEFAULT NULL,
  `gender` enum('L','P') DEFAULT NULL,
  `address` text DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `join_date` date NOT NULL,
  `status` enum('active','inactive','blacklisted') NOT NULL DEFAULT 'active',
  `photo` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `members`
--

INSERT INTO `members` (`id`, `user_id`, `member_number`, `nik`, `full_name`, `birth_date`, `birth_place`, `gender`, `address`, `phone`, `email`, `join_date`, `status`, `photo`, `notes`, `created_at`, `updated_at`) VALUES
(1, 5, 'M001', '3201011234560001', 'Ahmad Wijaya', '1985-05-15', 'Jakarta', 'L', 'Jl. Merdeka No. 123, Jakarta Pusat', '08123456789', 'ahmad.wijaya@email.com', '2024-01-15', 'active', NULL, 'Customer since 2024', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(2, 5, 'M002', '3201011234560002', 'Siti Nurhaliza', '1990-08-22', 'Bandung', 'P', 'Jl. Sudirman No. 456, Bandung', '08234567890', 'siti.nurhaliza@email.com', '2024-02-20', 'active', NULL, 'Customer since 2024', '2026-03-22 03:15:36', '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `member_summary`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `member_summary` (
`id` int(11)
,`member_number` varchar(20)
,`full_name` varchar(100)
,`phone` varchar(20)
,`email` varchar(100)
,`join_date` date
,`status` enum('active','inactive','blacklisted')
,`total_accounts` bigint(21)
,`total_balance` decimal(37,2)
,`total_loans` bigint(21)
,`total_loan_amount` decimal(37,2)
,`outstanding_loans` decimal(38,2)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `savings`
--

CREATE TABLE `savings` (
  `id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `savings_type` enum('wajib','pokok','sukarela','berjangka') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transaction_date` date NOT NULL,
  `transaction_time` time DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `maturity_date` date DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'approved',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `savings`
--

INSERT INTO `savings` (`id`, `member_id`, `savings_type`, `amount`, `transaction_date`, `transaction_time`, `description`, `interest_rate`, `maturity_date`, `created_by`, `approved_by`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'wajib', 500000.00, '2024-01-15', '09:30:00', 'Setoran awal simpanan wajib', 3.00, NULL, 1, 1, 'approved', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(2, 1, 'sukarela', 1000000.00, '2024-01-15', '09:35:00', 'Setoran awal simpanan sukarela', 2.50, NULL, 1, 1, 'approved', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(3, 2, 'wajib', 500000.00, '2024-02-20', '10:15:00', 'Setoran awal simpanan wajib', 3.00, NULL, 1, 1, 'approved', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(4, 2, 'sukarela', 750000.00, '2024-02-20', '10:20:00', 'Setoran awal simpanan sukarela', 2.50, NULL, 1, 1, 'approved', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(5, 1, 'sukarela', 100000.00, '2024-03-01', '14:30:00', 'Setoran tambahan', 2.50, NULL, 3, 1, 'approved', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(6, 2, 'sukarela', 200000.00, '2024-03-05', '15:45:00', 'Setoran tambahan', 2.50, NULL, 3, 1, 'approved', '2026-03-22 03:15:36', '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `system_config`
--

CREATE TABLE `system_config` (
  `id` int(11) NOT NULL,
  `config_key` varchar(100) NOT NULL,
  `config_value` text DEFAULT NULL,
  `config_type` enum('string','number','boolean','json') NOT NULL DEFAULT 'string',
  `description` varchar(255) DEFAULT NULL,
  `category` varchar(50) DEFAULT 'general',
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `system_config`
--

INSERT INTO `system_config` (`id`, `config_key`, `config_value`, `config_type`, `description`, `category`, `updated_by`, `updated_at`) VALUES
(1, 'ksp_name', 'KSP Lam Gabe Jaya', 'string', 'Nama Koperasi', 'general', NULL, '2026-03-22 03:15:36'),
(2, 'ksp_address', 'Jl. Koperasi No. 123, Jakarta', 'string', 'Alamat Koperasi', 'general', NULL, '2026-03-22 03:15:36'),
(3, 'ksp_phone', '021-12345678', 'string', 'Nomor Telepon', 'general', NULL, '2026-03-22 03:15:36'),
(4, 'ksp_email', 'info@ksplamgabejaya.co.id', 'string', 'Email Koperasi', 'general', NULL, '2026-03-22 03:15:36'),
(5, 'savings_wajib_minimum', '500000', 'number', 'Minimal simpanan wajib per bulan', 'savings', NULL, '2026-03-22 03:15:36'),
(6, 'savings_pokok_minimum', '1000000', 'number', 'Minimal simpanan pokok', 'savings', NULL, '2026-03-22 03:15:36'),
(7, 'loan_interest_min', '5.00', 'number', 'Bunga pinjaman minimal (%)', 'loans', NULL, '2026-03-22 03:15:36'),
(8, 'loan_interest_max', '18.00', 'number', 'Bunga pinjaman maksimal (%)', 'loans', NULL, '2026-03-22 03:15:36'),
(9, 'loan_term_max', '36', 'number', 'Jangka waktu pinjaman maksimal (bulan)', 'loans', NULL, '2026-03-22 03:15:36'),
(10, 'late_payment_fee', '2.00', 'number', 'Denda keterlambatan (%)', 'loans', NULL, '2026-03-22 03:15:36'),
(11, 'session_timeout', '30', 'number', 'Session timeout (menit)', 'security', NULL, '2026-03-22 03:15:36'),
(12, 'max_login_attempts', '5', 'number', 'Maksimal percobaan login', 'security', NULL, '2026-03-22 03:15:36'),
(13, 'lockout_duration', '15', 'number', 'Durasi lockout (menit)', 'security', NULL, '2026-03-22 03:15:36'),
(14, 'enable_notifications', 'true', 'boolean', 'Aktifkan notifikasi', 'features', NULL, '2026-03-22 03:15:36'),
(15, 'enable_audit_log', 'true', 'boolean', 'Aktifkan audit log', 'features', NULL, '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `transactions`
--

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL,
  `transaction_code` varchar(20) NOT NULL,
  `account_id` int(11) NOT NULL,
  `transaction_type` enum('debit','credit') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `reference_number` varchar(50) DEFAULT NULL,
  `transaction_date` date NOT NULL,
  `transaction_time` time DEFAULT NULL,
  `payment_method` enum('cash','transfer','bank_deposit','digital_payment') DEFAULT 'cash',
  `status` enum('pending','completed','failed','cancelled') NOT NULL DEFAULT 'completed',
  `created_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `transactions`
--

INSERT INTO `transactions` (`id`, `transaction_code`, `account_id`, `transaction_type`, `amount`, `description`, `reference_number`, `transaction_date`, `transaction_time`, `payment_method`, `status`, `created_by`, `approved_by`, `notes`, `created_at`, `updated_at`) VALUES
(1, 'TRX001', 1, 'credit', 500000.00, 'Setoran Awal Tabungan Wajib', 'SET001', '2024-01-15', '09:30:00', 'cash', 'completed', 1, 1, 'Initial deposit', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(2, 'TRX002', 2, 'credit', 1000000.00, 'Setoran Awal Tabungan Sukarela', 'SET002', '2024-01-15', '09:35:00', 'cash', 'completed', 1, 1, 'Initial deposit', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(3, 'TRX003', 3, 'credit', 500000.00, 'Setoran Awal Tabungan Wajib', 'SET003', '2024-02-20', '10:15:00', 'cash', 'completed', 1, 1, 'Initial deposit', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(4, 'TRX004', 4, 'credit', 750000.00, 'Setoran Awal Tabungan Sukarela', 'SET004', '2024-02-20', '10:20:00', 'cash', 'completed', 1, 1, 'Initial deposit', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(5, 'TRX005', 1, 'credit', 100000.00, 'Setoran Tambahan', 'SET005', '2024-03-01', '14:30:00', 'cash', 'completed', 3, 1, 'Monthly savings', '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(6, 'TRX006', 2, 'credit', 200000.00, 'Setoran Tambahan', 'SET006', '2024-03-05', '15:45:00', 'transfer', 'completed', 3, 1, 'Additional savings', '2026-03-22 03:15:36', '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `role` enum('bos','admin','teller','collector','nasabah') NOT NULL DEFAULT 'nasabah',
  `status` enum('active','inactive','suspended') NOT NULL DEFAULT 'active',
  `last_login` datetime DEFAULT NULL,
  `login_attempts` int(11) NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `full_name`, `phone`, `address`, `role`, `status`, `last_login`, `login_attempts`, `locked_until`, `created_at`, `updated_at`) VALUES
(1, 'bos', '$2y$10$v1gSY5EOZrBJD5OvR5mqb.GRhj3bH5jE7Q6GVh6gVxENfPEU4Soqy', 'bos@ksplamgabejaya.co.id', 'Bos KSP', '08123456789', 'Jl. Koperasi No. 123, Jakarta', 'bos', 'active', '2026-03-24 03:17:53', 0, NULL, '2026-03-22 03:15:36', '2026-03-23 20:17:53'),
(2, 'admin', '$2y$10$GTirzm2dOJQ9jNf2eUleSOms8NUqqNFmiUkxz2AABybCBSe35ETR.', 'admin@ksplamgabejaya.co.id', 'Administrator KSP', '08234567890', 'Jl. Koperasi No. 123, Jakarta', 'admin', 'active', '2026-03-24 02:16:04', 0, NULL, '2026-03-22 03:15:36', '2026-03-23 19:16:04'),
(3, 'teller', '$2y$10$JBSgHbHVUBB7BURCsO4LzePdLZE5GAw/wPNB4wvMHAebAkWE/Rkzm', 'teller@ksplamgabejaya.co.id', 'Teller KSP', '08345678901', 'Jl. Koperasi No. 123, Jakarta', 'teller', 'active', '2026-03-24 02:20:32', 0, NULL, '2026-03-22 03:15:36', '2026-03-23 19:20:32'),
(4, 'collector', '$2y$10$jtB7ZdjmGvty0X/WG3cBouoe2QxR1wvVm8DNvsRvB.tZUUoxlyCzq', 'collector@ksplamgabejaya.co.id', 'Collector KSP', '08456789012', 'Jl. Koperasi No. 123, Jakarta', 'collector', 'active', '2026-03-24 02:22:29', 0, NULL, '2026-03-22 03:15:36', '2026-03-23 19:22:29'),
(5, 'nasabah', '$2y$10$sN72QeV7Qc23gVsXAX/laO6XPI.N4Sv/2oUqqZVdvJQYELZncv0qq', 'nasabah@ksplamgabejaya.co.id', 'Ahmad Wijaya', '08123456789', 'Jl. Merdeka No. 456, Jakarta', 'nasabah', 'active', '2026-03-24 02:26:06', 0, NULL, '2026-03-22 03:15:36', '2026-03-23 19:26:06');

-- --------------------------------------------------------

--
-- Struktur untuk view `daily_transactions`
--
DROP TABLE IF EXISTS `daily_transactions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `daily_transactions`  AS SELECT cast(`t`.`transaction_date` as date) AS `transaction_date`, count(0) AS `total_transactions`, sum(case when `t`.`transaction_type` = 'credit' then 1 else 0 end) AS `total_credits`, sum(case when `t`.`transaction_type` = 'debit' then 1 else 0 end) AS `total_debits`, sum(case when `t`.`transaction_type` = 'credit' then `t`.`amount` else -`t`.`amount` end) AS `net_amount`, sum(case when `t`.`transaction_type` = 'credit' then `t`.`amount` else 0 end) AS `total_credits_amount`, sum(case when `t`.`transaction_type` = 'debit' then `t`.`amount` else 0 end) AS `total_debits_amount` FROM `transactions` AS `t` WHERE `t`.`status` = 'completed' GROUP BY cast(`t`.`transaction_date` as date) ORDER BY cast(`t`.`transaction_date` as date) DESC ;

-- --------------------------------------------------------

--
-- Struktur untuk view `loan_performance`
--
DROP TABLE IF EXISTS `loan_performance`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `loan_performance`  AS SELECT `l`.`id` AS `id`, `l`.`loan_number` AS `loan_number`, `m`.`full_name` AS `member_name`, `l`.`loan_amount` AS `loan_amount`, `l`.`interest_rate` AS `interest_rate`, `l`.`loan_term` AS `loan_term`, `l`.`status` AS `status`, `l`.`application_date` AS `application_date`, `l`.`disbursement_date` AS `disbursement_date`, coalesce(sum(`lp`.`amount`),0) AS `total_paid`, `l`.`loan_amount`- coalesce(sum(`lp`.`amount`),0) AS `remaining_balance`, CASE WHEN `l`.`loan_amount` - coalesce(sum(`lp`.`amount`),0) <= 0 THEN 'completed' WHEN `l`.`due_date` < curdate() AND `l`.`loan_amount` - coalesce(sum(`lp`.`amount`),0) > 0 THEN 'overdue' ELSE 'active' END AS `payment_status` FROM ((`loans` `l` left join `members` `m` on(`l`.`member_id` = `m`.`id`)) left join `loan_payments` `lp` on(`l`.`id` = `lp`.`loan_id` and `lp`.`status` = 'completed')) GROUP BY `l`.`id`, `l`.`loan_number`, `m`.`full_name`, `l`.`loan_amount`, `l`.`interest_rate`, `l`.`loan_term`, `l`.`status`, `l`.`application_date`, `l`.`disbursement_date` ORDER BY `l`.`application_date` DESC ;

-- --------------------------------------------------------

--
-- Struktur untuk view `member_summary`
--
DROP TABLE IF EXISTS `member_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `member_summary`  AS SELECT `m`.`id` AS `id`, `m`.`member_number` AS `member_number`, `m`.`full_name` AS `full_name`, `m`.`phone` AS `phone`, `m`.`email` AS `email`, `m`.`join_date` AS `join_date`, `m`.`status` AS `status`, count(distinct `a`.`id`) AS `total_accounts`, coalesce(sum(`a`.`balance`),0) AS `total_balance`, count(distinct `l`.`id`) AS `total_loans`, coalesce(sum(`l`.`loan_amount`),0) AS `total_loan_amount`, coalesce(`l`.`loan_amount` - coalesce(sum(`lp`.`amount`),0),0) AS `outstanding_loans` FROM (((`members` `m` left join `accounts` `a` on(`m`.`id` = `a`.`member_id` and `a`.`status` = 'active')) left join `loans` `l` on(`m`.`id` = `l`.`member_id` and `l`.`status` in ('active','completed'))) left join `loan_payments` `lp` on(`l`.`id` = `lp`.`loan_id` and `lp`.`status` = 'completed')) GROUP BY `m`.`id`, `m`.`member_number`, `m`.`full_name`, `m`.`phone`, `m`.`email`, `m`.`join_date`, `m`.`status` ORDER BY `m`.`full_name` ASC ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `account_number` (`account_number`),
  ADD KEY `member_id` (`member_id`),
  ADD KEY `account_type` (`account_type`),
  ADD KEY `status` (`status`);

--
-- Indeks untuk tabel `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `action` (`action`),
  ADD KEY `table_name` (`table_name`),
  ADD KEY `created_at` (`created_at`),
  ADD KEY `session_id` (`session_id`);

--
-- Indeks untuk tabel `loans`
--
ALTER TABLE `loans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `loan_number` (`loan_number`),
  ADD KEY `member_id` (`member_id`),
  ADD KEY `status` (`status`),
  ADD KEY `application_date` (`application_date`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `disbursed_by` (`disbursed_by`);

--
-- Indeks untuk tabel `loan_payments`
--
ALTER TABLE `loan_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `loan_id` (`loan_id`),
  ADD KEY `payment_date` (`payment_date`),
  ADD KEY `received_by` (`received_by`),
  ADD KEY `status` (`status`);

--
-- Indeks untuk tabel `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`),
  ADD KEY `ip_address` (`ip_address`),
  ADD KEY `attempt_time` (`attempt_time`),
  ADD KEY `success` (`success`);

--
-- Indeks untuk tabel `members`
--
ALTER TABLE `members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `member_number` (`member_number`),
  ADD UNIQUE KEY `nik` (`nik`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `status` (`status`),
  ADD KEY `join_date` (`join_date`);

--
-- Indeks untuk tabel `savings`
--
ALTER TABLE `savings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `member_id` (`member_id`),
  ADD KEY `savings_type` (`savings_type`),
  ADD KEY `transaction_date` (`transaction_date`),
  ADD KEY `status` (`status`),
  ADD KEY `created_by` (`created_by`);

--
-- Indeks untuk tabel `system_config`
--
ALTER TABLE `system_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `config_key` (`config_key`),
  ADD KEY `category` (`category`),
  ADD KEY `updated_by` (`updated_by`);

--
-- Indeks untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_code` (`transaction_code`),
  ADD KEY `account_id` (`account_id`),
  ADD KEY `transaction_type` (`transaction_type`),
  ADD KEY `transaction_date` (`transaction_date`),
  ADD KEY `status` (`status`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `approved_by` (`approved_by`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `role` (`role`),
  ADD KEY `status` (`status`),
  ADD KEY `last_login` (`last_login`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `loans`
--
ALTER TABLE `loans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `loan_payments`
--
ALTER TABLE `loan_payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `members`
--
ALTER TABLE `members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `savings`
--
ALTER TABLE `savings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `system_config`
--
ALTER TABLE `system_config`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT untuk tabel `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `accounts`
--
ALTER TABLE `accounts`
  ADD CONSTRAINT `accounts_member_id_fk` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `loans`
--
ALTER TABLE `loans`
  ADD CONSTRAINT `loans_approved_by_fk` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `loans_disbursed_by_fk` FOREIGN KEY (`disbursed_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `loans_member_id_fk` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `loan_payments`
--
ALTER TABLE `loan_payments`
  ADD CONSTRAINT `loan_payments_loan_id_fk` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `loan_payments_received_by_fk` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `members`
--
ALTER TABLE `members`
  ADD CONSTRAINT `members_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `savings`
--
ALTER TABLE `savings`
  ADD CONSTRAINT `savings_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `savings_member_id_fk` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `system_config`
--
ALTER TABLE `system_config`
  ADD CONSTRAINT `system_config_updated_by_fk` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transactions_approved_by_fk` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `transactions_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
