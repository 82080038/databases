-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: people_db
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `address_history`
--

DROP TABLE IF EXISTS `address_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action_type` enum('created','updated','deleted','verified','deactivated','reactivated') NOT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `changed_by_user_id` int(11) DEFAULT NULL,
  `changed_by_system` tinyint(1) DEFAULT 0,
  `change_reason` text DEFAULT NULL,
  `change_timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_address_history` (`address_id`,`change_timestamp`),
  KEY `idx_user_history` (`user_id`,`change_timestamp`),
  KEY `idx_action_type` (`action_type`),
  KEY `idx_change_timestamp` (`change_timestamp`),
  CONSTRAINT `address_history_ibfk_1` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `address_history_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address_history`
--

LOCK TABLES `address_history` WRITE;
/*!40000 ALTER TABLE `address_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `address_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `address_purposes`
--

DROP TABLE IF EXISTS `address_purposes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address_purposes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purpose_code` varchar(50) NOT NULL,
  `purpose_name` varchar(100) NOT NULL,
  `purpose_category` enum('personal','professional','logistics','legal','other') NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `requires_verification` tinyint(1) DEFAULT 0,
  `default_priority` enum('primary','secondary','tertiary','emergency') DEFAULT 'secondary',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `purpose_code` (`purpose_code`),
  KEY `idx_purpose_code` (`purpose_code`),
  KEY `idx_purpose_category` (`purpose_category`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address_purposes`
--

LOCK TABLES `address_purposes` WRITE;
/*!40000 ALTER TABLE `address_purposes` DISABLE KEYS */;
INSERT INTO `address_purposes` VALUES (1,'home','Rumah Tinggal','personal','Alamat tempat tinggal utama',1,1,'primary','2026-03-24 19:46:19'),(2,'boarding','Kos/Boarding','personal','Alamat tempat tinggal sementara',1,1,'secondary','2026-03-24 19:46:19'),(3,'parents','Orang Tua','personal','Alamat orang tua/wali',1,0,'secondary','2026-03-24 19:46:19'),(4,'family','Keluarga','personal','Alamat keluarga dekat',1,0,'secondary','2026-03-24 19:46:19'),(5,'emergency','Darurat','personal','Alamat untuk kontak darurat',1,1,'emergency','2026-03-24 19:46:19'),(6,'mailing','Surat Menyurat','personal','Alamat untuk menerima surat',1,1,'primary','2026-03-24 19:46:19'),(7,'vacation','Liburan','personal','Alamat tempat liburan',1,0,'tertiary','2026-03-24 19:46:19'),(8,'office','Kantor','professional','Alamat tempat kerja',1,1,'primary','2026-03-24 19:46:19'),(9,'workplace','Tempat Kerja','professional','Alamat lokasi kerja fisik',1,1,'primary','2026-03-24 19:46:19'),(10,'factory','Pabrik/Workshop','professional','Alamat pabrik atau workshop',1,1,'secondary','2026-03-24 19:46:19'),(11,'project','Proyek','professional','Alamat proyek sementara',1,0,'tertiary','2026-03-24 19:46:19'),(12,'client','Client','professional','Alamat client untuk kunjungan',1,0,'tertiary','2026-03-24 19:46:19'),(13,'supplier','Supplier','professional','Alamat supplier bisnis',1,0,'tertiary','2026-03-24 19:46:19'),(14,'shipping','Pengiriman','logistics','Alamat untuk pengiriman barang',1,1,'primary','2026-03-24 19:46:19'),(15,'pickup','Pickup','logistics','Alamat untuk pickup barang',1,1,'secondary','2026-03-24 19:46:19'),(16,'billing','Tagihan','logistics','Alamat untuk tagihan',1,1,'primary','2026-03-24 19:46:19'),(17,'warehouse','Gudang','logistics','Alamat gudang/penyimpanan',1,1,'secondary','2026-03-24 19:46:19'),(18,'distribution','Distribusi','logistics','Alamat pusat distribusi',1,0,'tertiary','2026-03-24 19:46:19'),(19,'domicile','Domisili','legal','Alamat legal domisili',1,1,'primary','2026-03-24 19:46:19'),(20,'tax','Perpajakan','legal','Alamat untuk keperluan perpajakan',1,1,'primary','2026-03-24 19:46:19'),(21,'ktp','KTP','legal','Alamat sesuai KTP',1,1,'primary','2026-03-24 19:46:19'),(22,'kk','Kartu Keluarga','legal','Alamat sesuai KK',1,1,'primary','2026-03-24 19:46:19'),(23,'court','Pengadilan','legal','Alamat untuk keperluan pengadilan',1,0,'secondary','2026-03-24 19:46:19');
/*!40000 ALTER TABLE `address_purposes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `address_usage_log`
--

DROP TABLE IF EXISTS `address_usage_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address_usage_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `usage_type` enum('mailing','billing','shipping','emergency','visit','verification','other') NOT NULL,
  `usage_context` varchar(100) DEFAULT NULL,
  `usage_timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `used_by_user_id` int(11) DEFAULT NULL,
  `reference_id` varchar(50) DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_address_usage` (`address_id`,`usage_timestamp`),
  KEY `idx_user_usage` (`user_id`,`usage_timestamp`),
  KEY `idx_usage_type` (`usage_type`),
  KEY `idx_usage_timestamp` (`usage_timestamp`),
  KEY `idx_reference` (`reference_type`,`reference_id`),
  CONSTRAINT `address_usage_log_ibfk_1` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `address_usage_log_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address_usage_log`
--

LOCK TABLES `address_usage_log` WRITE;
/*!40000 ALTER TABLE `address_usage_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `address_usage_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `cooperative_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_addresses_region` (`province_id`,`city_id`,`village_id`),
  KEY `idx_address_cooperative` (`cooperative_id`),
  KEY `idx_alamat_ids` (`province_id`,`regency_id`,`district_id`,`village_id`),
  KEY `idx_alamat_source` (`alamat_db_source`),
  KEY `idx_address_verified` (`address_verified`),
  KEY `idx_house_number` (`house_number`),
  KEY `idx_building_number` (`building_number`),
  KEY `idx_unit_number` (`unit_number`),
  KEY `idx_rt_rw` (`rt_number`,`rw_number`),
  KEY `idx_complex_name` (`complex_name`),
  KEY `idx_user_category` (`user_id`,`address_category`),
  KEY `idx_user_purpose` (`user_id`,`address_purpose`),
  KEY `idx_priority_level` (`priority_level`),
  KEY `idx_mailing_address` (`is_mailing_address`),
  KEY `idx_billing_address` (`is_billing_address`),
  KEY `idx_shipping_address` (`is_shipping_address`),
  KEY `idx_work_address` (`is_work_address`),
  KEY `idx_emergency_address` (`is_emergency_address`),
  KEY `idx_verification_status` (`verification_status`),
  KEY `idx_effective_period` (`effective_date`,`expiry_date`),
  KEY `idx_usage_count` (`usage_count`),
  CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_addresses_primary` BEFORE INSERT ON `addresses` FOR EACH ROW BEGIN
    IF NEW.is_primary THEN
        UPDATE addresses SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `verify_address_on_insert` AFTER INSERT ON `addresses` FOR EACH ROW BEGIN
    
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_addresses_primary_upd` BEFORE UPDATE ON `addresses` FOR EACH ROW BEGIN
    IF NEW.is_primary AND (OLD.is_primary IS NULL OR OLD.is_primary = FALSE) THEN
        UPDATE addresses SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `allowed_databases`
--

DROP TABLE IF EXISTS `allowed_databases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `allowed_databases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `db_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `allowed` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allowed_databases`
--

LOCK TABLES `allowed_databases` WRITE;
/*!40000 ALTER TABLE `allowed_databases` DISABLE KEYS */;
INSERT INTO `allowed_databases` VALUES (1,'alamat_db','Database for Indonesian addresses: provinces, cities, villages',1,'2026-02-03 14:13:06');
/*!40000 ALTER TABLE `allowed_databases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `action` varchar(50) DEFAULT NULL,
  `performed_by` int(11) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT current_timestamp(),
  `details` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `performed_by` (`performed_by`),
  KEY `idx_audit_logs_user_time` (`user_id`,`timestamp`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `audit_logs_ibfk_2` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blood_types`
--

DROP TABLE IF EXISTS `blood_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blood_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blood_types`
--

LOCK TABLES `blood_types` WRITE;
/*!40000 ALTER TABLE `blood_types` DISABLE KEYS */;
INSERT INTO `blood_types` VALUES (1,'A'),(6,'A-'),(5,'A+'),(3,'AB'),(10,'AB-'),(9,'AB+'),(2,'B'),(8,'B-'),(7,'B+'),(4,'O'),(12,'O-'),(11,'O+');
/*!40000 ALTER TABLE `blood_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `certifications`
--

DROP TABLE IF EXISTS `certifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `certification_name` varchar(255) NOT NULL,
  `issuing_organization` varchar(255) DEFAULT NULL,
  `date_issued` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `certificate_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `certifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certifications`
--

LOCK TABLES `certifications` WRITE;
/*!40000 ALTER TABLE `certifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `certifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consents`
--

DROP TABLE IF EXISTS `consents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `consents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `consent_type` varchar(100) DEFAULT NULL,
  `consented` tinyint(1) DEFAULT 0,
  `consent_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `purpose` text DEFAULT NULL,
  `policy_version` varchar(50) DEFAULT NULL,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `revoked_reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `consents_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consents`
--

LOCK TABLES `consents` WRITE;
/*!40000 ALTER TABLE `consents` DISABLE KEYS */;
/*!40000 ALTER TABLE `consents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_emails`
--

DROP TABLE IF EXISTS `contact_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `type` enum('personal','work','other') DEFAULT 'personal',
  `is_primary` tinyint(1) DEFAULT 0,
  `email_hash` char(128) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_contact_emails_user_email` (`user_id`,`email`),
  KEY `idx_contact_emails_hash` (`email_hash`),
  KEY `idx_contact_emails_primary` (`user_id`,`is_primary`),
  CONSTRAINT `contact_emails_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_emails`
--

LOCK TABLES `contact_emails` WRITE;
/*!40000 ALTER TABLE `contact_emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_emails` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_contact_emails_primary` BEFORE INSERT ON `contact_emails` FOR EACH ROW BEGIN
    IF NEW.is_primary THEN
        UPDATE contact_emails SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_contact_emails_primary_upd` BEFORE UPDATE ON `contact_emails` FOR EACH ROW BEGIN
    IF NEW.is_primary AND (OLD.is_primary IS NULL OR OLD.is_primary = FALSE) THEN
        UPDATE contact_emails SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `contact_phones`
--

DROP TABLE IF EXISTS `contact_phones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_phones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `type` enum('mobile','home','work','other') DEFAULT 'mobile',
  `is_primary` tinyint(1) DEFAULT 0,
  `phone_hash` char(128) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_contact_phones_user_phone` (`user_id`,`phone`),
  KEY `idx_contact_phones_hash` (`phone_hash`),
  KEY `idx_contact_phones_primary` (`user_id`,`is_primary`),
  CONSTRAINT `contact_phones_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_phones`
--

LOCK TABLES `contact_phones` WRITE;
/*!40000 ALTER TABLE `contact_phones` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_phones` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_contact_phones_primary` BEFORE INSERT ON `contact_phones` FOR EACH ROW BEGIN
    IF NEW.is_primary THEN
        UPDATE contact_phones SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_contact_phones_primary_upd` BEFORE UPDATE ON `contact_phones` FOR EACH ROW BEGIN
    IF NEW.is_primary AND (OLD.is_primary IS NULL OR OLD.is_primary = FALSE) THEN
        UPDATE contact_phones SET is_primary = FALSE WHERE user_id = NEW.user_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `data_subject_requests`
--

DROP TABLE IF EXISTS `data_subject_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_subject_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `request_type` enum('access','rectification','erasure','portability','restriction','objection') NOT NULL,
  `status` enum('pending','in_progress','fulfilled','rejected') DEFAULT 'pending',
  `requested_at` timestamp NULL DEFAULT current_timestamp(),
  `fulfilled_at` timestamp NULL DEFAULT NULL,
  `details` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_dsr_user_status` (`user_id`,`status`),
  CONSTRAINT `data_subject_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_subject_requests`
--

LOCK TABLES `data_subject_requests` WRITE;
/*!40000 ALTER TABLE `data_subject_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_subject_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `education_records`
--

DROP TABLE IF EXISTS `education_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `education_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `degree` varchar(100) DEFAULT NULL,
  `field_of_study` varchar(100) DEFAULT NULL,
  `start_year` year(4) DEFAULT NULL,
  `end_year` year(4) DEFAULT NULL,
  `grade` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_education_institution` (`institution`),
  CONSTRAINT `education_records_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `education_records`
--

LOCK TABLES `education_records` WRITE;
/*!40000 ALTER TABLE `education_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `education_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emergency_contacts`
--

DROP TABLE IF EXISTS `emergency_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emergency_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `relation` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `emergency_contacts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emergency_contacts`
--

LOCK TABLES `emergency_contacts` WRITE;
/*!40000 ALTER TABLE `emergency_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `emergency_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employment_records`
--

DROP TABLE IF EXISTS `employment_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employment_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `company` varchar(255) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `salary` decimal(15,2) DEFAULT NULL,
  `reason_for_leaving` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_employment_company` (`company`),
  CONSTRAINT `employment_records_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employment_records`
--

LOCK TABLES `employment_records` WRITE;
/*!40000 ALTER TABLE `employment_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `employment_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ethnicities`
--

DROP TABLE IF EXISTS `ethnicities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ethnicities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ethnicities`
--

LOCK TABLES `ethnicities` WRITE;
/*!40000 ALTER TABLE `ethnicities` DISABLE KEYS */;
INSERT INTO `ethnicities` VALUES (3,'Batak'),(5,'Betawi'),(1,'Jawa'),(6,'Lainnya'),(4,'Minangkabau'),(2,'Sunda');
/*!40000 ALTER TABLE `ethnicities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `family_members`
--

DROP TABLE IF EXISTS `family_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `family_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `relation` enum('ayah','ibu','pasangan','anak','saudara') DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `contact_info` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `family_members_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `family_members`
--

LOCK TABLES `family_members` WRITE;
/*!40000 ALTER TABLE `family_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `family_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_info`
--

DROP TABLE IF EXISTS `financial_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` enum('income','assets','debts','investments','other') DEFAULT 'income',
  `amount` decimal(15,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'IDR',
  `description` text DEFAULT NULL,
  `date_recorded` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `financial_info_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_info`
--

LOCK TABLES `financial_info` WRITE;
/*!40000 ALTER TABLE `financial_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `genders`
--

DROP TABLE IF EXISTS `genders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `genders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `genders`
--

LOCK TABLES `genders` WRITE;
/*!40000 ALTER TABLE `genders` DISABLE KEYS */;
INSERT INTO `genders` VALUES (1,'laki-laki'),(2,'perempuan');
/*!40000 ALTER TABLE `genders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `health_records`
--

DROP TABLE IF EXISTS `health_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `health_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `record_type` enum('alergi','penyakit','obat','operasi','vaksinasi') DEFAULT NULL,
  `description` text DEFAULT NULL,
  `date_recorded` date DEFAULT NULL,
  `severity` varchar(50) DEFAULT NULL,
  `doctor` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `health_records_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `health_records`
--

LOCK TABLES `health_records` WRITE;
/*!40000 ALTER TABLE `health_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `health_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identities`
--

DROP TABLE IF EXISTS `identities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `kyc_completeness` tinyint(3) unsigned DEFAULT NULL,
  `foto_path` varchar(255) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nik` (`nik`),
  KEY `gender_id` (`gender_id`),
  KEY `marital_status_id` (`marital_status_id`),
  KEY `religion_id` (`religion_id`),
  KEY `ethnicity_id` (`ethnicity_id`),
  KEY `blood_type_id` (`blood_type_id`),
  KEY `idx_identities_user` (`user_id`),
  KEY `idx_identities_nomor_kk` (`nomor_kk`),
  KEY `idx_identities_pep` (`pep_flag`),
  KEY `idx_identities_risk` (`risk_score`),
  KEY `idx_identities_kyc_next_review` (`kyc_next_review_at`),
  CONSTRAINT `identities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `identities_ibfk_2` FOREIGN KEY (`gender_id`) REFERENCES `genders` (`id`),
  CONSTRAINT `identities_ibfk_3` FOREIGN KEY (`marital_status_id`) REFERENCES `marital_statuses` (`id`),
  CONSTRAINT `identities_ibfk_4` FOREIGN KEY (`religion_id`) REFERENCES `religions` (`id`),
  CONSTRAINT `identities_ibfk_5` FOREIGN KEY (`ethnicity_id`) REFERENCES `ethnicities` (`id`),
  CONSTRAINT `identities_ibfk_6` FOREIGN KEY (`blood_type_id`) REFERENCES `blood_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identities`
--

LOCK TABLES `identities` WRITE;
/*!40000 ALTER TABLE `identities` DISABLE KEYS */;
/*!40000 ALTER TABLE `identities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_types`
--

DROP TABLE IF EXISTS `identity_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `required` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_types`
--

LOCK TABLES `identity_types` WRITE;
/*!40000 ALTER TABLE `identity_types` DISABLE KEYS */;
INSERT INTO `identity_types` VALUES (1,'KTP','Kartu Tanda Penduduk Indonesia','Indonesia',1,'2026-02-03 14:12:57'),(2,'Passport','Passport (any country)',NULL,0,'2026-02-03 14:12:57'),(3,'SIM','Surat Izin Mengemudi','Indonesia',0,'2026-02-03 14:12:57');
/*!40000 ALTER TABLE `identity_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `language` varchar(100) NOT NULL,
  `proficiency` enum('basic','conversational','fluent','native') DEFAULT 'conversational',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `languages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `life_events`
--

DROP TABLE IF EXISTS `life_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `life_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `event_type` enum('kelahiran','pernikahan','perceraian','kematian','pindah','lainnya') DEFAULT NULL,
  `event_date` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `related_person` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `life_events_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `life_events`
--

LOCK TABLES `life_events` WRITE;
/*!40000 ALTER TABLE `life_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `life_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marital_statuses`
--

DROP TABLE IF EXISTS `marital_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `marital_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marital_statuses`
--

LOCK TABLES `marital_statuses` WRITE;
/*!40000 ALTER TABLE `marital_statuses` DISABLE KEYS */;
INSERT INTO `marital_statuses` VALUES (1,'belum_kawin'),(3,'cerai_hidup'),(4,'cerai_mati'),(2,'kawin');
/*!40000 ALTER TABLE `marital_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `occupation_ranks`
--

DROP TABLE IF EXISTS `occupation_ranks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `occupation_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `pendidikan_min` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `occupation_id` (`occupation_id`),
  CONSTRAINT `occupation_ranks_ibfk_1` FOREIGN KEY (`occupation_id`) REFERENCES `occupations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=764 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `occupation_ranks`
--

LOCK TABLES `occupation_ranks` WRITE;
/*!40000 ALTER TABLE `occupation_ranks` DISABLE KEYS */;
INSERT INTO `occupation_ranks` VALUES (560,100,'I/A',1,'2026-02-05 05:50:36',1,'I (JURU)','I/A','Juru Muda','I/A','','SD / Sederajat'),(561,5,'I/A',1,'2026-02-05 05:50:36',1,'I (JURU)','I/A','Juru Muda','I/A','','SD / Sederajat'),(562,100,'I/B',1,'2026-02-05 05:50:36',2,'I (JURU)','I/B','Juru Muda Tingkat I','I/B','','-'),(563,5,'I/B',1,'2026-02-05 05:50:36',2,'I (JURU)','I/B','Juru Muda Tingkat I','I/B','','-'),(564,100,'I/C',1,'2026-02-05 05:50:36',3,'I (JURU)','I/C','Juru','I/C','','SMP / Sederajat'),(565,5,'I/C',1,'2026-02-05 05:50:36',3,'I (JURU)','I/C','Juru','I/C','','SMP / Sederajat'),(566,100,'I/D',1,'2026-02-05 05:50:36',4,'I (JURU)','I/D','Juru Tingkat I','I/D','','-'),(567,5,'I/D',1,'2026-02-05 05:50:36',4,'I (JURU)','I/D','Juru Tingkat I','I/D','','-'),(568,100,'II/A',1,'2026-02-05 05:50:36',5,'II (PENGATUR)','II/A','Pengatur Muda','II/A','','SMA / SMK / Sederajat'),(569,5,'II/A',1,'2026-02-05 05:50:36',5,'II (PENGATUR)','II/A','Pengatur Muda','II/A','','SMA / SMK / Sederajat'),(570,100,'II/B',1,'2026-02-05 05:50:36',6,'II (PENGATUR)','II/B','Pengatur Muda Tingkat I','II/B','','D2'),(571,5,'II/B',1,'2026-02-05 05:50:36',6,'II (PENGATUR)','II/B','Pengatur Muda Tingkat I','II/B','','D2'),(572,100,'II/C',1,'2026-02-05 05:50:36',7,'II (PENGATUR)','II/C','Pengatur','II/C','','D3'),(573,5,'II/C',1,'2026-02-05 05:50:36',7,'II (PENGATUR)','II/C','Pengatur','II/C','','D3'),(574,100,'II/D',1,'2026-02-05 05:50:36',8,'II (PENGATUR)','II/D','Pengatur Tingkat I','II/D','','-'),(575,5,'II/D',1,'2026-02-05 05:50:36',8,'II (PENGATUR)','II/D','Pengatur Tingkat I','II/D','','-'),(576,100,'III/A',1,'2026-02-05 05:50:36',9,'III (PENATA)','III/A','Penata Muda','III/A','','S1 / D4'),(577,5,'III/A',1,'2026-02-05 05:50:36',9,'III (PENATA)','III/A','Penata Muda','III/A','','S1 / D4'),(578,100,'III/B',1,'2026-02-05 05:50:36',10,'III (PENATA)','III/B','Penata Muda Tingkat I','III/B','','S2'),(579,5,'III/B',1,'2026-02-05 05:50:36',10,'III (PENATA)','III/B','Penata Muda Tingkat I','III/B','','S2'),(580,100,'III/C',1,'2026-02-05 05:50:36',11,'III (PENATA)','III/C','Penata','III/C','','S3'),(581,5,'III/C',1,'2026-02-05 05:50:36',11,'III (PENATA)','III/C','Penata','III/C','','S3'),(582,100,'III/D',1,'2026-02-05 05:50:36',12,'III (PENATA)','III/D','Penata Tingkat I','III/D','','-'),(583,5,'III/D',1,'2026-02-05 05:50:36',12,'III (PENATA)','III/D','Penata Tingkat I','III/D','','-'),(584,100,'IV/A',1,'2026-02-05 05:50:36',13,'IV (PEMBINA)','IV/A','Pembina','IV/A','','-'),(585,5,'IV/A',1,'2026-02-05 05:50:36',13,'IV (PEMBINA)','IV/A','Pembina','IV/A','','-'),(586,100,'IV/B',1,'2026-02-05 05:50:36',14,'IV (PEMBINA)','IV/B','Pembina Tingkat I','IV/B','','-'),(587,5,'IV/B',1,'2026-02-05 05:50:36',14,'IV (PEMBINA)','IV/B','Pembina Tingkat I','IV/B','','-'),(588,100,'IV/C',1,'2026-02-05 05:50:36',15,'IV (PEMBINA)','IV/C','Pembina Utama Muda','IV/C','','-'),(589,5,'IV/C',1,'2026-02-05 05:50:36',15,'IV (PEMBINA)','IV/C','Pembina Utama Muda','IV/C','','-'),(590,100,'IV/D',1,'2026-02-05 05:50:36',16,'IV (PEMBINA)','IV/D','Pembina Utama Madya','IV/D','','-'),(591,5,'IV/D',1,'2026-02-05 05:50:36',16,'IV (PEMBINA)','IV/D','Pembina Utama Madya','IV/D','','-'),(592,100,'IV/E',1,'2026-02-05 05:50:36',17,'IV (PEMBINA)','IV/E','Pembina Utama','IV/E','','-'),(593,5,'IV/E',1,'2026-02-05 05:50:36',17,'IV (PEMBINA)','IV/E','Pembina Utama','IV/E','','-'),(623,7,'BHARADA',1,'2026-02-05 05:50:36',1,'TAMTAMA','TAMTAMA','Bhayangkara Dua','BHARADA','1 Balok Merah Miring',NULL),(624,7,'BHARATU',1,'2026-02-05 05:50:36',2,'TAMTAMA','TAMTAMA','Bhayangkara Satu','BHARATU','2 Balok Merah Miring',NULL),(625,7,'BHARAKA',1,'2026-02-05 05:50:36',3,'TAMTAMA','TAMTAMA','Bhayangkara Kepala','BHARAKA','3 Balok Merah Miring',NULL),(626,7,'ABRIPDA',1,'2026-02-05 05:50:36',4,'TAMTAMA','TAMTAMA','Ajun Brigadir Polisi Dua','ABRIPDA','1 Balok Merah V',NULL),(627,7,'ABRIPTU',1,'2026-02-05 05:50:36',5,'TAMTAMA','TAMTAMA','Ajun Brigadir Polisi Satu','ABRIPTU','2 Balok Merah V',NULL),(628,7,'ABRIP',1,'2026-02-05 05:50:36',6,'TAMTAMA','TAMTAMA','Ajun Brigadir Polisi','ABRIP','3 Balok Merah V',NULL),(629,7,'BRIPDA',1,'2026-02-05 05:50:36',7,'BINTARA','BINTARA','Brigadir Polisi Dua','BRIPDA','1 Balok Perak V',NULL),(630,7,'BRIPTU',1,'2026-02-05 05:50:36',8,'BINTARA','BINTARA','Brigadir Polisi Satu','BRIPTU','2 Balok Perak V',NULL),(631,7,'BRIGPOL',1,'2026-02-05 05:50:36',9,'BINTARA','BINTARA','Brigadir Polisi','BRIGPOL','3 Balok Perak V',NULL),(632,7,'BRIPKA',1,'2026-02-05 05:50:36',10,'BINTARA','BINTARA','Brigadir Polisi Kepala','BRIPKA','4 Balok Perak V',NULL),(633,7,'AIPDA',1,'2026-02-05 05:50:36',11,'BINTARA TINGGI','BINTARA TINGGI','Ajun Inspektur Polisi Dua','AIPDA','1 Balok Perak Bergelombang',NULL),(634,7,'AIPTU',1,'2026-02-05 05:50:36',12,'BINTARA TINGGI','BINTARA TINGGI','Ajun Inspektur Polisi Satu','AIPTU','2 Balok Perak Bergelombang',NULL),(635,7,'IPDA',1,'2026-02-05 05:50:36',13,'PERWIRA PERTAMA','PAMA','Inspektur Polisi Dua','IPDA','1 Balok Emas',NULL),(636,7,'IPTU',1,'2026-02-05 05:50:36',14,'PERWIRA PERTAMA','PAMA','Inspektur Polisi Satu','IPTU','2 Balok Emas',NULL),(637,7,'AKP',1,'2026-02-05 05:50:36',15,'PERWIRA PERTAMA','PAMA','Ajun Komisaris Polisi','AKP','3 Balok Emas',NULL),(638,7,'KOMPOL',1,'2026-02-05 05:50:36',16,'PERWIRA MENENGAH','PAMEN','Komisaris Polisi','KOMPOL','1 Melati Emas',NULL),(639,7,'AKBP',1,'2026-02-05 05:50:36',17,'PERWIRA MENENGAH','PAMEN','Ajun Komisaris Besar Polisi','AKBP','2 Melati Emas',NULL),(640,7,'KOMBES POL',1,'2026-02-05 05:50:36',18,'PERWIRA MENENGAH','PAMEN','Komisaris Besar Polisi','KOMBES POL','3 Melati Emas',NULL),(641,7,'BRIGJEN POL',1,'2026-02-05 05:50:36',19,'PERWIRA TINGGI','PATI','Brigadir Jenderal Polisi','BRIGJEN POL','1 Bintang Emas',NULL),(642,7,'IRJEN POL',1,'2026-02-05 05:50:36',20,'PERWIRA TINGGI','PATI','Inspektur Jenderal Polisi','IRJEN POL','2 Bintang Emas',NULL),(643,7,'KOMJEN POL',1,'2026-02-05 05:50:36',21,'PERWIRA TINGGI','PATI','Komisaris Jenderal Polisi','KOMJEN POL','3 Bintang Emas',NULL),(644,7,'JEND POL',1,'2026-02-05 05:50:36',22,'PERWIRA TINGGI','PATI','Jenderal Polisi','JEND POL','4 Bintang Emas',NULL),(654,6,'PRADA',1,'2026-02-05 05:50:36',1,'TAMTAMA','PRAJURIT/KELASI','Prajurit Dua (Prada)','PRADA','',NULL),(655,6,'PRATU',1,'2026-02-05 05:50:36',2,'TAMTAMA','PRAJURIT/KELASI','Prajurit Satu (Pratu)','PRATU','',NULL),(656,6,'PRAKA',1,'2026-02-05 05:50:36',3,'TAMTAMA','PRAJURIT/KELASI','Prajurit Kepala (Praka)','PRAKA','',NULL),(657,6,'KOPDA',1,'2026-02-05 05:50:36',4,'TAMTAMA','KEPALA','Kopral Dua (Kopda)','KOPDA','',NULL),(658,6,'KOPTU',1,'2026-02-05 05:50:36',5,'TAMTAMA','KEPALA','Kopral Satu (Koptu)','KOPTU','',NULL),(659,6,'KOPKA',1,'2026-02-05 05:50:36',6,'TAMTAMA','KEPALA','Kopral Kepala (Kopka)','KOPKA','',NULL),(660,6,'SERDA',1,'2026-02-05 05:50:36',7,'BINTARA','BINTARA','Sersan Dua (Serda)','SERDA','',NULL),(661,6,'SERTU',1,'2026-02-05 05:50:36',8,'BINTARA','BINTARA','Sersan Satu (Sertu)','SERTU','',NULL),(662,6,'SERKA',1,'2026-02-05 05:50:36',9,'BINTARA','BINTARA','Sersan Kepala (Serka)','SERKA','',NULL),(663,6,'SERMA',1,'2026-02-05 05:50:36',10,'BINTARA','BINTARA','Sersan Mayor (Serma)','SERMA','',NULL),(664,6,'PELDA',1,'2026-02-05 05:50:36',11,'BINTARA','BINTARA TINGGI','Pembantu Letnan Dua (Pelda)','PELDA','',NULL),(665,6,'PELTU',1,'2026-02-05 05:50:36',12,'BINTARA','BINTARA TINGGI','Pembantu Letnan Satu (Peltu)','PELTU','',NULL),(666,6,'LETDA',1,'2026-02-05 05:50:36',13,'PERWIRA','PERWIRA PERTAMA (PAMA)','Letnan Dua (Letda)','LETDA','',NULL),(667,6,'LETTU',1,'2026-02-05 05:50:36',14,'PERWIRA','PERWIRA PERTAMA (PAMA)','Letnan Satu (Lettu)','LETTU','',NULL),(668,6,'KAPT',1,'2026-02-05 05:50:36',15,'PERWIRA','PERWIRA PERTAMA (PAMA)','Kapten','KAPT','',NULL),(669,6,'MAYOR',1,'2026-02-05 05:50:36',16,'PERWIRA','PERWIRA MENENGAH (PAMEN)','Mayor','MAYOR','',NULL),(670,6,'LETKOL',1,'2026-02-05 05:50:36',17,'PERWIRA','PERWIRA MENENGAH (PAMEN)','Letnan Kolonel (Letkol)','LETKOL','',NULL),(671,6,'KOL',1,'2026-02-05 05:50:36',18,'PERWIRA','PERWIRA MENENGAH (PAMEN)','Kolonel','KOL','',NULL),(672,6,'BRIGJEN',1,'2026-02-05 05:50:36',19,'PERWIRA','PERWIRA TINGGI (PATI)','Brigadir Jenderal TNI (Brigjen)','BRIGJEN','',NULL),(673,6,'MAYJEN',1,'2026-02-05 05:50:36',20,'PERWIRA','PERWIRA TINGGI (PATI)','Mayor Jenderal TNI (Mayjen)','MAYJEN','',NULL),(674,6,'LETJEN',1,'2026-02-05 05:50:36',21,'PERWIRA','PERWIRA TINGGI (PATI)','Letnan Jenderal TNI (Letjen)','LETJEN','',NULL),(675,6,'JEND TNI',1,'2026-02-05 05:50:36',22,'PERWIRA','PERWIRA TINGGI (PATI)','Jenderal TNI','JEND TNI','',NULL),(676,6,'LAKSMA',1,'2026-02-05 05:50:36',23,'PERWIRA','PERWIRA TINGGI (PATI)','Laksamana Pertama TNI (Laksma)','LAKSMA','',NULL),(677,6,'LAKSDA',1,'2026-02-05 05:50:36',24,'PERWIRA','PERWIRA TINGGI (PATI)','Laksamana Muda TNI (Laksda)','LAKSDA','',NULL),(678,6,'LAKSDYA',1,'2026-02-05 05:50:36',25,'PERWIRA','PERWIRA TINGGI (PATI)','Laksamana Madya TNI (Laksdya)','LAKSDYA','',NULL),(679,6,'LAKSAMANA TNI',1,'2026-02-05 05:50:36',26,'PERWIRA','PERWIRA TINGGI (PATI)','Laksamana TNI','LAKSAMANA TNI','',NULL),(680,6,'MARSMA',1,'2026-02-05 05:50:36',27,'PERWIRA','PERWIRA TINGGI (PATI)','Marsekal Pertama TNI (Marsma)','MARSMA','',NULL),(681,6,'MARSDA',1,'2026-02-05 05:50:36',28,'PERWIRA','PERWIRA TINGGI (PATI)','Marsekal Muda TNI (Marsda)','MARSDA','',NULL),(682,6,'MARSDYA',1,'2026-02-05 05:50:36',29,'PERWIRA','PERWIRA TINGGI (PATI)','Marsekal Madya TNI (Marsdya)','MARSDYA','',NULL),(683,6,'MARSEKAL TNI',1,'2026-02-05 05:50:36',30,'PERWIRA','PERWIRA TINGGI (PATI)','Marsekal TNI','MARSEKAL TNI','',NULL),(685,101,'I/A',1,'2026-02-05 05:50:36',1,'I (JURU)','I/A','Juru (1 Garis Miring Putih)','I/A','1 Garis Miring Putih',NULL),(686,101,'I/B',1,'2026-02-05 05:50:36',2,'I (JURU)','I/B','Juru (2 Garis Miring Putih)','I/B','2 Garis Miring Putih',NULL),(687,101,'I/C',1,'2026-02-05 05:50:36',3,'I (JURU)','I/C','Juru (3 Garis Miring Putih)','I/C','3 Garis Miring Putih',NULL),(688,101,'I/D',1,'2026-02-05 05:50:36',4,'I (JURU)','I/D','Juru (4 Garis Miring Putih)','I/D','4 Garis Miring Putih',NULL),(689,101,'II/A',1,'2026-02-05 05:50:36',5,'II (PENGATUR)','II/A','Pengatur Muda (1 Balok Putih)','II/A','1 Balok Putih',NULL),(690,101,'II/B',1,'2026-02-05 05:50:36',6,'II (PENGATUR)','II/B','Pengatur Muda (2 Balok Putih)','II/B','2 Balok Putih',NULL),(691,101,'II/C',1,'2026-02-05 05:50:36',7,'II (PENGATUR)','II/C','Pengatur (3 Balok Putih)','II/C','3 Balok Putih',NULL),(692,101,'II/D',1,'2026-02-05 05:50:36',8,'II (PENGATUR)','II/D','Pengatur (4 Balok Putih)','II/D','4 Balok Putih',NULL),(693,101,'III/A',1,'2026-02-05 05:50:36',9,'III (PENATA)','III/A','Penata Muda (1 Balok Kuning)','III/A','1 Balok Kuning',NULL),(694,101,'III/B',1,'2026-02-05 05:50:36',10,'III (PENATA)','III/B','Penata Muda (2 Balok Kuning)','III/B','2 Balok Kuning',NULL),(695,101,'III/C',1,'2026-02-05 05:50:36',11,'III (PENATA)','III/C','Penata (3 Balok Kuning)','III/C','3 Balok Kuning',NULL),(696,101,'III/D',1,'2026-02-05 05:50:36',12,'III (PENATA)','III/D','Penata (4 Balok Kuning)','III/D','4 Balok Kuning',NULL),(697,101,'IV/A',1,'2026-02-05 05:50:36',13,'IV (PEMBINA)','IV/A','Pembina (Bintang Emas)','IV/A','Bintang Emas',NULL),(698,101,'IV/B',1,'2026-02-05 05:50:36',14,'IV (PEMBINA)','IV/B','Pembina Tingkat I (Bintang Emas)','IV/B','Bintang Emas',NULL),(699,101,'IV/C',1,'2026-02-05 05:50:36',15,'IV (PEMBINA)','IV/C','Pembina Utama Muda (Bintang Emas)','IV/C','Bintang Emas',NULL),(700,101,'IV/D',1,'2026-02-05 05:50:36',16,'IV (PEMBINA)','IV/D','Pembina Utama Madya (Bintang Emas)','IV/D','Bintang Emas',NULL),(701,101,'IV/E',1,'2026-02-05 05:50:36',17,'IV (PEMBINA)','IV/E','Pembina Utama (Bintang Emas)','IV/E','Bintang Emas',NULL),(716,102,'I/A',1,'2026-02-05 05:50:36',1,'I (JURU)','I/A','Juru (1 Garis Miring Perak)','I/A','1 Garis Miring Perak',NULL),(717,102,'I/B',1,'2026-02-05 05:50:36',2,'I (JURU)','I/B','Juru (2 Garis Miring Perak)','I/B','2 Garis Miring Perak',NULL),(718,102,'I/C',1,'2026-02-05 05:50:36',3,'I (JURU)','I/C','Juru (3 Garis Miring Perak)','I/C','3 Garis Miring Perak',NULL),(719,102,'I/D',1,'2026-02-05 05:50:36',4,'I (JURU)','I/D','Juru (4 Garis Miring Perak)','I/D','4 Garis Miring Perak',NULL),(720,102,'II/A',1,'2026-02-05 05:50:36',5,'II (PENGATUR)','II/A','Pengatur Muda (1 Balok Perak)','II/A','1 Balok Perak',NULL),(721,102,'II/B',1,'2026-02-05 05:50:36',6,'II (PENGATUR)','II/B','Pengatur Muda (2 Balok Perak)','II/B','2 Balok Perak',NULL),(722,102,'II/C',1,'2026-02-05 05:50:36',7,'II (PENGATUR)','II/C','Pengatur (3 Balok Perak)','II/C','3 Balok Perak',NULL),(723,102,'II/D',1,'2026-02-05 05:50:36',8,'II (PENGATUR)','II/D','Pengatur (4 Balok Perak)','II/D','4 Balok Perak',NULL),(724,102,'III/A',1,'2026-02-05 05:50:36',9,'III (PENATA)','III/A','Penata Muda (1 Balok Emas)','III/A','1 Balok Emas',NULL),(725,102,'III/B',1,'2026-02-05 05:50:36',10,'III (PENATA)','III/B','Penata Muda (2 Balok Emas)','III/B','2 Balok Emas',NULL),(726,102,'III/C',1,'2026-02-05 05:50:36',11,'III (PENATA)','III/C','Penata (3 Balok Emas)','III/C','3 Balok Emas',NULL),(727,102,'III/D',1,'2026-02-05 05:50:36',12,'III (PENATA)','III/D','Penata (4 Balok Emas)','III/D','4 Balok Emas',NULL),(728,102,'IV/A',1,'2026-02-05 05:50:36',13,'IV (PEMBINA)','IV/A','Pembina (Bintang)','IV/A','Bintang',NULL),(729,102,'IV/B',1,'2026-02-05 05:50:36',14,'IV (PEMBINA)','IV/B','Pembina Tingkat I (Bintang)','IV/B','Bintang',NULL),(730,102,'IV/C',1,'2026-02-05 05:50:36',15,'IV (PEMBINA)','IV/C','Pembina Utama Muda (Bintang)','IV/C','Bintang',NULL),(731,102,'IV/D',1,'2026-02-05 05:50:36',16,'IV (PEMBINA)','IV/D','Pembina Utama Madya (Bintang)','IV/D','Bintang',NULL),(732,102,'IV/E',1,'2026-02-05 05:50:36',17,'IV (PEMBINA)','IV/E','Pembina Utama (Bintang)','IV/E','Bintang',NULL),(747,103,'I/A',1,'2026-02-05 05:50:36',1,'I (JURU)','I/A','Juru (1 Garis Miring Perak)','I/A','1 Garis Miring Perak',NULL),(748,103,'I/B',1,'2026-02-05 05:50:36',2,'I (JURU)','I/B','Juru (2 Garis Miring Perak)','I/B','2 Garis Miring Perak',NULL),(749,103,'I/C',1,'2026-02-05 05:50:36',3,'I (JURU)','I/C','Juru (3 Garis Miring Perak)','I/C','3 Garis Miring Perak',NULL),(750,103,'I/D',1,'2026-02-05 05:50:36',4,'I (JURU)','I/D','Juru (4 Garis Miring Perak)','I/D','4 Garis Miring Perak',NULL),(751,103,'II/A',1,'2026-02-05 05:50:36',5,'II (PENGATUR)','II/A','Pengatur Muda (1 Balok Perak)','II/A','1 Balok Perak',NULL),(752,103,'II/B',1,'2026-02-05 05:50:36',6,'II (PENGATUR)','II/B','Pengatur Muda (2 Balok Perak)','II/B','2 Balok Perak',NULL),(753,103,'II/C',1,'2026-02-05 05:50:36',7,'II (PENGATUR)','II/C','Pengatur (3 Balok Perak)','II/C','3 Balok Perak',NULL),(754,103,'II/D',1,'2026-02-05 05:50:36',8,'II (PENGATUR)','II/D','Pengatur (4 Balok Perak)','II/D','4 Balok Perak',NULL),(755,103,'III/A',1,'2026-02-05 05:50:36',9,'III (PENATA)','III/A','Penata Muda (1 Balok Emas)','III/A','1 Balok Emas',NULL),(756,103,'III/B',1,'2026-02-05 05:50:36',10,'III (PENATA)','III/B','Penata Muda (2 Balok Emas)','III/B','2 Balok Emas',NULL),(757,103,'III/C',1,'2026-02-05 05:50:36',11,'III (PENATA)','III/C','Penata (3 Balok Emas)','III/C','3 Balok Emas',NULL),(758,103,'III/D',1,'2026-02-05 05:50:36',12,'III (PENATA)','III/D','Penata (4 Balok Emas)','III/D','4 Balok Emas',NULL),(759,103,'IV/A',1,'2026-02-05 05:50:36',13,'IV (PEMBINA)','IV/A','Pembina (Bintang)','IV/A','Bintang',NULL),(760,103,'IV/B',1,'2026-02-05 05:50:36',14,'IV (PEMBINA)','IV/B','Pembina Tingkat I (Bintang)','IV/B','Bintang',NULL),(761,103,'IV/C',1,'2026-02-05 05:50:36',15,'IV (PEMBINA)','IV/C','Pembina Utama Muda (Bintang)','IV/C','Bintang',NULL),(762,103,'IV/D',1,'2026-02-05 05:50:36',16,'IV (PEMBINA)','IV/D','Pembina Utama Madya (Bintang)','IV/D','Bintang',NULL),(763,103,'IV/E',1,'2026-02-05 05:50:36',17,'IV (PEMBINA)','IV/E','Pembina Utama (Bintang)','IV/E','Bintang',NULL);
/*!40000 ALTER TABLE `occupation_ranks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `occupations`
--

DROP TABLE IF EXISTS `occupations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `occupations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `requires_rank` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `occupations`
--

LOCK TABLES `occupations` WRITE;
/*!40000 ALTER TABLE `occupations` DISABLE KEYS */;
INSERT INTO `occupations` VALUES (1,'BELUM/TIDAK BEKERJA',1,'2026-02-05 05:50:36',0),(2,'MENGURUS RUMAH TANGGA',1,'2026-02-05 05:50:36',0),(3,'PELAJAR/MAHASISWA',1,'2026-02-05 05:50:36',0),(4,'PENSIUNAN',1,'2026-02-05 05:50:36',0),(5,'PEGAWAI NEGERI SIPIL',1,'2026-02-05 05:50:36',1),(6,'TENTARA NASIONAL INDONESIA',1,'2026-02-05 05:50:36',1),(7,'KEPOLISIAN RI',1,'2026-02-05 05:50:36',1),(8,'PERDAGANGAN',1,'2026-02-05 05:50:36',0),(9,'PETANI/PEKEBUN',1,'2026-02-05 05:50:36',0),(10,'PETERNAK',1,'2026-02-05 05:50:36',0),(11,'NELAYAN/PERIKANAN',1,'2026-02-05 05:50:36',0),(12,'INDUSTRI',1,'2026-02-05 05:50:36',0),(13,'KONSTRUKSI',1,'2026-02-05 05:50:36',0),(14,'TRANSPORTASI',1,'2026-02-05 05:50:36',0),(15,'KARYAWAN SWASTA',1,'2026-02-05 05:50:36',0),(16,'KARYAWAN BUMN',1,'2026-02-05 05:50:36',0),(17,'KARYAWAN BUMD',1,'2026-02-05 05:50:36',0),(18,'KARYAWAN HONORER',1,'2026-02-05 05:50:36',0),(19,'BURUH HARIAN LEPAS',1,'2026-02-05 05:50:36',0),(20,'BURUH TANI/PERKEBUNAN',1,'2026-02-05 05:50:36',0),(21,'BURUH NELAYAN/PERIKANAN',1,'2026-02-05 05:50:36',0),(22,'BURUH PETERNAKAN',1,'2026-02-05 05:50:36',0),(23,'TUKANG CUKUR',1,'2026-02-05 05:50:36',0),(24,'TUKANG LISTRIK',1,'2026-02-05 05:50:36',0),(25,'TUKANG BATU',1,'2026-02-05 05:50:36',0),(26,'TUKANG KAYU',1,'2026-02-05 05:50:36',0),(27,'TUKANG SOL SEPATU',1,'2026-02-05 05:50:36',0),(28,'TUKANG LAS/PANDAI BESI',1,'2026-02-05 05:50:36',0),(29,'TUKANG JAHIT',1,'2026-02-05 05:50:36',0),(30,'TUKANG GIGI',1,'2026-02-05 05:50:36',0),(31,'PENATA RIAS',1,'2026-02-05 05:50:36',0),(32,'PENATA BUSANA',1,'2026-02-05 05:50:36',0),(33,'PENATA RAMBUT',1,'2026-02-05 05:50:36',0),(34,'MEKANIK',1,'2026-02-05 05:50:36',0),(35,'SENIMAN',1,'2026-02-05 05:50:36',0),(36,'TABIB',1,'2026-02-05 05:50:36',0),(37,'PARAJI',1,'2026-02-05 05:50:36',0),(38,'PERANCANG BUSANA',1,'2026-02-05 05:50:36',0),(39,'PENTERJEMAH',1,'2026-02-05 05:50:36',0),(40,'IMAM MASJID',1,'2026-02-05 05:50:36',0),(41,'PENDETA',1,'2026-02-05 05:50:36',0),(42,'PASTOR',1,'2026-02-05 05:50:36',0),(43,'WARTAWAN',1,'2026-02-05 05:50:36',0),(44,'USTADZ/MUBALIGH',1,'2026-02-05 05:50:36',0),(45,'JURU MASAK',1,'2026-02-05 05:50:36',0),(46,'PROMOTOR ACARA',1,'2026-02-05 05:50:36',0),(47,'ANGGOTA DPR-RI',1,'2026-02-05 05:50:36',0),(48,'ANGGOTA DPD',1,'2026-02-05 05:50:36',0),(49,'ANGGOTA BPK',1,'2026-02-05 05:50:36',0),(50,'PRESIDEN',1,'2026-02-05 05:50:36',0),(51,'WAKIL PRESIDEN',1,'2026-02-05 05:50:36',0),(52,'ANGGOTA MAHKAMAH KONSTITUSI',1,'2026-02-05 05:50:36',0),(53,'ANGGOTA KABINET/MENTERI',1,'2026-02-05 05:50:36',0),(54,'DUTA BESAR',1,'2026-02-05 05:50:36',0),(55,'GUBERNUR',1,'2026-02-05 05:50:36',0),(56,'WAKIL GUBERNUR',1,'2026-02-05 05:50:36',0),(57,'BUPATI',1,'2026-02-05 05:50:36',0),(58,'WAKIL BUPATI',1,'2026-02-05 05:50:36',0),(59,'WALIKOTA',1,'2026-02-05 05:50:36',0),(60,'WAKIL WALIKOTA',1,'2026-02-05 05:50:36',0),(61,'ANGGOTA DPRD PROVINSI',1,'2026-02-05 05:50:36',0),(62,'ANGGOTA DPRD KABUPATEN/KOTA',1,'2026-02-05 05:50:36',0),(63,'DOSEN',1,'2026-02-05 05:50:36',0),(64,'GURU',1,'2026-02-05 05:50:36',0),(65,'PILOT',1,'2026-02-05 05:50:36',0),(66,'PENGACARA',1,'2026-02-05 05:50:36',0),(67,'NOTARIS',1,'2026-02-05 05:50:36',0),(68,'ARSITEK',1,'2026-02-05 05:50:36',0),(69,'AKUNTAN',1,'2026-02-05 05:50:36',0),(70,'KONSULTAN',1,'2026-02-05 05:50:36',0),(71,'DOKTER',1,'2026-02-05 05:50:36',0),(72,'BIDAN',1,'2026-02-05 05:50:36',0),(73,'PERAWAT',1,'2026-02-05 05:50:36',0),(74,'APOTEKER',1,'2026-02-05 05:50:36',0),(75,'PSIKOLOG/PSIKIATER',1,'2026-02-05 05:50:36',0),(76,'PENYULUH PERTANIAN',1,'2026-02-05 05:50:36',0),(77,'PENYULUH PERIKANAN',1,'2026-02-05 05:50:36',0),(78,'PENYULUH KEHUTANAN',1,'2026-02-05 05:50:36',0),(79,'PARAMEDIS',1,'2026-02-05 05:50:36',0),(80,'PENELITI',1,'2026-02-05 05:50:36',0),(81,'SOPIR',1,'2026-02-05 05:50:36',0),(82,'PIALANG',1,'2026-02-05 05:50:36',0),(83,'PARANORMAL',1,'2026-02-05 05:50:36',0),(84,'PEDAGANG',1,'2026-02-05 05:50:36',0),(85,'PERANGKAT DESA',1,'2026-02-05 05:50:36',0),(86,'KEPALA DESA',1,'2026-02-05 05:50:36',0),(87,'BIARAWATI',1,'2026-02-05 05:50:36',0),(88,'WIRASWASTA',1,'2026-02-05 05:50:36',0),(89,'ANGGOTA LEMBAGA TINGGI LAINNYA',1,'2026-02-05 05:50:36',0),(90,'ARTIS',1,'2026-02-05 05:50:36',0),(91,'ATLET',1,'2026-02-05 05:50:36',0),(92,'MANAJER',1,'2026-02-05 05:50:36',0),(93,'TENAGA AHLI',1,'2026-02-05 05:50:36',0),(94,'KEPALA WILAYAH',1,'2026-02-05 05:50:36',0),(95,'DOSEN (NON PNS)',1,'2026-02-05 05:50:36',0),(96,'GURU (NON PNS)',1,'2026-02-05 05:50:36',0),(97,'SWASTA (LAINNYA)',1,'2026-02-05 05:50:36',0),(98,'TUKANG JAHIT (NON PNS)',1,'2026-02-05 05:50:36',0),(99,'LAINNYA',1,'2026-02-05 05:50:36',0),(100,'ASN/PNS',1,'2026-02-05 05:50:36',1),(101,'POLSUSPAS',1,'2026-02-05 05:50:36',1),(102,'BEA CUKAI',1,'2026-02-05 05:50:36',1),(103,'SATPOL PP',1,'2026-02-05 05:50:36',1);
/*!40000 ALTER TABLE `occupations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `people_complete_addresses`
--

DROP TABLE IF EXISTS `people_complete_addresses`;
/*!50001 DROP VIEW IF EXISTS `people_complete_addresses`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `people_complete_addresses` AS SELECT 
 1 AS `id`,
 1 AS `user_id`,
 1 AS `address_type`,
 1 AS `is_primary`,
 1 AS `country`,
 1 AS `province_id`,
 1 AS `regency_id`,
 1 AS `district_id`,
 1 AS `village_id`,
 1 AS `postal_code`,
 1 AS `street_address`,
 1 AS `alamat_detil`,
 1 AS `latitude`,
 1 AS `longitude`,
 1 AS `alamat_db_source`,
 1 AS `address_verified`,
 1 AS `created_at`,
 1 AS `province_name`,
 1 AS `regency_name`,
 1 AS `district_name`,
 1 AS `village_name`,
 1 AS `complete_address`,
 1 AS `user_name`,
 1 AS `user_email`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `people_complete_addresses_enhanced`
--

DROP TABLE IF EXISTS `people_complete_addresses_enhanced`;
/*!50001 DROP VIEW IF EXISTS `people_complete_addresses_enhanced`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `people_complete_addresses_enhanced` AS SELECT 
 1 AS `id`,
 1 AS `user_id`,
 1 AS `address_type`,
 1 AS `is_primary`,
 1 AS `country`,
 1 AS `province_id`,
 1 AS `regency_id`,
 1 AS `district_id`,
 1 AS `village_id`,
 1 AS `postal_code`,
 1 AS `street_address`,
 1 AS `alamat_detil`,
 1 AS `latitude`,
 1 AS `longitude`,
 1 AS `alamat_db_source`,
 1 AS `address_verified`,
 1 AS `created_at`,
 1 AS `house_number`,
 1 AS `building_number`,
 1 AS `unit_number`,
 1 AS `floor_number`,
 1 AS `rt_number`,
 1 AS `rw_number`,
 1 AS `complex_name`,
 1 AS `gate_number`,
 1 AS `special_instructions`,
 1 AS `user_landmark`,
 1 AS `building_type_id`,
 1 AS `province_name`,
 1 AS `regency_name`,
 1 AS `district_name`,
 1 AS `village_name`,
 1 AS `street_name`,
 1 AS `street_type`,
 1 AS `street_postal_code`,
 1 AS `extended_postal_code`,
 1 AS `landmark_name`,
 1 AS `landmark_type`,
 1 AS `building_type`,
 1 AS `building_category`,
 1 AS `complete_address`,
 1 AS `user_name`,
 1 AS `user_email`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `physical_attributes`
--

DROP TABLE IF EXISTS `physical_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `physical_attributes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `tinggi_badan` int(11) DEFAULT NULL,
  `berat_badan` decimal(5,2) DEFAULT NULL,
  `warna_rambut` varchar(50) DEFAULT NULL,
  `warna_kulit` varchar(50) DEFAULT NULL,
  `warna_mata` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `physical_attributes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `physical_attributes`
--

LOCK TABLES `physical_attributes` WRITE;
/*!40000 ALTER TABLE `physical_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `physical_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `preferences`
--

DROP TABLE IF EXISTS `preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `preference` varchar(255) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `preferences`
--

LOCK TABLES `preferences` WRITE;
/*!40000 ALTER TABLE `preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reference_contacts`
--

DROP TABLE IF EXISTS `reference_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reference_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `relation` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `reference_contacts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reference_contacts`
--

LOCK TABLES `reference_contacts` WRITE;
/*!40000 ALTER TABLE `reference_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `reference_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `religions`
--

DROP TABLE IF EXISTS `religions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `religions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `religions`
--

LOCK TABLES `religions` WRITE;
/*!40000 ALTER TABLE `religions` DISABLE KEYS */;
INSERT INTO `religions` VALUES (5,'Buddha'),(4,'Hindu'),(1,'Islam'),(3,'Katolik'),(6,'Konghucu'),(2,'Kristen'),(7,'Lainnya');
/*!40000 ALTER TABLE `religions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skills`
--

DROP TABLE IF EXISTS `skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `skill_name` varchar(100) NOT NULL,
  `proficiency_level` enum('beginner','intermediate','advanced','expert') DEFAULT 'intermediate',
  `years_of_experience` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `skills_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skills`
--

LOCK TABLES `skills` WRITE;
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_profiles`
--

DROP TABLE IF EXISTS `social_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `platform` varchar(50) NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `username` varchar(100) DEFAULT NULL,
  `followers_count` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_social_platform_user` (`platform`,`username`),
  CONSTRAINT `social_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_profiles`
--

LOCK TABLES `social_profiles` WRITE;
/*!40000 ALTER TABLE `social_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `travel_history`
--

DROP TABLE IF EXISTS `travel_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `travel_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `country` varchar(100) DEFAULT NULL,
  `purpose` varchar(100) DEFAULT NULL,
  `date_from` date DEFAULT NULL,
  `date_to` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `travel_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `travel_history`
--

LOCK TABLES `travel_history` WRITE;
/*!40000 ALTER TABLE `travel_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `travel_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `user_address_summary`
--

DROP TABLE IF EXISTS `user_address_summary`;
/*!50001 DROP VIEW IF EXISTS `user_address_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `user_address_summary` AS SELECT 
 1 AS `user_id`,
 1 AS `user_name`,
 1 AS `user_email`,
 1 AS `address_category`,
 1 AS `address_count`,
 1 AS `verified_count`,
 1 AS `primary_count`,
 1 AS `primary_address`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `user_identity_documents`
--

DROP TABLE IF EXISTS `user_identity_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_identity_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `document_number` (`document_number`),
  KEY `user_id` (`user_id`),
  KEY `identity_type_id` (`identity_type_id`),
  CONSTRAINT `user_identity_documents_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_identity_documents_ibfk_2` FOREIGN KEY (`identity_type_id`) REFERENCES `identity_types` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_identity_documents`
--

LOCK TABLES `user_identity_documents` WRITE;
/*!40000 ALTER TABLE `user_identity_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_identity_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `user_multiple_addresses`
--

DROP TABLE IF EXISTS `user_multiple_addresses`;
/*!50001 DROP VIEW IF EXISTS `user_multiple_addresses`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `user_multiple_addresses` AS SELECT 
 1 AS `id`,
 1 AS `user_id`,
 1 AS `address_type`,
 1 AS `address_category`,
 1 AS `address_purpose`,
 1 AS `purpose_name`,
 1 AS `purpose_category`,
 1 AS `purpose_description`,
 1 AS `priority_level`,
 1 AS `is_primary`,
 1 AS `is_mailing_address`,
 1 AS `is_billing_address`,
 1 AS `is_shipping_address`,
 1 AS `is_work_address`,
 1 AS `is_emergency_address`,
 1 AS `country`,
 1 AS `province_id`,
 1 AS `regency_id`,
 1 AS `district_id`,
 1 AS `village_id`,
 1 AS `postal_code`,
 1 AS `street_address`,
 1 AS `alamat_detil`,
 1 AS `house_number`,
 1 AS `building_number`,
 1 AS `unit_number`,
 1 AS `floor_number`,
 1 AS `rt_number`,
 1 AS `rw_number`,
 1 AS `complex_name`,
 1 AS `gate_number`,
 1 AS `special_instructions`,
 1 AS `user_landmark`,
 1 AS `building_type_id`,
 1 AS `latitude`,
 1 AS `longitude`,
 1 AS `cooperative_id`,
 1 AS `verification_status`,
 1 AS `verification_date`,
 1 AS `verification_method`,
 1 AS `effective_date`,
 1 AS `expiry_date`,
 1 AS `last_used_date`,
 1 AS `usage_count`,
 1 AS `notes`,
 1 AS `created_at`,
 1 AS `province_name`,
 1 AS `regency_name`,
 1 AS `district_name`,
 1 AS `village_name`,
 1 AS `street_name`,
 1 AS `street_type`,
 1 AS `extended_postal_code`,
 1 AS `landmark_name`,
 1 AS `landmark_type`,
 1 AS `building_type`,
 1 AS `building_category`,
 1 AS `user_name`,
 1 AS `user_email`,
 1 AS `complete_address`,
 1 AS `verification_status_text`,
 1 AS `priority_text`,
 1 AS `category_text`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `user_primary_addresses`
--

DROP TABLE IF EXISTS `user_primary_addresses`;
/*!50001 DROP VIEW IF EXISTS `user_primary_addresses`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `user_primary_addresses` AS SELECT 
 1 AS `user_id`,
 1 AS `user_name`,
 1 AS `user_email`,
 1 AS `primary_address`,
 1 AS `primary_address_id`,
 1 AS `mailing_address`,
 1 AS `mailing_address_id`,
 1 AS `billing_address`,
 1 AS `billing_address_id`,
 1 AS `shipping_address`,
 1 AS `shipping_address_id`,
 1 AS `work_address`,
 1 AS `work_address_id`,
 1 AS `emergency_address`,
 1 AS `emergency_address_id`,
 1 AS `total_addresses`,
 1 AS `verified_addresses`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'ADMIN PALING BAIK DI DUNIA','82080038@koperasi.com','081910457868','$2y$10$N.UC2TY6FU5wt70.9cfHvOeCia0FRj.tGZYmsu57jK/a9il9UPP2e','active','email','id','Asia/Jakarta',0,'2026-02-04 17:27:52','2026-02-04 20:02:03'),(2,'Test User','test@example.com','08123456789','test_hash','active','email','id','Asia/Jakarta',0,'2026-03-24 19:36:46','2026-03-24 19:36:46');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_identities_masked`
--

DROP TABLE IF EXISTS `v_identities_masked`;
/*!50001 DROP VIEW IF EXISTS `v_identities_masked`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_identities_masked` AS SELECT 
 1 AS `id`,
 1 AS `user_id`,
 1 AS `nik_masked`,
 1 AS `kk_masked`,
 1 AS `passport_masked`,
 1 AS `sim_masked`,
 1 AS `status`,
 1 AS `verified`,
 1 AS `pep_flag`,
 1 AS `risk_score`,
 1 AS `kyc_last_review_at`,
 1 AS `kyc_next_review_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `people_complete_addresses`
--

/*!50001 DROP VIEW IF EXISTS `people_complete_addresses`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `people_complete_addresses` AS select `a`.`id` AS `id`,`a`.`user_id` AS `user_id`,`a`.`address_type` AS `address_type`,`a`.`is_primary` AS `is_primary`,`a`.`country` AS `country`,`a`.`province_id` AS `province_id`,`a`.`regency_id` AS `regency_id`,`a`.`district_id` AS `district_id`,`a`.`village_id` AS `village_id`,`a`.`postal_code` AS `postal_code`,`a`.`street_address` AS `street_address`,`a`.`alamat_detil` AS `alamat_detil`,`a`.`latitude` AS `latitude`,`a`.`longitude` AS `longitude`,`a`.`alamat_db_source` AS `alamat_db_source`,`a`.`address_verified` AS `address_verified`,`a`.`created_at` AS `created_at`,`p`.`name` AS `province_name`,`r`.`name` AS `regency_name`,`d`.`name` AS `district_name`,`v`.`name` AS `village_name`,concat(coalesce(`a`.`alamat_detil`,`a`.`street_address`,''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`a`.`postal_code`,`v`.`postal_code`,`r`.`postal_code`,'')) AS `complete_address`,`u`.`nama` AS `user_name`,`u`.`email` AS `user_email` from (((((`people_db`.`addresses` `a` left join `alamat_db`.`provinces` `p` on(`a`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`a`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`a`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`a`.`village_id` = `v`.`id`)) left join `people_db`.`users` `u` on(`a`.`user_id` = `u`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `people_complete_addresses_enhanced`
--

/*!50001 DROP VIEW IF EXISTS `people_complete_addresses_enhanced`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `people_complete_addresses_enhanced` AS select `a`.`id` AS `id`,`a`.`user_id` AS `user_id`,`a`.`address_type` AS `address_type`,`a`.`is_primary` AS `is_primary`,`a`.`country` AS `country`,`a`.`province_id` AS `province_id`,`a`.`regency_id` AS `regency_id`,`a`.`district_id` AS `district_id`,`a`.`village_id` AS `village_id`,`a`.`postal_code` AS `postal_code`,`a`.`street_address` AS `street_address`,`a`.`alamat_detil` AS `alamat_detil`,`a`.`latitude` AS `latitude`,`a`.`longitude` AS `longitude`,`a`.`alamat_db_source` AS `alamat_db_source`,`a`.`address_verified` AS `address_verified`,`a`.`created_at` AS `created_at`,`a`.`house_number` AS `house_number`,`a`.`building_number` AS `building_number`,`a`.`unit_number` AS `unit_number`,`a`.`floor_number` AS `floor_number`,`a`.`rt_number` AS `rt_number`,`a`.`rw_number` AS `rw_number`,`a`.`complex_name` AS `complex_name`,`a`.`gate_number` AS `gate_number`,`a`.`special_instructions` AS `special_instructions`,`a`.`user_landmark` AS `user_landmark`,`a`.`building_type_id` AS `building_type_id`,`p`.`name` AS `province_name`,`r`.`name` AS `regency_name`,`d`.`name` AS `district_name`,`v`.`name` AS `village_name`,`s`.`street_name` AS `street_name`,`s`.`street_type` AS `street_type`,`s`.`postal_code` AS `street_postal_code`,`pc`.`postal_code` AS `extended_postal_code`,`l`.`landmark_name` AS `landmark_name`,`l`.`landmark_type` AS `landmark_type`,`bt`.`building_type` AS `building_type`,`bt`.`category` AS `building_category`,concat(coalesce(`a`.`alamat_detil`,`a`.`street_address`,''),', ',coalesce(`a`.`house_number`,''),' ',coalesce(`a`.`building_number`,''),' ',coalesce(`s`.`street_type`,''),' ',coalesce(`s`.`street_name`,''),', ',coalesce(concat('RT ',`a`.`rt_number`),''),' ',coalesce(concat('RW ',`a`.`rw_number`),''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`a`.`postal_code`,`v`.`postal_code`,`r`.`postal_code`,`pc`.`postal_code`,'')) AS `complete_address`,`u`.`nama` AS `user_name`,`u`.`email` AS `user_email` from (((((((((`people_db`.`addresses` `a` left join `alamat_db`.`provinces` `p` on(`a`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`a`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`a`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`a`.`village_id` = `v`.`id`)) left join `alamat_db`.`streets` `s` on(`s`.`village_id` = `v`.`id` and `a`.`street_address` like concat('%',`s`.`street_name`,'%'))) left join `alamat_db`.`postal_codes_extended` `pc` on(`pc`.`village_id` = `v`.`id`)) left join `alamat_db`.`landmarks` `l` on(`l`.`village_id` = `v`.`id`)) left join `alamat_db`.`building_types` `bt` on(`a`.`building_type_id` = `bt`.`id`)) left join `people_db`.`users` `u` on(`a`.`user_id` = `u`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `user_address_summary`
--

/*!50001 DROP VIEW IF EXISTS `user_address_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_address_summary` AS select `user_multiple_addresses`.`user_id` AS `user_id`,`user_multiple_addresses`.`user_name` AS `user_name`,`user_multiple_addresses`.`user_email` AS `user_email`,`user_multiple_addresses`.`address_category` AS `address_category`,count(0) AS `address_count`,sum(case when `user_multiple_addresses`.`verification_status` = 'verified' then 1 else 0 end) AS `verified_count`,sum(case when `user_multiple_addresses`.`is_primary` = 1 then 1 else 0 end) AS `primary_count`,max(case when `user_multiple_addresses`.`priority_level` = 'primary' then `user_multiple_addresses`.`complete_address` end) AS `primary_address` from `people_db`.`user_multiple_addresses` group by `user_multiple_addresses`.`user_id`,`user_multiple_addresses`.`user_name`,`user_multiple_addresses`.`user_email`,`user_multiple_addresses`.`address_category` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `user_multiple_addresses`
--

/*!50001 DROP VIEW IF EXISTS `user_multiple_addresses`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_multiple_addresses` AS select `a`.`id` AS `id`,`a`.`user_id` AS `user_id`,`a`.`address_type` AS `address_type`,`a`.`address_category` AS `address_category`,`a`.`address_purpose` AS `address_purpose`,`ap`.`purpose_name` AS `purpose_name`,`ap`.`purpose_category` AS `purpose_category`,`ap`.`description` AS `purpose_description`,`a`.`priority_level` AS `priority_level`,`a`.`is_primary` AS `is_primary`,`a`.`is_mailing_address` AS `is_mailing_address`,`a`.`is_billing_address` AS `is_billing_address`,`a`.`is_shipping_address` AS `is_shipping_address`,`a`.`is_work_address` AS `is_work_address`,`a`.`is_emergency_address` AS `is_emergency_address`,`a`.`country` AS `country`,`a`.`province_id` AS `province_id`,`a`.`regency_id` AS `regency_id`,`a`.`district_id` AS `district_id`,`a`.`village_id` AS `village_id`,`a`.`postal_code` AS `postal_code`,`a`.`street_address` AS `street_address`,`a`.`alamat_detil` AS `alamat_detil`,`a`.`house_number` AS `house_number`,`a`.`building_number` AS `building_number`,`a`.`unit_number` AS `unit_number`,`a`.`floor_number` AS `floor_number`,`a`.`rt_number` AS `rt_number`,`a`.`rw_number` AS `rw_number`,`a`.`complex_name` AS `complex_name`,`a`.`gate_number` AS `gate_number`,`a`.`special_instructions` AS `special_instructions`,`a`.`user_landmark` AS `user_landmark`,`a`.`building_type_id` AS `building_type_id`,`a`.`latitude` AS `latitude`,`a`.`longitude` AS `longitude`,`a`.`cooperative_id` AS `cooperative_id`,`a`.`verification_status` AS `verification_status`,`a`.`verification_date` AS `verification_date`,`a`.`verification_method` AS `verification_method`,`a`.`effective_date` AS `effective_date`,`a`.`expiry_date` AS `expiry_date`,`a`.`last_used_date` AS `last_used_date`,`a`.`usage_count` AS `usage_count`,`a`.`notes` AS `notes`,`a`.`created_at` AS `created_at`,`p`.`name` AS `province_name`,`r`.`name` AS `regency_name`,`d`.`name` AS `district_name`,`v`.`name` AS `village_name`,`s`.`street_name` AS `street_name`,`s`.`street_type` AS `street_type`,`pc`.`postal_code` AS `extended_postal_code`,`l`.`landmark_name` AS `landmark_name`,`l`.`landmark_type` AS `landmark_type`,`bt`.`building_type` AS `building_type`,`bt`.`category` AS `building_category`,`u`.`nama` AS `user_name`,`u`.`email` AS `user_email`,concat(coalesce(`a`.`alamat_detil`,`a`.`street_address`,''),', ',coalesce(`a`.`house_number`,''),' ',coalesce(`a`.`building_number`,''),' ',coalesce(`s`.`street_type`,''),' ',coalesce(`s`.`street_name`,''),', ',coalesce(concat('RT ',`a`.`rt_number`),''),' ',coalesce(concat('RW ',`a`.`rw_number`),''),', ',coalesce(`a`.`complex_name`,''),', ',coalesce(`v`.`name`,''),', ',coalesce(`d`.`name`,''),', ',coalesce(`r`.`name`,''),', ',coalesce(`p`.`name`,''),' ',coalesce(`a`.`postal_code`,`v`.`postal_code`,`r`.`postal_code`,`pc`.`postal_code`,'')) AS `complete_address`,case when `a`.`verification_status` = 'verified' then 'Terverifikasi' when `a`.`verification_status` = 'pending' then 'Menunggu Verifikasi' when `a`.`verification_status` = 'rejected' then 'Ditolak' else 'Belum Terverifikasi' end AS `verification_status_text`,case when `a`.`priority_level` = 'primary' then 'Utama' when `a`.`priority_level` = 'secondary' then 'Sekunder' when `a`.`priority_level` = 'tertiary' then 'Tersier' when `a`.`priority_level` = 'emergency' then 'Darurat' else 'Tidak Diketahui' end AS `priority_text`,case when `a`.`address_category` = 'personal' then 'Pribadi' when `a`.`address_category` = 'professional' then 'Profesional' when `a`.`address_category` = 'logistics' then 'Logistik' when `a`.`address_category` = 'legal' then 'Legal' else 'Lainnya' end AS `category_text` from ((((((((((`people_db`.`addresses` `a` left join `people_db`.`address_purposes` `ap` on(`a`.`address_purpose` = `ap`.`purpose_code`)) left join `alamat_db`.`provinces` `p` on(`a`.`province_id` = `p`.`id`)) left join `alamat_db`.`regencies` `r` on(`a`.`regency_id` = `r`.`id`)) left join `alamat_db`.`districts` `d` on(`a`.`district_id` = `d`.`id`)) left join `alamat_db`.`villages` `v` on(`a`.`village_id` = `v`.`id`)) left join `alamat_db`.`streets` `s` on(`s`.`village_id` = `v`.`id` and `a`.`street_address` like concat('%',`s`.`street_name`,'%'))) left join `alamat_db`.`postal_codes_extended` `pc` on(`pc`.`village_id` = `v`.`id`)) left join `alamat_db`.`landmarks` `l` on(`l`.`village_id` = `v`.`id`)) left join `alamat_db`.`building_types` `bt` on(`a`.`building_type_id` = `bt`.`id`)) left join `people_db`.`users` `u` on(`a`.`user_id` = `u`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `user_primary_addresses`
--

/*!50001 DROP VIEW IF EXISTS `user_primary_addresses`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_primary_addresses` AS select `user_multiple_addresses`.`user_id` AS `user_id`,`user_multiple_addresses`.`user_name` AS `user_name`,`user_multiple_addresses`.`user_email` AS `user_email`,max(case when `user_multiple_addresses`.`priority_level` = 'primary' then `user_multiple_addresses`.`complete_address` end) AS `primary_address`,max(case when `user_multiple_addresses`.`priority_level` = 'primary' then `user_multiple_addresses`.`id` end) AS `primary_address_id`,max(case when `user_multiple_addresses`.`is_mailing_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `mailing_address`,max(case when `user_multiple_addresses`.`is_mailing_address` = 1 then `user_multiple_addresses`.`id` end) AS `mailing_address_id`,max(case when `user_multiple_addresses`.`is_billing_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `billing_address`,max(case when `user_multiple_addresses`.`is_billing_address` = 1 then `user_multiple_addresses`.`id` end) AS `billing_address_id`,max(case when `user_multiple_addresses`.`is_shipping_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `shipping_address`,max(case when `user_multiple_addresses`.`is_shipping_address` = 1 then `user_multiple_addresses`.`id` end) AS `shipping_address_id`,max(case when `user_multiple_addresses`.`is_work_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `work_address`,max(case when `user_multiple_addresses`.`is_work_address` = 1 then `user_multiple_addresses`.`id` end) AS `work_address_id`,max(case when `user_multiple_addresses`.`is_emergency_address` = 1 then `user_multiple_addresses`.`complete_address` end) AS `emergency_address`,max(case when `user_multiple_addresses`.`is_emergency_address` = 1 then `user_multiple_addresses`.`id` end) AS `emergency_address_id`,count(0) AS `total_addresses`,sum(case when `user_multiple_addresses`.`verification_status` = 'verified' then 1 else 0 end) AS `verified_addresses` from `people_db`.`user_multiple_addresses` group by `user_multiple_addresses`.`user_id`,`user_multiple_addresses`.`user_name`,`user_multiple_addresses`.`user_email` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_identities_masked`
--

/*!50001 DROP VIEW IF EXISTS `v_identities_masked`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_identities_masked` AS select `identities`.`id` AS `id`,`identities`.`user_id` AS `user_id`,concat(repeat('X',12),right(`identities`.`nik`,4)) AS `nik_masked`,concat(repeat('X',12),right(`identities`.`nomor_kk`,4)) AS `kk_masked`,concat('***',right(`identities`.`nomor_passport`,3)) AS `passport_masked`,concat('***',right(`identities`.`nomor_sim`,3)) AS `sim_masked`,`identities`.`status` AS `status`,`identities`.`verified` AS `verified`,`identities`.`pep_flag` AS `pep_flag`,`identities`.`risk_score` AS `risk_score`,`identities`.`kyc_last_review_at` AS `kyc_last_review_at`,`identities`.`kyc_next_review_at` AS `kyc_next_review_at` from `identities` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-25 13:38:11
