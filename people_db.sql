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
-- Database: `people_db`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddUserAddress` (IN `p_user_id` INT, IN `p_address_type` VARCHAR(20), IN `p_address_category` VARCHAR(20), IN `p_address_purpose` VARCHAR(50), IN `p_priority_level` VARCHAR(20), IN `p_province_id` INT, IN `p_regency_id` INT, IN `p_district_id` INT, IN `p_village_id` INT, IN `p_street_address` TEXT, IN `p_alamat_detil` TEXT, IN `p_house_number` VARCHAR(20), IN `p_postal_code` VARCHAR(10), IN `p_is_mailing` BOOLEAN, IN `p_is_billing` BOOLEAN, IN `p_is_shipping` BOOLEAN, IN `p_is_work` BOOLEAN, IN `p_is_emergency` BOOLEAN, IN `p_notes` TEXT)   BEGIN
    DECLARE v_address_id INT;
    DECLARE v_old_primary_id INT;
    
    
    IF NOT EXISTS (
        SELECT 1 FROM alamat_db.provinces p
        JOIN alamat_db.regencies r ON r.province_id = p.id
        JOIN alamat_db.districts d ON d.regency_id = r.id
        JOIN alamat_db.villages v ON v.district_id = d.id
        WHERE p.id = p_province_id AND r.id = p_regency_id AND d.id = p_district_id AND v.id = p_village_id
    ) THEN
        SELECT FALSE as success, 'Invalid address hierarchy' as message;
    ELSE
        
        IF p_priority_level = 'primary' THEN
            SELECT id INTO v_old_primary_id 
            FROM addresses 
            WHERE user_id = p_user_id AND priority_level = 'primary' AND address_category = p_address_category
            LIMIT 1;
            
            IF v_old_primary_id IS NOT NULL THEN
                UPDATE addresses SET priority_level = 'secondary' WHERE id = v_old_primary_id;
            END IF;
        END IF;
        
        
        INSERT INTO addresses (
            user_id, address_type, address_category, address_purpose, priority_level,
            province_id, regency_id, district_id, village_id, street_address, alamat_detil,
            house_number, postal_code, is_mailing_address, is_billing_address, 
            is_shipping_address, is_work_address, is_emergency_address, notes
        ) VALUES (
            p_user_id, p_address_type, p_address_category, p_address_purpose, p_priority_level,
            p_province_id, p_regency_id, p_district_id, p_village_id, p_street_address, p_alamat_detil,
            p_house_number, p_postal_code, p_is_mailing, p_is_billing,
            p_is_shipping, p_is_work, p_is_emergency, p_notes
        );
        
        SET v_address_id = LAST_INSERT_ID();
        
        
        INSERT INTO address_history (address_id, user_id, action_type, new_values, change_reason)
        VALUES (v_address_id, p_user_id, 'created', 
                JSON_OBJECT('address_type', p_address_type, 'priority_level', p_priority_level),
                'New address added');
        
        SELECT TRUE as success, 'Address added successfully' as message, v_address_id as address_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserAddressByPurpose` (IN `p_user_id` INT, IN `p_purpose` VARCHAR(50))   BEGIN
    SELECT 
        a.*,
        ap.purpose_name,
        ap.purpose_category,
        p.name as province_name,
        r.name as regency_name,
        d.name as district_name,
        v.name as village_name,
        CONCAT(
            COALESCE(a.alamat_detil, a.street_address, ''), ', ',
            COALESCE(a.house_number, ''), ' ',
            COALESCE(v.name, ''), ', ',
            COALESCE(d.name, ''), ', ',
            COALESCE(r.name, ''), ', ',
            COALESCE(p.name, ''), ' ',
            COALESCE(a.postal_code, v.postal_code, '')
        ) as complete_address
    FROM addresses a
    LEFT JOIN address_purposes ap ON a.address_purpose = ap.purpose_code
    LEFT JOIN alamat_db.provinces p ON a.province_id = p.id
    LEFT JOIN alamat_db.regencies r ON a.regency_id = r.id
    LEFT JOIN alamat_db.districts d ON a.district_id = d.id
    LEFT JOIN alamat_db.villages v ON a.village_id = v.id
    WHERE a.user_id = p_user_id 
      AND (a.address_purpose = p_purpose OR a.address_type = p_purpose)
      AND (a.expiry_date IS NULL OR a.expiry_date >= CURDATE())
    ORDER BY 
        CASE a.priority_level
            WHEN 'primary' THEN 1
            WHEN 'secondary' THEN 2
            WHEN 'tertiary' THEN 3
            WHEN 'emergency' THEN 4
            ELSE 5
        END,
        a.usage_count DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateAddressUsage` (IN `p_address_id` INT, IN `p_usage_type` VARCHAR(50), IN `p_reference_id` VARCHAR(50), IN `p_reference_type` VARCHAR(50))   BEGIN
    DECLARE v_user_id INT;
    
    
    SELECT user_id INTO v_user_id FROM addresses WHERE id = p_address_id;
    
    IF v_user_id IS NOT NULL THEN
        
        UPDATE addresses 
        SET usage_count = usage_count + 1, 
            last_used_date = CURRENT_TIMESTAMP 
        WHERE id = p_address_id;
        
        
        INSERT INTO address_usage_log (address_id, user_id, usage_type, reference_id, reference_type)
        VALUES (p_address_id, v_user_id, p_usage_type, p_reference_id, p_reference_type);
        
        SELECT TRUE as success, 'Address usage updated' as message;
    ELSE
        SELECT FALSE as success, 'Address not found' as message;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ValidateAddressFromAlamatDB` (IN `p_address_id` INT, IN `p_province_id` INT, IN `p_regency_id` INT, IN `p_district_id` INT, IN `p_village_id` INT)   BEGIN
    DECLARE v_valid BOOLEAN DEFAULT FALSE;
    DECLARE v_count INT DEFAULT 0;
    
    
    SELECT COUNT(*) INTO v_count
    FROM alamat_db.provinces p
    JOIN alamat_db.regencies r ON r.province_id = p.id
    JOIN alamat_db.districts d ON d.regency_id = r.id
    JOIN alamat_db.villages v ON v.district_id = d.id
    WHERE p.id = p_province_id 
      AND r.id = p_regency_id 
      AND d.id = p_district_id 
      AND v.id = p_village_id;
    
    IF v_count > 0 THEN
        
        UPDATE people_db.addresses 
        SET alamat_db_source = TRUE,
            address_verified = TRUE,
            verification_date = CURRENT_TIMESTAMP,
            regency_id = p_regency_id,
            district_id = p_district_id
        WHERE id = p_address_id;
        
        SELECT TRUE as success, 'Address validated successfully' as message;
    ELSE
        SELECT FALSE as success, 'Invalid address IDs in alamat_db' as message;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ValidateCompleteAddressEnhanced` (IN `p_province_id` INT, IN `p_regency_id` INT, IN `p_district_id` INT, IN `p_village_id` INT, IN `p_street_name` VARCHAR(255), IN `p_house_number` VARCHAR(20), IN `p_rt_number` VARCHAR(10), IN `p_rw_number` VARCHAR(10), IN `p_postal_code` VARCHAR(10))   BEGIN
    DECLARE v_is_valid BOOLEAN DEFAULT FALSE;
    DECLARE v_validation_message VARCHAR(255);
    DECLARE v_match_count INT DEFAULT 0;
    DECLARE v_complete_address TEXT;
    
    
    SELECT COUNT(*) INTO v_match_count
    FROM alamat_db.provinces p
    JOIN alamat_db.regencies r ON r.province_id = p.id
    JOIN alamat_db.districts d ON d.regency_id = r.id
    JOIN alamat_db.villages v ON v.district_id = d.id
    WHERE p.id = p_province_id 
      AND r.id = p_regency_id 
      AND d.id = p_district_id 
      AND v.id = p_village_id;
    
    IF v_match_count > 0 THEN
        
        SET v_complete_address = CONCAT(
            COALESCE(p_house_number, ''), ' ',
            COALESCE(p_street_name, ''), ', ',
            COALESCE('RT ' + p_rt_number, ''), ' ',
            COALESCE('RW ' + p_rw_number, ''), ', ',
            (SELECT name FROM alamat_db.villages WHERE id = p_village_id), ', ',
            (SELECT name FROM alamat_db.districts WHERE id = p_district_id), ', ',
            (SELECT name FROM alamat_db.regencies WHERE id = p_regency_id), ', ',
            (SELECT name FROM alamat_db.provinces WHERE id = p_province_id), ' ',
            COALESCE(p_postal_code, (SELECT postal_code FROM alamat_db.villages WHERE id = p_village_id), '')
        );
        
        SET v_is_valid = TRUE;
        SET v_validation_message = 'Complete address is valid';
    ELSE
        SET v_is_valid = FALSE;
        SET v_validation_message = 'Invalid address hierarchy';
        SET v_complete_address = NULL;
    END IF;
    
    SELECT v_is_valid as is_valid, v_validation_message as message, v_complete_address as formatted_address;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `addresses`
--

CREATE TABLE `addresses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `address_type` enum('home','work','other') DEFAULT 'home',
  `address_category` enum('personal','professional','logistics','legal','other') DEFAULT 'personal',
  `address_purpose` varchar(50) DEFAULT NULL,
  `priority_level` enum('primary','secondary','tertiary','emergency') DEFAULT 'secondary',
  `is_mailing_address` tinyint(1) DEFAULT 0,
  `is_billing_address` tinyint(1) DEFAULT 0,
  `is_shipping_address` tinyint(1) DEFAULT 0,
  `is_work_address` tinyint(1) DEFAULT 0,
  `is_emergency_address` tinyint(1) DEFAULT 0,
  `effective_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `verification_status` enum('unverified','pending','verified','rejected') DEFAULT 'unverified',
  `verification_method` enum('document','visit','phone','email','self_certify') DEFAULT NULL,
  `last_used_date` timestamp NULL DEFAULT NULL,
  `usage_count` int(11) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `country` varchar(100) DEFAULT 'Indonesia',
  `province_id` int(11) DEFAULT NULL,
  `regency_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `village_id` int(11) DEFAULT NULL,
  `alamat_db_source` tinyint(1) DEFAULT 0,
  `address_verified` tinyint(1) DEFAULT 0,
  `verification_date` timestamp NULL DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `street_address` varchar(255) DEFAULT NULL,
  `house_number` varchar(20) DEFAULT NULL,
  `building_number` varchar(20) DEFAULT NULL,
  `unit_number` varchar(20) DEFAULT NULL,
  `floor_number` varchar(10) DEFAULT NULL,
  `rt_number` varchar(10) DEFAULT NULL,
  `rw_number` varchar(10) DEFAULT NULL,
  `complex_name` varchar(100) DEFAULT NULL,
  `gate_number` varchar(20) DEFAULT NULL,
  `special_instructions` text DEFAULT NULL,
  `user_landmark` varchar(255) DEFAULT NULL,
  `building_type_id` int(11) DEFAULT NULL,
  `alamat_detil` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `cooperative_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `addresses`
--
DELIMITER $$
CREATE TRIGGER `trg_addresses_primary` BEFORE INSERT ON `addresses` FOR EACH ROW BEGIN
    IF NEW.is_primary THEN
        UPDATE addresses SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_addresses_primary_upd` BEFORE UPDATE ON `addresses` FOR EACH ROW BEGIN
    IF NEW.is_primary AND (OLD.is_primary IS NULL OR OLD.is_primary = FALSE) THEN
        UPDATE addresses SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `verify_address_on_insert` AFTER INSERT ON `addresses` FOR EACH ROW BEGIN
    
    IF NEW.province_id IS NOT NULL 
       AND NEW.village_id IS NOT NULL 
       AND NEW.regency_id IS NOT NULL 
       AND NEW.district_id IS NOT NULL THEN
       
        CALL ValidateAddressFromAlamatDB(
            NEW.id, 
            NEW.province_id, 
            NEW.regency_id, 
            NEW.district_id, 
            NEW.village_id
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `address_history`
--

CREATE TABLE `address_history` (
  `id` int(11) NOT NULL,
  `address_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action_type` enum('created','updated','deleted','verified','deactivated','reactivated') NOT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `changed_by_user_id` int(11) DEFAULT NULL,
  `changed_by_system` tinyint(1) DEFAULT 0,
  `change_reason` text DEFAULT NULL,
  `change_timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `address_purposes`
--

CREATE TABLE `address_purposes` (
  `id` int(11) NOT NULL,
  `purpose_code` varchar(50) NOT NULL,
  `purpose_name` varchar(100) NOT NULL,
  `purpose_category` enum('personal','professional','logistics','legal','other') NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `requires_verification` tinyint(1) DEFAULT 0,
  `default_priority` enum('primary','secondary','tertiary','emergency') DEFAULT 'secondary',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `address_purposes`
--

INSERT INTO `address_purposes` (`id`, `purpose_code`, `purpose_name`, `purpose_category`, `description`, `is_active`, `requires_verification`, `default_priority`, `created_at`) VALUES
(1, 'home', 'Rumah Tinggal', 'personal', 'Alamat tempat tinggal utama', 1, 1, 'primary', '2026-03-24 19:46:19'),
(2, 'boarding', 'Kos/Boarding', 'personal', 'Alamat tempat tinggal sementara', 1, 1, 'secondary', '2026-03-24 19:46:19'),
(3, 'parents', 'Orang Tua', 'personal', 'Alamat orang tua/wali', 1, 0, 'secondary', '2026-03-24 19:46:19'),
(4, 'family', 'Keluarga', 'personal', 'Alamat keluarga dekat', 1, 0, 'secondary', '2026-03-24 19:46:19'),
(5, 'emergency', 'Darurat', 'personal', 'Alamat untuk kontak darurat', 1, 1, 'emergency', '2026-03-24 19:46:19'),
(6, 'mailing', 'Surat Menyurat', 'personal', 'Alamat untuk menerima surat', 1, 1, 'primary', '2026-03-24 19:46:19'),
(7, 'vacation', 'Liburan', 'personal', 'Alamat tempat liburan', 1, 0, 'tertiary', '2026-03-24 19:46:19'),
(8, 'office', 'Kantor', 'professional', 'Alamat tempat kerja', 1, 1, 'primary', '2026-03-24 19:46:19'),
(9, 'workplace', 'Tempat Kerja', 'professional', 'Alamat lokasi kerja fisik', 1, 1, 'primary', '2026-03-24 19:46:19'),
(10, 'factory', 'Pabrik/Workshop', 'professional', 'Alamat pabrik atau workshop', 1, 1, 'secondary', '2026-03-24 19:46:19'),
(11, 'project', 'Proyek', 'professional', 'Alamat proyek sementara', 1, 0, 'tertiary', '2026-03-24 19:46:19'),
(12, 'client', 'Client', 'professional', 'Alamat client untuk kunjungan', 1, 0, 'tertiary', '2026-03-24 19:46:19'),
(13, 'supplier', 'Supplier', 'professional', 'Alamat supplier bisnis', 1, 0, 'tertiary', '2026-03-24 19:46:19'),
(14, 'shipping', 'Pengiriman', 'logistics', 'Alamat untuk pengiriman barang', 1, 1, 'primary', '2026-03-24 19:46:19'),
(15, 'pickup', 'Pickup', 'logistics', 'Alamat untuk pickup barang', 1, 1, 'secondary', '2026-03-24 19:46:19'),
(16, 'billing', 'Tagihan', 'logistics', 'Alamat untuk tagihan', 1, 1, 'primary', '2026-03-24 19:46:19'),
(17, 'warehouse', 'Gudang', 'logistics', 'Alamat gudang/penyimpanan', 1, 1, 'secondary', '2026-03-24 19:46:19'),
(18, 'distribution', 'Distribusi', 'logistics', 'Alamat pusat distribusi', 1, 0, 'tertiary', '2026-03-24 19:46:19'),
(19, 'domicile', 'Domisili', 'legal', 'Alamat legal domisili', 1, 1, 'primary', '2026-03-24 19:46:19'),
(20, 'tax', 'Perpajakan', 'legal', 'Alamat untuk keperluan perpajakan', 1, 1, 'primary', '2026-03-24 19:46:19'),
(21, 'ktp', 'KTP', 'legal', 'Alamat sesuai KTP', 1, 1, 'primary', '2026-03-24 19:46:19'),
(22, 'kk', 'Kartu Keluarga', 'legal', 'Alamat sesuai KK', 1, 1, 'primary', '2026-03-24 19:46:19'),
(23, 'court', 'Pengadilan', 'legal', 'Alamat untuk keperluan pengadilan', 1, 0, 'secondary', '2026-03-24 19:46:19');

-- --------------------------------------------------------

--
-- Struktur dari tabel `address_usage_log`
--

CREATE TABLE `address_usage_log` (
  `id` int(11) NOT NULL,
  `address_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `usage_type` enum('mailing','billing','shipping','emergency','visit','verification','other') NOT NULL,
  `usage_context` varchar(100) DEFAULT NULL,
  `usage_timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `used_by_user_id` int(11) DEFAULT NULL,
  `reference_id` varchar(50) DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `allowed_databases`
--

CREATE TABLE `allowed_databases` (
  `id` int(11) NOT NULL,
  `db_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `allowed` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `allowed_databases`
--

INSERT INTO `allowed_databases` (`id`, `db_name`, `description`, `allowed`, `created_at`) VALUES
(1, 'alamat_db', 'Database for Indonesian addresses: provinces, cities, villages', 1, '2026-02-03 14:13:06');

-- --------------------------------------------------------

--
-- Struktur dari tabel `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(50) DEFAULT NULL,
  `performed_by` int(11) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT current_timestamp(),
  `details` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `blood_types`
--

CREATE TABLE `blood_types` (
  `id` int(11) NOT NULL,
  `name` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `blood_types`
--

INSERT INTO `blood_types` (`id`, `name`) VALUES
(1, 'A'),
(6, 'A-'),
(5, 'A+'),
(3, 'AB'),
(10, 'AB-'),
(9, 'AB+'),
(2, 'B'),
(8, 'B-'),
(7, 'B+'),
(4, 'O'),
(12, 'O-'),
(11, 'O+');

-- --------------------------------------------------------

--
-- Struktur dari tabel `certifications`
--

CREATE TABLE `certifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `certification_name` varchar(255) NOT NULL,
  `issuing_organization` varchar(255) DEFAULT NULL,
  `date_issued` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `certificate_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `consents`
--

CREATE TABLE `consents` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `consent_type` varchar(100) DEFAULT NULL,
  `consented` tinyint(1) DEFAULT 0,
  `consent_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `purpose` text DEFAULT NULL,
  `policy_version` varchar(50) DEFAULT NULL,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `revoked_reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `contact_emails`
--

CREATE TABLE `contact_emails` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `type` enum('personal','work','other') DEFAULT 'personal',
  `is_primary` tinyint(1) DEFAULT 0,
  `email_hash` char(128) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `contact_emails`
--
DELIMITER $$
CREATE TRIGGER `trg_contact_emails_primary` BEFORE INSERT ON `contact_emails` FOR EACH ROW BEGIN
    IF NEW.is_primary THEN
        UPDATE contact_emails SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_contact_emails_primary_upd` BEFORE UPDATE ON `contact_emails` FOR EACH ROW BEGIN
    IF NEW.is_primary AND (OLD.is_primary IS NULL OR OLD.is_primary = FALSE) THEN
        UPDATE contact_emails SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `contact_phones`
--

CREATE TABLE `contact_phones` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `type` enum('mobile','home','work','other') DEFAULT 'mobile',
  `is_primary` tinyint(1) DEFAULT 0,
  `phone_hash` char(128) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `contact_phones`
--
DELIMITER $$
CREATE TRIGGER `trg_contact_phones_primary` BEFORE INSERT ON `contact_phones` FOR EACH ROW BEGIN
    IF NEW.is_primary THEN
        UPDATE contact_phones SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_contact_phones_primary_upd` BEFORE UPDATE ON `contact_phones` FOR EACH ROW BEGIN
    IF NEW.is_primary AND (OLD.is_primary IS NULL OR OLD.is_primary = FALSE) THEN
        UPDATE contact_phones SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `data_subject_requests`
--

CREATE TABLE `data_subject_requests` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `request_type` enum('access','rectification','erasure','portability','restriction','objection') NOT NULL,
  `status` enum('pending','in_progress','fulfilled','rejected') DEFAULT 'pending',
  `requested_at` timestamp NULL DEFAULT current_timestamp(),
  `fulfilled_at` timestamp NULL DEFAULT NULL,
  `details` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `education_records`
--

CREATE TABLE `education_records` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `degree` varchar(100) DEFAULT NULL,
  `field_of_study` varchar(100) DEFAULT NULL,
  `start_year` year(4) DEFAULT NULL,
  `end_year` year(4) DEFAULT NULL,
  `grade` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `emergency_contacts`
--

CREATE TABLE `emergency_contacts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `relation` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `employment_records`
--

CREATE TABLE `employment_records` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `company` varchar(255) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `salary` decimal(15,2) DEFAULT NULL,
  `reason_for_leaving` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `ethnicities`
--

CREATE TABLE `ethnicities` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `ethnicities`
--

INSERT INTO `ethnicities` (`id`, `name`) VALUES
(3, 'Batak'),
(5, 'Betawi'),
(1, 'Jawa'),
(6, 'Lainnya'),
(4, 'Minangkabau'),
(2, 'Sunda');

-- --------------------------------------------------------

--
-- Struktur dari tabel `family_members`
--

CREATE TABLE `family_members` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `relation` enum('ayah','ibu','pasangan','anak','saudara') DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `contact_info` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `financial_info`
--

CREATE TABLE `financial_info` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` enum('income','assets','debts','investments','other') DEFAULT 'income',
  `amount` decimal(15,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'IDR',
  `description` text DEFAULT NULL,
  `date_recorded` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `genders`
--

CREATE TABLE `genders` (
  `id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `genders`
--

INSERT INTO `genders` (`id`, `name`) VALUES
(1, 'laki-laki'),
(2, 'perempuan');

-- --------------------------------------------------------

--
-- Struktur dari tabel `health_records`
--

CREATE TABLE `health_records` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `record_type` enum('alergi','penyakit','obat','operasi','vaksinasi') DEFAULT NULL,
  `description` text DEFAULT NULL,
  `date_recorded` date DEFAULT NULL,
  `severity` varchar(50) DEFAULT NULL,
  `doctor` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `identities`
--

CREATE TABLE `identities` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `nik` varchar(20) DEFAULT NULL,
  `nomor_kk` varchar(20) DEFAULT NULL,
  `nama_lengkap` varchar(255) DEFAULT NULL,
  `tempat_lahir` varchar(100) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `status` enum('draft','complete','verified') DEFAULT 'draft',
  `gender_id` int(11) DEFAULT NULL,
  `marital_status_id` int(11) DEFAULT NULL,
  `religion_id` int(11) DEFAULT NULL,
  `ethnicity_id` int(11) DEFAULT NULL,
  `kewarganegaraan` varchar(100) DEFAULT 'Indonesia',
  `blood_type_id` int(11) DEFAULT NULL,
  `nomor_passport` varchar(20) DEFAULT NULL,
  `nomor_sim` varchar(20) DEFAULT NULL,
  `nik_encrypted` varbinary(512) DEFAULT NULL,
  `passport_encrypted` varbinary(512) DEFAULT NULL,
  `sim_encrypted` varbinary(512) DEFAULT NULL,
  `pep_flag` tinyint(1) DEFAULT 0,
  `pep_source` varchar(255) DEFAULT NULL,
  `risk_score` enum('low','medium','high') DEFAULT 'low',
  `risk_reason` text DEFAULT NULL,
  `kyc_last_review_at` timestamp NULL DEFAULT NULL,
  `kyc_next_review_at` timestamp NULL DEFAULT NULL,
  `kyc_completeness` tinyint(3) UNSIGNED DEFAULT NULL,
  `foto_path` varchar(255) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `identity_types`
--

CREATE TABLE `identity_types` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `required` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `identity_types`
--

INSERT INTO `identity_types` (`id`, `name`, `description`, `country`, `required`, `created_at`) VALUES
(1, 'KTP', 'Kartu Tanda Penduduk Indonesia', 'Indonesia', 1, '2026-02-03 14:12:57'),
(2, 'Passport', 'Passport (any country)', NULL, 0, '2026-02-03 14:12:57'),
(3, 'SIM', 'Surat Izin Mengemudi', 'Indonesia', 0, '2026-02-03 14:12:57');

-- --------------------------------------------------------

--
-- Struktur dari tabel `languages`
--

CREATE TABLE `languages` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `language` varchar(100) NOT NULL,
  `proficiency` enum('basic','conversational','fluent','native') DEFAULT 'conversational',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `life_events`
--

CREATE TABLE `life_events` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_type` enum('kelahiran','pernikahan','perceraian','kematian','pindah','lainnya') DEFAULT NULL,
  `event_date` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `related_person` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `marital_statuses`
--

CREATE TABLE `marital_statuses` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `marital_statuses`
--

INSERT INTO `marital_statuses` (`id`, `name`) VALUES
(1, 'belum_kawin'),
(3, 'cerai_hidup'),
(4, 'cerai_mati'),
(2, 'kawin');

-- --------------------------------------------------------

--
-- Struktur dari tabel `occupations`
--

CREATE TABLE `occupations` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `requires_rank` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `occupations`
--

INSERT INTO `occupations` (`id`, `name`, `is_active`, `created_at`, `requires_rank`) VALUES
(1, 'BELUM/TIDAK BEKERJA', 1, '2026-02-05 05:50:36', 0),
(2, 'MENGURUS RUMAH TANGGA', 1, '2026-02-05 05:50:36', 0),
(3, 'PELAJAR/MAHASISWA', 1, '2026-02-05 05:50:36', 0),
(4, 'PENSIUNAN', 1, '2026-02-05 05:50:36', 0),
(5, 'PEGAWAI NEGERI SIPIL', 1, '2026-02-05 05:50:36', 1),
(6, 'TENTARA NASIONAL INDONESIA', 1, '2026-02-05 05:50:36', 1),
(7, 'KEPOLISIAN RI', 1, '2026-02-05 05:50:36', 1),
(8, 'PERDAGANGAN', 1, '2026-02-05 05:50:36', 0),
(9, 'PETANI/PEKEBUN', 1, '2026-02-05 05:50:36', 0),
(10, 'PETERNAK', 1, '2026-02-05 05:50:36', 0),
(11, 'NELAYAN/PERIKANAN', 1, '2026-02-05 05:50:36', 0),
(12, 'INDUSTRI', 1, '2026-02-05 05:50:36', 0),
(13, 'KONSTRUKSI', 1, '2026-02-05 05:50:36', 0),
(14, 'TRANSPORTASI', 1, '2026-02-05 05:50:36', 0),
(15, 'KARYAWAN SWASTA', 1, '2026-02-05 05:50:36', 0),
(16, 'KARYAWAN BUMN', 1, '2026-02-05 05:50:36', 0),
(17, 'KARYAWAN BUMD', 1, '2026-02-05 05:50:36', 0),
(18, 'KARYAWAN HONORER', 1, '2026-02-05 05:50:36', 0),
(19, 'BURUH HARIAN LEPAS', 1, '2026-02-05 05:50:36', 0),
(20, 'BURUH TANI/PERKEBUNAN', 1, '2026-02-05 05:50:36', 0),
(21, 'BURUH NELAYAN/PERIKANAN', 1, '2026-02-05 05:50:36', 0),
(22, 'BURUH PETERNAKAN', 1, '2026-02-05 05:50:36', 0),
(23, 'TUKANG CUKUR', 1, '2026-02-05 05:50:36', 0),
(24, 'TUKANG LISTRIK', 1, '2026-02-05 05:50:36', 0),
(25, 'TUKANG BATU', 1, '2026-02-05 05:50:36', 0),
(26, 'TUKANG KAYU', 1, '2026-02-05 05:50:36', 0),
(27, 'TUKANG SOL SEPATU', 1, '2026-02-05 05:50:36', 0),
(28, 'TUKANG LAS/PANDAI BESI', 1, '2026-02-05 05:50:36', 0),
(29, 'TUKANG JAHIT', 1, '2026-02-05 05:50:36', 0),
(30, 'TUKANG GIGI', 1, '2026-02-05 05:50:36', 0),
(31, 'PENATA RIAS', 1, '2026-02-05 05:50:36', 0),
(32, 'PENATA BUSANA', 1, '2026-02-05 05:50:36', 0),
(33, 'PENATA RAMBUT', 1, '2026-02-05 05:50:36', 0),
(34, 'MEKANIK', 1, '2026-02-05 05:50:36', 0),
(35, 'SENIMAN', 1, '2026-02-05 05:50:36', 0),
(36, 'TABIB', 1, '2026-02-05 05:50:36', 0),
(37, 'PARAJI', 1, '2026-02-05 05:50:36', 0),
(38, 'PERANCANG BUSANA', 1, '2026-02-05 05:50:36', 0),
(39, 'PENTERJEMAH', 1, '2026-02-05 05:50:36', 0),
(40, 'IMAM MASJID', 1, '2026-02-05 05:50:36', 0),
(41, 'PENDETA', 1, '2026-02-05 05:50:36', 0),
(42, 'PASTOR', 1, '2026-02-05 05:50:36', 0),
(43, 'WARTAWAN', 1, '2026-02-05 05:50:36', 0),
(44, 'USTADZ/MUBALIGH', 1, '2026-02-05 05:50:36', 0),
(45, 'JURU MASAK', 1, '2026-02-05 05:50:36', 0),
(46, 'PROMOTOR ACARA', 1, '2026-02-05 05:50:36', 0),
(47, 'ANGGOTA DPR-RI', 1, '2026-02-05 05:50:36', 0),
(48, 'ANGGOTA DPD', 1, '2026-02-05 05:50:36', 0),
(49, 'ANGGOTA BPK', 1, '2026-02-05 05:50:36', 0),
(50, 'PRESIDEN', 1, '2026-02-05 05:50:36', 0),
(51, 'WAKIL PRESIDEN', 1, '2026-02-05 05:50:36', 0),
(52, 'ANGGOTA MAHKAMAH KONSTITUSI', 1, '2026-02-05 05:50:36', 0),
(53, 'ANGGOTA KABINET/MENTERI', 1, '2026-02-05 05:50:36', 0),
(54, 'DUTA BESAR', 1, '2026-02-05 05:50:36', 0),
(55, 'GUBERNUR', 1, '2026-02-05 05:50:36', 0),
(56, 'WAKIL GUBERNUR', 1, '2026-02-05 05:50:36', 0),
(57, 'BUPATI', 1, '2026-02-05 05:50:36', 0),
(58, 'WAKIL BUPATI', 1, '2026-02-05 05:50:36', 0),
(59, 'WALIKOTA', 1, '2026-02-05 05:50:36', 0),
(60, 'WAKIL WALIKOTA', 1, '2026-02-05 05:50:36', 0),
(61, 'ANGGOTA DPRD PROVINSI', 1, '2026-02-05 05:50:36', 0),
(62, 'ANGGOTA DPRD KABUPATEN/KOTA', 1, '2026-02-05 05:50:36', 0),
(63, 'DOSEN', 1, '2026-02-05 05:50:36', 0),
(64, 'GURU', 1, '2026-02-05 05:50:36', 0),
(65, 'PILOT', 1, '2026-02-05 05:50:36', 0),
(66, 'PENGACARA', 1, '2026-02-05 05:50:36', 0),
(67, 'NOTARIS', 1, '2026-02-05 05:50:36', 0),
(68, 'ARSITEK', 1, '2026-02-05 05:50:36', 0),
(69, 'AKUNTAN', 1, '2026-02-05 05:50:36', 0),
(70, 'KONSULTAN', 1, '2026-02-05 05:50:36', 0),
(71, 'DOKTER', 1, '2026-02-05 05:50:36', 0),
(72, 'BIDAN', 1, '2026-02-05 05:50:36', 0),
(73, 'PERAWAT', 1, '2026-02-05 05:50:36', 0),
(74, 'APOTEKER', 1, '2026-02-05 05:50:36', 0),
(75, 'PSIKOLOG/PSIKIATER', 1, '2026-02-05 05:50:36', 0),
(76, 'PENYULUH PERTANIAN', 1, '2026-02-05 05:50:36', 0),
(77, 'PENYULUH PERIKANAN', 1, '2026-02-05 05:50:36', 0),
(78, 'PENYULUH KEHUTANAN', 1, '2026-02-05 05:50:36', 0),
(79, 'PARAMEDIS', 1, '2026-02-05 05:50:36', 0),
(80, 'PENELITI', 1, '2026-02-05 05:50:36', 0),
(81, 'SOPIR', 1, '2026-02-05 05:50:36', 0),
(82, 'PIALANG', 1, '2026-02-05 05:50:36', 0),
(83, 'PARANORMAL', 1, '2026-02-05 05:50:36', 0),
(84, 'PEDAGANG', 1, '2026-02-05 05:50:36', 0),
(85, 'PERANGKAT DESA', 1, '2026-02-05 05:50:36', 0),
(86, 'KEPALA DESA', 1, '2026-02-05 05:50:36', 0),
(87, 'BIARAWATI', 1, '2026-02-05 05:50:36', 0),
(88, 'WIRASWASTA', 1, '2026-02-05 05:50:36', 0),
(89, 'ANGGOTA LEMBAGA TINGGI LAINNYA', 1, '2026-02-05 05:50:36', 0),
(90, 'ARTIS', 1, '2026-02-05 05:50:36', 0),
(91, 'ATLET', 1, '2026-02-05 05:50:36', 0),
(92, 'MANAJER', 1, '2026-02-05 05:50:36', 0),
(93, 'TENAGA AHLI', 1, '2026-02-05 05:50:36', 0),
(94, 'KEPALA WILAYAH', 1, '2026-02-05 05:50:36', 0),
(95, 'DOSEN (NON PNS)', 1, '2026-02-05 05:50:36', 0),
(96, 'GURU (NON PNS)', 1, '2026-02-05 05:50:36', 0),
(97, 'SWASTA (LAINNYA)', 1, '2026-02-05 05:50:36', 0),
(98, 'TUKANG JAHIT (NON PNS)', 1, '2026-02-05 05:50:36', 0),
(99, 'LAINNYA', 1, '2026-02-05 05:50:36', 0),
(100, 'ASN/PNS', 1, '2026-02-05 05:50:36', 1),
(101, 'POLSUSPAS', 1, '2026-02-05 05:50:36', 1),
(102, 'BEA CUKAI', 1, '2026-02-05 05:50:36', 1),
(103, 'SATPOL PP', 1, '2026-02-05 05:50:36', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `occupation_ranks`
--

CREATE TABLE `occupation_ranks` (
  `id` int(11) NOT NULL,
  `occupation_id` int(11) NOT NULL,
  `rank_name` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `sort_order` int(11) DEFAULT 0,
  `golongan` varchar(100) DEFAULT NULL,
  `tingkatan` varchar(100) DEFAULT NULL,
  `nama_pangkat` varchar(150) DEFAULT NULL,
  `singkatan` varchar(50) DEFAULT NULL,
  `lambang` varchar(150) DEFAULT NULL,
  `pendidikan_min` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `occupation_ranks`
--

INSERT INTO `occupation_ranks` (`id`, `occupation_id`, `rank_name`, `is_active`, `created_at`, `sort_order`, `golongan`, `tingkatan`, `nama_pangkat`, `singkatan`, `lambang`, `pendidikan_min`) VALUES
(560, 100, 'I/A', 1, '2026-02-05 05:50:36', 1, 'I (JURU)', 'I/A', 'Juru Muda', 'I/A', '', 'SD / Sederajat'),
(561, 5, 'I/A', 1, '2026-02-05 05:50:36', 1, 'I (JURU)', 'I/A', 'Juru Muda', 'I/A', '', 'SD / Sederajat'),
(562, 100, 'I/B', 1, '2026-02-05 05:50:36', 2, 'I (JURU)', 'I/B', 'Juru Muda Tingkat I', 'I/B', '', '-'),
(563, 5, 'I/B', 1, '2026-02-05 05:50:36', 2, 'I (JURU)', 'I/B', 'Juru Muda Tingkat I', 'I/B', '', '-'),
(564, 100, 'I/C', 1, '2026-02-05 05:50:36', 3, 'I (JURU)', 'I/C', 'Juru', 'I/C', '', 'SMP / Sederajat'),
(565, 5, 'I/C', 1, '2026-02-05 05:50:36', 3, 'I (JURU)', 'I/C', 'Juru', 'I/C', '', 'SMP / Sederajat'),
(566, 100, 'I/D', 1, '2026-02-05 05:50:36', 4, 'I (JURU)', 'I/D', 'Juru Tingkat I', 'I/D', '', '-'),
(567, 5, 'I/D', 1, '2026-02-05 05:50:36', 4, 'I (JURU)', 'I/D', 'Juru Tingkat I', 'I/D', '', '-'),
(568, 100, 'II/A', 1, '2026-02-05 05:50:36', 5, 'II (PENGATUR)', 'II/A', 'Pengatur Muda', 'II/A', '', 'SMA / SMK / Sederajat'),
(569, 5, 'II/A', 1, '2026-02-05 05:50:36', 5, 'II (PENGATUR)', 'II/A', 'Pengatur Muda', 'II/A', '', 'SMA / SMK / Sederajat'),
(570, 100, 'II/B', 1, '2026-02-05 05:50:36', 6, 'II (PENGATUR)', 'II/B', 'Pengatur Muda Tingkat I', 'II/B', '', 'D2'),
(571, 5, 'II/B', 1, '2026-02-05 05:50:36', 6, 'II (PENGATUR)', 'II/B', 'Pengatur Muda Tingkat I', 'II/B', '', 'D2'),
(572, 100, 'II/C', 1, '2026-02-05 05:50:36', 7, 'II (PENGATUR)', 'II/C', 'Pengatur', 'II/C', '', 'D3'),
(573, 5, 'II/C', 1, '2026-02-05 05:50:36', 7, 'II (PENGATUR)', 'II/C', 'Pengatur', 'II/C', '', 'D3'),
(574, 100, 'II/D', 1, '2026-02-05 05:50:36', 8, 'II (PENGATUR)', 'II/D', 'Pengatur Tingkat I', 'II/D', '', '-'),
(575, 5, 'II/D', 1, '2026-02-05 05:50:36', 8, 'II (PENGATUR)', 'II/D', 'Pengatur Tingkat I', 'II/D', '', '-'),
(576, 100, 'III/A', 1, '2026-02-05 05:50:36', 9, 'III (PENATA)', 'III/A', 'Penata Muda', 'III/A', '', 'S1 / D4'),
(577, 5, 'III/A', 1, '2026-02-05 05:50:36', 9, 'III (PENATA)', 'III/A', 'Penata Muda', 'III/A', '', 'S1 / D4'),
(578, 100, 'III/B', 1, '2026-02-05 05:50:36', 10, 'III (PENATA)', 'III/B', 'Penata Muda Tingkat I', 'III/B', '', 'S2'),
(579, 5, 'III/B', 1, '2026-02-05 05:50:36', 10, 'III (PENATA)', 'III/B', 'Penata Muda Tingkat I', 'III/B', '', 'S2'),
(580, 100, 'III/C', 1, '2026-02-05 05:50:36', 11, 'III (PENATA)', 'III/C', 'Penata', 'III/C', '', 'S3'),
(581, 5, 'III/C', 1, '2026-02-05 05:50:36', 11, 'III (PENATA)', 'III/C', 'Penata', 'III/C', '', 'S3'),
(582, 100, 'III/D', 1, '2026-02-05 05:50:36', 12, 'III (PENATA)', 'III/D', 'Penata Tingkat I', 'III/D', '', '-'),
(583, 5, 'III/D', 1, '2026-02-05 05:50:36', 12, 'III (PENATA)', 'III/D', 'Penata Tingkat I', 'III/D', '', '-'),
(584, 100, 'IV/A', 1, '2026-02-05 05:50:36', 13, 'IV (PEMBINA)', 'IV/A', 'Pembina', 'IV/A', '', '-'),
(585, 5, 'IV/A', 1, '2026-02-05 05:50:36', 13, 'IV (PEMBINA)', 'IV/A', 'Pembina', 'IV/A', '', '-'),
(586, 100, 'IV/B', 1, '2026-02-05 05:50:36', 14, 'IV (PEMBINA)', 'IV/B', 'Pembina Tingkat I', 'IV/B', '', '-'),
(587, 5, 'IV/B', 1, '2026-02-05 05:50:36', 14, 'IV (PEMBINA)', 'IV/B', 'Pembina Tingkat I', 'IV/B', '', '-'),
(588, 100, 'IV/C', 1, '2026-02-05 05:50:36', 15, 'IV (PEMBINA)', 'IV/C', 'Pembina Utama Muda', 'IV/C', '', '-'),
(589, 5, 'IV/C', 1, '2026-02-05 05:50:36', 15, 'IV (PEMBINA)', 'IV/C', 'Pembina Utama Muda', 'IV/C', '', '-'),
(590, 100, 'IV/D', 1, '2026-02-05 05:50:36', 16, 'IV (PEMBINA)', 'IV/D', 'Pembina Utama Madya', 'IV/D', '', '-'),
(591, 5, 'IV/D', 1, '2026-02-05 05:50:36', 16, 'IV (PEMBINA)', 'IV/D', 'Pembina Utama Madya', 'IV/D', '', '-'),
(592, 100, 'IV/E', 1, '2026-02-05 05:50:36', 17, 'IV (PEMBINA)', 'IV/E', 'Pembina Utama', 'IV/E', '', '-'),
(593, 5, 'IV/E', 1, '2026-02-05 05:50:36', 17, 'IV (PEMBINA)', 'IV/E', 'Pembina Utama', 'IV/E', '', '-'),
(623, 7, 'BHARADA', 1, '2026-02-05 05:50:36', 1, 'TAMTAMA', 'TAMTAMA', 'Bhayangkara Dua', 'BHARADA', '1 Balok Merah Miring', NULL),
(624, 7, 'BHARATU', 1, '2026-02-05 05:50:36', 2, 'TAMTAMA', 'TAMTAMA', 'Bhayangkara Satu', 'BHARATU', '2 Balok Merah Miring', NULL),
(625, 7, 'BHARAKA', 1, '2026-02-05 05:50:36', 3, 'TAMTAMA', 'TAMTAMA', 'Bhayangkara Kepala', 'BHARAKA', '3 Balok Merah Miring', NULL),
(626, 7, 'ABRIPDA', 1, '2026-02-05 05:50:36', 4, 'TAMTAMA', 'TAMTAMA', 'Ajun Brigadir Polisi Dua', 'ABRIPDA', '1 Balok Merah V', NULL),
(627, 7, 'ABRIPTU', 1, '2026-02-05 05:50:36', 5, 'TAMTAMA', 'TAMTAMA', 'Ajun Brigadir Polisi Satu', 'ABRIPTU', '2 Balok Merah V', NULL),
(628, 7, 'ABRIP', 1, '2026-02-05 05:50:36', 6, 'TAMTAMA', 'TAMTAMA', 'Ajun Brigadir Polisi', 'ABRIP', '3 Balok Merah V', NULL),
(629, 7, 'BRIPDA', 1, '2026-02-05 05:50:36', 7, 'BINTARA', 'BINTARA', 'Brigadir Polisi Dua', 'BRIPDA', '1 Balok Perak V', NULL),
(630, 7, 'BRIPTU', 1, '2026-02-05 05:50:36', 8, 'BINTARA', 'BINTARA', 'Brigadir Polisi Satu', 'BRIPTU', '2 Balok Perak V', NULL),
(631, 7, 'BRIGPOL', 1, '2026-02-05 05:50:36', 9, 'BINTARA', 'BINTARA', 'Brigadir Polisi', 'BRIGPOL', '3 Balok Perak V', NULL),
(632, 7, 'BRIPKA', 1, '2026-02-05 05:50:36', 10, 'BINTARA', 'BINTARA', 'Brigadir Polisi Kepala', 'BRIPKA', '4 Balok Perak V', NULL),
(633, 7, 'AIPDA', 1, '2026-02-05 05:50:36', 11, 'BINTARA TINGGI', 'BINTARA TINGGI', 'Ajun Inspektur Polisi Dua', 'AIPDA', '1 Balok Perak Bergelombang', NULL),
(634, 7, 'AIPTU', 1, '2026-02-05 05:50:36', 12, 'BINTARA TINGGI', 'BINTARA TINGGI', 'Ajun Inspektur Polisi Satu', 'AIPTU', '2 Balok Perak Bergelombang', NULL),
(635, 7, 'IPDA', 1, '2026-02-05 05:50:36', 13, 'PERWIRA PERTAMA', 'PAMA', 'Inspektur Polisi Dua', 'IPDA', '1 Balok Emas', NULL),
(636, 7, 'IPTU', 1, '2026-02-05 05:50:36', 14, 'PERWIRA PERTAMA', 'PAMA', 'Inspektur Polisi Satu', 'IPTU', '2 Balok Emas', NULL),
(637, 7, 'AKP', 1, '2026-02-05 05:50:36', 15, 'PERWIRA PERTAMA', 'PAMA', 'Ajun Komisaris Polisi', 'AKP', '3 Balok Emas', NULL),
(638, 7, 'KOMPOL', 1, '2026-02-05 05:50:36', 16, 'PERWIRA MENENGAH', 'PAMEN', 'Komisaris Polisi', 'KOMPOL', '1 Melati Emas', NULL),
(639, 7, 'AKBP', 1, '2026-02-05 05:50:36', 17, 'PERWIRA MENENGAH', 'PAMEN', 'Ajun Komisaris Besar Polisi', 'AKBP', '2 Melati Emas', NULL),
(640, 7, 'KOMBES POL', 1, '2026-02-05 05:50:36', 18, 'PERWIRA MENENGAH', 'PAMEN', 'Komisaris Besar Polisi', 'KOMBES POL', '3 Melati Emas', NULL),
(641, 7, 'BRIGJEN POL', 1, '2026-02-05 05:50:36', 19, 'PERWIRA TINGGI', 'PATI', 'Brigadir Jenderal Polisi', 'BRIGJEN POL', '1 Bintang Emas', NULL),
(642, 7, 'IRJEN POL', 1, '2026-02-05 05:50:36', 20, 'PERWIRA TINGGI', 'PATI', 'Inspektur Jenderal Polisi', 'IRJEN POL', '2 Bintang Emas', NULL),
(643, 7, 'KOMJEN POL', 1, '2026-02-05 05:50:36', 21, 'PERWIRA TINGGI', 'PATI', 'Komisaris Jenderal Polisi', 'KOMJEN POL', '3 Bintang Emas', NULL),
(644, 7, 'JEND POL', 1, '2026-02-05 05:50:36', 22, 'PERWIRA TINGGI', 'PATI', 'Jenderal Polisi', 'JEND POL', '4 Bintang Emas', NULL),
(654, 6, 'PRADA', 1, '2026-02-05 05:50:36', 1, 'TAMTAMA', 'PRAJURIT/KELASI', 'Prajurit Dua (Prada)', 'PRADA', '', NULL),
(655, 6, 'PRATU', 1, '2026-02-05 05:50:36', 2, 'TAMTAMA', 'PRAJURIT/KELASI', 'Prajurit Satu (Pratu)', 'PRATU', '', NULL),
(656, 6, 'PRAKA', 1, '2026-02-05 05:50:36', 3, 'TAMTAMA', 'PRAJURIT/KELASI', 'Prajurit Kepala (Praka)', 'PRAKA', '', NULL),
(657, 6, 'KOPDA', 1, '2026-02-05 05:50:36', 4, 'TAMTAMA', 'KEPALA', 'Kopral Dua (Kopda)', 'KOPDA', '', NULL),
(658, 6, 'KOPTU', 1, '2026-02-05 05:50:36', 5, 'TAMTAMA', 'KEPALA', 'Kopral Satu (Koptu)', 'KOPTU', '', NULL),
(659, 6, 'KOPKA', 1, '2026-02-05 05:50:36', 6, 'TAMTAMA', 'KEPALA', 'Kopral Kepala (Kopka)', 'KOPKA', '', NULL),
(660, 6, 'SERDA', 1, '2026-02-05 05:50:36', 7, 'BINTARA', 'BINTARA', 'Sersan Dua (Serda)', 'SERDA', '', NULL),
(661, 6, 'SERTU', 1, '2026-02-05 05:50:36', 8, 'BINTARA', 'BINTARA', 'Sersan Satu (Sertu)', 'SERTU', '', NULL),
(662, 6, 'SERKA', 1, '2026-02-05 05:50:36', 9, 'BINTARA', 'BINTARA', 'Sersan Kepala (Serka)', 'SERKA', '', NULL),
(663, 6, 'SERMA', 1, '2026-02-05 05:50:36', 10, 'BINTARA', 'BINTARA', 'Sersan Mayor (Serma)', 'SERMA', '', NULL),
(664, 6, 'PELDA', 1, '2026-02-05 05:50:36', 11, 'BINTARA', 'BINTARA TINGGI', 'Pembantu Letnan Dua (Pelda)', 'PELDA', '', NULL),
(665, 6, 'PELTU', 1, '2026-02-05 05:50:36', 12, 'BINTARA', 'BINTARA TINGGI', 'Pembantu Letnan Satu (Peltu)', 'PELTU', '', NULL),
(666, 6, 'LETDA', 1, '2026-02-05 05:50:36', 13, 'PERWIRA', 'PERWIRA PERTAMA (PAMA)', 'Letnan Dua (Letda)', 'LETDA', '', NULL),
(667, 6, 'LETTU', 1, '2026-02-05 05:50:36', 14, 'PERWIRA', 'PERWIRA PERTAMA (PAMA)', 'Letnan Satu (Lettu)', 'LETTU', '', NULL),
(668, 6, 'KAPT', 1, '2026-02-05 05:50:36', 15, 'PERWIRA', 'PERWIRA PERTAMA (PAMA)', 'Kapten', 'KAPT', '', NULL),
(669, 6, 'MAYOR', 1, '2026-02-05 05:50:36', 16, 'PERWIRA', 'PERWIRA MENENGAH (PAMEN)', 'Mayor', 'MAYOR', '', NULL),
(670, 6, 'LETKOL', 1, '2026-02-05 05:50:36', 17, 'PERWIRA', 'PERWIRA MENENGAH (PAMEN)', 'Letnan Kolonel (Letkol)', 'LETKOL', '', NULL),
(671, 6, 'KOL', 1, '2026-02-05 05:50:36', 18, 'PERWIRA', 'PERWIRA MENENGAH (PAMEN)', 'Kolonel', 'KOL', '', NULL),
(672, 6, 'BRIGJEN', 1, '2026-02-05 05:50:36', 19, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Brigadir Jenderal TNI (Brigjen)', 'BRIGJEN', '', NULL),
(673, 6, 'MAYJEN', 1, '2026-02-05 05:50:36', 20, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Mayor Jenderal TNI (Mayjen)', 'MAYJEN', '', NULL),
(674, 6, 'LETJEN', 1, '2026-02-05 05:50:36', 21, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Letnan Jenderal TNI (Letjen)', 'LETJEN', '', NULL),
(675, 6, 'JEND TNI', 1, '2026-02-05 05:50:36', 22, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Jenderal TNI', 'JEND TNI', '', NULL),
(676, 6, 'LAKSMA', 1, '2026-02-05 05:50:36', 23, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Laksamana Pertama TNI (Laksma)', 'LAKSMA', '', NULL),
(677, 6, 'LAKSDA', 1, '2026-02-05 05:50:36', 24, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Laksamana Muda TNI (Laksda)', 'LAKSDA', '', NULL),
(678, 6, 'LAKSDYA', 1, '2026-02-05 05:50:36', 25, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Laksamana Madya TNI (Laksdya)', 'LAKSDYA', '', NULL),
(679, 6, 'LAKSAMANA TNI', 1, '2026-02-05 05:50:36', 26, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Laksamana TNI', 'LAKSAMANA TNI', '', NULL),
(680, 6, 'MARSMA', 1, '2026-02-05 05:50:36', 27, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Marsekal Pertama TNI (Marsma)', 'MARSMA', '', NULL),
(681, 6, 'MARSDA', 1, '2026-02-05 05:50:36', 28, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Marsekal Muda TNI (Marsda)', 'MARSDA', '', NULL),
(682, 6, 'MARSDYA', 1, '2026-02-05 05:50:36', 29, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Marsekal Madya TNI (Marsdya)', 'MARSDYA', '', NULL),
(683, 6, 'MARSEKAL TNI', 1, '2026-02-05 05:50:36', 30, 'PERWIRA', 'PERWIRA TINGGI (PATI)', 'Marsekal TNI', 'MARSEKAL TNI', '', NULL),
(685, 101, 'I/A', 1, '2026-02-05 05:50:36', 1, 'I (JURU)', 'I/A', 'Juru (1 Garis Miring Putih)', 'I/A', '1 Garis Miring Putih', NULL),
(686, 101, 'I/B', 1, '2026-02-05 05:50:36', 2, 'I (JURU)', 'I/B', 'Juru (2 Garis Miring Putih)', 'I/B', '2 Garis Miring Putih', NULL),
(687, 101, 'I/C', 1, '2026-02-05 05:50:36', 3, 'I (JURU)', 'I/C', 'Juru (3 Garis Miring Putih)', 'I/C', '3 Garis Miring Putih', NULL),
(688, 101, 'I/D', 1, '2026-02-05 05:50:36', 4, 'I (JURU)', 'I/D', 'Juru (4 Garis Miring Putih)', 'I/D', '4 Garis Miring Putih', NULL),
(689, 101, 'II/A', 1, '2026-02-05 05:50:36', 5, 'II (PENGATUR)', 'II/A', 'Pengatur Muda (1 Balok Putih)', 'II/A', '1 Balok Putih', NULL),
(690, 101, 'II/B', 1, '2026-02-05 05:50:36', 6, 'II (PENGATUR)', 'II/B', 'Pengatur Muda (2 Balok Putih)', 'II/B', '2 Balok Putih', NULL),
(691, 101, 'II/C', 1, '2026-02-05 05:50:36', 7, 'II (PENGATUR)', 'II/C', 'Pengatur (3 Balok Putih)', 'II/C', '3 Balok Putih', NULL),
(692, 101, 'II/D', 1, '2026-02-05 05:50:36', 8, 'II (PENGATUR)', 'II/D', 'Pengatur (4 Balok Putih)', 'II/D', '4 Balok Putih', NULL),
(693, 101, 'III/A', 1, '2026-02-05 05:50:36', 9, 'III (PENATA)', 'III/A', 'Penata Muda (1 Balok Kuning)', 'III/A', '1 Balok Kuning', NULL),
(694, 101, 'III/B', 1, '2026-02-05 05:50:36', 10, 'III (PENATA)', 'III/B', 'Penata Muda (2 Balok Kuning)', 'III/B', '2 Balok Kuning', NULL),
(695, 101, 'III/C', 1, '2026-02-05 05:50:36', 11, 'III (PENATA)', 'III/C', 'Penata (3 Balok Kuning)', 'III/C', '3 Balok Kuning', NULL),
(696, 101, 'III/D', 1, '2026-02-05 05:50:36', 12, 'III (PENATA)', 'III/D', 'Penata (4 Balok Kuning)', 'III/D', '4 Balok Kuning', NULL),
(697, 101, 'IV/A', 1, '2026-02-05 05:50:36', 13, 'IV (PEMBINA)', 'IV/A', 'Pembina (Bintang Emas)', 'IV/A', 'Bintang Emas', NULL),
(698, 101, 'IV/B', 1, '2026-02-05 05:50:36', 14, 'IV (PEMBINA)', 'IV/B', 'Pembina Tingkat I (Bintang Emas)', 'IV/B', 'Bintang Emas', NULL),
(699, 101, 'IV/C', 1, '2026-02-05 05:50:36', 15, 'IV (PEMBINA)', 'IV/C', 'Pembina Utama Muda (Bintang Emas)', 'IV/C', 'Bintang Emas', NULL),
(700, 101, 'IV/D', 1, '2026-02-05 05:50:36', 16, 'IV (PEMBINA)', 'IV/D', 'Pembina Utama Madya (Bintang Emas)', 'IV/D', 'Bintang Emas', NULL),
(701, 101, 'IV/E', 1, '2026-02-05 05:50:36', 17, 'IV (PEMBINA)', 'IV/E', 'Pembina Utama (Bintang Emas)', 'IV/E', 'Bintang Emas', NULL),
(716, 102, 'I/A', 1, '2026-02-05 05:50:36', 1, 'I (JURU)', 'I/A', 'Juru (1 Garis Miring Perak)', 'I/A', '1 Garis Miring Perak', NULL),
(717, 102, 'I/B', 1, '2026-02-05 05:50:36', 2, 'I (JURU)', 'I/B', 'Juru (2 Garis Miring Perak)', 'I/B', '2 Garis Miring Perak', NULL),
(718, 102, 'I/C', 1, '2026-02-05 05:50:36', 3, 'I (JURU)', 'I/C', 'Juru (3 Garis Miring Perak)', 'I/C', '3 Garis Miring Perak', NULL),
(719, 102, 'I/D', 1, '2026-02-05 05:50:36', 4, 'I (JURU)', 'I/D', 'Juru (4 Garis Miring Perak)', 'I/D', '4 Garis Miring Perak', NULL),
(720, 102, 'II/A', 1, '2026-02-05 05:50:36', 5, 'II (PENGATUR)', 'II/A', 'Pengatur Muda (1 Balok Perak)', 'II/A', '1 Balok Perak', NULL),
(721, 102, 'II/B', 1, '2026-02-05 05:50:36', 6, 'II (PENGATUR)', 'II/B', 'Pengatur Muda (2 Balok Perak)', 'II/B', '2 Balok Perak', NULL),
(722, 102, 'II/C', 1, '2026-02-05 05:50:36', 7, 'II (PENGATUR)', 'II/C', 'Pengatur (3 Balok Perak)', 'II/C', '3 Balok Perak', NULL),
(723, 102, 'II/D', 1, '2026-02-05 05:50:36', 8, 'II (PENGATUR)', 'II/D', 'Pengatur (4 Balok Perak)', 'II/D', '4 Balok Perak', NULL),
(724, 102, 'III/A', 1, '2026-02-05 05:50:36', 9, 'III (PENATA)', 'III/A', 'Penata Muda (1 Balok Emas)', 'III/A', '1 Balok Emas', NULL),
(725, 102, 'III/B', 1, '2026-02-05 05:50:36', 10, 'III (PENATA)', 'III/B', 'Penata Muda (2 Balok Emas)', 'III/B', '2 Balok Emas', NULL),
(726, 102, 'III/C', 1, '2026-02-05 05:50:36', 11, 'III (PENATA)', 'III/C', 'Penata (3 Balok Emas)', 'III/C', '3 Balok Emas', NULL),
(727, 102, 'III/D', 1, '2026-02-05 05:50:36', 12, 'III (PENATA)', 'III/D', 'Penata (4 Balok Emas)', 'III/D', '4 Balok Emas', NULL),
(728, 102, 'IV/A', 1, '2026-02-05 05:50:36', 13, 'IV (PEMBINA)', 'IV/A', 'Pembina (Bintang)', 'IV/A', 'Bintang', NULL),
(729, 102, 'IV/B', 1, '2026-02-05 05:50:36', 14, 'IV (PEMBINA)', 'IV/B', 'Pembina Tingkat I (Bintang)', 'IV/B', 'Bintang', NULL),
(730, 102, 'IV/C', 1, '2026-02-05 05:50:36', 15, 'IV (PEMBINA)', 'IV/C', 'Pembina Utama Muda (Bintang)', 'IV/C', 'Bintang', NULL),
(731, 102, 'IV/D', 1, '2026-02-05 05:50:36', 16, 'IV (PEMBINA)', 'IV/D', 'Pembina Utama Madya (Bintang)', 'IV/D', 'Bintang', NULL),
(732, 102, 'IV/E', 1, '2026-02-05 05:50:36', 17, 'IV (PEMBINA)', 'IV/E', 'Pembina Utama (Bintang)', 'IV/E', 'Bintang', NULL),
(747, 103, 'I/A', 1, '2026-02-05 05:50:36', 1, 'I (JURU)', 'I/A', 'Juru (1 Garis Miring Perak)', 'I/A', '1 Garis Miring Perak', NULL),
(748, 103, 'I/B', 1, '2026-02-05 05:50:36', 2, 'I (JURU)', 'I/B', 'Juru (2 Garis Miring Perak)', 'I/B', '2 Garis Miring Perak', NULL),
(749, 103, 'I/C', 1, '2026-02-05 05:50:36', 3, 'I (JURU)', 'I/C', 'Juru (3 Garis Miring Perak)', 'I/C', '3 Garis Miring Perak', NULL),
(750, 103, 'I/D', 1, '2026-02-05 05:50:36', 4, 'I (JURU)', 'I/D', 'Juru (4 Garis Miring Perak)', 'I/D', '4 Garis Miring Perak', NULL),
(751, 103, 'II/A', 1, '2026-02-05 05:50:36', 5, 'II (PENGATUR)', 'II/A', 'Pengatur Muda (1 Balok Perak)', 'II/A', '1 Balok Perak', NULL),
(752, 103, 'II/B', 1, '2026-02-05 05:50:36', 6, 'II (PENGATUR)', 'II/B', 'Pengatur Muda (2 Balok Perak)', 'II/B', '2 Balok Perak', NULL),
(753, 103, 'II/C', 1, '2026-02-05 05:50:36', 7, 'II (PENGATUR)', 'II/C', 'Pengatur (3 Balok Perak)', 'II/C', '3 Balok Perak', NULL),
(754, 103, 'II/D', 1, '2026-02-05 05:50:36', 8, 'II (PENGATUR)', 'II/D', 'Pengatur (4 Balok Perak)', 'II/D', '4 Balok Perak', NULL),
(755, 103, 'III/A', 1, '2026-02-05 05:50:36', 9, 'III (PENATA)', 'III/A', 'Penata Muda (1 Balok Emas)', 'III/A', '1 Balok Emas', NULL),
(756, 103, 'III/B', 1, '2026-02-05 05:50:36', 10, 'III (PENATA)', 'III/B', 'Penata Muda (2 Balok Emas)', 'III/B', '2 Balok Emas', NULL),
(757, 103, 'III/C', 1, '2026-02-05 05:50:36', 11, 'III (PENATA)', 'III/C', 'Penata (3 Balok Emas)', 'III/C', '3 Balok Emas', NULL),
(758, 103, 'III/D', 1, '2026-02-05 05:50:36', 12, 'III (PENATA)', 'III/D', 'Penata (4 Balok Emas)', 'III/D', '4 Balok Emas', NULL),
(759, 103, 'IV/A', 1, '2026-02-05 05:50:36', 13, 'IV (PEMBINA)', 'IV/A', 'Pembina (Bintang)', 'IV/A', 'Bintang', NULL),
(760, 103, 'IV/B', 1, '2026-02-05 05:50:36', 14, 'IV (PEMBINA)', 'IV/B', 'Pembina Tingkat I (Bintang)', 'IV/B', 'Bintang', NULL),
(761, 103, 'IV/C', 1, '2026-02-05 05:50:36', 15, 'IV (PEMBINA)', 'IV/C', 'Pembina Utama Muda (Bintang)', 'IV/C', 'Bintang', NULL),
(762, 103, 'IV/D', 1, '2026-02-05 05:50:36', 16, 'IV (PEMBINA)', 'IV/D', 'Pembina Utama Madya (Bintang)', 'IV/D', 'Bintang', NULL),
(763, 103, 'IV/E', 1, '2026-02-05 05:50:36', 17, 'IV (PEMBINA)', 'IV/E', 'Pembina Utama (Bintang)', 'IV/E', 'Bintang', NULL);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `people_complete_addresses`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `people_complete_addresses` (
`id` int(11)
,`user_id` int(11)
,`address_type` enum('home','work','other')
,`is_primary` tinyint(1)
,`country` varchar(100)
,`province_id` int(11)
,`regency_id` int(11)
,`district_id` int(11)
,`village_id` int(11)
,`postal_code` varchar(20)
,`street_address` varchar(255)
,`alamat_detil` varchar(255)
,`latitude` decimal(10,8)
,`longitude` decimal(11,8)
,`alamat_db_source` tinyint(1)
,`address_verified` tinyint(1)
,`created_at` timestamp
,`province_name` varchar(100)
,`regency_name` varchar(100)
,`district_name` varchar(100)
,`village_name` varchar(100)
,`complete_address` text
,`user_name` varchar(255)
,`user_email` varchar(255)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `people_complete_addresses_enhanced`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `people_complete_addresses_enhanced` (
`id` int(11)
,`user_id` int(11)
,`address_type` enum('home','work','other')
,`is_primary` tinyint(1)
,`country` varchar(100)
,`province_id` int(11)
,`regency_id` int(11)
,`district_id` int(11)
,`village_id` int(11)
,`postal_code` varchar(20)
,`street_address` varchar(255)
,`alamat_detil` varchar(255)
,`latitude` decimal(10,8)
,`longitude` decimal(11,8)
,`alamat_db_source` tinyint(1)
,`address_verified` tinyint(1)
,`created_at` timestamp
,`house_number` varchar(20)
,`building_number` varchar(20)
,`unit_number` varchar(20)
,`floor_number` varchar(10)
,`rt_number` varchar(10)
,`rw_number` varchar(10)
,`complex_name` varchar(100)
,`gate_number` varchar(20)
,`special_instructions` text
,`user_landmark` varchar(255)
,`building_type_id` int(11)
,`province_name` varchar(100)
,`regency_name` varchar(100)
,`district_name` varchar(100)
,`village_name` varchar(100)
,`street_name` varchar(255)
,`street_type` enum('jalan','gang','lorong','komplek','perumahan','jalan raya','boulevard','avenue')
,`street_postal_code` varchar(10)
,`extended_postal_code` varchar(10)
,`landmark_name` varchar(255)
,`landmark_type` enum('masjid','gereja','sekolah','rumah sakit','pasar','kantor','tugu','jembatan','sungai','lainnya')
,`building_type` varchar(100)
,`building_category` enum('residential','commercial','industrial','public','mixed')
,`complete_address` text
,`user_name` varchar(255)
,`user_email` varchar(255)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `physical_attributes`
--

CREATE TABLE `physical_attributes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `tinggi_badan` int(11) DEFAULT NULL,
  `berat_badan` decimal(5,2) DEFAULT NULL,
  `warna_rambut` varchar(50) DEFAULT NULL,
  `warna_kulit` varchar(50) DEFAULT NULL,
  `warna_mata` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `preferences`
--

CREATE TABLE `preferences` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `preference` varchar(255) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `reference_contacts`
--

CREATE TABLE `reference_contacts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `relation` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `religions`
--

CREATE TABLE `religions` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `religions`
--

INSERT INTO `religions` (`id`, `name`) VALUES
(5, 'Buddha'),
(4, 'Hindu'),
(1, 'Islam'),
(3, 'Katolik'),
(6, 'Konghucu'),
(2, 'Kristen'),
(7, 'Lainnya');

-- --------------------------------------------------------

--
-- Struktur dari tabel `skills`
--

CREATE TABLE `skills` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `skill_name` varchar(100) NOT NULL,
  `proficiency_level` enum('beginner','intermediate','advanced','expert') DEFAULT 'intermediate',
  `years_of_experience` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `social_profiles`
--

CREATE TABLE `social_profiles` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `platform` varchar(50) NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `username` varchar(100) DEFAULT NULL,
  `followers_count` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `travel_history`
--

CREATE TABLE `travel_history` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `country` varchar(100) DEFAULT NULL,
  `purpose` varchar(100) DEFAULT NULL,
  `date_from` date DEFAULT NULL,
  `date_to` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `status` enum('active','inactive','pending') DEFAULT 'pending',
  `preferred_channel` enum('email','sms','wa','push') DEFAULT 'email',
  `preferred_language` varchar(10) DEFAULT 'id',
  `timezone` varchar(50) DEFAULT 'Asia/Jakarta',
  `mfa_enabled` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `nama`, `email`, `phone`, `password_hash`, `status`, `preferred_channel`, `preferred_language`, `timezone`, `mfa_enabled`, `created_at`, `updated_at`) VALUES
(1, 'ADMIN PALING BAIK DI DUNIA', '82080038@koperasi.com', '081910457868', '$2y$10$N.UC2TY6FU5wt70.9cfHvOeCia0FRj.tGZYmsu57jK/a9il9UPP2e', 'active', 'email', 'id', 'Asia/Jakarta', 0, '2026-02-04 17:27:52', '2026-02-04 20:02:03'),
(2, 'Test User', 'test@example.com', '08123456789', 'test_hash', 'active', 'email', 'id', 'Asia/Jakarta', 0, '2026-03-24 19:36:46', '2026-03-24 19:36:46');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `user_address_summary`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `user_address_summary` (
`user_id` int(11)
,`user_name` varchar(255)
,`user_email` varchar(255)
,`address_category` enum('personal','professional','logistics','legal','other')
,`address_count` bigint(21)
,`verified_count` decimal(22,0)
,`primary_count` decimal(22,0)
,`primary_address` mediumtext
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `user_identity_documents`
--

CREATE TABLE `user_identity_documents` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `identity_type_id` int(11) NOT NULL,
  `document_number` varchar(50) DEFAULT NULL,
  `issued_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `issuing_authority` varchar(255) DEFAULT NULL,
  `document_path` varchar(255) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `verified_by` int(11) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `user_multiple_addresses`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `user_multiple_addresses` (
`id` int(11)
,`user_id` int(11)
,`address_type` enum('home','work','other')
,`address_category` enum('personal','professional','logistics','legal','other')
,`address_purpose` varchar(50)
,`purpose_name` varchar(100)
,`purpose_category` enum('personal','professional','logistics','legal','other')
,`purpose_description` text
,`priority_level` enum('primary','secondary','tertiary','emergency')
,`is_primary` tinyint(1)
,`is_mailing_address` tinyint(1)
,`is_billing_address` tinyint(1)
,`is_shipping_address` tinyint(1)
,`is_work_address` tinyint(1)
,`is_emergency_address` tinyint(1)
,`country` varchar(100)
,`province_id` int(11)
,`regency_id` int(11)
,`district_id` int(11)
,`village_id` int(11)
,`postal_code` varchar(20)
,`street_address` varchar(255)
,`alamat_detil` varchar(255)
,`house_number` varchar(20)
,`building_number` varchar(20)
,`unit_number` varchar(20)
,`floor_number` varchar(10)
,`rt_number` varchar(10)
,`rw_number` varchar(10)
,`complex_name` varchar(100)
,`gate_number` varchar(20)
,`special_instructions` text
,`user_landmark` varchar(255)
,`building_type_id` int(11)
,`latitude` decimal(10,8)
,`longitude` decimal(11,8)
,`cooperative_id` int(11)
,`verification_status` enum('unverified','pending','verified','rejected')
,`verification_date` timestamp
,`verification_method` enum('document','visit','phone','email','self_certify')
,`effective_date` date
,`expiry_date` date
,`last_used_date` timestamp
,`usage_count` int(11)
,`notes` text
,`created_at` timestamp
,`province_name` varchar(100)
,`regency_name` varchar(100)
,`district_name` varchar(100)
,`village_name` varchar(100)
,`street_name` varchar(255)
,`street_type` enum('jalan','gang','lorong','komplek','perumahan','jalan raya','boulevard','avenue')
,`extended_postal_code` varchar(10)
,`landmark_name` varchar(255)
,`landmark_type` enum('masjid','gereja','sekolah','rumah sakit','pasar','kantor','tugu','jembatan','sungai','lainnya')
,`building_type` varchar(100)
,`building_category` enum('residential','commercial','industrial','public','mixed')
,`user_name` varchar(255)
,`user_email` varchar(255)
,`complete_address` text
,`verification_status_text` varchar(19)
,`priority_text` varchar(15)
,`category_text` varchar(11)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `user_primary_addresses`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `user_primary_addresses` (
`user_id` int(11)
,`user_name` varchar(255)
,`user_email` varchar(255)
,`primary_address` mediumtext
,`primary_address_id` bigint(11)
,`mailing_address` mediumtext
,`mailing_address_id` bigint(11)
,`billing_address` mediumtext
,`billing_address_id` bigint(11)
,`shipping_address` mediumtext
,`shipping_address_id` bigint(11)
,`work_address` mediumtext
,`work_address_id` bigint(11)
,`emergency_address` mediumtext
,`emergency_address_id` bigint(11)
,`total_addresses` bigint(21)
,`verified_addresses` decimal(22,0)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_identities_masked`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_identities_masked` (
`id` int(11)
,`user_id` int(11)
,`nik_masked` varchar(16)
,`kk_masked` varchar(16)
,`passport_masked` varchar(6)
,`sim_masked` varchar(6)
,`status` enum('draft','complete','verified')
,`verified` tinyint(1)
,`pep_flag` tinyint(1)
,`risk_score` enum('low','medium','high')
,`kyc_last_review_at` timestamp
,`kyc_next_review_at` timestamp
);

-- --------------------------------------------------------

--
-- Struktur untuk view `people_complete_addresses`
--
DROP TABLE IF EXISTS `people_complete_addresses`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `people_complete_addresses`  AS SELECT `a`.`id` AS `id`, `a`.`user_id` AS `user_id`, `a`.`address_type` AS `address_type`, `a`.`is_primary` AS `is_primary`, `a`.`country` AS `country`, `a`.`province_id` AS `province_id`, `a`.`regency_id` AS `regency_id`, `a`.`district_id` AS `district_id`, `a`.`village_id` AS `village_id`, `a`.`postal_code` AS `postal_code`, `a`.`street_address` AS `street_address`, `a`.`alamat_detil` AS `alamat_detil`, `a`.`latitude` AS `latitude`, `a`.`longitude` AS `longitude`, `a`.`alamat_db_source` AS `alamat_db_source`, `a`.`address_verified` AS `address_verified`, `a`.`created_at` AS `created_at`, `p`.`name` AS `province_name`, `r`.`name` AS `regency_name`, `d`.`name` AS `district_name`, `v`.`name` AS `village_name`, concat(coalesce(`a`.`alamat_detil`,`a`.`street_address`,''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`a`.`postal_code`,`v`.`postal_code`,`r`.`postal_code`,'')) AS `complete_address`, `u`.`nama` AS `user_name`, `u`.`email` AS `user_email` FROM (((((`addresses` `a` left join `alamat_db`.`provinces` `p` on(`a`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`a`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`a`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`a`.`village_id` = `v`.`id`)) left join `users` `u` on(`a`.`user_id` = `u`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `people_complete_addresses_enhanced`
--
DROP TABLE IF EXISTS `people_complete_addresses_enhanced`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `people_complete_addresses_enhanced`  AS SELECT `a`.`id` AS `id`, `a`.`user_id` AS `user_id`, `a`.`address_type` AS `address_type`, `a`.`is_primary` AS `is_primary`, `a`.`country` AS `country`, `a`.`province_id` AS `province_id`, `a`.`regency_id` AS `regency_id`, `a`.`district_id` AS `district_id`, `a`.`village_id` AS `village_id`, `a`.`postal_code` AS `postal_code`, `a`.`street_address` AS `street_address`, `a`.`alamat_detil` AS `alamat_detil`, `a`.`latitude` AS `latitude`, `a`.`longitude` AS `longitude`, `a`.`alamat_db_source` AS `alamat_db_source`, `a`.`address_verified` AS `address_verified`, `a`.`created_at` AS `created_at`, `a`.`house_number` AS `house_number`, `a`.`building_number` AS `building_number`, `a`.`unit_number` AS `unit_number`, `a`.`floor_number` AS `floor_number`, `a`.`rt_number` AS `rt_number`, `a`.`rw_number` AS `rw_number`, `a`.`complex_name` AS `complex_name`, `a`.`gate_number` AS `gate_number`, `a`.`special_instructions` AS `special_instructions`, `a`.`user_landmark` AS `user_landmark`, `a`.`building_type_id` AS `building_type_id`, `p`.`name` AS `province_name`, `r`.`name` AS `regency_name`, `d`.`name` AS `district_name`, `v`.`name` AS `village_name`, `s`.`street_name` AS `street_name`, `s`.`street_type` AS `street_type`, `s`.`postal_code` AS `street_postal_code`, `pc`.`postal_code` AS `extended_postal_code`, `l`.`landmark_name` AS `landmark_name`, `l`.`landmark_type` AS `landmark_type`, `bt`.`building_type` AS `building_type`, `bt`.`category` AS `building_category`, concat(coalesce(`a`.`alamat_detil`,`a`.`street_address`,''),', ',coalesce(`a`.`house_number`,''),' ',coalesce(`a`.`building_number`,''),' ',coalesce(`s`.`street_type`,''),' ',coalesce(`s`.`street_name`,''),', ',coalesce(concat('RT ',`a`.`rt_number`),''),' ',coalesce(concat('RW ',`a`.`rw_number`),''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`a`.`postal_code`,`v`.`postal_code`,`r`.`postal_code`,`pc`.`postal_code`,'')) AS `complete_address`, `u`.`nama` AS `user_name`, `u`.`email` AS `user_email` FROM (((((((((`addresses` `a` left join `alamat_db`.`provinces` `p` on(`a`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`a`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`a`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`a`.`village_id` = `v`.`id`)) left join `alamat_db`.`streets` `s` on(`s`.`village_id` = `v`.`id` and `a`.`street_address` like concat('%',`s`.`street_name`,'%'))) left join `alamat_db`.`postal_codes_extended` `pc` on(`pc`.`village_id` = `v`.`id`)) left join `alamat_db`.`landmarks` `l` on(`l`.`village_id` = `v`.`id`)) left join `alamat_db`.`building_types` `bt` on(`a`.`building_type_id` = `bt`.`id`)) left join `users` `u` on(`a`.`user_id` = `u`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `user_address_summary`
--
DROP TABLE IF EXISTS `user_address_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_address_summary`  AS SELECT `user_multiple_addresses`.`user_id` AS `user_id`, `user_multiple_addresses`.`user_name` AS `user_name`, `user_multiple_addresses`.`user_email` AS `user_email`, `user_multiple_addresses`.`address_category` AS `address_category`, count(0) AS `address_count`, sum(case when `user_multiple_addresses`.`verification_status` = 'verified' then 1 else 0 end) AS `verified_count`, sum(case when `user_multiple_addresses`.`is_primary` = 1 then 1 else 0 end) AS `primary_count`, max(case when `user_multiple_addresses`.`priority_level` = 'primary' then `user_multiple_addresses`.`complete_address` end) AS `primary_address` FROM `user_multiple_addresses` GROUP BY `user_multiple_addresses`.`user_id`, `user_multiple_addresses`.`user_name`, `user_multiple_addresses`.`user_email`, `user_multiple_addresses`.`address_category` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `user_multiple_addresses`
--
DROP TABLE IF EXISTS `user_multiple_addresses`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_multiple_addresses`  AS SELECT `a`.`id` AS `id`, `a`.`user_id` AS `user_id`, `a`.`address_type` AS `address_type`, `a`.`address_category` AS `address_category`, `a`.`address_purpose` AS `address_purpose`, `ap`.`purpose_name` AS `purpose_name`, `ap`.`purpose_category` AS `purpose_category`, `ap`.`description` AS `purpose_description`, `a`.`priority_level` AS `priority_level`, `a`.`is_primary` AS `is_primary`, `a`.`is_mailing_address` AS `is_mailing_address`, `a`.`is_billing_address` AS `is_billing_address`, `a`.`is_shipping_address` AS `is_shipping_address`, `a`.`is_work_address` AS `is_work_address`, `a`.`is_emergency_address` AS `is_emergency_address`, `a`.`country` AS `country`, `a`.`province_id` AS `province_id`, `a`.`regency_id` AS `regency_id`, `a`.`district_id` AS `district_id`, `a`.`village_id` AS `village_id`, `a`.`postal_code` AS `postal_code`, `a`.`street_address` AS `street_address`, `a`.`alamat_detil` AS `alamat_detil`, `a`.`house_number` AS `house_number`, `a`.`building_number` AS `building_number`, `a`.`unit_number` AS `unit_number`, `a`.`floor_number` AS `floor_number`, `a`.`rt_number` AS `rt_number`, `a`.`rw_number` AS `rw_number`, `a`.`complex_name` AS `complex_name`, `a`.`gate_number` AS `gate_number`, `a`.`special_instructions` AS `special_instructions`, `a`.`user_landmark` AS `user_landmark`, `a`.`building_type_id` AS `building_type_id`, `a`.`latitude` AS `latitude`, `a`.`longitude` AS `longitude`, `a`.`cooperative_id` AS `cooperative_id`, `a`.`verification_status` AS `verification_status`, `a`.`verification_date` AS `verification_date`, `a`.`verification_method` AS `verification_method`, `a`.`effective_date` AS `effective_date`, `a`.`expiry_date` AS `expiry_date`, `a`.`last_used_date` AS `last_used_date`, `a`.`usage_count` AS `usage_count`, `a`.`notes` AS `notes`, `a`.`created_at` AS `created_at`, `p`.`name` AS `province_name`, `r`.`name` AS `regency_name`, `d`.`name` AS `district_name`, `v`.`name` AS `village_name`, `s`.`street_name` AS `street_name`, `s`.`street_type` AS `street_type`, `pc`.`postal_code` AS `extended_postal_code`, `l`.`landmark_name` AS `landmark_name`, `l`.`landmark_type` AS `landmark_type`, `bt`.`building_type` AS `building_type`, `bt`.`category` AS `building_category`, `u`.`nama` AS `user_name`, `u`.`email` AS `user_email`, concat(coalesce(`a`.`alamat_detil`,`a`.`street_address`,''),', ',coalesce(`a`.`house_number`,''),' ',coalesce(`a`.`building_number`,''),' ',coalesce(`s`.`street_type`,''),' ',coalesce(`s`.`street_name`,''),', ',coalesce(concat('RT ',`a`.`rt_number`),''),' ',coalesce(concat('RW ',`a`.`rw_number`),''),', ',coalesce(`a`.`complex_name`,''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`a`.`postal_code`,`v`.`postal_code`,`r`.`postal_code`,`pc`.`postal_code`,'')) AS `complete_address`, CASE WHEN `a`.`verification_status` = 'verified' THEN 'Terverifikasi' WHEN `a`.`verification_status` = 'pending' THEN 'Menunggu Verifikasi' WHEN `a`.`verification_status` = 'rejected' THEN 'Ditolak' ELSE 'Belum Terverifikasi' END AS `verification_status_text`, CASE WHEN `a`.`priority_level` = 'primary' THEN 'Utama' WHEN `a`.`priority_level` = 'secondary' THEN 'Sekunder' WHEN `a`.`priority_level` = 'tertiary' THEN 'Tersier' WHEN `a`.`priority_level` = 'emergency' THEN 'Darurat' ELSE 'Tidak Diketahui' END AS `priority_text`, CASE WHEN `a`.`address_category` = 'personal' THEN 'Pribadi' WHEN `a`.`address_category` = 'professional' THEN 'Profesional' WHEN `a`.`address_category` = 'logistics' THEN 'Logistik' WHEN `a`.`address_category` = 'legal' THEN 'Legal' ELSE 'Lainnya' END AS `category_text` FROM ((((((((((`addresses` `a` left join `address_purposes` `ap` on(`a`.`address_purpose` = `ap`.`purpose_code`)) left join `alamat_db`.`provinces` `p` on(`a`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`a`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`a`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`a`.`village_id` = `v`.`id`)) left join `alamat_db`.`streets` `s` on(`s`.`village_id` = `v`.`id` and `a`.`street_address` like concat('%',`s`.`street_name`,'%'))) left join `alamat_db`.`postal_codes_extended` `pc` on(`pc`.`village_id` = `v`.`id`)) left join `alamat_db`.`landmarks` `l` on(`l`.`village_id` = `v`.`id`)) left join `alamat_db`.`building_types` `bt` on(`a`.`building_type_id` = `bt`.`id`)) left join `users` `u` on(`a`.`user_id` = `u`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `user_primary_addresses`
--
DROP TABLE IF EXISTS `user_primary_addresses`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_primary_addresses`  AS SELECT `user_multiple_addresses`.`user_id` AS `user_id`, `user_multiple_addresses`.`user_name` AS `user_name`, `user_multiple_addresses`.`user_email` AS `user_email`, max(case when `user_multiple_addresses`.`priority_level` = 'primary' then `user_multiple_addresses`.`complete_address` end) AS `primary_address`, max(case when `user_multiple_addresses`.`priority_level` = 'primary' then `user_multiple_addresses`.`id` end) AS `primary_address_id`, max(case when `user_multiple_addresses`.`is_mailing_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `mailing_address`, max(case when `user_multiple_addresses`.`is_mailing_address` = 1 then `user_multiple_addresses`.`id` end) AS `mailing_address_id`, max(case when `user_multiple_addresses`.`is_billing_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `billing_address`, max(case when `user_multiple_addresses`.`is_billing_address` = 1 then `user_multiple_addresses`.`id` end) AS `billing_address_id`, max(case when `user_multiple_addresses`.`is_shipping_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `shipping_address`, max(case when `user_multiple_addresses`.`is_shipping_address` = 1 then `user_multiple_addresses`.`id` end) AS `shipping_address_id`, max(case when `user_multiple_addresses`.`is_work_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `work_address`, max(case when `user_multiple_addresses`.`is_work_address` = 1 then `user_multiple_addresses`.`id` end) AS `work_address_id`, max(case when `user_multiple_addresses`.`is_emergency_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `emergency_address`, max(case when `user_multiple_addresses`.`is_emergency_address` = 1 then `user_multiple_addresses`.`id` end) AS `emergency_address_id`, count(0) AS `total_addresses`, sum(case when `user_multiple_addresses`.`verification_status` = 'verified' then 1 else 0 end) AS `verified_addresses` FROM `user_multiple_addresses` GROUP BY `user_multiple_addresses`.`user_id`, `user_multiple_addresses`.`user_name`, `user_multiple_addresses`.`user_email` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_identities_masked`
--
DROP TABLE IF EXISTS `v_identities_masked`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_identities_masked`  AS SELECT `identities`.`id` AS `id`, `identities`.`user_id` AS `user_id`, concat(repeat('X',12),right(`identities`.`nik`,4)) AS `nik_masked`, concat(repeat('X',12),right(`identities`.`nomor_kk`,4)) AS `kk_masked`, concat('***',right(`identities`.`nomor_passport`,3)) AS `passport_masked`, concat('***',right(`identities`.`nomor_sim`,3)) AS `sim_masked`, `identities`.`status` AS `status`, `identities`.`verified` AS `verified`, `identities`.`pep_flag` AS `pep_flag`, `identities`.`risk_score` AS `risk_score`, `identities`.`kyc_last_review_at` AS `kyc_last_review_at`, `identities`.`kyc_next_review_at` AS `kyc_next_review_at` FROM `identities` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_addresses_region` (`province_id`,`city_id`,`village_id`),
  ADD KEY `idx_address_cooperative` (`cooperative_id`),
  ADD KEY `idx_alamat_ids` (`province_id`,`regency_id`,`district_id`,`village_id`),
  ADD KEY `idx_alamat_source` (`alamat_db_source`),
  ADD KEY `idx_address_verified` (`address_verified`),
  ADD KEY `idx_house_number` (`house_number`),
  ADD KEY `idx_building_number` (`building_number`),
  ADD KEY `idx_unit_number` (`unit_number`),
  ADD KEY `idx_rt_rw` (`rt_number`,`rw_number`),
  ADD KEY `idx_complex_name` (`complex_name`),
  ADD KEY `idx_user_category` (`user_id`,`address_category`),
  ADD KEY `idx_user_purpose` (`user_id`,`address_purpose`),
  ADD KEY `idx_priority_level` (`priority_level`),
  ADD KEY `idx_mailing_address` (`is_mailing_address`),
  ADD KEY `idx_billing_address` (`is_billing_address`),
  ADD KEY `idx_shipping_address` (`is_shipping_address`),
  ADD KEY `idx_work_address` (`is_work_address`),
  ADD KEY `idx_emergency_address` (`is_emergency_address`),
  ADD KEY `idx_verification_status` (`verification_status`),
  ADD KEY `idx_effective_period` (`effective_date`,`expiry_date`),
  ADD KEY `idx_usage_count` (`usage_count`);

--
-- Indeks untuk tabel `address_history`
--
ALTER TABLE `address_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_address_history` (`address_id`,`change_timestamp`),
  ADD KEY `idx_user_history` (`user_id`,`change_timestamp`),
  ADD KEY `idx_action_type` (`action_type`),
  ADD KEY `idx_change_timestamp` (`change_timestamp`);

--
-- Indeks untuk tabel `address_purposes`
--
ALTER TABLE `address_purposes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `purpose_code` (`purpose_code`),
  ADD KEY `idx_purpose_code` (`purpose_code`),
  ADD KEY `idx_purpose_category` (`purpose_category`),
  ADD KEY `idx_is_active` (`is_active`);

--
-- Indeks untuk tabel `address_usage_log`
--
ALTER TABLE `address_usage_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_address_usage` (`address_id`,`usage_timestamp`),
  ADD KEY `idx_user_usage` (`user_id`,`usage_timestamp`),
  ADD KEY `idx_usage_type` (`usage_type`),
  ADD KEY `idx_usage_timestamp` (`usage_timestamp`),
  ADD KEY `idx_reference` (`reference_type`,`reference_id`);

--
-- Indeks untuk tabel `allowed_databases`
--
ALTER TABLE `allowed_databases`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `db_name` (`db_name`);

--
-- Indeks untuk tabel `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `performed_by` (`performed_by`),
  ADD KEY `idx_audit_logs_user_time` (`user_id`,`timestamp`);

--
-- Indeks untuk tabel `blood_types`
--
ALTER TABLE `blood_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `certifications`
--
ALTER TABLE `certifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `consents`
--
ALTER TABLE `consents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `contact_emails`
--
ALTER TABLE `contact_emails`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_contact_emails_user_email` (`user_id`,`email`),
  ADD KEY `idx_contact_emails_hash` (`email_hash`),
  ADD KEY `idx_contact_emails_primary` (`user_id`,`is_primary`);

--
-- Indeks untuk tabel `contact_phones`
--
ALTER TABLE `contact_phones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_contact_phones_user_phone` (`user_id`,`phone`),
  ADD KEY `idx_contact_phones_hash` (`phone_hash`),
  ADD KEY `idx_contact_phones_primary` (`user_id`,`is_primary`);

--
-- Indeks untuk tabel `data_subject_requests`
--
ALTER TABLE `data_subject_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dsr_user_status` (`user_id`,`status`);

--
-- Indeks untuk tabel `education_records`
--
ALTER TABLE `education_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_education_institution` (`institution`);

--
-- Indeks untuk tabel `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `employment_records`
--
ALTER TABLE `employment_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_employment_company` (`company`);

--
-- Indeks untuk tabel `ethnicities`
--
ALTER TABLE `ethnicities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `family_members`
--
ALTER TABLE `family_members`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `financial_info`
--
ALTER TABLE `financial_info`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `genders`
--
ALTER TABLE `genders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `health_records`
--
ALTER TABLE `health_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `identities`
--
ALTER TABLE `identities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nik` (`nik`),
  ADD KEY `gender_id` (`gender_id`),
  ADD KEY `marital_status_id` (`marital_status_id`),
  ADD KEY `religion_id` (`religion_id`),
  ADD KEY `ethnicity_id` (`ethnicity_id`),
  ADD KEY `blood_type_id` (`blood_type_id`),
  ADD KEY `idx_identities_user` (`user_id`),
  ADD KEY `idx_identities_nomor_kk` (`nomor_kk`),
  ADD KEY `idx_identities_pep` (`pep_flag`),
  ADD KEY `idx_identities_risk` (`risk_score`),
  ADD KEY `idx_identities_kyc_next_review` (`kyc_next_review_at`);

--
-- Indeks untuk tabel `identity_types`
--
ALTER TABLE `identity_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `languages`
--
ALTER TABLE `languages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `life_events`
--
ALTER TABLE `life_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `marital_statuses`
--
ALTER TABLE `marital_statuses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `occupations`
--
ALTER TABLE `occupations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `occupation_ranks`
--
ALTER TABLE `occupation_ranks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `occupation_id` (`occupation_id`);

--
-- Indeks untuk tabel `physical_attributes`
--
ALTER TABLE `physical_attributes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `preferences`
--
ALTER TABLE `preferences`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `reference_contacts`
--
ALTER TABLE `reference_contacts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `religions`
--
ALTER TABLE `religions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `skills`
--
ALTER TABLE `skills`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `social_profiles`
--
ALTER TABLE `social_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_social_platform_user` (`platform`,`username`);

--
-- Indeks untuk tabel `travel_history`
--
ALTER TABLE `travel_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indeks untuk tabel `user_identity_documents`
--
ALTER TABLE `user_identity_documents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `document_number` (`document_number`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `identity_type_id` (`identity_type_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `address_history`
--
ALTER TABLE `address_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `address_purposes`
--
ALTER TABLE `address_purposes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT untuk tabel `address_usage_log`
--
ALTER TABLE `address_usage_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `allowed_databases`
--
ALTER TABLE `allowed_databases`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `blood_types`
--
ALTER TABLE `blood_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `certifications`
--
ALTER TABLE `certifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `consents`
--
ALTER TABLE `consents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `contact_emails`
--
ALTER TABLE `contact_emails`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `contact_phones`
--
ALTER TABLE `contact_phones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `data_subject_requests`
--
ALTER TABLE `data_subject_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `education_records`
--
ALTER TABLE `education_records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `employment_records`
--
ALTER TABLE `employment_records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `ethnicities`
--
ALTER TABLE `ethnicities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `family_members`
--
ALTER TABLE `family_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `financial_info`
--
ALTER TABLE `financial_info`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `genders`
--
ALTER TABLE `genders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `health_records`
--
ALTER TABLE `health_records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `identities`
--
ALTER TABLE `identities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `identity_types`
--
ALTER TABLE `identity_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `languages`
--
ALTER TABLE `languages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `life_events`
--
ALTER TABLE `life_events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `marital_statuses`
--
ALTER TABLE `marital_statuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `occupations`
--
ALTER TABLE `occupations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;

--
-- AUTO_INCREMENT untuk tabel `occupation_ranks`
--
ALTER TABLE `occupation_ranks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=764;

--
-- AUTO_INCREMENT untuk tabel `physical_attributes`
--
ALTER TABLE `physical_attributes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `preferences`
--
ALTER TABLE `preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `reference_contacts`
--
ALTER TABLE `reference_contacts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `religions`
--
ALTER TABLE `religions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `skills`
--
ALTER TABLE `skills`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `social_profiles`
--
ALTER TABLE `social_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `travel_history`
--
ALTER TABLE `travel_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `user_identity_documents`
--
ALTER TABLE `user_identity_documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `address_history`
--
ALTER TABLE `address_history`
  ADD CONSTRAINT `address_history_ibfk_1` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `address_history_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `address_usage_log`
--
ALTER TABLE `address_usage_log`
  ADD CONSTRAINT `address_usage_log_ibfk_1` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `address_usage_log_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `audit_logs_ibfk_2` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `certifications`
--
ALTER TABLE `certifications`
  ADD CONSTRAINT `certifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `consents`
--
ALTER TABLE `consents`
  ADD CONSTRAINT `consents_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `contact_emails`
--
ALTER TABLE `contact_emails`
  ADD CONSTRAINT `contact_emails_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `contact_phones`
--
ALTER TABLE `contact_phones`
  ADD CONSTRAINT `contact_phones_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `data_subject_requests`
--
ALTER TABLE `data_subject_requests`
  ADD CONSTRAINT `data_subject_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `education_records`
--
ALTER TABLE `education_records`
  ADD CONSTRAINT `education_records_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  ADD CONSTRAINT `emergency_contacts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `employment_records`
--
ALTER TABLE `employment_records`
  ADD CONSTRAINT `employment_records_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `family_members`
--
ALTER TABLE `family_members`
  ADD CONSTRAINT `family_members_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `financial_info`
--
ALTER TABLE `financial_info`
  ADD CONSTRAINT `financial_info_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `health_records`
--
ALTER TABLE `health_records`
  ADD CONSTRAINT `health_records_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `identities`
--
ALTER TABLE `identities`
  ADD CONSTRAINT `identities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `identities_ibfk_2` FOREIGN KEY (`gender_id`) REFERENCES `genders` (`id`),
  ADD CONSTRAINT `identities_ibfk_3` FOREIGN KEY (`marital_status_id`) REFERENCES `marital_statuses` (`id`),
  ADD CONSTRAINT `identities_ibfk_4` FOREIGN KEY (`religion_id`) REFERENCES `religions` (`id`),
  ADD CONSTRAINT `identities_ibfk_5` FOREIGN KEY (`ethnicity_id`) REFERENCES `ethnicities` (`id`),
  ADD CONSTRAINT `identities_ibfk_6` FOREIGN KEY (`blood_type_id`) REFERENCES `blood_types` (`id`);

--
-- Ketidakleluasaan untuk tabel `languages`
--
ALTER TABLE `languages`
  ADD CONSTRAINT `languages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `life_events`
--
ALTER TABLE `life_events`
  ADD CONSTRAINT `life_events_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `occupation_ranks`
--
ALTER TABLE `occupation_ranks`
  ADD CONSTRAINT `occupation_ranks_ibfk_1` FOREIGN KEY (`occupation_id`) REFERENCES `occupations` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `physical_attributes`
--
ALTER TABLE `physical_attributes`
  ADD CONSTRAINT `physical_attributes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `preferences`
--
ALTER TABLE `preferences`
  ADD CONSTRAINT `preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `reference_contacts`
--
ALTER TABLE `reference_contacts`
  ADD CONSTRAINT `reference_contacts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `skills`
--
ALTER TABLE `skills`
  ADD CONSTRAINT `skills_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `social_profiles`
--
ALTER TABLE `social_profiles`
  ADD CONSTRAINT `social_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `travel_history`
--
ALTER TABLE `travel_history`
  ADD CONSTRAINT `travel_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `user_identity_documents`
--
ALTER TABLE `user_identity_documents`
  ADD CONSTRAINT `user_identity_documents_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_identity_documents_ibfk_2` FOREIGN KEY (`identity_type_id`) REFERENCES `identity_types` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
