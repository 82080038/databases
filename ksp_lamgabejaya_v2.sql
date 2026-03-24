-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Waktu pembuatan: 24 Mar 2026 pada 22.20
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
-- Database: `ksp_lamgabejaya_v2`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateBranchWithAddress` (IN `p_branch_code` VARCHAR(20), IN `p_branch_name` VARCHAR(100), IN `p_branch_type` VARCHAR(50), IN `p_province_id` INT, IN `p_regency_id` INT, IN `p_district_id` INT, IN `p_village_id` INT, IN `p_detail_address` TEXT, IN `p_house_number` VARCHAR(20), IN `p_building_name` VARCHAR(100), IN `p_postal_code` VARCHAR(10), IN `p_branch_phone` VARCHAR(20), IN `p_branch_email` VARCHAR(100), IN `p_manager_id` INT, IN `p_latitude` DECIMAL(10,8), IN `p_longitude` DECIMAL(11,8))   BEGIN
    DECLARE v_branch_id INT;
    
    
    IF NOT EXISTS (
        SELECT 1 FROM alamat_db.provinces p
        JOIN alamat_db.regencies r ON r.province_id = p.id
        JOIN alamat_db.districts d ON d.regency_id = r.id
        JOIN alamat_db.villages v ON v.district_id = d.id
        WHERE p.id = p_province_id AND r.id = p_regency_id AND d.id = p_district_id AND v.id = p_village_id
    ) THEN
        SELECT FALSE as success, 'Invalid address hierarchy' as message;
    ELSE
        
        INSERT INTO branches (
            branch_code, branch_name, branch_type, province_id, regency_id, district_id, village_id,
            detail_address, house_number, building_name, postal_code, branch_phone, branch_email,
            manager_id, gps_coordinates, opened_date
        ) VALUES (
            p_branch_code, p_branch_name, p_branch_type, p_province_id, p_regency_id, p_district_id, p_village_id,
            p_detail_address, p_house_number, p_building_name, p_postal_code, p_branch_phone, p_branch_email,
            p_manager_id, POINT(p_latitude, p_longitude), CURDATE()
        );
        
        SET v_branch_id = LAST_INSERT_ID();
        
        
        INSERT INTO branch_operating_hours (branch_id, day_of_week, open_time, close_time, is_closed) VALUES
        (v_branch_id, 'monday', '08:00:00', '16:00:00', FALSE),
        (v_branch_id, 'tuesday', '08:00:00', '16:00:00', FALSE),
        (v_branch_id, 'wednesday', '08:00:00', '16:00:00', FALSE),
        (v_branch_id, 'thursday', '08:00:00', '16:00:00', FALSE),
        (v_branch_id, 'friday', '08:00:00', '16:00:00', FALSE),
        (v_branch_id, 'saturday', '08:00:00', '13:00:00', FALSE),
        (v_branch_id, 'sunday', NULL, NULL, TRUE);
        
        SELECT TRUE as success, 'Branch created successfully' as message, v_branch_id as branch_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBranchesByServiceArea` (IN `p_province_id` INT, IN `p_regency_id` INT, IN `p_district_id` INT)   BEGIN
    SELECT 
        b.id,
        b.branch_code,
        b.branch_name,
        b.branch_type,
        b.branch_status,
        b.is_active,
        b.branch_phone,
        b.branch_email,
        b.operating_hours,
        bca.service_type,
        bca.coverage_description,
        b.complete_address,
        b.gps_coordinates_text,
        b.status_description,
        u.full_name as manager_name
    FROM branch_complete_address b
    JOIN branch_service_areas bca ON b.id = bca.branch_id
    LEFT JOIN users u ON b.manager_id = u.id
    WHERE bca.province_id = p_province_id 
      AND bca.regency_id = p_regency_id 
      AND bca.district_id = p_district_id
      AND b.is_active = TRUE
      AND bca.is_active = TRUE
    ORDER BY 
        CASE b.branch_type
            WHEN 'headquarters' THEN 1
            WHEN 'main_branch' THEN 2
            WHEN 'sub_branch' THEN 3
            WHEN 'service_unit' THEN 4
            ELSE 5
        END,
        b.branch_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetEmployeeWithPeopleData` (IN `p_employee_id` INT)   BEGIN
    SELECT 
        e.*,
        u.nama as people_nama,
        u.email as people_email,
        u.phone as people_phone,
        i.nama_lengkap,
        i.tempat_lahir,
        i.tanggal_lahir,
        g.name as gender_name,
        ms.name as marital_status_name,
        rel.name as religion_name,
        eth.name as ethnicity_name,
        bt.name as blood_type_name,
        i.risk_score,
        i.kyc_completeness,
        emp.company,
        emp.position as employment_position,
        emp.industry,
        emp.start_date,
        emp.end_date,
        emp.salary,
        a.street_address,
        a.alamat_detil,
        p.name as province_name,
        r.name as regency_name,
        d.name as district_name,
        v.name as village_name,
        a.postal_code,
        a.latitude,
        a.longitude,
        a.address_verified,
        CONCAT(
            COALESCE(a.alamat_detil, a.street_address, ''), ', ',
            COALESCE(v.name, ''), ', ',
            COALESCE(d.name, ''), ', ',
            COALESCE(r.name, ''), ', ',
            COALESCE(p.name, ''), ' ',
            COALESCE(a.postal_code, v.postal_code, r.postal_code, '')
        ) as complete_address
    FROM ksp_lamgabejaya_v2.employees e
    LEFT JOIN people_db.users u ON e.user_id = u.id
    LEFT JOIN people_db.identities i ON u.id = i.user_id
    LEFT JOIN people_db.genders g ON i.gender_id = g.id
    LEFT JOIN people_db.marital_statuses ms ON i.marital_status_id = ms.id
    LEFT JOIN people_db.religions rel ON i.religion_id = rel.id
    LEFT JOIN people_db.ethnicities eth ON i.ethnicity_id = eth.id
    LEFT JOIN people_db.blood_types bt ON i.blood_type_id = bt.id
    LEFT JOIN people_db.employment_records emp ON u.id = emp.user_id
    LEFT JOIN people_db.addresses a ON u.id = a.user_id AND a.is_primary = 1
    LEFT JOIN alamat_db.provinces p ON a.province_id = p.id
    LEFT JOIN alamat_db.regencies r ON a.regency_id = r.id
    LEFT JOIN alamat_db.districts d ON a.district_id = d.id
    LEFT JOIN alamat_db.villages v ON a.village_id = v.id
    WHERE e.id = p_employee_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMemberWithPeopleData` (IN `p_member_id` INT)   BEGIN
    SELECT 
        m.*,
        u.nama as people_nama,
        u.email as people_email,
        u.phone as people_phone,
        i.nama_lengkap,
        i.tempat_lahir,
        i.tanggal_lahir,
        g.name as gender_name,
        ms.name as marital_status_name,
        rel.name as religion_name,
        eth.name as ethnicity_name,
        bt.name as blood_type_name,
        i.risk_score,
        i.kyc_completeness,
        a.street_address,
        a.alamat_detil,
        p.name as province_name,
        r.name as regency_name,
        d.name as district_name,
        v.name as village_name,
        a.postal_code,
        a.latitude,
        a.longitude,
        a.address_verified,
        CONCAT(
            COALESCE(a.alamat_detil, a.street_address, ''), ', ',
            COALESCE(v.name, ''), ', ',
            COALESCE(d.name, ''), ', ',
            COALESCE(r.name, ''), ', ',
            COALESCE(p.name, ''), ' ',
            COALESCE(a.postal_code, v.postal_code, r.postal_code, '')
        ) as complete_address
    FROM ksp_lamgabejaya_v2.members m
    LEFT JOIN people_db.users u ON m.user_id = u.id
    LEFT JOIN people_db.identities i ON u.id = i.user_id
    LEFT JOIN people_db.genders g ON i.gender_id = g.id
    LEFT JOIN people_db.marital_statuses ms ON i.marital_status_id = ms.id
    LEFT JOIN people_db.religions rel ON i.religion_id = rel.id
    LEFT JOIN people_db.ethnicities eth ON i.ethnicity_id = eth.id
    LEFT JOIN people_db.blood_types bt ON i.blood_type_id = bt.id
    LEFT JOIN people_db.addresses a ON u.id = a.user_id AND a.is_primary = 1
    LEFT JOIN alamat_db.provinces p ON a.province_id = p.id
    LEFT JOIN alamat_db.regencies r ON a.regency_id = r.id
    LEFT JOIN alamat_db.districts d ON a.district_id = d.id
    LEFT JOIN alamat_db.villages v ON a.village_id = v.id
    WHERE m.id = p_member_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MigrateMemberToPeopleDB` (IN `p_member_id` INT, IN `p_nama` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_phone` VARCHAR(20))   BEGIN
    DECLARE v_user_id INT;
    DECLARE v_identity_id INT;
    
    
    INSERT INTO people_db.users (nama, email, phone, status, created_at)
    VALUES (p_nama, p_email, p_phone, 'active', CURRENT_TIMESTAMP())
    ON DUPLICATE KEY UPDATE 
        nama = VALUES(nama),
        email = VALUES(email),
        phone = VALUES(phone),
        updated_at = CURRENT_TIMESTAMP();
    
    
    SELECT id INTO v_user_id FROM people_db.users WHERE email = p_email LIMIT 1;
    
    
    UPDATE ksp_lamgabejaya_v2.members 
    SET user_id = v_user_id 
    WHERE id = p_member_id;
    
    
    INSERT INTO people_db.identities (user_id, nama_lengkap, status, created_at)
    VALUES (v_user_id, p_nama, 'draft', CURRENT_TIMESTAMP())
    ON DUPLICATE KEY UPDATE 
        nama_lengkap = VALUES(nama_lengkap),
        updated_at = CURRENT_TIMESTAMP();
    
    SELECT v_user_id as user_id, 'Migration completed successfully' as message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ValidateAddressIds` (IN `p_province_id` INT, IN `p_regency_id` INT, IN `p_district_id` INT, IN `p_village_id` INT)   BEGIN
    DECLARE v_valid BOOLEAN DEFAULT FALSE;
    DECLARE v_error_msg VARCHAR(255);
    
    
    SELECT COUNT(*) > 0 INTO v_valid
    FROM alamat_db.provinces p
    JOIN alamat_db.regencies r ON r.province_id = p.id
    JOIN alamat_db.districts d ON d.regency_id = r.id
    JOIN alamat_db.villages v ON v.district_id = d.id
    WHERE p.id = p_province_id 
      AND r.id = p_regency_id 
      AND d.id = p_district_id 
      AND v.id = p_village_id;
    
    IF v_valid THEN
        SELECT TRUE as is_valid, 'Address IDs are valid' as message;
    ELSE
        SELECT FALSE as is_valid, 'Invalid address IDs or incorrect hierarchy' as message;
    END IF;
END$$

DELIMITER ;

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
  `status` enum('active','inactive','closed') NOT NULL DEFAULT 'active',
  `opened_date` date NOT NULL,
  `closed_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `accounts`
--

