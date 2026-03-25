-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: mono_v2
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
-- Temporary view structure for view `dashboard_stats`
--

DROP TABLE IF EXISTS `dashboard_stats`;
/*!50001 DROP VIEW IF EXISTS `dashboard_stats`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dashboard_stats` AS SELECT 
 1 AS `active_users`,
 1 AS `active_members`,
 1 AS `active_loans`,
 1 AS `pending_loans`,
 1 AS `total_savings`,
 1 AS `total_loans`,
 1 AS `today_tracking_points`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `geofence_areas`
--

DROP TABLE IF EXISTS `geofence_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `geofence_areas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `radius` decimal(8,2) NOT NULL,
  `type` enum('safe','restricted','risk') NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `geofence_areas`
--

LOCK TABLES `geofence_areas` WRITE;
/*!40000 ALTER TABLE `geofence_areas` DISABLE KEYS */;
INSERT INTO `geofence_areas` VALUES (1,'KSP Office',-6.20880000,106.84560000,100.00,'safe','Main office area',1,'2026-03-24 21:29:18','2026-03-24 21:29:18'),(2,'Restricted Zone A',-6.21000000,106.84700000,50.00,'restricted','High security area',1,'2026-03-24 21:29:18','2026-03-24 21:29:18'),(3,'Risk Area B',-6.20700000,106.84400000,75.00,'risk','Potential danger zone',1,'2026-03-24 21:29:18','2026-03-24 21:29:18'),(4,'KSP Office',-6.20880000,106.84560000,100.00,'safe','Main office area',1,'2026-03-24 21:29:27','2026-03-24 21:29:27'),(5,'Restricted Zone A',-6.21000000,106.84700000,50.00,'restricted','High security area',1,'2026-03-24 21:29:27','2026-03-24 21:29:27'),(6,'Risk Area B',-6.20700000,106.84400000,75.00,'risk','Potential danger zone',1,'2026-03-24 21:29:27','2026-03-24 21:29:27'),(7,'KSP Office',-6.20880000,106.84560000,100.00,'safe','Main office area',1,'2026-03-24 21:29:35','2026-03-24 21:29:35'),(8,'Restricted Zone A',-6.21000000,106.84700000,50.00,'restricted','High security area',1,'2026-03-24 21:29:35','2026-03-24 21:29:35'),(9,'Risk Area B',-6.20700000,106.84400000,75.00,'risk','Potential danger zone',1,'2026-03-24 21:29:35','2026-03-24 21:29:35');
/*!40000 ALTER TABLE `geofence_areas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gps_tracking`
--

DROP TABLE IF EXISTS `gps_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gps_tracking` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `accuracy` decimal(8,2) DEFAULT NULL,
  `altitude` decimal(8,2) DEFAULT NULL,
  `speed` decimal(8,2) DEFAULT NULL,
  `bearing` decimal(8,2) DEFAULT NULL,
  `timestamp` datetime NOT NULL,
  `tracking_session` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_staff_id` (`staff_id`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `idx_tracking_session` (`tracking_session`),
  CONSTRAINT `gps_tracking_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gps_tracking`
--

LOCK TABLES `gps_tracking` WRITE;
/*!40000 ALTER TABLE `gps_tracking` DISABLE KEYS */;
INSERT INTO `gps_tracking` VALUES (1,3,-6.20880000,106.84560000,10.00,NULL,NULL,NULL,'2026-03-25 04:29:35','session_001','2026-03-24 21:29:35'),(2,3,-6.20900000,106.84580000,12.00,NULL,NULL,NULL,'2026-03-25 03:29:35','session_001','2026-03-24 21:29:35'),(3,3,-6.20920000,106.84600000,8.00,NULL,NULL,NULL,'2026-03-25 02:29:35','session_001','2026-03-24 21:29:35');
/*!40000 ALTER TABLE `gps_tracking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loans`
--

DROP TABLE IF EXISTS `loans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `loan_number` varchar(20) NOT NULL,
  `member_id` int(11) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `interest_rate` decimal(5,2) NOT NULL,
  `duration_months` int(11) NOT NULL,
  `purpose` text DEFAULT NULL,
  `status` enum('pending','approved','rejected','active','completed','defaulted') DEFAULT 'pending',
  `approved_by` int(11) DEFAULT NULL,
  `approved_date` datetime DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `monthly_payment` decimal(15,2) DEFAULT NULL,
  `remaining_balance` decimal(15,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `loan_number` (`loan_number`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_loan_number` (`loan_number`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `loans_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `loans_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loans`
--

LOCK TABLES `loans` WRITE;
/*!40000 ALTER TABLE `loans` DISABLE KEYS */;
/*!40000 ALTER TABLE `loans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `members`
--

DROP TABLE IF EXISTS `members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_number` varchar(20) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `join_date` date DEFAULT NULL,
  `status` enum('active','inactive','blacklisted') DEFAULT 'active',
  `balance` decimal(15,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `member_number` (`member_number`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_member_number` (`member_number`),
  KEY `idx_email` (`email`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `members`
--

LOCK TABLES `members` WRITE;
/*!40000 ALTER TABLE `members` DISABLE KEYS */;
INSERT INTO `members` VALUES (1,'M001','Updated Member Name','budi@example.com','08123456789','Jl. Merdeka No. 123, Jakarta',NULL,'2026-03-25','active',0.00,'2026-03-24 21:29:18','2026-03-25 00:30:15'),(2,'M002','Siti Nurhaliza','siti@example.com','08123456790','Jl. Sudirman No. 456, Jakarta',NULL,'2026-03-25','active',0.00,'2026-03-24 21:29:18','2026-03-24 21:29:35'),(3,'M003','Ahmad Wijaya','ahmad@example.com','08123456791','Jl. Gatot Subroto No. 789, Jakarta',NULL,'2026-03-25','active',0.00,'2026-03-24 21:29:18','2026-03-24 21:29:35'),(10,'M2026036136','Test User','test@example.com','08123456789','Test Address',NULL,'2026-03-25','active',0.00,'2026-03-25 06:08:50','2026-03-25 06:08:50'),(11,'M2026030559','Test User','test4@example.com','08123456789','',NULL,'2026-03-25','active',0.00,'2026-03-25 06:10:06','2026-03-25 06:10:06'),(12,'M2026032411','<script>alert(\"XSS\")</script>','xss@example.com','08123456789','',NULL,'2026-03-25','active',0.00,'2026-03-25 06:13:42','2026-03-25 06:13:42');
/*!40000 ALTER TABLE `members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `savings`
--

DROP TABLE IF EXISTS `savings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `savings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transaction_type` enum('deposit','withdrawal','interest') NOT NULL,
  `description` text DEFAULT NULL,
  `balance_after` decimal(15,2) NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_transaction_type` (`transaction_type`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `savings_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `savings_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `savings`
--

LOCK TABLES `savings` WRITE;
/*!40000 ALTER TABLE `savings` DISABLE KEYS */;
/*!40000 ALTER TABLE `savings` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER after_savings_insert 
AFTER INSERT ON savings
FOR EACH ROW
BEGIN
    CALL UpdateMemberBalance(NEW.member_id);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `system_logs`
--

DROP TABLE IF EXISTS `system_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `level` enum('info','warning','error','critical') DEFAULT 'info',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_level` (`level`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `system_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_logs`
--

LOCK TABLES `system_logs` WRITE;
/*!40000 ALTER TABLE `system_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_number` varchar(20) NOT NULL,
  `member_id` int(11) DEFAULT NULL,
  `type` enum('loan_payment','savings_deposit','savings_withdrawal','fee','penalty') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `description` text DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `status` enum('pending','completed','cancelled') DEFAULT 'pending',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_number` (`transaction_number`),
  KEY `created_by` (`created_by`),
  KEY `idx_transaction_number` (`transaction_number`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER after_transaction_insert 
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    INSERT INTO system_logs (user_id, action, description, level)
    VALUES (NEW.created_by, NEW.type, CONCAT('Transaction ', NEW.transaction_number, ' created'), 'info');
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `role` enum('admin','staff','member','bos') NOT NULL DEFAULT 'member',
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'manager','$2y$10$Ur819K2YeKzhJNxfxYT47OOXWFmaLDb93MS0ZZkrHjt4WnShEzZLm','manager@ksp-lamgabejaya.com','Manager','bos',NULL,NULL,'active',NULL,'2026-03-24 21:29:18','2026-03-25 05:29:52'),(3,'staff','$2y$10$yqdtFQBCrU0wJcFr3tVHmuQiMBJfHmo4lokwr4OkOIcq/hCDl3pLS','staff@ksp-lamgabejaya.com','Staff User','staff',NULL,NULL,'active',NULL,'2026-03-24 21:29:18','2026-03-25 05:29:52'),(10,'member001','$2y$10$f7CjytOIZ8C055ylafl2EOdj9ZhNAzCb8byb3kkNEQAuLyTAG15iy','member001@ksplamabejaya.co.id','','member',NULL,NULL,'active',NULL,'2026-03-25 04:26:16','2026-03-25 05:29:52'),(14,'admin','$2y$10$SGP7XW0I2VIpVuPB.O49h.LQBojzhDhr89cCWRfgLn4Qbmz7gjeAK','admin@ksp.com','Administrator','admin',NULL,NULL,'active','2026-03-25 13:30:15','2026-03-25 05:53:45','2026-03-25 06:30:15');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `dashboard_stats`
--

/*!50001 DROP VIEW IF EXISTS `dashboard_stats`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `dashboard_stats` AS select (select count(0) from `users` where `users`.`status` = 'active') AS `active_users`,(select count(0) from `members` where `members`.`status` = 'active') AS `active_members`,(select count(0) from `loans` where `loans`.`status` = 'active') AS `active_loans`,(select count(0) from `loans` where `loans`.`status` = 'pending') AS `pending_loans`,(select coalesce(sum(`members`.`balance`),0) from `members` where `members`.`status` = 'active') AS `total_savings`,(select coalesce(sum(`loans`.`amount`),0) from `loans` where `loans`.`status` = 'active') AS `total_loans`,(select count(0) from `gps_tracking` where cast(`gps_tracking`.`timestamp` as date) = curdate()) AS `today_tracking_points` */;
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

-- Dump completed on 2026-03-25 13:38:02