INSERT INTO `accounts` (`id`, `member_id`, `account_number`, `account_type`, `account_name`, `balance`, `interest_rate`, `status`, `opened_date`, `closed_date`, `created_at`, `updated_at`) VALUES
(1, 1, 'A001', 'simpanan', 'Tabungan Wajib - Ahmad Wijaya', 500000.00, 3.00, 'active', '2024-01-15', NULL, '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(2, 1, 'A002', 'simpanan', 'Tabungan Sukarela - Ahmad Wijaya', 1000000.00, 2.50, 'active', '2024-01-15', NULL, '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(3, 2, 'A003', 'simpanan', 'Tabungan Wajib - Siti Nurhaliza', 500000.00, 3.00, 'active', '2024-02-20', NULL, '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(4, 2, 'A004', 'simpanan', 'Tabungan Sukarela - Siti Nurhaliza', 750000.00, 2.50, 'active', '2024-02-20', NULL, '2026-03-22 03:15:36', '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `activity_locations`
--

CREATE TABLE `activity_locations` (
  `id` int(11) NOT NULL,
  `activity_type` enum('collection','visit','meeting','other') NOT NULL,
  `person_id` int(11) NOT NULL,
  `person_type` enum('member','employee','staff') NOT NULL,
  `province_id` int(11) DEFAULT NULL,
  `regency_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `village_id` int(11) DEFAULT NULL,
  `detail_address` text DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `activity_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `activity_milestones`
--

CREATE TABLE `activity_milestones` (
  `id` int(11) NOT NULL,
  `plan_id` int(11) NOT NULL,
  `milestone_name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `target_date` date NOT NULL,
  `target_value` decimal(15,2) DEFAULT 0.00,
  `actual_value` decimal(15,2) DEFAULT 0.00,
  `status` enum('pending','in_progress','completed','delayed') NOT NULL DEFAULT 'pending',
  `completion_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `activity_plans`
--

CREATE TABLE `activity_plans` (
  `id` int(11) NOT NULL,
  `plan_name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `plan_type` enum('monthly','quarterly','yearly','special') NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `target_members` int(11) DEFAULT 0,
  `target_savings` decimal(15,2) DEFAULT 0.00,
  `target_loans` decimal(15,2) DEFAULT 0.00,
  `target_collections` decimal(15,2) DEFAULT 0.00,
  `budget` decimal(15,2) DEFAULT 0.00,
  `responsible_person_id` int(11) DEFAULT NULL,
  `status` enum('draft','active','completed','cancelled') NOT NULL DEFAULT 'draft',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `table_name`, `record_id`, `old_values`, `new_values`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 1, 'CREATE', 'users', 1, NULL, '{\"username\":\"admin\",\"role\":\"admin\",\"status\":\"active\"}', '127.0.0.1', 'Mozilla/5.0 (System Initializer)', '2026-03-22 03:15:36'),
(2, 1, 'CREATE', 'members', 1, NULL, '{\"member_number\":\"M001\",\"full_name\":\"Ahmad Wijaya\",\"status\":\"active\"}', '127.0.0.1', 'Mozilla/5.0 (System Initializer)', '2026-03-22 03:15:36'),
(3, 1, 'CREATE', 'accounts', 1, NULL, '{\"account_number\":\"A001\",\"account_type\":\"simpanan\",\"balance\":500000}', '127.0.0.1', 'Mozilla/5.0 (System Initializer)', '2026-03-22 03:15:36'),
(4, 1, 'CREATE', 'loans', 1, NULL, '{\"loan_number\":\"L001\",\"loan_amount\":5000000,\"status\":\"active\"}', '127.0.0.1', 'Mozilla/5.0 (System Initializer)', '2026-03-22 03:15:36'),
(5, 2, 'UPDATE', 'loans', 1, NULL, '{\"status\":\"approved\",\"approved_by\":2}', '127.0.0.1', 'Mozilla/5.0 (Manager Browser)', '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `audit_trail`
--

CREATE TABLE `audit_trail` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `record_id` int(11) DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `session_id` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `audit_trail`
--

INSERT INTO `audit_trail` (`id`, `user_id`, `action`, `table_name`, `record_id`, `old_values`, `new_values`, `ip_address`, `user_agent`, `session_id`, `created_at`) VALUES
(1, 4, 'UPDATE', 'members', 1, '{\"full_name\": \"Ahmad Wijaya\", \"status\": \"active\"}', '{\"full_name\": \"Ahmad Wijaya\", \"status\": \"active\"}', NULL, NULL, NULL, '2026-03-24 19:21:02'),
(2, 4, 'UPDATE', 'members', 1, '{\"full_name\": \"Ahmad Wijaya\", \"status\": \"active\"}', '{\"full_name\": \"Ahmad Wijaya\", \"status\": \"active\"}', NULL, NULL, NULL, '2026-03-24 19:21:28'),
(3, 4, 'UPDATE', 'members', 1, '{\"full_name\": \"Ahmad Wijaya\", \"status\": \"active\"}', '{\"full_name\": \"Ahmad Wijaya\", \"status\": \"active\"}', NULL, NULL, NULL, '2026-03-24 19:22:19');

-- --------------------------------------------------------

--
-- Struktur dari tabel `branches`
--

CREATE TABLE `branches` (
  `id` int(11) NOT NULL,
  `branch_code` varchar(20) NOT NULL,
  `branch_name` varchar(100) NOT NULL,
  `branch_type` enum('kantor_pusat','cabang','unit','pos') DEFAULT 'cabang',
  `province_id` int(11) DEFAULT NULL,
  `regency_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `village_id` int(11) DEFAULT NULL,
  `detail_address` text DEFAULT NULL,
  `house_number` varchar(20) DEFAULT NULL,
  `building_name` varchar(100) DEFAULT NULL,
  `floor_number` varchar(10) DEFAULT NULL,
  `unit_number` varchar(20) DEFAULT NULL,
  `rt_number` varchar(10) DEFAULT NULL,
  `rw_number` varchar(10) DEFAULT NULL,
  `complex_name` varchar(100) DEFAULT NULL,
  `landmark_reference` varchar(255) DEFAULT NULL,
  `parking_info` text DEFAULT NULL,
  `facility_info` text DEFAULT NULL,
  `operating_hours` varchar(100) DEFAULT NULL,
  `gps_coordinates` point DEFAULT NULL,
  `coverage_area` text DEFAULT NULL,
  `branch_phone` varchar(20) DEFAULT NULL,
  `branch_email` varchar(100) DEFAULT NULL,
  `npwp` varchar(25) DEFAULT NULL,
  `business_license` varchar(50) DEFAULT NULL,
  `establishment_date` date DEFAULT NULL,
  `branch_status` enum('headquarters','main_branch','sub_branch','service_unit','mobile_unit') DEFAULT 'main_branch',
  `is_active` tinyint(1) DEFAULT 1,
  `last_inspection_date` date DEFAULT NULL,
  `inspection_notes` text DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `manager_id` int(11) DEFAULT NULL,
  `status` enum('active','inactive','closed') DEFAULT 'active',
  `opened_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `branch_complete_address`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `branch_complete_address` (
`id` int(11)
,`branch_code` varchar(20)
,`branch_name` varchar(100)
,`branch_type` enum('kantor_pusat','cabang','unit','pos')
,`branch_status` enum('headquarters','main_branch','sub_branch','service_unit','mobile_unit')
,`is_active` tinyint(1)
,`province_id` int(11)
,`regency_id` int(11)
,`district_id` int(11)
,`village_id` int(11)
,`detail_address` text
,`house_number` varchar(20)
,`building_name` varchar(100)
,`floor_number` varchar(10)
,`unit_number` varchar(20)
,`rt_number` varchar(10)
,`rw_number` varchar(10)
,`complex_name` varchar(100)
,`landmark_reference` varchar(255)
,`postal_code` varchar(10)
,`branch_phone` varchar(20)
,`branch_email` varchar(100)
,`operating_hours` varchar(100)
,`coverage_area` text
,`manager_id` int(11)
,`opened_date` date
,`establishment_date` date
,`npwp` varchar(25)
,`business_license` varchar(50)
,`last_inspection_date` date
,`inspection_notes` text
,`created_at` timestamp
,`updated_at` timestamp
,`province_name` varchar(100)
,`province_code` varchar(10)
,`regency_name` varchar(100)
,`regency_code` varchar(10)
,`district_name` varchar(100)
,`district_code` varchar(10)
,`village_name` varchar(100)
,`village_code` varchar(10)
,`street_name` varchar(255)
,`street_type` enum('jalan','gang','lorong','komplek','perumahan','jalan raya','boulevard','avenue')
,`extended_postal_code` varchar(10)
,`landmark_name` varchar(255)
,`landmark_type` enum('masjid','gereja','sekolah','rumah sakit','pasar','kantor','tugu','jembatan','sungai','lainnya')
,`manager_name` varchar(100)
,`manager_email` varchar(100)
,`complete_address` mediumtext
,`gps_coordinates_text` varchar(48)
,`type_name` varchar(50)
,`type_category` enum('corporate','branch','unit','mobile','virtual')
,`type_description` text
,`status_description` varchar(20)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `branch_facilities`
--

CREATE TABLE `branch_facilities` (
  `id` int(11) NOT NULL,
  `branch_id` int(11) NOT NULL,
  `facility_type` enum('atm','parking','meeting_room','customer_service','safe_deposit','wifi','ac','security','wheelchair_access') NOT NULL,
  `facility_status` enum('available','unavailable','maintenance') DEFAULT 'available',
  `facility_description` text DEFAULT NULL,
  `last_maintenance_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `branch_operating_hours`
--

CREATE TABLE `branch_operating_hours` (
  `id` int(11) NOT NULL,
  `branch_id` int(11) NOT NULL,
  `day_of_week` enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday') NOT NULL,
  `open_time` time NOT NULL,
  `close_time` time NOT NULL,
  `is_closed` tinyint(1) DEFAULT 0,
  `special_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `branch_service_areas`
--

CREATE TABLE `branch_service_areas` (
  `id` int(11) NOT NULL,
  `branch_id` int(11) NOT NULL,
  `province_id` int(11) NOT NULL,
  `regency_id` int(11) NOT NULL,
  `district_id` int(11) NOT NULL,
  `service_type` enum('full_service','collection_only','consultation_only','registration_only') DEFAULT 'full_service',
  `coverage_description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `branch_types`
--

CREATE TABLE `branch_types` (
  `id` int(11) NOT NULL,
  `branch_type` varchar(50) NOT NULL,
  `category` enum('corporate','branch','unit','mobile','virtual') NOT NULL,
  `description` text DEFAULT NULL,
  `min_staff_required` int(11) DEFAULT 1,
  `has_atm` tinyint(1) DEFAULT 0,
  `has_parking` tinyint(1) DEFAULT 0,
  `has_meeting_room` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `branch_types`
--

INSERT INTO `branch_types` (`id`, `branch_type`, `category`, `description`, `min_staff_required`, `has_atm`, `has_parking`, `has_meeting_room`, `created_at`) VALUES
(1, 'Kantor Pusat', 'corporate', 'Kantor pusat operasional KSP', 10, 1, 1, 1, '2026-03-24 19:43:52'),
(2, 'Cabang Utama', 'branch', 'Cabang utama dengan fasilitas lengkap', 5, 1, 1, 1, '2026-03-24 19:43:52'),
(3, 'Cabang Reguler', 'branch', 'Cabang standar untuk layanan nasabah', 3, 0, 1, 0, '2026-03-24 19:43:52'),
(4, 'Unit Layanan', 'unit', 'Unit layanan minimal', 2, 0, 0, 0, '2026-03-24 19:43:52'),
(5, 'Pos Layanan', 'unit', 'Pos layanan mobile/terbatas', 1, 0, 0, 0, '2026-03-24 19:43:52'),
(6, 'Unit Mobile', 'mobile', 'Layanan bergerak', 1, 0, 0, 0, '2026-03-24 19:43:52'),
(7, 'Virtual Branch', 'virtual', 'Layanan online saja', 0, 0, 0, 0, '2026-03-24 19:43:52'),
(8, 'Kantor Pusat', 'corporate', 'Kantor pusat operasional KSP', 10, 1, 1, 1, '2026-03-24 19:44:44'),
(9, 'Cabang Utama', 'branch', 'Cabang utama dengan fasilitas lengkap', 5, 1, 1, 1, '2026-03-24 19:44:44'),
(10, 'Cabang Reguler', 'branch', 'Cabang standar untuk layanan nasabah', 3, 0, 1, 0, '2026-03-24 19:44:44'),
(11, 'Unit Layanan', 'unit', 'Unit layanan minimal', 2, 0, 0, 0, '2026-03-24 19:44:44'),
(12, 'Pos Layanan', 'unit', 'Pos layanan mobile/terbatas', 1, 0, 0, 0, '2026-03-24 19:44:44'),
(13, 'Unit Mobile', 'mobile', 'Layanan bergerak', 1, 0, 0, 0, '2026-03-24 19:44:44'),
(14, 'Virtual Branch', 'virtual', 'Layanan online saja', 0, 0, 0, 0, '2026-03-24 19:44:44'),
(15, 'Kantor Pusat', 'corporate', 'Kantor pusat operasional KSP', 10, 1, 1, 1, '2026-03-24 19:45:02'),
(16, 'Cabang Utama', 'branch', 'Cabang utama dengan fasilitas lengkap', 5, 1, 1, 1, '2026-03-24 19:45:02'),
(17, 'Cabang Reguler', 'branch', 'Cabang standar untuk layanan nasabah', 3, 0, 1, 0, '2026-03-24 19:45:02'),
(18, 'Unit Layanan', 'unit', 'Unit layanan minimal', 2, 0, 0, 0, '2026-03-24 19:45:02'),
(19, 'Pos Layanan', 'unit', 'Pos layanan mobile/terbatas', 1, 0, 0, 0, '2026-03-24 19:45:02'),
(20, 'Unit Mobile', 'mobile', 'Layanan bergerak', 1, 0, 0, 0, '2026-03-24 19:45:02'),
(21, 'Virtual Branch', 'virtual', 'Layanan online saja', 0, 0, 0, 0, '2026-03-24 19:45:02');

-- --------------------------------------------------------

--
-- Struktur dari tabel `chart_of_accounts`
--

CREATE TABLE `chart_of_accounts` (
  `id` int(11) NOT NULL,
  `account_code` varchar(20) NOT NULL,
  `account_name` varchar(200) NOT NULL,
  `account_type` enum('asset','liability','equity','revenue','expense') NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `level` int(11) NOT NULL DEFAULT 1,
  `is_active` tinyint(1) DEFAULT 1,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `chart_of_accounts`
--

INSERT INTO `chart_of_accounts` (`id`, `account_code`, `account_name`, `account_type`, `parent_id`, `level`, `is_active`, `description`, `created_at`, `updated_at`) VALUES
(1, '1000', 'AKTIVA', 'asset', NULL, 1, 1, 'Total Aktiva', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(2, '1100', 'Aktiva Lancar', 'asset', NULL, 2, 1, 'Aktiva Lancar', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(3, '1110', 'Kas', 'asset', NULL, 3, 1, 'Kas dan Setara Kas', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(4, '1120', 'Bank', 'asset', NULL, 3, 1, 'Rekening Bank', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(5, '1130', 'Piutang Anggota', 'asset', NULL, 3, 1, 'Piutang dari Anggota', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(6, '1140', 'Piutang Pinjaman', 'asset', NULL, 3, 1, 'Piutang Pinjaman Beredar', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(7, '1200', 'Aktiva Tetap', 'asset', NULL, 2, 1, 'Aktiva Tetap', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(8, '1210', 'Tanah dan Bangunan', 'asset', NULL, 3, 1, 'Tanah dan Bangunan Kantor', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(9, '1220', 'Kendaraan Operasional', 'asset', NULL, 3, 1, 'Kendaraan Operasional', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(10, '2000', 'KEWAJIBAN', 'liability', NULL, 1, 1, 'Total Kewajiban', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(11, '2100', 'Kewajiban Lancar', 'liability', NULL, 2, 1, 'Kewajiban Lancar', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(12, '2110', 'Simpanan Anggota', 'liability', NULL, 3, 1, 'Simpanan Wajib dan Pokok', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(13, '2120', 'Hutang Bank', 'liability', NULL, 3, 1, 'Hutang kepada Bank', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(14, '3000', 'EKUITAS', 'equity', NULL, 1, 1, 'Total Ekuitas', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(15, '3100', 'Modal Dasar', 'equity', NULL, 2, 1, 'Modal Dasar Koperasi', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(16, '3110', 'Modal Setor', 'equity', NULL, 3, 1, 'Modal yang Telah Disetor', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(17, '3200', 'SHU', 'equity', NULL, 2, 1, 'Sisa Hasil Usaha', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(18, '3210', 'SHU Tahun Berjalan', 'equity', NULL, 3, 1, 'SHU Tahun Berjalan', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(19, '4000', 'PENDAPATAN', 'revenue', NULL, 1, 1, 'Total Pendapatan', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(20, '4100', 'Pendapatan Bunga', 'revenue', NULL, 2, 1, 'Pendapatan dari Bunga Pinjaman', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(21, '4200', 'Pendapatan Layanan', 'revenue', NULL, 2, 1, 'Pendapatan dari Layanan', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(22, '5000', 'BEBAN', 'expense', NULL, 1, 1, 'Total Beban', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(23, '5100', 'Beban Bunga', 'expense', NULL, 2, 1, 'Beban Bunga Simpanan', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(24, '5200', 'Beban Operasional', 'expense', NULL, 2, 1, 'Beban Operasional', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(25, '5210', 'Gaji dan Upah', 'expense', NULL, 3, 1, 'Gaji Karyawan', '2026-03-24 18:46:28', '2026-03-24 18:46:28'),
(26, '5220', 'Beban Administrasi', 'expense', NULL, 3, 1, 'Beban Administrasi Umum', '2026-03-24 18:46:28', '2026-03-24 18:46:28');

-- --------------------------------------------------------

--
-- Struktur dari tabel `collection_verification`
--

CREATE TABLE `collection_verification` (
  `id` int(11) NOT NULL,
  `collector_id` int(11) NOT NULL,
  `verification_date` date NOT NULL,
  `total_collected` decimal(15,2) NOT NULL,
  `total_deposited` decimal(15,2) NOT NULL,
  `difference_amount` decimal(15,2) DEFAULT 0.00,
  `deposit_reference` varchar(100) DEFAULT NULL,
  `deposit_bank` varchar(50) DEFAULT NULL,
  `deposit_date` datetime DEFAULT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `verification_status` enum('pending','verified','rejected','needs_correction') NOT NULL DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `collector_performance`
--

CREATE TABLE `collector_performance` (
  `id` int(11) NOT NULL,
  `collector_id` int(11) NOT NULL,
  `period_month` date NOT NULL,
  `target_collection` decimal(15,2) NOT NULL,
  `actual_collection` decimal(15,2) NOT NULL,
  `target_new_members` int(11) DEFAULT 0,
  `actual_new_members` int(11) DEFAULT 0,
  `target_visits` int(11) DEFAULT 0,
  `actual_visits` int(11) DEFAULT 0,
  `successful_visits` int(11) DEFAULT 0,
  `problem_loans_handled` int(11) DEFAULT 0,
  `recovery_amount` decimal(15,2) DEFAULT 0.00,
  `commission_rate` decimal(5,2) DEFAULT 0.00,
  `commission_earned` decimal(15,2) DEFAULT 0.00,
  `bonus` decimal(15,2) DEFAULT 0.00,
  `performance_score` decimal(5,2) DEFAULT 0.00,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `daily_consumption_expenses`
--

CREATE TABLE `daily_consumption_expenses` (
  `id` int(11) NOT NULL,
  `expense_date` date NOT NULL,
  `employee_id` int(11) NOT NULL,
  `meal_allowance` tinyint(1) DEFAULT 0,
  `meal_amount` decimal(15,2) DEFAULT 0.00,
  `soap_supplies` tinyint(1) DEFAULT 0,
  `soap_amount` decimal(15,2) DEFAULT 0.00,
  `other_supplies` text DEFAULT NULL,
  `other_amount` decimal(15,2) DEFAULT 0.00,
  `total_amount` decimal(15,2) GENERATED ALWAYS AS (`meal_amount` + `soap_amount` + `other_amount`) STORED,
  `notes` text DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `daily_transactions`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `daily_transactions` (
`transaction_date` date
,`total_transactions` bigint(21)
,`total_credits` decimal(37,2)
,`total_debits` decimal(37,2)
,`net_amount` decimal(37,2)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `digital_payments`
--

CREATE TABLE `digital_payments` (
  `id` int(11) NOT NULL,
  `payment_transaction_id` int(11) NOT NULL,
  `gateway_provider` enum('qris','gopay','ovo','dana','linkaja','shopeepay') NOT NULL,
  `qr_code` varchar(500) DEFAULT NULL,
  `qr_expiry` timestamp NULL DEFAULT NULL,
  `payment_url` varchar(500) DEFAULT NULL,
  `callback_url` varchar(500) DEFAULT NULL,
  `gateway_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gateway_response`)),
  `settlement_status` enum('pending','settled','failed') DEFAULT 'pending',
  `settlement_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `employees`
--

CREATE TABLE `employees` (
  `id` int(11) NOT NULL,
  `employee_number` varchar(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `nik` varchar(16) DEFAULT NULL,
  `full_name` varchar(100) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `birth_place` varchar(100) DEFAULT NULL,
  `gender` enum('L','P') DEFAULT NULL,
  `address` text DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `join_date` date NOT NULL,
  `position` varchar(50) DEFAULT NULL,
  `department` varchar(50) DEFAULT NULL,
  `employment_type` enum('tetap','kontrak','harian','magang') NOT NULL DEFAULT 'tetap',
  `salary_grade` varchar(20) DEFAULT NULL,
  `bank_name` varchar(50) DEFAULT NULL,
  `bank_account` varchar(50) DEFAULT NULL,
  `bpjs_kesehatan` varchar(20) DEFAULT NULL,
  `bpjs_ketenagakerjaan` varchar(20) DEFAULT NULL,
  `npwp` varchar(20) DEFAULT NULL,
  `marital_status` enum('single','married','divorced','widowed') DEFAULT NULL,
  `spouse_name` varchar(100) DEFAULT NULL,
  `spouse_occupation` varchar(100) DEFAULT NULL,
  `number_of_children` int(3) DEFAULT 0,
  `education_level` varchar(50) DEFAULT NULL,
  `major` varchar(100) DEFAULT NULL,
  `institution` varchar(100) DEFAULT NULL,
  `graduation_year` int(4) DEFAULT NULL,
  `emergency_contact_name` varchar(100) DEFAULT NULL,
  `emergency_contact_phone` varchar(20) DEFAULT NULL,
  `emergency_contact_relation` varchar(50) DEFAULT NULL,
  `status` enum('active','inactive','resigned','terminated') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `province_id` int(11) DEFAULT NULL,
  `regency_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `village_id` int(11) DEFAULT NULL,
  `detail_address` text DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `employee_complete_address`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `employee_complete_address` (
`id` int(11)
,`full_name` varchar(100)
,`detail_address` text
,`postal_code` varchar(10)
,`province_name` varchar(100)
,`regency_name` varchar(100)
,`district_name` varchar(100)
,`village_name` varchar(100)
,`complete_address` mediumtext
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `employee_experience`
--

CREATE TABLE `employee_experience` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `company_name` varchar(100) NOT NULL,
  `position` varchar(50) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `employee_family`
--

CREATE TABLE `employee_family` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `relationship` varchar(50) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `expense_categories`
--

CREATE TABLE `expense_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `budget_limit` decimal(15,2) DEFAULT 0.00,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `expense_categories`
--

INSERT INTO `expense_categories` (`id`, `name`, `description`, `parent_id`, `budget_limit`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Biaya Operasional Kantor', 'Biaya-biaya untuk operasional kantor sehari-hari', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(2, 'Biaya Konsumsi', 'Biaya makanan dan minuman untuk karyawan', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(3, 'Biaya Listrik & Air', 'Pembayaran listrik, air, dan utilitas lainnya', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(4, 'Biaya Telekomunikasi', 'Biaya telepon, internet, dan komunikasi', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(5, 'Biaya Transportasi', 'Biaya transportasi dan kendaraan operasional', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(6, 'Biaya Pemeliharaan', 'Biaya maintenance dan perbaikan', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(7, 'Biaya Marketing', 'Biaya promosi dan marketing', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(8, 'Biaya Administrasi', 'Biaya administrasi dan perijinan', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(9, 'Biaya Event', 'Biaya acara dan kegiatan khusus', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(10, 'Biaya Lain-lain', 'Biaya-biaya lainnya', NULL, 0.00, 1, '2026-03-24 05:28:01', '2026-03-24 05:28:01');

-- --------------------------------------------------------

--
-- Struktur dari tabel `financial_reports`
--

CREATE TABLE `financial_reports` (
  `id` int(11) NOT NULL,
  `report_type` enum('balance_sheet','income_statement','cash_flow','trial_balance') NOT NULL,
  `report_date` date NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `report_data` longtext DEFAULT NULL,
  `status` enum('draft','final') DEFAULT 'draft',
  `generated_by` int(11) NOT NULL,
  `generated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `general_ledger`
--

CREATE TABLE `general_ledger` (
  `id` int(11) NOT NULL,
  `transaction_date` date NOT NULL,
  `account_code` varchar(20) NOT NULL,
  `debit_amount` decimal(15,2) DEFAULT 0.00,
  `credit_amount` decimal(15,2) DEFAULT 0.00,
  `balance` decimal(15,2) DEFAULT 0.00,
  `transaction_type` varchar(50) NOT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `reference_table` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `gps_tracking`
--

CREATE TABLE `gps_tracking` (
  `id` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `accuracy` decimal(5,2) DEFAULT NULL,
  `altitude` decimal(8,2) DEFAULT NULL,
  `speed` decimal(5,2) DEFAULT NULL,
  `heading` decimal(5,2) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `interest_methods`
--

CREATE TABLE `interest_methods` (
  `id` int(11) NOT NULL,
  `method_name` varchar(50) NOT NULL,
  `method_code` varchar(20) NOT NULL,
  `description` text DEFAULT NULL,
  `formula` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `interest_methods`
--

INSERT INTO `interest_methods` (`id`, `method_name`, `method_code`, `description`, `formula`, `is_active`, `created_at`) VALUES
(1, 'Flat', 'FLAT', 'Bunga tetap selama periode pinjaman', 'interest = principal * rate * period', 1, '2026-03-24 18:46:28'),
(2, 'Anuitas', 'ANUITAS', 'Angsuran tetap dengan bunga menurun', 'installment = (principal * rate * (1+rate)^n) / ((1+rate)^n - 1)', 1, '2026-03-24 18:46:28'),
(3, 'Menurun', 'MENURUN', 'Bunga menurun berdasarkan sisa pinjaman', 'interest = remaining_balance * rate', 1, '2026-03-24 18:46:28');

-- --------------------------------------------------------

--
-- Struktur dari tabel `inventory_borrowing`
--

CREATE TABLE `inventory_borrowing` (
  `id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `borrowed_by` int(11) NOT NULL,
  `borrow_date` datetime NOT NULL,
  `expected_return_date` datetime DEFAULT NULL,
  `actual_return_date` datetime DEFAULT NULL,
  `purpose` text DEFAULT NULL,
  `condition_when_borrowed` enum('excellent','good','fair','poor') DEFAULT 'good',
  `condition_when_returned` enum('excellent','good','fair','poor') DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `status` enum('pending','approved','borrowed','returned','overdue') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `inventory_categories`
--

CREATE TABLE `inventory_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `depreciation_rate` decimal(5,2) DEFAULT 0.00,
  `useful_life_years` int(3) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `inventory_categories`
--

INSERT INTO `inventory_categories` (`id`, `name`, `description`, `parent_id`, `depreciation_rate`, `useful_life_years`, `created_at`, `updated_at`) VALUES
(1, 'Kendaraan', 'Sepeda motor, mobil, dan kendaraan operasional', NULL, 20.00, 5, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(2, 'Komputer & Laptop', 'PC, laptop, dan perangkat komputasi', NULL, 33.30, 3, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(3, 'Furniture', 'Meja, kursi, dan furniture kantor', NULL, 10.00, 10, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(4, 'Elektronik', 'Printer, scanner, dan elektronik kantor', NULL, 25.00, 4, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(5, 'Alat Tulis', 'Peralatan tulis dan kantor kecil', NULL, 0.00, 0, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(6, 'Bangunan', 'Gedung dan fasilitas bangunan', NULL, 5.00, 20, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(7, 'Tanah', 'Tanah dan properti', NULL, 0.00, 0, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(8, 'Lain-lain', 'Inventaris lainnya', NULL, 10.00, 5, '2026-03-24 05:28:01', '2026-03-24 05:28:01');

-- --------------------------------------------------------

--
-- Struktur dari tabel `inventory_items`
--

CREATE TABLE `inventory_items` (
  `id` int(11) NOT NULL,
  `item_code` varchar(50) NOT NULL,
  `category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `model` varchar(50) DEFAULT NULL,
  `serial_number` varchar(50) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `purchase_price` decimal(15,2) DEFAULT NULL,
  `current_value` decimal(15,2) DEFAULT NULL,
  `depreciation_rate` decimal(5,2) DEFAULT 0.00,
  `useful_life_years` int(3) DEFAULT 0,
  `item_condition` enum('excellent','good','fair','poor') DEFAULT 'good',
  `location` varchar(100) DEFAULT NULL,
  `status` enum('available','in_use','maintenance','retired','lost') NOT NULL DEFAULT 'available',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `inventory_maintenance`
--

CREATE TABLE `inventory_maintenance` (
  `id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `maintenance_date` date NOT NULL,
  `maintenance_type` enum('preventive','corrective','emergency') NOT NULL,
  `description` text NOT NULL,
  `cost` decimal(15,2) DEFAULT 0.00,
  `performed_by` varchar(100) DEFAULT NULL,
  `next_maintenance_date` date DEFAULT NULL,
  `status` enum('scheduled','in_progress','completed','cancelled') NOT NULL DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `journal_entries`
--

CREATE TABLE `journal_entries` (
  `id` int(11) NOT NULL,
  `journal_number` varchar(30) NOT NULL,
  `transaction_date` date NOT NULL,
  `description` text NOT NULL,
  `total_debit` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_credit` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('draft','posted','cancelled') DEFAULT 'draft',
  `posted_by` int(11) DEFAULT NULL,
  `posted_at` timestamp NULL DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `journal_entry_lines`
--

CREATE TABLE `journal_entry_lines` (
  `id` int(11) NOT NULL,
  `journal_id` int(11) NOT NULL,
  `account_code` varchar(20) NOT NULL,
  `debit_amount` decimal(15,2) DEFAULT 0.00,
  `credit_amount` decimal(15,2) DEFAULT 0.00,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `ksp_employee_people_view`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `ksp_employee_people_view` (
`employee_id` int(11)
,`nik` varchar(16)
,`full_name` varchar(100)
,`birth_date` date
,`birth_place` varchar(100)
,`gender` enum('L','P')
,`address` text
,`phone` varchar(20)
,`email` varchar(100)
,`employee_position` varchar(50)
,`department` varchar(50)
,`join_date` date
,`status` enum('active','inactive','resigned','terminated')
,`people_nama` varchar(255)
,`people_email` varchar(255)
,`people_phone` varchar(20)
,`people_status` enum('active','inactive','pending')
,`nama_lengkap` varchar(255)
,`tempat_lahir` varchar(100)
,`tanggal_lahir` date
,`gender_id` int(11)
,`marital_status_id` int(11)
,`religion_id` int(11)
,`ethnicity_id` int(11)
,`blood_type_id` int(11)
,`kewarganegaraan` varchar(100)
,`risk_score` enum('low','medium','high')
,`kyc_completeness` tinyint(3) unsigned
,`identity_verified` tinyint(1)
,`company` varchar(255)
,`employment_position` varchar(100)
,`industry` varchar(100)
,`start_date` date
,`end_date` date
,`salary` decimal(15,2)
,`street_address` varchar(255)
,`alamat_detil` varchar(255)
,`province_id` int(11)
,`regency_id` int(11)
,`district_id` int(11)
,`village_id` int(11)
,`postal_code` varchar(20)
,`latitude` decimal(10,8)
,`longitude` decimal(11,8)
,`address_verified` tinyint(1)
,`complete_address` text
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `ksp_member_people_view`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `ksp_member_people_view` (
`member_id` int(11)
,`member_number` varchar(20)
,`user_id` int(11)
,`nik` varchar(16)
,`full_name` varchar(100)
,`birth_date` date
,`birth_place` varchar(100)
,`gender` enum('L','P')
,`address` text
,`phone` varchar(20)
,`email` varchar(100)
,`join_date` date
,`status` enum('active','inactive','blacklisted')
,`people_nama` varchar(255)
,`people_email` varchar(255)
,`people_phone` varchar(20)
,`people_status` enum('active','inactive','pending')
,`nama_lengkap` varchar(255)
,`tempat_lahir` varchar(100)
,`tanggal_lahir` date
,`gender_id` int(11)
,`marital_status_id` int(11)
,`religion_id` int(11)
,`ethnicity_id` int(11)
,`blood_type_id` int(11)
,`kewarganegaraan` varchar(100)
,`risk_score` enum('low','medium','high')
,`kyc_completeness` tinyint(3) unsigned
,`identity_verified` tinyint(1)
,`street_address` varchar(255)
,`alamat_detil` varchar(255)
,`province_id` int(11)
,`regency_id` int(11)
,`district_id` int(11)
,`village_id` int(11)
,`postal_code` varchar(20)
,`latitude` decimal(10,8)
,`longitude` decimal(11,8)
,`address_verified` tinyint(1)
,`complete_address` text
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `leave_requests`
--

CREATE TABLE `leave_requests` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `leave_type` enum('annual','sick','maternity','paternity','unpaid','other') NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `total_days` decimal(5,2) NOT NULL,
  `reason` text DEFAULT NULL,
  `replacement_employee_id` int(11) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `purpose` varchar(255) DEFAULT NULL,
  `collateral` text DEFAULT NULL,
  `status` enum('pending','approved','rejected','active','completed','defaulted') NOT NULL DEFAULT 'pending',
  `application_date` date NOT NULL,
  `approval_date` date DEFAULT NULL,
  `disbursement_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `collector_id` int(11) DEFAULT NULL,
  `assessment_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `loans`
--

INSERT INTO `loans` (`id`, `member_id`, `loan_number`, `loan_amount`, `interest_rate`, `loan_term`, `purpose`, `collateral`, `status`, `application_date`, `approval_date`, `disbursement_date`, `due_date`, `approved_by`, `created_at`, `updated_at`, `collector_id`, `assessment_id`) VALUES
(1, 1, 'L001', 5000000.00, 12.00, 12, 'Modal usaha kecil', NULL, 'active', '2024-02-01', '2024-02-05', '2024-02-06', '2025-02-05', 2, '2026-03-22 03:15:36', '2026-03-22 03:15:36', NULL, NULL),
(2, 2, 'L002', 3000000.00, 10.00, 6, 'Biaya pendidikan', NULL, 'active', '2024-03-01', '2024-03-03', '2024-03-04', '2024-09-03', 2, '2026-03-22 03:15:36', '2026-03-22 03:15:36', NULL, NULL);

--
-- Trigger `loans`
--
DELIMITER $$
CREATE TRIGGER `audit_loans_insert` AFTER INSERT ON `loans` FOR EACH ROW BEGIN
    INSERT INTO audit_trail (user_id, action, table_name, record_id, new_values)
    VALUES (NEW.approved_by, 'INSERT', 'loans', NEW.id, JSON_OBJECT(
        'loan_number', NEW.loan_number,
        'member_id', NEW.member_id,
        'loan_amount', NEW.loan_amount,
        'status', NEW.status
    ));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `loan_assessments`
--

CREATE TABLE `loan_assessments` (
  `id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `assessment_date` date NOT NULL,
  `requested_amount` decimal(15,2) NOT NULL,
  `purpose` varchar(255) NOT NULL,
  `assessment_type` enum('new','topup','restructure') NOT NULL,
  `monthly_income` decimal(15,2) DEFAULT NULL,
  `monthly_expenses` decimal(15,2) DEFAULT NULL,
  `other_loans` decimal(15,2) DEFAULT 0.00,
  `collateral_value` decimal(15,2) DEFAULT 0.00,
  `credit_score` int(3) DEFAULT 0,
  `risk_level` enum('low','medium','high') NOT NULL,
  `recommended_amount` decimal(15,2) DEFAULT NULL,
  `recommended_interest_rate` decimal(5,2) DEFAULT NULL,
  `recommended_term_months` int(11) DEFAULT NULL,
  `assessment_result` enum('approved','rejected','needs_review') NOT NULL,
  `rejection_reason` text DEFAULT NULL,
  `assessed_by` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `payment_date` date NOT NULL,
  `payment_method` enum('cash','transfer','bank_deposit') NOT NULL DEFAULT 'cash',
  `received_by` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `collected_by` int(11) DEFAULT NULL,
  `verification_status` enum('pending','verified','rejected') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `loan_payments`
--

INSERT INTO `loan_payments` (`id`, `loan_id`, `payment_number`, `amount`, `principal_amount`, `interest_amount`, `payment_date`, `payment_method`, `received_by`, `notes`, `created_at`, `collected_by`, `verification_status`) VALUES
(1, 1, 1, 466666.67, 416666.67, 50000.00, '2024-03-06', 'cash', 3, 'Angsuran bulan Maret', '2026-03-22 03:15:36', NULL, 'pending'),
(2, 2, 1, 516666.67, 500000.00, 16666.67, '2024-04-04', 'transfer', 3, 'Angsuran bulan April', '2026-03-22 03:15:36', NULL, 'pending');

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
-- Struktur dari tabel `loan_promissory_notes`
--

CREATE TABLE `loan_promissory_notes` (
  `id` int(11) NOT NULL,
  `loan_id` int(11) NOT NULL,
  `promissory_number` varchar(50) NOT NULL,
  `promissory_date` date NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `interest_rate` decimal(5,2) NOT NULL,
  `loan_term_months` int(11) NOT NULL,
  `monthly_installment` decimal(15,2) NOT NULL,
  `due_date` date NOT NULL,
  `guarantor_name` varchar(100) DEFAULT NULL,
  `guarantor_address` text DEFAULT NULL,
  `guarantor_phone` varchar(20) DEFAULT NULL,
  `guarantor_nik` varchar(16) DEFAULT NULL,
  `collateral_description` text DEFAULT NULL,
  `collateral_value` decimal(15,2) DEFAULT 0.00,
  `witness_name` varchar(100) DEFAULT NULL,
  `witness_position` varchar(50) DEFAULT NULL,
  `status` enum('active','completed','defaulted','cancelled') NOT NULL DEFAULT 'active',
  `signed_by_member` tinyint(1) DEFAULT 0,
  `signed_by_witness` tinyint(1) DEFAULT 0,
  `signed_by_officer` tinyint(1) DEFAULT 0,
  `attachment_url` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `loan_schedules`
--

CREATE TABLE `loan_schedules` (
  `id` int(11) NOT NULL,
  `loan_id` int(11) NOT NULL,
  `installment_number` int(11) NOT NULL,
  `due_date` date NOT NULL,
  `principal_amount` decimal(15,2) NOT NULL,
  `interest_amount` decimal(15,2) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `principal_paid` decimal(15,2) DEFAULT 0.00,
  `interest_paid` decimal(15,2) DEFAULT 0.00,
  `total_paid` decimal(15,2) DEFAULT 0.00,
  `outstanding_balance` decimal(15,2) NOT NULL,
  `status` enum('pending','partial','paid','overdue') DEFAULT 'pending',
  `paid_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `location_history`
--

CREATE TABLE `location_history` (
  `id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `person_type` enum('member','employee','staff') NOT NULL,
  `date` date NOT NULL,
  `total_locations` int(11) DEFAULT 0,
  `first_location_time` time DEFAULT NULL,
  `last_location_time` time DEFAULT NULL,
  `total_distance_km` decimal(8,2) DEFAULT NULL,
  `avg_accuracy` decimal(5,2) DEFAULT NULL,
  `location_summary` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`location_summary`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `attempt_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `login_attempts`
--

INSERT INTO `login_attempts` (`id`, `username`, `ip_address`, `user_agent`, `success`, `attempt_time`) VALUES
(3, 'bos', '127.0.0.1', NULL, 0, '2026-03-22 03:27:22'),
(4, 'bos', '127.0.0.1', NULL, 0, '2026-03-22 03:27:52'),
(5, 'bos', '127.0.0.1', NULL, 0, '2026-03-22 03:28:06'),
(6, 'wrong', '::1', NULL, 0, '2026-03-22 03:29:01'),
(7, 'wrong', '::1', NULL, 0, '2026-03-22 03:50:05'),
(8, 'wrong', '::1', NULL, 0, '2026-03-22 03:52:51'),
(9, 'wrong', '::1', NULL, 0, '2026-03-22 03:53:40'),
(10, 'wrong', '::1', NULL, 0, '2026-03-22 03:54:35'),
(11, '<script>', '::1', NULL, 0, '2026-03-22 03:54:59'),
(12, 'bos', '127.0.0.1', NULL, 0, '2026-03-22 04:03:19');

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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `collector_id` int(11) DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `regency_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `village_id` int(11) DEFAULT NULL,
  `detail_address` text DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `members`
--

INSERT INTO `members` (`id`, `user_id`, `member_number`, `nik`, `full_name`, `birth_date`, `birth_place`, `gender`, `address`, `phone`, `email`, `join_date`, `status`, `created_at`, `updated_at`, `collector_id`, `province_id`, `regency_id`, `district_id`, `village_id`, `detail_address`, `postal_code`) VALUES
(1, 4, 'M001', '3201011234560001', 'Ahmad Wijaya', '1985-05-15', 'Jakarta', 'L', 'Jl. Merdeka No. 123, Jakarta Pusat', '08123456789', 'member001@ksplamgabejaya.co.id', '2024-01-15', 'active', '2026-03-22 03:15:36', '2026-03-24 19:22:19', NULL, 11, 1107, 1107061, 1107062001, 'Jl. Test Address No. 123', '23681'),
(2, 5, 'M002', '3201011234560002', 'Siti Nurhaliza', '1990-08-22', 'Bandung', 'P', 'Jl. Sudirman No. 456, Bandung', '08234567890', 'member002@ksplamgabejaya.co.id', '2024-02-20', 'active', '2026-03-22 03:15:36', '2026-03-22 03:15:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 1, 'MEM001', '1234567890123456', 'Anggota Satu', '1990-01-01', NULL, 'L', 'Alamat Test 1', '08123456789', 'anggota1@example.com', '2024-01-01', 'active', '2026-03-24 04:38:36', '2026-03-24 04:38:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

--
-- Trigger `members`
--
DELIMITER $$
CREATE TRIGGER `audit_members_insert` AFTER INSERT ON `members` FOR EACH ROW BEGIN
    INSERT INTO audit_trail (user_id, action, table_name, record_id, new_values)
    VALUES (NEW.user_id, 'INSERT', 'members', NEW.id, JSON_OBJECT(
        'member_number', NEW.member_number,
        'full_name', NEW.full_name,
        'nik', NEW.nik,
        'status', NEW.status
    ));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `audit_members_update` AFTER UPDATE ON `members` FOR EACH ROW BEGIN
    INSERT INTO audit_trail (user_id, action, table_name, record_id, old_values, new_values)
    VALUES (NEW.user_id, 'UPDATE', 'members', NEW.id, 
        JSON_OBJECT('full_name', OLD.full_name, 'status', OLD.status),
        JSON_OBJECT('full_name', NEW.full_name, 'status', NEW.status)
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `member_balances`
--

CREATE TABLE `member_balances` (
  `id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `total_savings` decimal(15,2) DEFAULT 0.00,
  `total_loans` decimal(15,2) DEFAULT 0.00,
  `available_balance` decimal(15,2) DEFAULT 0.00,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `member_complete_address`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `member_complete_address` (
`id` int(11)
,`member_number` varchar(20)
,`full_name` varchar(100)
,`detail_address` text
,`postal_code` varchar(10)
,`province_name` varchar(100)
,`regency_name` varchar(100)
,`district_name` varchar(100)
,`village_name` varchar(100)
,`complete_address` mediumtext
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `member_shu_distribution`
--

CREATE TABLE `member_shu_distribution` (
  `id` int(11) NOT NULL,
  `shu_calculation_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `base_amount` decimal(15,2) NOT NULL,
  `shu_share` decimal(15,2) NOT NULL,
  `distribution_status` enum('calculated','distributed','credited') DEFAULT 'calculated',
  `distributed_amount` decimal(15,2) DEFAULT 0.00,
  `distributed_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `operational_expenses`
--

CREATE TABLE `operational_expenses` (
  `id` int(11) NOT NULL,
  `expense_number` varchar(20) NOT NULL,
  `category_id` int(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `expense_date` date NOT NULL,
  `receipt_number` varchar(50) DEFAULT NULL,
  `supplier_name` varchar(100) DEFAULT NULL,
  `payment_method` enum('cash','transfer','card','credit') NOT NULL DEFAULT 'cash',
  `bank_account` varchar(50) DEFAULT NULL,
  `status` enum('draft','submitted','approved','rejected','paid') NOT NULL DEFAULT 'draft',
  `requested_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `overtime_records`
--

CREATE TABLE `overtime_records` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `overtime_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `hours` decimal(5,2) NOT NULL,
  `rate` decimal(5,2) NOT NULL DEFAULT 1.00,
  `amount` decimal(15,2) NOT NULL,
  `reason` text DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `payment_transactions`
--

CREATE TABLE `payment_transactions` (
  `id` int(11) NOT NULL,
  `transaction_number` varchar(30) NOT NULL,
  `member_id` int(11) NOT NULL,
  `loan_id` int(11) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `payment_type` enum('loan_payment','savings_deposit','loan_disbursement','withdrawal','fee','penalty') NOT NULL,
  `payment_method` enum('cash','bank_transfer','digital_wallet','check','payroll') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transaction_date` date NOT NULL,
  `status` enum('pending','completed','failed','cancelled') DEFAULT 'pending',
  `reference_number` varchar(100) DEFAULT NULL,
  `gateway_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gateway_data`)),
  `notes` text DEFAULT NULL,
  `processed_by` int(11) NOT NULL,
  `processed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `payroll_details`
--

CREATE TABLE `payroll_details` (
  `id` int(11) NOT NULL,
  `payroll_period_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `basic_salary` decimal(15,2) NOT NULL,
  `position_allowance` decimal(15,2) DEFAULT 0.00,
  `transport_allowance` decimal(15,2) DEFAULT 0.00,
  `meal_allowance` decimal(15,2) DEFAULT 0.00,
  `communication_allowance` decimal(15,2) DEFAULT 0.00,
  `housing_allowance` decimal(15,2) DEFAULT 0.00,
  `health_allowance` decimal(15,2) DEFAULT 0.00,
  `other_allowance` decimal(15,2) DEFAULT 0.00,
  `overtime_hours` decimal(5,2) DEFAULT 0.00,
  `overtime_rate` decimal(5,2) DEFAULT 0.00,
  `overtime_amount` decimal(15,2) DEFAULT 0.00,
  `bonus` decimal(15,2) DEFAULT 0.00,
  `commission` decimal(15,2) DEFAULT 0.00,
  `gross_salary` decimal(15,2) NOT NULL,
  `bpjs_kesehatan_deduction` decimal(15,2) DEFAULT 0.00,
  `bpjs_ketenagakerjaan_deduction` decimal(15,2) DEFAULT 0.00,
  `pph21_deduction` decimal(15,2) DEFAULT 0.00,
  `other_deductions` decimal(15,2) DEFAULT 0.00,
  `total_deductions` decimal(15,2) GENERATED ALWAYS AS (`bpjs_kesehatan_deduction` + `bpjs_ketenagakerjaan_deduction` + `pph21_deduction` + `other_deductions`) STORED,
  `net_salary` decimal(15,2) GENERATED ALWAYS AS (`gross_salary` - `total_deductions`) STORED,
  `bank_name` varchar(50) DEFAULT NULL,
  `bank_account` varchar(50) DEFAULT NULL,
  `transfer_reference` varchar(100) DEFAULT NULL,
  `status` enum('calculated','approved','paid','failed') NOT NULL DEFAULT 'calculated',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `payroll_periods`
--

CREATE TABLE `payroll_periods` (
  `id` int(11) NOT NULL,
  `period_name` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `payment_date` date DEFAULT NULL,
  `status` enum('draft','calculated','approved','paid') NOT NULL DEFAULT 'draft',
  `total_employees` int(11) DEFAULT 0,
  `total_gross_salary` decimal(15,2) DEFAULT 0.00,
  `total_deductions` decimal(15,2) DEFAULT 0.00,
  `total_net_salary` decimal(15,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `route_execution`
--

CREATE TABLE `route_execution` (
  `id` int(11) NOT NULL,
  `route_plan_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `person_type` enum('employee','staff') NOT NULL,
  `start_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `end_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `actual_distance_km` decimal(8,2) DEFAULT NULL,
  `actual_duration_minutes` int(11) DEFAULT NULL,
  `completion_percentage` decimal(5,2) DEFAULT NULL,
  `status` enum('started','in_progress','completed','failed') DEFAULT 'started',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `route_plans`
--

CREATE TABLE `route_plans` (
  `id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `person_type` enum('employee','staff') NOT NULL,
  `route_name` varchar(100) NOT NULL,
  `route_type` enum('collection','visit','delivery','patrol') NOT NULL,
  `start_latitude` decimal(10,8) NOT NULL,
  `start_longitude` decimal(11,8) NOT NULL,
  `end_latitude` decimal(10,8) NOT NULL,
  `end_longitude` decimal(11,8) NOT NULL,
  `waypoints` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`waypoints`)),
  `estimated_distance_km` decimal(8,2) DEFAULT NULL,
  `estimated_duration_minutes` int(11) DEFAULT NULL,
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `status` enum('planned','active','completed','cancelled') DEFAULT 'planned',
  `planned_date` date DEFAULT NULL,
  `planned_time` time DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `salary_structure`
--

CREATE TABLE `salary_structure` (
  `id` int(11) NOT NULL,
  `grade` varchar(20) NOT NULL,
  `basic_salary` decimal(15,2) NOT NULL,
  `position_allowance` decimal(15,2) DEFAULT 0.00,
  `transport_allowance` decimal(15,2) DEFAULT 0.00,
  `meal_allowance` decimal(15,2) DEFAULT 0.00,
  `communication_allowance` decimal(15,2) DEFAULT 0.00,
  `housing_allowance` decimal(15,2) DEFAULT 0.00,
  `health_allowance` decimal(15,2) DEFAULT 0.00,
  `other_allowance` decimal(15,2) DEFAULT 0.00,
  `total_allowance` decimal(15,2) GENERATED ALWAYS AS (`position_allowance` + `transport_allowance` + `meal_allowance` + `communication_allowance` + `housing_allowance` + `health_allowance` + `other_allowance`) STORED,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `salary_structure`
--

INSERT INTO `salary_structure` (`id`, `grade`, `basic_salary`, `position_allowance`, `transport_allowance`, `meal_allowance`, `communication_allowance`, `housing_allowance`, `health_allowance`, `other_allowance`, `created_at`, `updated_at`) VALUES
(1, 'GA', 3000000.00, 500000.00, 300000.00, 400000.00, 0.00, 0.00, 0.00, 0.00, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(2, 'GB', 4000000.00, 750000.00, 400000.00, 500000.00, 0.00, 0.00, 0.00, 0.00, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(3, 'GC', 5000000.00, 1000000.00, 500000.00, 600000.00, 0.00, 0.00, 0.00, 0.00, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(4, 'GD', 6000000.00, 1250000.00, 600000.00, 700000.00, 0.00, 0.00, 0.00, 0.00, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(5, 'GE', 7500000.00, 1500000.00, 750000.00, 800000.00, 0.00, 0.00, 0.00, 0.00, '2026-03-24 05:28:01', '2026-03-24 05:28:01'),
(6, 'GF', 10000000.00, 2000000.00, 1000000.00, 1000000.00, 0.00, 0.00, 0.00, 0.00, '2026-03-24 05:28:01', '2026-03-24 05:28:01');

-- --------------------------------------------------------

--
-- Struktur dari tabel `savings`
--

CREATE TABLE `savings` (
  `id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `savings_type` enum('wajib','pokok','sukarela') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transaction_date` date NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `savings`
--

INSERT INTO `savings` (`id`, `member_id`, `savings_type`, `amount`, `transaction_date`, `description`, `created_by`, `created_at`) VALUES
(1, 1, 'wajib', 500000.00, '2024-01-15', 'Setoran awal simpanan wajib', 1, '2026-03-22 03:15:36'),
(2, 1, 'sukarela', 1000000.00, '2024-01-15', 'Setoran awal simpanan sukarela', 1, '2026-03-22 03:15:36'),
(3, 2, 'wajib', 500000.00, '2024-02-20', 'Setoran awal simpanan wajib', 1, '2026-03-22 03:15:36'),
(4, 2, 'sukarela', 750000.00, '2024-02-20', 'Setoran awal simpanan sukarela', 1, '2026-03-22 03:15:36'),
(5, 1, 'sukarela', 100000.00, '2024-03-01', 'Setoran tambahan', 1, '2026-03-22 03:15:36'),
(6, 2, 'sukarela', 200000.00, '2024-03-05', 'Setoran tambahan', 1, '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `schedule_details`
--

CREATE TABLE `schedule_details` (
  `id` int(11) NOT NULL,
  `schedule_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `work_date` date NOT NULL,
  `day_type` enum('regular','weekend','holiday') NOT NULL DEFAULT 'regular',
  `shift_start` time DEFAULT NULL,
  `shift_end` time DEFAULT NULL,
  `break_start` time DEFAULT NULL,
  `break_end` time DEFAULT NULL,
  `work_hours` decimal(5,2) DEFAULT 0.00,
  `is_working_day` tinyint(1) DEFAULT 1,
  `task_description` text DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `status` enum('scheduled','present','absent','late','sick','leave') NOT NULL DEFAULT 'scheduled',
  `check_in_time` time DEFAULT NULL,
  `check_out_time` time DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `shu_calculations`
--

CREATE TABLE `shu_calculations` (
  `id` int(11) NOT NULL,
  `calculation_year` year(4) NOT NULL,
  `total_revenue` decimal(15,2) NOT NULL,
  `total_expense` decimal(15,2) NOT NULL,
  `net_profit` decimal(15,2) NOT NULL,
  `shu_amount` decimal(15,2) NOT NULL,
  `member_share_percentage` decimal(5,2) DEFAULT 85.00,
  `reserve_percentage` decimal(5,2) DEFAULT 10.00,
  `staff_share_percentage` decimal(5,2) DEFAULT 5.00,
  `status` enum('draft','approved','distributed') DEFAULT 'draft',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `system_config`
--

CREATE TABLE `system_config` (
  `id` int(11) NOT NULL,
  `config_key` varchar(100) NOT NULL,
  `config_value` text NOT NULL,
  `config_type` enum('string','number','boolean','json') DEFAULT 'string',
  `description` text DEFAULT NULL,
  `is_editable` tinyint(1) DEFAULT 1,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `system_config`
--

INSERT INTO `system_config` (`id`, `config_key`, `config_value`, `config_type`, `description`, `is_editable`, `updated_by`, `updated_at`) VALUES
(1, 'interest_calculation_method', 'FLAT', 'string', 'Metode perhitungan bunga default', 1, NULL, '2026-03-24 18:46:28'),
(2, 'minimum_savings_wajib', '50000', 'number', 'Minimal simpanan wajib bulanan', 1, NULL, '2026-03-24 18:46:28'),
(3, 'minimum_savings_pokok', '100000', 'number', 'Minimal simpanan pokok', 1, NULL, '2026-03-24 18:46:28'),
(4, 'late_payment_penalty', '0.05', 'number', 'Persentase denda keterlambatan', 1, NULL, '2026-03-24 18:46:28'),
(5, 'max_loan_amount', '50000000', 'number', 'Maksimal jumlah pinjaman', 1, NULL, '2026-03-24 18:46:28'),
(6, 'loan_approval_required', 'true', 'boolean', 'Persetujuan pinjaman wajib', 1, NULL, '2026-03-24 18:46:28'),
(7, 'digital_payment_enabled', 'true', 'boolean', 'Pembayaran digital diaktifkan', 1, NULL, '2026-03-24 18:46:28'),
(8, 'audit_trail_enabled', 'true', 'boolean', 'Audit trail diaktifkan', 1, NULL, '2026-03-24 18:46:28');

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
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `transactions`
--

INSERT INTO `transactions` (`id`, `transaction_code`, `account_id`, `transaction_type`, `amount`, `description`, `reference_number`, `transaction_date`, `created_by`, `created_at`) VALUES
(1, 'TRX001', 1, 'credit', 500000.00, 'Setoran Awal Tabungan Wajib', 'SET001', '2024-01-15', 1, '2026-03-22 03:15:36'),
(2, 'TRX002', 2, 'credit', 1000000.00, 'Setoran Awal Tabungan Sukarela', 'SET002', '2024-01-15', 1, '2026-03-22 03:15:36'),
(3, 'TRX003', 3, 'credit', 500000.00, 'Setoran Awal Tabungan Wajib', 'SET003', '2024-02-20', 1, '2026-03-22 03:15:36'),
(4, 'TRX004', 4, 'credit', 750000.00, 'Setoran Awal Tabungan Sukarela', 'SET004', '2024-02-20', 1, '2026-03-22 03:15:36'),
(5, 'TRX005', 1, 'credit', 100000.00, 'Setoran Tambahan', 'SET005', '2024-03-01', 1, '2026-03-22 03:15:36'),
(6, 'TRX006', 2, 'credit', 200000.00, 'Setoran Tambahan', 'SET006', '2024-03-05', 1, '2026-03-22 03:15:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `transaction_locks`
--

CREATE TABLE `transaction_locks` (
  `id` int(11) NOT NULL,
  `lock_key` varchar(100) NOT NULL,
  `lock_type` enum('member','account','loan') NOT NULL,
  `lock_id` int(11) NOT NULL,
  `locked_by` int(11) NOT NULL,
  `locked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `role` enum('admin','manager','staff','member') NOT NULL DEFAULT 'member',
  `status` enum('active','inactive','suspended') NOT NULL DEFAULT 'active',
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `full_name`, `role`, `status`, `last_login`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'admin', 'admin@ksp.co.id', 'Administrator', 'admin', 'active', '2026-03-22 11:10:59', '2026-03-22 03:15:36', '2026-03-24 16:29:13'),
(2, 'manager', 'manager', 'manager@ksplamgabejaya.co.id', 'Manager KSP', 'manager', 'active', '2026-03-22 10:32:27', '2026-03-22 03:15:36', '2026-03-24 17:07:56'),
(3, 'staff', 'staff', 'staff@ksplamgabejaya.co.id', 'Staff KSP', 'staff', 'active', '2026-03-22 10:32:27', '2026-03-22 03:15:36', '2026-03-24 17:07:56'),
(4, 'member001', 'member001', 'member001@ksplamgabejaya.co.id', 'Ahmad Wijaya', 'member', 'active', '2026-03-22 10:32:27', '2026-03-22 03:15:36', '2026-03-24 17:07:56'),
(5, 'member002', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member002@ksplamgabejaya.co.id', 'Siti Nurhaliza', 'member', 'active', NULL, '2026-03-22 03:15:36', '2026-03-22 03:15:36'),
(7, 'bos', 'bos', 'bos@ksp.co.id', 'Bos Koperasi', 'admin', 'active', NULL, '2026-03-24 16:29:13', '2026-03-24 16:29:13'),
(8, 'teller', 'teller', 'teller@ksp.co.id', 'Petugas Teller', 'manager', 'active', NULL, '2026-03-24 16:29:13', '2026-03-24 16:29:13'),
(9, 'collector', 'collector', 'collector@ksp.co.id', 'Petugas Lapangan', 'staff', 'active', NULL, '2026-03-24 16:29:13', '2026-03-24 16:29:13'),
(10, 'nasabah', 'nasabah', 'nasabah@ksp.co.id', 'Nasabah Sample', 'member', 'active', NULL, '2026-03-24 16:29:13', '2026-03-24 16:29:13');

-- --------------------------------------------------------

--
-- Struktur dari tabel `work_schedules`
--

CREATE TABLE `work_schedules` (
  `id` int(11) NOT NULL,
  `schedule_name` varchar(100) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_template` tinyint(1) DEFAULT 0,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur untuk view `branch_complete_address`
--
DROP TABLE IF EXISTS `branch_complete_address`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `branch_complete_address`  AS SELECT `b`.`id` AS `id`, `b`.`branch_code` AS `branch_code`, `b`.`branch_name` AS `branch_name`, `b`.`branch_type` AS `branch_type`, `b`.`branch_status` AS `branch_status`, `b`.`is_active` AS `is_active`, `b`.`province_id` AS `province_id`, `b`.`regency_id` AS `regency_id`, `b`.`district_id` AS `district_id`, `b`.`village_id` AS `village_id`, `b`.`detail_address` AS `detail_address`, `b`.`house_number` AS `house_number`, `b`.`building_name` AS `building_name`, `b`.`floor_number` AS `floor_number`, `b`.`unit_number` AS `unit_number`, `b`.`rt_number` AS `rt_number`, `b`.`rw_number` AS `rw_number`, `b`.`complex_name` AS `complex_name`, `b`.`landmark_reference` AS `landmark_reference`, `b`.`postal_code` AS `postal_code`, `b`.`branch_phone` AS `branch_phone`, `b`.`branch_email` AS `branch_email`, `b`.`operating_hours` AS `operating_hours`, `b`.`coverage_area` AS `coverage_area`, `b`.`manager_id` AS `manager_id`, `b`.`opened_date` AS `opened_date`, `b`.`establishment_date` AS `establishment_date`, `b`.`npwp` AS `npwp`, `b`.`business_license` AS `business_license`, `b`.`last_inspection_date` AS `last_inspection_date`, `b`.`inspection_notes` AS `inspection_notes`, `b`.`created_at` AS `created_at`, `b`.`updated_at` AS `updated_at`, `p`.`name` AS `province_name`, `p`.`code` AS `province_code`, `r`.`name` AS `regency_name`, `r`.`code` AS `regency_code`, `d`.`name` AS `district_name`, `d`.`code` AS `district_code`, `v`.`name` AS `village_name`, `v`.`code` AS `village_code`, `s`.`street_name` AS `street_name`, `s`.`street_type` AS `street_type`, `pc`.`postal_code` AS `extended_postal_code`, `l`.`landmark_name` AS `landmark_name`, `l`.`landmark_type` AS `landmark_type`, `u`.`full_name` AS `manager_name`, `u`.`email` AS `manager_email`, concat(coalesce(`b`.`building_name`,''),' ',coalesce(`b`.`house_number`,''),' ',coalesce(`s`.`street_type`,''),' ',coalesce(`s`.`street_name`,''),', ',coalesce(`b`.`detail_address`,''),', ',coalesce(concat('RT ',`b`.`rt_number`),''),' ',coalesce(concat('RW ',`b`.`rw_number`),''),', ',coalesce(`b`.`complex_name`,''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`b`.`postal_code`,`v`.`postal_code`,`r`.`postal_code`,`pc`.`postal_code`,'')) AS `complete_address`, CASE WHEN `b`.`gps_coordinates` is not null THEN concat(st_x(`b`.`gps_coordinates`),', ',st_y(`b`.`gps_coordinates`)) ELSE NULL END AS `gps_coordinates_text`, `bt`.`branch_type` AS `type_name`, `bt`.`category` AS `type_category`, `bt`.`description` AS `type_description`, CASE WHEN `b`.`is_active` = 1 AND `b`.`branch_status` = 'headquarters' THEN 'Kantor Pusat - Aktif' WHEN `b`.`is_active` = 1 AND `b`.`branch_status` = 'main_branch' THEN 'Cabang Utama - Aktif' WHEN `b`.`is_active` = 1 AND `b`.`branch_status` = 'sub_branch' THEN 'Cabang - Aktif' WHEN `b`.`is_active` = 1 AND `b`.`branch_status` = 'service_unit' THEN 'Unit Layanan - Aktif' WHEN `b`.`is_active` = 1 AND `b`.`branch_status` = 'mobile_unit' THEN 'Unit Mobile - Aktif' WHEN `b`.`is_active` = 0 THEN 'Tidak Aktif' ELSE 'Status Unknown' END AS `status_description` FROM (((((((((`branches` `b` left join `alamat_db`.`provinces` `p` on(`b`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`b`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`b`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`b`.`village_id` = `v`.`id`)) left join `alamat_db`.`streets` `s` on(`s`.`village_id` = `v`.`id` and `b`.`detail_address` like concat('%',`s`.`street_name`,'%'))) left join `alamat_db`.`postal_codes_extended` `pc` on(`pc`.`village_id` = `v`.`id`)) left join `alamat_db`.`landmarks` `l` on(`l`.`village_id` = `v`.`id`)) left join `users` `u` on(`b`.`manager_id` = `u`.`id`)) left join `branch_types` `bt` on(`b`.`branch_type` = `bt`.`branch_type`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `daily_transactions`
--
DROP TABLE IF EXISTS `daily_transactions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `daily_transactions`  AS SELECT cast(`t`.`transaction_date` as date) AS `transaction_date`, count(0) AS `total_transactions`, sum(case when `t`.`transaction_type` = 'credit' then `t`.`amount` else 0 end) AS `total_credits`, sum(case when `t`.`transaction_type` = 'debit' then `t`.`amount` else 0 end) AS `total_debits`, sum(`t`.`amount`) AS `net_amount` FROM `transactions` AS `t` GROUP BY cast(`t`.`transaction_date` as date) ORDER BY cast(`t`.`transaction_date` as date) DESC ;

-- --------------------------------------------------------

--
-- Struktur untuk view `employee_complete_address`
--
DROP TABLE IF EXISTS `employee_complete_address`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employee_complete_address`  AS SELECT `e`.`id` AS `id`, `e`.`full_name` AS `full_name`, `e`.`detail_address` AS `detail_address`, `e`.`postal_code` AS `postal_code`, `p`.`name` AS `province_name`, `r`.`name` AS `regency_name`, `d`.`name` AS `district_name`, `v`.`name` AS `village_name`, concat(coalesce(`e`.`detail_address`,''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`e`.`postal_code`,`v`.`postal_code`,'')) AS `complete_address` FROM ((((`employees` `e` left join `alamat_db`.`provinces` `p` on(`e`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`e`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`e`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`e`.`village_id` = `v`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `ksp_employee_people_view`
--
DROP TABLE IF EXISTS `ksp_employee_people_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ksp_employee_people_view`  AS SELECT `e`.`id` AS `employee_id`, `e`.`nik` AS `nik`, `e`.`full_name` AS `full_name`, `e`.`birth_date` AS `birth_date`, `e`.`birth_place` AS `birth_place`, `e`.`gender` AS `gender`, `e`.`address` AS `address`, `e`.`phone` AS `phone`, `e`.`email` AS `email`, `e`.`position` AS `employee_position`, `e`.`department` AS `department`, `e`.`join_date` AS `join_date`, `e`.`status` AS `status`, `u`.`nama` AS `people_nama`, `u`.`email` AS `people_email`, `u`.`phone` AS `people_phone`, `u`.`status` AS `people_status`, `i`.`nama_lengkap` AS `nama_lengkap`, `i`.`tempat_lahir` AS `tempat_lahir`, `i`.`tanggal_lahir` AS `tanggal_lahir`, `i`.`gender_id` AS `gender_id`, `i`.`marital_status_id` AS `marital_status_id`, `i`.`religion_id` AS `religion_id`, `i`.`ethnicity_id` AS `ethnicity_id`, `i`.`blood_type_id` AS `blood_type_id`, `i`.`kewarganegaraan` AS `kewarganegaraan`, `i`.`risk_score` AS `risk_score`, `i`.`kyc_completeness` AS `kyc_completeness`, `i`.`verified` AS `identity_verified`, `emp`.`company` AS `company`, `emp`.`position` AS `employment_position`, `emp`.`industry` AS `industry`, `emp`.`start_date` AS `start_date`, `emp`.`end_date` AS `end_date`, `emp`.`salary` AS `salary`, `a`.`street_address` AS `street_address`, `a`.`alamat_detil` AS `alamat_detil`, `a`.`province_id` AS `province_id`, `a`.`regency_id` AS `regency_id`, `a`.`district_id` AS `district_id`, `a`.`village_id` AS `village_id`, `a`.`postal_code` AS `postal_code`, `a`.`latitude` AS `latitude`, `a`.`longitude` AS `longitude`, `a`.`address_verified` AS `address_verified`, concat(coalesce(`a`.`alamat_detil`,`a`.`street_address`,''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`a`.`postal_code`,`v`.`postal_code`,`r`.`postal_code`,'')) AS `complete_address` FROM ((((((((`employees` `e` left join `people_db`.`users` `u` on(`e`.`user_id` = `u`.`id`)) left join `people_db`.`identities` `i` on(`u`.`id` = `i`.`user_id`)) left join `people_db`.`addresses` `a` on(`u`.`id` = `a`.`user_id` and `a`.`is_primary` = 1)) left join `people_db`.`employment_records` `emp` on(`u`.`id` = `emp`.`user_id`)) left join `alamat_db`.`provinces` `p` on(`a`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`a`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`a`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`a`.`village_id` = `v`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `ksp_member_people_view`
--
DROP TABLE IF EXISTS `ksp_member_people_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ksp_member_people_view`  AS SELECT `m`.`id` AS `member_id`, `m`.`member_number` AS `member_number`, `m`.`user_id` AS `user_id`, `m`.`nik` AS `nik`, `m`.`full_name` AS `full_name`, `m`.`birth_date` AS `birth_date`, `m`.`birth_place` AS `birth_place`, `m`.`gender` AS `gender`, `m`.`address` AS `address`, `m`.`phone` AS `phone`, `m`.`email` AS `email`, `m`.`join_date` AS `join_date`, `m`.`status` AS `status`, `u`.`nama` AS `people_nama`, `u`.`email` AS `people_email`, `u`.`phone` AS `people_phone`, `u`.`status` AS `people_status`, `i`.`nama_lengkap` AS `nama_lengkap`, `i`.`tempat_lahir` AS `tempat_lahir`, `i`.`tanggal_lahir` AS `tanggal_lahir`, `i`.`gender_id` AS `gender_id`, `i`.`marital_status_id` AS `marital_status_id`, `i`.`religion_id` AS `religion_id`, `i`.`ethnicity_id` AS `ethnicity_id`, `i`.`blood_type_id` AS `blood_type_id`, `i`.`kewarganegaraan` AS `kewarganegaraan`, `i`.`risk_score` AS `risk_score`, `i`.`kyc_completeness` AS `kyc_completeness`, `i`.`verified` AS `identity_verified`, `a`.`street_address` AS `street_address`, `a`.`alamat_detil` AS `alamat_detil`, `a`.`province_id` AS `province_id`, `a`.`regency_id` AS `regency_id`, `a`.`district_id` AS `district_id`, `a`.`village_id` AS `village_id`, `a`.`postal_code` AS `postal_code`, `a`.`latitude` AS `latitude`, `a`.`longitude` AS `longitude`, `a`.`address_verified` AS `address_verified`, concat(coalesce(`a`.`alamat_detil`,`a`.`street_address`,''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`a`.`postal_code`,`v`.`postal_code`,`r`.`postal_code`,'')) AS `complete_address` FROM (((((((`members` `m` left join `people_db`.`users` `u` on(`m`.`user_id` = `u`.`id`)) left join `people_db`.`identities` `i` on(`u`.`id` = `i`.`user_id`)) left join `people_db`.`addresses` `a` on(`u`.`id` = `a`.`user_id` and `a`.`is_primary` = 1)) left join `alamat_db`.`provinces` `p` on(`a`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`a`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`a`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`a`.`village_id` = `v`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `loan_performance`
--
DROP TABLE IF EXISTS `loan_performance`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `loan_performance`  AS SELECT `l`.`id` AS `id`, `l`.`loan_number` AS `loan_number`, `m`.`full_name` AS `member_name`, `l`.`loan_amount` AS `loan_amount`, `l`.`interest_rate` AS `interest_rate`, `l`.`loan_term` AS `loan_term`, `l`.`status` AS `status`, `l`.`application_date` AS `application_date`, `l`.`disbursement_date` AS `disbursement_date`, coalesce(sum(`lp`.`amount`),0) AS `total_paid`, `l`.`loan_amount`- coalesce(sum(`lp`.`amount`),0) AS `remaining_balance`, CASE WHEN `l`.`status` = 'completed' THEN 'Lunas' WHEN `l`.`status` = 'active' AND `l`.`due_date` < curdate() THEN 'Macet' WHEN `l`.`status` = 'active' THEN 'Aktif' ELSE `l`.`status` END AS `payment_status` FROM ((`loans` `l` join `members` `m` on(`l`.`member_id` = `m`.`id`)) left join `loan_payments` `lp` on(`l`.`id` = `lp`.`loan_id`)) GROUP BY `l`.`id`, `l`.`loan_number`, `m`.`full_name`, `l`.`loan_amount`, `l`.`interest_rate`, `l`.`loan_term`, `l`.`status`, `l`.`application_date`, `l`.`disbursement_date` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `member_complete_address`
--
DROP TABLE IF EXISTS `member_complete_address`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `member_complete_address`  AS SELECT `m`.`id` AS `id`, `m`.`member_number` AS `member_number`, `m`.`full_name` AS `full_name`, `m`.`detail_address` AS `detail_address`, `m`.`postal_code` AS `postal_code`, `p`.`name` AS `province_name`, `r`.`name` AS `regency_name`, `d`.`name` AS `district_name`, `v`.`name` AS `village_name`, concat(coalesce(`m`.`detail_address`,''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`m`.`postal_code`,`v`.`postal_code`,'')) AS `complete_address` FROM ((((`members` `m` left join `alamat_db`.`provinces` `p` on(`m`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`m`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`m`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`m`.`village_id` = `v`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `member_summary`
--
DROP TABLE IF EXISTS `member_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `member_summary`  AS SELECT `m`.`id` AS `id`, `m`.`member_number` AS `member_number`, `m`.`full_name` AS `full_name`, `m`.`phone` AS `phone`, `m`.`email` AS `email`, `m`.`join_date` AS `join_date`, `m`.`status` AS `status`, count(distinct `a`.`id`) AS `total_accounts`, coalesce(sum(`a`.`balance`),0) AS `total_balance`, count(distinct `l`.`id`) AS `total_loans`, coalesce(sum(`l`.`loan_amount`),0) AS `total_loan_amount` FROM ((`members` `m` left join `accounts` `a` on(`m`.`id` = `a`.`member_id` and `a`.`status` = 'active')) left join `loans` `l` on(`m`.`id` = `l`.`member_id` and `l`.`status` in ('active','completed'))) GROUP BY `m`.`id`, `m`.`member_number`, `m`.`full_name`, `m`.`phone`, `m`.`email`, `m`.`join_date`, `m`.`status` ;

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
-- Indeks untuk tabel `activity_locations`
--
ALTER TABLE `activity_locations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_person_activity` (`person_id`,`person_type`,`activity_date`),
  ADD KEY `idx_location` (`province_id`,`regency_id`,`district_id`,`village_id`),
  ADD KEY `idx_activity_type` (`activity_type`);

--
-- Indeks untuk tabel `activity_milestones`
--
ALTER TABLE `activity_milestones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_plan_date` (`plan_id`,`target_date`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `activity_plans`
--
ALTER TABLE `activity_plans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `responsible_person_id` (`responsible_person_id`),
  ADD KEY `idx_dates` (`start_date`,`end_date`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_type` (`plan_type`);

--
-- Indeks untuk tabel `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `action` (`action`),
  ADD KEY `table_name` (`table_name`),
  ADD KEY `created_at` (`created_at`);

--
-- Indeks untuk tabel `audit_trail`
--
ALTER TABLE `audit_trail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_trail_user` (`user_id`),
  ADD KEY `idx_audit_trail_table` (`table_name`,`record_id`);

--
-- Indeks untuk tabel `branches`
--
ALTER TABLE `branches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `branch_code` (`branch_code`),
  ADD KEY `manager_id` (`manager_id`),
  ADD KEY `idx_branch_code` (`branch_code`),
  ADD KEY `idx_province` (`province_id`),
  ADD KEY `idx_regency` (`regency_id`),
  ADD KEY `idx_district` (`district_id`),
  ADD KEY `idx_village` (`village_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_house_number` (`house_number`),
  ADD KEY `idx_building_name` (`building_name`),
  ADD KEY `idx_complex_name` (`complex_name`),
  ADD KEY `idx_branch_status` (`branch_status`),
  ADD KEY `idx_is_active` (`is_active`),
  ADD KEY `idx_coverage_area` (`coverage_area`(50)),
  ADD KEY `idx_gps_coordinates` (`gps_coordinates`(25));

--
-- Indeks untuk tabel `branch_facilities`
--
ALTER TABLE `branch_facilities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_branch_facility` (`branch_id`,`facility_type`),
  ADD KEY `idx_facility_type` (`facility_type`),
  ADD KEY `idx_facility_status` (`facility_status`);

--
-- Indeks untuk tabel `branch_operating_hours`
--
ALTER TABLE `branch_operating_hours`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_branch_schedule` (`branch_id`,`day_of_week`),
  ADD KEY `idx_day_of_week` (`day_of_week`);

--
-- Indeks untuk tabel `branch_service_areas`
--
ALTER TABLE `branch_service_areas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_branch_service` (`branch_id`,`service_type`),
  ADD KEY `idx_service_area` (`province_id`,`regency_id`,`district_id`),
  ADD KEY `idx_service_type` (`service_type`);

--
-- Indeks untuk tabel `branch_types`
--
ALTER TABLE `branch_types`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_branch_type` (`branch_type`),
  ADD KEY `idx_category` (`category`);

--
-- Indeks untuk tabel `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `account_code` (`account_code`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Indeks untuk tabel `collection_verification`
--
ALTER TABLE `collection_verification`
  ADD PRIMARY KEY (`id`),
  ADD KEY `verified_by` (`verified_by`),
  ADD KEY `idx_collector_date` (`collector_id`,`verification_date`),
  ADD KEY `idx_status` (`verification_status`);

--
-- Indeks untuk tabel `collector_performance`
--
ALTER TABLE `collector_performance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `collector_period` (`collector_id`,`period_month`),
  ADD KEY `idx_collector` (`collector_id`),
  ADD KEY `idx_period` (`period_month`);

--
-- Indeks untuk tabel `daily_consumption_expenses`
--
ALTER TABLE `daily_consumption_expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_employee_date` (`employee_id`,`expense_date`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `digital_payments`
--
ALTER TABLE `digital_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `payment_transaction_id` (`payment_transaction_id`);

--
-- Indeks untuk tabel `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employee_number` (`employee_number`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_department` (`department`),
  ADD KEY `idx_employment_type` (`employment_type`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_province` (`province_id`),
  ADD KEY `idx_regency` (`regency_id`),
  ADD KEY `idx_district` (`district_id`),
  ADD KEY `idx_village` (`village_id`);

--
-- Indeks untuk tabel `employee_experience`
--
ALTER TABLE `employee_experience`
  ADD PRIMARY KEY (`id`),
  ADD KEY `employee_id` (`employee_id`);

--
-- Indeks untuk tabel `employee_family`
--
ALTER TABLE `employee_family`
  ADD PRIMARY KEY (`id`),
  ADD KEY `employee_id` (`employee_id`);

--
-- Indeks untuk tabel `expense_categories`
--
ALTER TABLE `expense_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_parent` (`parent_id`),
  ADD KEY `idx_active` (`is_active`);

--
-- Indeks untuk tabel `financial_reports`
--
ALTER TABLE `financial_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `generated_by` (`generated_by`);

--
-- Indeks untuk tabel `general_ledger`
--
ALTER TABLE `general_ledger`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_general_ledger_date` (`transaction_date`),
  ADD KEY `idx_general_ledger_account` (`account_code`);

--
-- Indeks untuk tabel `gps_tracking`
--
ALTER TABLE `gps_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `staff_id` (`staff_id`),
  ADD KEY `idx_person_location` (`timestamp`);

--
-- Indeks untuk tabel `interest_methods`
--
ALTER TABLE `interest_methods`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `method_name` (`method_name`),
  ADD UNIQUE KEY `method_code` (`method_code`);

--
-- Indeks untuk tabel `inventory_borrowing`
--
ALTER TABLE `inventory_borrowing`
  ADD PRIMARY KEY (`id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_item` (`item_id`),
  ADD KEY `idx_employee` (`borrowed_by`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_borrow_date` (`borrow_date`);

--
-- Indeks untuk tabel `inventory_categories`
--
ALTER TABLE `inventory_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_parent` (`parent_id`);

--
-- Indeks untuk tabel `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `item_code` (`item_code`),
  ADD KEY `idx_item_code` (`item_code`),
  ADD KEY `idx_category` (`category_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_location` (`location`);

--
-- Indeks untuk tabel `inventory_maintenance`
--
ALTER TABLE `inventory_maintenance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_item_date` (`item_id`,`maintenance_date`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `journal_entries`
--
ALTER TABLE `journal_entries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `journal_number` (`journal_number`),
  ADD KEY `posted_by` (`posted_by`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_journal_entries_date` (`transaction_date`);

--
-- Indeks untuk tabel `journal_entry_lines`
--
ALTER TABLE `journal_entry_lines`
  ADD PRIMARY KEY (`id`),
  ADD KEY `journal_id` (`journal_id`),
  ADD KEY `account_code` (`account_code`);

--
-- Indeks untuk tabel `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `replacement_employee_id` (`replacement_employee_id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_employee_dates` (`employee_id`,`start_date`,`end_date`),
  ADD KEY `idx_status` (`status`);

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
  ADD KEY `idx_loans_collector` (`collector_id`),
  ADD KEY `idx_loans_assessment` (`assessment_id`);

--
-- Indeks untuk tabel `loan_assessments`
--
ALTER TABLE `loan_assessments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_member_date` (`member_id`,`assessment_date`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_assessed_by` (`assessed_by`);

--
-- Indeks untuk tabel `loan_payments`
--
ALTER TABLE `loan_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `loan_id` (`loan_id`),
  ADD KEY `payment_date` (`payment_date`),
  ADD KEY `received_by` (`received_by`),
  ADD KEY `idx_loan_payments_collector` (`collected_by`);

--
-- Indeks untuk tabel `loan_promissory_notes`
--
ALTER TABLE `loan_promissory_notes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `promissory_number` (`promissory_number`),
  ADD KEY `idx_loan` (`loan_id`),
  ADD KEY `idx_promissory_number` (`promissory_number`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_due_date` (`due_date`);

--
-- Indeks untuk tabel `loan_schedules`
--
ALTER TABLE `loan_schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_loan_schedules_loan` (`loan_id`),
  ADD KEY `idx_loan_schedules_due` (`due_date`);

--
-- Indeks untuk tabel `location_history`
--
ALTER TABLE `location_history`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_person_date` (`person_id`,`person_type`,`date`),
  ADD KEY `idx_date` (`date`),
  ADD KEY `idx_person_date` (`person_id`,`person_type`);

--
-- Indeks untuk tabel `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`),
  ADD KEY `ip_address` (`ip_address`),
  ADD KEY `attempt_time` (`attempt_time`);

--
-- Indeks untuk tabel `members`
--
ALTER TABLE `members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `member_number` (`member_number`),
  ADD UNIQUE KEY `nik` (`nik`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `status` (`status`),
  ADD KEY `idx_members_collector` (`collector_id`),
  ADD KEY `idx_province` (`province_id`),
  ADD KEY `idx_regency` (`regency_id`),
  ADD KEY `idx_district` (`district_id`),
  ADD KEY `idx_village` (`village_id`);

--
-- Indeks untuk tabel `member_balances`
--
ALTER TABLE `member_balances`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `member_id` (`member_id`);

--
-- Indeks untuk tabel `member_shu_distribution`
--
ALTER TABLE `member_shu_distribution`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_member_shu` (`shu_calculation_id`,`member_id`),
  ADD KEY `member_id` (`member_id`);

--
-- Indeks untuk tabel `operational_expenses`
--
ALTER TABLE `operational_expenses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `expense_number` (`expense_number`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_expense_number` (`expense_number`),
  ADD KEY `idx_category` (`category_id`),
  ADD KEY `idx_date` (`expense_date`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_requested_by` (`requested_by`);

--
-- Indeks untuk tabel `overtime_records`
--
ALTER TABLE `overtime_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_employee_date` (`employee_id`,`overtime_date`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `payment_transactions`
--
ALTER TABLE `payment_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_number` (`transaction_number`),
  ADD KEY `loan_id` (`loan_id`),
  ADD KEY `account_id` (`account_id`),
  ADD KEY `processed_by` (`processed_by`),
  ADD KEY `idx_payment_transactions_date` (`transaction_date`),
  ADD KEY `idx_payment_transactions_member` (`member_id`);

--
-- Indeks untuk tabel `payroll_details`
--
ALTER TABLE `payroll_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `employee_id` (`employee_id`),
  ADD KEY `idx_payroll_employee` (`payroll_period_id`,`employee_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `payroll_periods`
--
ALTER TABLE `payroll_periods`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `period_name` (`period_name`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_payment_date` (`payment_date`);

--
-- Indeks untuk tabel `route_execution`
--
ALTER TABLE `route_execution`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_route_execution` (`route_plan_id`,`status`),
  ADD KEY `idx_person_execution` (`person_id`,`person_type`,`start_time`);

--
-- Indeks untuk tabel `route_plans`
--
ALTER TABLE `route_plans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_person_route` (`person_id`,`person_type`,`status`),
  ADD KEY `idx_planned_date` (`planned_date`),
  ADD KEY `idx_route_type` (`route_type`);

--
-- Indeks untuk tabel `salary_structure`
--
ALTER TABLE `salary_structure`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `grade` (`grade`),
  ADD KEY `idx_grade` (`grade`);

--
-- Indeks untuk tabel `savings`
--
ALTER TABLE `savings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `member_id` (`member_id`),
  ADD KEY `savings_type` (`savings_type`),
  ADD KEY `transaction_date` (`transaction_date`),
  ADD KEY `created_by` (`created_by`);

--
-- Indeks untuk tabel `schedule_details`
--
ALTER TABLE `schedule_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `schedule_id` (`schedule_id`),
  ADD KEY `idx_employee_date` (`employee_id`,`work_date`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `shu_calculations`
--
ALTER TABLE `shu_calculations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `created_by` (`created_by`);

--
-- Indeks untuk tabel `system_config`
--
ALTER TABLE `system_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `config_key` (`config_key`),
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
  ADD KEY `created_by` (`created_by`);

--
-- Indeks untuk tabel `transaction_locks`
--
ALTER TABLE `transaction_locks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `lock_key` (`lock_key`),
  ADD KEY `locked_by` (`locked_by`),
  ADD KEY `idx_transaction_locks_key` (`lock_key`),
  ADD KEY `idx_transaction_locks_expiry` (`expires_at`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `role` (`role`),
  ADD KEY `status` (`status`);

--
-- Indeks untuk tabel `work_schedules`
--
ALTER TABLE `work_schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_date_range` (`start_date`,`end_date`),
  ADD KEY `idx_template` (`is_template`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `activity_locations`
--
ALTER TABLE `activity_locations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `activity_milestones`
--
ALTER TABLE `activity_milestones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `activity_plans`
--
ALTER TABLE `activity_plans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `audit_trail`
--
ALTER TABLE `audit_trail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `branches`
--
ALTER TABLE `branches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `branch_facilities`
--
ALTER TABLE `branch_facilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `branch_operating_hours`
--
ALTER TABLE `branch_operating_hours`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `branch_service_areas`
--
ALTER TABLE `branch_service_areas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `branch_types`
--
ALTER TABLE `branch_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT untuk tabel `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT untuk tabel `collection_verification`
--
ALTER TABLE `collection_verification`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `collector_performance`
--
ALTER TABLE `collector_performance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `daily_consumption_expenses`
--
ALTER TABLE `daily_consumption_expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `digital_payments`
--
ALTER TABLE `digital_payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `employees`
--
ALTER TABLE `employees`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `employee_experience`
--
ALTER TABLE `employee_experience`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `employee_family`
--
ALTER TABLE `employee_family`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `expense_categories`
--
ALTER TABLE `expense_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `financial_reports`
--
ALTER TABLE `financial_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `general_ledger`
--
ALTER TABLE `general_ledger`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `gps_tracking`
--
ALTER TABLE `gps_tracking`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `interest_methods`
--
ALTER TABLE `interest_methods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `inventory_borrowing`
--
ALTER TABLE `inventory_borrowing`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `inventory_categories`
--
ALTER TABLE `inventory_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `inventory_items`
--
ALTER TABLE `inventory_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `inventory_maintenance`
--
ALTER TABLE `inventory_maintenance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `journal_entries`
--
ALTER TABLE `journal_entries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `journal_entry_lines`
--
ALTER TABLE `journal_entry_lines`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `leave_requests`
--
ALTER TABLE `leave_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `loans`
--
ALTER TABLE `loans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `loan_assessments`
--
ALTER TABLE `loan_assessments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `loan_payments`
--
ALTER TABLE `loan_payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `loan_promissory_notes`
--
ALTER TABLE `loan_promissory_notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `loan_schedules`
--
ALTER TABLE `loan_schedules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `location_history`
--
ALTER TABLE `location_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `members`
--
ALTER TABLE `members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `member_balances`
--
ALTER TABLE `member_balances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `member_shu_distribution`
--
ALTER TABLE `member_shu_distribution`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `operational_expenses`
--
ALTER TABLE `operational_expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `overtime_records`
--
ALTER TABLE `overtime_records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `payment_transactions`
--
ALTER TABLE `payment_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `payroll_details`
--
ALTER TABLE `payroll_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `payroll_periods`
--
ALTER TABLE `payroll_periods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `route_execution`
--
ALTER TABLE `route_execution`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `route_plans`
--
ALTER TABLE `route_plans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `salary_structure`
--
ALTER TABLE `salary_structure`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `savings`
--
ALTER TABLE `savings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `schedule_details`
--
ALTER TABLE `schedule_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `shu_calculations`
--
ALTER TABLE `shu_calculations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `system_config`
--
ALTER TABLE `system_config`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `transaction_locks`
--
ALTER TABLE `transaction_locks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT untuk tabel `work_schedules`
--
ALTER TABLE `work_schedules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `accounts`
--
ALTER TABLE `accounts`
  ADD CONSTRAINT `accounts_member_id_fk` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `activity_milestones`
--
ALTER TABLE `activity_milestones`
  ADD CONSTRAINT `activity_milestones_ibfk_1` FOREIGN KEY (`plan_id`) REFERENCES `activity_plans` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `activity_plans`
--
ALTER TABLE `activity_plans`
  ADD CONSTRAINT `activity_plans_ibfk_1` FOREIGN KEY (`responsible_person_id`) REFERENCES `employees` (`id`);

--
-- Ketidakleluasaan untuk tabel `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `audit_trail`
--
ALTER TABLE `audit_trail`
  ADD CONSTRAINT `audit_trail_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `branches`
--
ALTER TABLE `branches`
  ADD CONSTRAINT `branches_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `branch_facilities`
--
ALTER TABLE `branch_facilities`
  ADD CONSTRAINT `branch_facilities_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `branch_operating_hours`
--
ALTER TABLE `branch_operating_hours`
  ADD CONSTRAINT `branch_operating_hours_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `branch_service_areas`
--
ALTER TABLE `branch_service_areas`
  ADD CONSTRAINT `branch_service_areas_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  ADD CONSTRAINT `chart_of_accounts_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `chart_of_accounts` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `collection_verification`
--
ALTER TABLE `collection_verification`
  ADD CONSTRAINT `collection_verification_ibfk_1` FOREIGN KEY (`collector_id`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `collection_verification_ibfk_2` FOREIGN KEY (`verified_by`) REFERENCES `employees` (`id`);

--
-- Ketidakleluasaan untuk tabel `collector_performance`
--
ALTER TABLE `collector_performance`
  ADD CONSTRAINT `collector_performance_ibfk_1` FOREIGN KEY (`collector_id`) REFERENCES `employees` (`id`);

--
-- Ketidakleluasaan untuk tabel `daily_consumption_expenses`
--
ALTER TABLE `daily_consumption_expenses`
  ADD CONSTRAINT `daily_consumption_expenses_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `daily_consumption_expenses_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `employees` (`id`);

--
-- Ketidakleluasaan untuk tabel `digital_payments`
--
ALTER TABLE `digital_payments`
  ADD CONSTRAINT `digital_payments_ibfk_1` FOREIGN KEY (`payment_transaction_id`) REFERENCES `payment_transactions` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `employee_experience`
--
ALTER TABLE `employee_experience`
  ADD CONSTRAINT `employee_experience_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `employee_family`
--
ALTER TABLE `employee_family`
  ADD CONSTRAINT `employee_family_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `expense_categories`
--
ALTER TABLE `expense_categories`
  ADD CONSTRAINT `expense_categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `expense_categories` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `financial_reports`
--
ALTER TABLE `financial_reports`
  ADD CONSTRAINT `financial_reports_ibfk_1` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `general_ledger`
--
ALTER TABLE `general_ledger`
  ADD CONSTRAINT `general_ledger_ibfk_1` FOREIGN KEY (`account_code`) REFERENCES `chart_of_accounts` (`account_code`),
  ADD CONSTRAINT `general_ledger_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `gps_tracking`
--
ALTER TABLE `gps_tracking`
  ADD CONSTRAINT `gps_tracking_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `inventory_borrowing`
--
ALTER TABLE `inventory_borrowing`
  ADD CONSTRAINT `inventory_borrowing_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`),
  ADD CONSTRAINT `inventory_borrowing_ibfk_2` FOREIGN KEY (`borrowed_by`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `inventory_borrowing_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `employees` (`id`);

--
-- Ketidakleluasaan untuk tabel `inventory_categories`
--
ALTER TABLE `inventory_categories`
  ADD CONSTRAINT `inventory_categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `inventory_categories` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD CONSTRAINT `inventory_items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `inventory_categories` (`id`);

--
-- Ketidakleluasaan untuk tabel `inventory_maintenance`
--
ALTER TABLE `inventory_maintenance`
  ADD CONSTRAINT `inventory_maintenance_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`);

--
-- Ketidakleluasaan untuk tabel `journal_entries`
--
ALTER TABLE `journal_entries`
  ADD CONSTRAINT `journal_entries_ibfk_1` FOREIGN KEY (`posted_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `journal_entries_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `journal_entry_lines`
--
ALTER TABLE `journal_entry_lines`
  ADD CONSTRAINT `journal_entry_lines_ibfk_1` FOREIGN KEY (`journal_id`) REFERENCES `journal_entries` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `journal_entry_lines_ibfk_2` FOREIGN KEY (`account_code`) REFERENCES `chart_of_accounts` (`account_code`);

--
-- Ketidakleluasaan untuk tabel `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `leave_requests_ibfk_2` FOREIGN KEY (`replacement_employee_id`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `leave_requests_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `employees` (`id`);

--
-- Ketidakleluasaan untuk tabel `loans`
--
ALTER TABLE `loans`
  ADD CONSTRAINT `loans_approved_by_fk` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `loans_ibfk_1` FOREIGN KEY (`collector_id`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `loans_ibfk_2` FOREIGN KEY (`assessment_id`) REFERENCES `loan_assessments` (`id`),
  ADD CONSTRAINT `loans_member_id_fk` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `loan_assessments`
--
ALTER TABLE `loan_assessments`
  ADD CONSTRAINT `loan_assessments_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  ADD CONSTRAINT `loan_assessments_ibfk_2` FOREIGN KEY (`assessed_by`) REFERENCES `employees` (`id`);

--
-- Ketidakleluasaan untuk tabel `loan_payments`
--
ALTER TABLE `loan_payments`
  ADD CONSTRAINT `loan_payments_ibfk_1` FOREIGN KEY (`collected_by`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `loan_payments_loan_id_fk` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `loan_payments_received_by_fk` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `loan_promissory_notes`
--
ALTER TABLE `loan_promissory_notes`
  ADD CONSTRAINT `loan_promissory_notes_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `loan_schedules`
--
ALTER TABLE `loan_schedules`
  ADD CONSTRAINT `loan_schedules_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `members`
--
ALTER TABLE `members`
  ADD CONSTRAINT `members_ibfk_1` FOREIGN KEY (`collector_id`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `members_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `member_balances`
--
ALTER TABLE `member_balances`
  ADD CONSTRAINT `member_balances_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `member_shu_distribution`
--
ALTER TABLE `member_shu_distribution`
  ADD CONSTRAINT `member_shu_distribution_ibfk_1` FOREIGN KEY (`shu_calculation_id`) REFERENCES `shu_calculations` (`id`),
  ADD CONSTRAINT `member_shu_distribution_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`);

--
-- Ketidakleluasaan untuk tabel `operational_expenses`
--
ALTER TABLE `operational_expenses`
  ADD CONSTRAINT `operational_expenses_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`),
  ADD CONSTRAINT `operational_expenses_ibfk_2` FOREIGN KEY (`requested_by`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `operational_expenses_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `employees` (`id`);

--
-- Ketidakleluasaan untuk tabel `overtime_records`
--
ALTER TABLE `overtime_records`
  ADD CONSTRAINT `overtime_records_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `payment_transactions`
--
ALTER TABLE `payment_transactions`
  ADD CONSTRAINT `payment_transactions_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  ADD CONSTRAINT `payment_transactions_ibfk_2` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`),
  ADD CONSTRAINT `payment_transactions_ibfk_3` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`),
  ADD CONSTRAINT `payment_transactions_ibfk_4` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `payroll_details`
--
ALTER TABLE `payroll_details`
  ADD CONSTRAINT `payroll_details_ibfk_1` FOREIGN KEY (`payroll_period_id`) REFERENCES `payroll_periods` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payroll_details_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `route_execution`
--
ALTER TABLE `route_execution`
  ADD CONSTRAINT `route_execution_ibfk_1` FOREIGN KEY (`route_plan_id`) REFERENCES `route_plans` (`id`);

--
-- Ketidakleluasaan untuk tabel `savings`
--
ALTER TABLE `savings`
  ADD CONSTRAINT `savings_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `savings_member_id_fk` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `schedule_details`
--
ALTER TABLE `schedule_details`
  ADD CONSTRAINT `schedule_details_ibfk_1` FOREIGN KEY (`schedule_id`) REFERENCES `work_schedules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedule_details_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`);

--
-- Ketidakleluasaan untuk tabel `shu_calculations`
--
ALTER TABLE `shu_calculations`
  ADD CONSTRAINT `shu_calculations_ibfk_1` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `shu_calculations_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `system_config`
--
ALTER TABLE `system_config`
  ADD CONSTRAINT `system_config_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transactions_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `transaction_locks`
--
ALTER TABLE `transaction_locks`
  ADD CONSTRAINT `transaction_locks_ibfk_1` FOREIGN KEY (`locked_by`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
