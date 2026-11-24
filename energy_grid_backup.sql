-- MySQL dump 10.13  Distrib 26.10.0, for macos26.6 (arm64)
--
-- Host: localhost    Database: energy_grid_db
-- ------------------------------------------------------
-- Server version	26.10.0

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
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'e8c0b716-d0f6-11f1-a11d-698047e29959:1-78';

--
-- Table structure for table `Energy_Consumption`
--

DROP TABLE IF EXISTS `Energy_Consumption`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Energy_Consumption` (
  `Consumption_ID` int NOT NULL AUTO_INCREMENT,
  `Zone_ID` int NOT NULL,
  `Recorded_At` datetime NOT NULL,
  `Energy_Consumed_MWh` decimal(12,2) NOT NULL,
  `Consumer_Category` varchar(60) NOT NULL,
  PRIMARY KEY (`Consumption_ID`),
  KEY `idx_consumption_zone_time` (`Zone_ID`,`Recorded_At`),
  CONSTRAINT `fk_consumption_zone` FOREIGN KEY (`Zone_ID`) REFERENCES `Grid_Zone` (`Zone_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_consumption_nonnegative` CHECK ((`Energy_Consumed_MWh` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Energy_Consumption`
--

LOCK TABLES `Energy_Consumption` WRITE;
/*!40000 ALTER TABLE `Energy_Consumption` DISABLE KEYS */;
INSERT INTO `Energy_Consumption` VALUES (1,1,'2026-10-30 18:00:00',420.00,'Residential'),(2,1,'2026-10-30 18:00:00',65.00,'Commercial'),(3,2,'2026-10-30 18:00:00',310.00,'Industrial'),(4,2,'2026-10-30 18:00:00',55.00,'Residential'),(5,3,'2026-10-30 18:00:00',250.00,'Residential'),(6,3,'2026-10-30 18:00:00',45.00,'Commercial');
/*!40000 ALTER TABLE `Energy_Consumption` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Energy_Demand`
--

DROP TABLE IF EXISTS `Energy_Demand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Energy_Demand` (
  `Demand_ID` int NOT NULL AUTO_INCREMENT,
  `Zone_ID` int NOT NULL,
  `Recorded_At` datetime NOT NULL,
  `Demand_MW` decimal(10,2) NOT NULL,
  `Peak_Demand_Flag` tinyint(1) NOT NULL DEFAULT '0',
  `Source_Description` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`Demand_ID`),
  KEY `idx_demand_zone_time` (`Zone_ID`,`Recorded_At`),
  CONSTRAINT `fk_demand_zone` FOREIGN KEY (`Zone_ID`) REFERENCES `Grid_Zone` (`Zone_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_demand_nonnegative` CHECK ((`Demand_MW` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Energy_Demand`
--

LOCK TABLES `Energy_Demand` WRITE;
/*!40000 ALTER TABLE `Energy_Demand` DISABLE KEYS */;
INSERT INTO `Energy_Demand` VALUES (1,1,'2026-10-30 10:00:00',410.00,0,'Hourly meter reading'),(2,1,'2026-10-30 18:00:00',485.00,1,'Evening peak reading'),(3,2,'2026-10-30 10:00:00',300.00,0,'Hourly meter reading'),(4,2,'2026-10-30 18:00:00',390.00,1,'Industrial evening peak'),(5,3,'2026-10-30 10:00:00',280.00,0,'Hourly meter reading'),(6,3,'2026-10-30 18:00:00',320.00,1,'Evening peak reading');
/*!40000 ALTER TABLE `Energy_Demand` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Energy_Generation`
--

DROP TABLE IF EXISTS `Energy_Generation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Energy_Generation` (
  `Generation_ID` int NOT NULL AUTO_INCREMENT,
  `Station_ID` int NOT NULL,
  `Recorded_At` datetime NOT NULL,
  `Generation_MW` decimal(10,2) NOT NULL,
  `Energy_Source` varchar(60) NOT NULL,
  PRIMARY KEY (`Generation_ID`),
  KEY `idx_generation_station_time` (`Station_ID`,`Recorded_At`),
  CONSTRAINT `fk_generation_station` FOREIGN KEY (`Station_ID`) REFERENCES `Power_Station` (`Station_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_generation_nonnegative` CHECK ((`Generation_MW` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Energy_Generation`
--

LOCK TABLES `Energy_Generation` WRITE;
/*!40000 ALTER TABLE `Energy_Generation` DISABLE KEYS */;
INSERT INTO `Energy_Generation` VALUES (1,1,'2026-10-30 18:00:00',390.00,'Thermal'),(2,2,'2026-10-30 18:00:00',90.00,'Solar'),(3,3,'2026-10-30 18:00:00',280.00,'Gas'),(4,4,'2026-10-30 18:00:00',300.00,'Mixed');
/*!40000 ALTER TABLE `Energy_Generation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Energy_Storage_Unit`
--

DROP TABLE IF EXISTS `Energy_Storage_Unit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Energy_Storage_Unit` (
  `Storage_ID` int NOT NULL AUTO_INCREMENT,
  `Station_ID` int NOT NULL,
  `Technology_ID` int NOT NULL,
  `Storage_Name` varchar(120) NOT NULL,
  `Capacity_MWh` decimal(10,2) NOT NULL,
  `Current_Charge_Percent` decimal(5,2) NOT NULL,
  `Max_Discharge_MW` decimal(10,2) NOT NULL,
  `Unit_Status` enum('Available','In Use','Maintenance','Offline') NOT NULL DEFAULT 'Available',
  `Commissioned_Date` date DEFAULT NULL,
  PRIMARY KEY (`Storage_ID`),
  KEY `fk_storage_station` (`Station_ID`),
  KEY `fk_storage_technology` (`Technology_ID`),
  KEY `idx_storage_status_charge` (`Unit_Status`,`Current_Charge_Percent`),
  CONSTRAINT `fk_storage_station` FOREIGN KEY (`Station_ID`) REFERENCES `Power_Station` (`Station_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_storage_technology` FOREIGN KEY (`Technology_ID`) REFERENCES `Storage_Technology` (`Technology_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_storage_capacity` CHECK ((`Capacity_MWh` > 0)),
  CONSTRAINT `chk_storage_charge` CHECK ((`Current_Charge_Percent` between 0 and 100)),
  CONSTRAINT `chk_storage_discharge` CHECK ((`Max_Discharge_MW` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Energy_Storage_Unit`
--

LOCK TABLES `Energy_Storage_Unit` WRITE;
/*!40000 ALTER TABLE `Energy_Storage_Unit` DISABLE KEYS */;
INSERT INTO `Energy_Storage_Unit` VALUES (1,1,1,'Noida Battery A',100.00,85.00,25.00,'Available','2023-04-01'),(2,2,1,'Solar Backup B',60.00,35.00,15.00,'Available','2024-01-15'),(3,3,2,'Industrial Storage C',150.00,20.00,30.00,'Available','2022-08-10'),(4,4,1,'South Delhi Battery D',80.00,90.00,20.00,'In Use','2023-11-20'),(5,4,3,'South Delhi Hydro E',200.00,70.00,40.00,'Available','2021-06-01');
/*!40000 ALTER TABLE `Energy_Storage_Unit` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_storage_low_charge_after_insert` AFTER INSERT ON `energy_storage_unit` FOR EACH ROW BEGIN
    IF NEW.Current_Charge_Percent <= 30
       AND NOT EXISTS (
           SELECT 1
           FROM Storage_Alert
           WHERE Storage_ID = NEW.Storage_ID
             AND Alert_Type = 'Low Charge'
             AND Alert_Status = 'Active'
       ) THEN

        INSERT INTO Storage_Alert (
            Storage_ID,
            Alert_Type,
            Alert_Message,
            Alert_Status
        )
        VALUES (
            NEW.Storage_ID,
            'Low Charge',
            CONCAT(
                'Automatic alert: charge is ',
                NEW.Current_Charge_Percent,
                '%'
            ),
            'Active'
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
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_storage_low_charge_after_update` AFTER UPDATE ON `energy_storage_unit` FOR EACH ROW BEGIN
    IF NEW.Current_Charge_Percent <= 30
       AND OLD.Current_Charge_Percent > 30
       AND NOT EXISTS (
           SELECT 1
           FROM Storage_Alert
           WHERE Storage_ID = NEW.Storage_ID
             AND Alert_Type = 'Low Charge'
             AND Alert_Status = 'Active'
       ) THEN

        INSERT INTO Storage_Alert (
            Storage_ID,
            Alert_Type,
            Alert_Message,
            Alert_Status
        )
        VALUES (
            NEW.Storage_ID,
            'Low Charge',
            CONCAT(
                'Automatic alert: charge fell to ',
                NEW.Current_Charge_Percent,
                '%'
            ),
            'Active'
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Grid_Incident`
--

DROP TABLE IF EXISTS `Grid_Incident`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Grid_Incident` (
  `Incident_ID` int NOT NULL AUTO_INCREMENT,
  `Zone_ID` int NOT NULL,
  `Incident_Type` varchar(80) NOT NULL,
  `Incident_Description` varchar(255) NOT NULL,
  `Severity` enum('Low','Medium','High','Critical') NOT NULL,
  `Started_At` datetime NOT NULL,
  `Resolved_At` datetime DEFAULT NULL,
  `Incident_Status` enum('Open','In Progress','Resolved') NOT NULL DEFAULT 'Open',
  PRIMARY KEY (`Incident_ID`),
  KEY `idx_incident_zone_status` (`Zone_ID`,`Incident_Status`),
  KEY `idx_incident_status_severity` (`Incident_Status`,`Severity`),
  CONSTRAINT `fk_incident_zone` FOREIGN KEY (`Zone_ID`) REFERENCES `Grid_Zone` (`Zone_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_incident_dates` CHECK (((`Resolved_At` is null) or (`Resolved_At` >= `Started_At`)))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Grid_Incident`
--

LOCK TABLES `Grid_Incident` WRITE;
/*!40000 ALTER TABLE `Grid_Incident` DISABLE KEYS */;
INSERT INTO `Grid_Incident` VALUES (1,1,'Demand Surge','Unexpected rise in evening electricity demand','High','2026-10-30 17:45:00',NULL,'In Progress'),(2,2,'Equipment Overload','Transformer operating near its rated limit','Critical','2026-10-30 17:30:00',NULL,'Open'),(3,3,'Voltage Fluctuation','Short voltage fluctuation reported','Medium','2026-10-30 16:20:00','2026-10-30 17:00:00','Resolved');
/*!40000 ALTER TABLE `Grid_Incident` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Grid_Stress`
--

DROP TABLE IF EXISTS `Grid_Stress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Grid_Stress` (
  `Stress_ID` int NOT NULL AUTO_INCREMENT,
  `Zone_ID` int NOT NULL,
  `Assessed_At` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Grid_Stress_Score` decimal(6,2) NOT NULL,
  `Stress_Level` enum('Normal','Moderate','High','Critical') NOT NULL,
  `Assessment_Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Stress_ID`),
  KEY `idx_stress_zone_time` (`Zone_ID`,`Assessed_At`),
  KEY `idx_stress_level_time` (`Stress_Level`,`Assessed_At`),
  CONSTRAINT `fk_stress_zone` FOREIGN KEY (`Zone_ID`) REFERENCES `Grid_Zone` (`Zone_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_stress_score` CHECK ((`Grid_Stress_Score` between 0 and 100))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Grid_Stress`
--

LOCK TABLES `Grid_Stress` WRITE;
/*!40000 ALTER TABLE `Grid_Stress` DISABLE KEYS */;
INSERT INTO `Grid_Stress` VALUES (1,1,'2026-10-30 18:15:00',78.00,'High','High evening demand; storage available'),(2,2,'2026-10-30 18:15:00',91.00,'Critical','Industrial demand spike and low storage charge'),(3,3,'2026-10-30 18:15:00',42.00,'Moderate','Demand elevated but manageable'),(4,1,'2026-11-10 15:39:34',80.46,'Critical','Rule-based: 60% demand pressure, 25% storage deficit, 15% incident pressure');
/*!40000 ALTER TABLE `Grid_Stress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Grid_Zone`
--

DROP TABLE IF EXISTS `Grid_Zone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Grid_Zone` (
  `Zone_ID` int NOT NULL AUTO_INCREMENT,
  `Zone_Name` varchar(100) NOT NULL,
  `City` varchar(80) NOT NULL,
  `State_Name` varchar(80) NOT NULL,
  `Zone_Description` varchar(255) DEFAULT NULL,
  `Created_At` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Zone_ID`),
  UNIQUE KEY `Zone_Name` (`Zone_Name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Grid_Zone`
--

LOCK TABLES `Grid_Zone` WRITE;
/*!40000 ALTER TABLE `Grid_Zone` DISABLE KEYS */;
INSERT INTO `Grid_Zone` VALUES (1,'Noida Central','Noida','Uttar Pradesh','Central commercial and residential zone','2026-11-10 15:30:13'),(2,'Greater Noida East','Greater Noida','Uttar Pradesh','Industrial and residential zone','2026-11-10 15:30:13'),(3,'Delhi South','New Delhi','Delhi','Mixed-use urban zone','2026-11-10 15:30:13');
/*!40000 ALTER TABLE `Grid_Zone` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Maintenance`
--

DROP TABLE IF EXISTS `Maintenance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Maintenance` (
  `Maintenance_ID` int NOT NULL AUTO_INCREMENT,
  `Storage_ID` int NOT NULL,
  `Technician_ID` int NOT NULL,
  `Scheduled_Date` date NOT NULL,
  `Completed_Date` date DEFAULT NULL,
  `Maintenance_Type` varchar(80) NOT NULL,
  `Maintenance_Description` varchar(255) DEFAULT NULL,
  `Maintenance_Status` enum('Scheduled','In Progress','Completed','Cancelled') NOT NULL DEFAULT 'Scheduled',
  PRIMARY KEY (`Maintenance_ID`),
  KEY `fk_maintenance_technician` (`Technician_ID`),
  KEY `idx_maintenance_storage_date` (`Storage_ID`,`Scheduled_Date`),
  CONSTRAINT `fk_maintenance_storage` FOREIGN KEY (`Storage_ID`) REFERENCES `Energy_Storage_Unit` (`Storage_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_maintenance_technician` FOREIGN KEY (`Technician_ID`) REFERENCES `Technician` (`Technician_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_maintenance_dates` CHECK (((`Completed_Date` is null) or (`Completed_Date` >= `Scheduled_Date`)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Maintenance`
--

LOCK TABLES `Maintenance` WRITE;
/*!40000 ALTER TABLE `Maintenance` DISABLE KEYS */;
INSERT INTO `Maintenance` VALUES (1,1,1,'2026-11-05',NULL,'Routine Inspection','Check battery health and terminal connections','Scheduled'),(2,2,2,'2026-10-25','2026-10-25','Battery Calibration','Charge calibration completed','Completed'),(3,3,1,'2026-11-02',NULL,'Capacity Test','Investigate reduced charge retention','Scheduled'),(4,4,2,'2026-10-28',NULL,'Cooling Check','Inspect cooling system','In Progress');
/*!40000 ALTER TABLE `Maintenance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Power_Station`
--

DROP TABLE IF EXISTS `Power_Station`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Power_Station` (
  `Station_ID` int NOT NULL AUTO_INCREMENT,
  `Zone_ID` int NOT NULL,
  `Station_Name` varchar(120) NOT NULL,
  `Station_Type` varchar(50) NOT NULL,
  `Installed_Capacity_MW` decimal(10,2) NOT NULL,
  `Operational_Status` enum('Operational','Maintenance','Offline') NOT NULL DEFAULT 'Operational',
  PRIMARY KEY (`Station_ID`),
  UNIQUE KEY `Zone_ID` (`Zone_ID`,`Station_Name`),
  CONSTRAINT `fk_station_zone` FOREIGN KEY (`Zone_ID`) REFERENCES `Grid_Zone` (`Zone_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_station_capacity` CHECK ((`Installed_Capacity_MW` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Power_Station`
--

LOCK TABLES `Power_Station` WRITE;
/*!40000 ALTER TABLE `Power_Station` DISABLE KEYS */;
INSERT INTO `Power_Station` VALUES (1,1,'Noida Thermal Station','Thermal',500.00,'Operational'),(2,1,'Noida Solar Park','Solar',120.00,'Operational'),(3,2,'Greater Noida Gas Station','Gas',350.00,'Operational'),(4,3,'South Delhi Grid Station','Mixed',420.00,'Operational');
/*!40000 ALTER TABLE `Power_Station` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Resource_Allocation`
--

DROP TABLE IF EXISTS `Resource_Allocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Resource_Allocation` (
  `Allocation_ID` int NOT NULL AUTO_INCREMENT,
  `Storage_ID` int NOT NULL,
  `Incident_ID` int NOT NULL,
  `Allocated_At` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Allocated_Power_MW` decimal(10,2) NOT NULL,
  `Allocation_Duration_Hours` decimal(8,2) NOT NULL,
  `Allocation_Status` enum('Planned','Active','Completed','Cancelled') NOT NULL DEFAULT 'Planned',
  PRIMARY KEY (`Allocation_ID`),
  KEY `idx_allocation_incident` (`Incident_ID`),
  KEY `idx_allocation_storage` (`Storage_ID`),
  CONSTRAINT `fk_allocation_incident` FOREIGN KEY (`Incident_ID`) REFERENCES `Grid_Incident` (`Incident_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_allocation_storage` FOREIGN KEY (`Storage_ID`) REFERENCES `Energy_Storage_Unit` (`Storage_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_allocation_duration` CHECK ((`Allocation_Duration_Hours` > 0)),
  CONSTRAINT `chk_allocation_power` CHECK ((`Allocated_Power_MW` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Resource_Allocation`
--

LOCK TABLES `Resource_Allocation` WRITE;
/*!40000 ALTER TABLE `Resource_Allocation` DISABLE KEYS */;
INSERT INTO `Resource_Allocation` VALUES (1,1,1,'2026-10-30 18:30:00',10.00,2.00,'Active'),(2,3,2,'2026-10-30 18:35:00',12.00,3.00,'Planned'),(3,4,3,'2026-10-30 16:30:00',5.00,1.00,'Completed');
/*!40000 ALTER TABLE `Resource_Allocation` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_allocation_before_insert` BEFORE INSERT ON `resource_allocation` FOR EACH ROW BEGIN
    DECLARE v_max_mw DECIMAL(10,2) DEFAULT NULL;
    DECLARE v_energy DECIMAL(12,2) DEFAULT NULL;

    IF NEW.Allocation_Status IN ('Planned', 'Active') THEN

        SELECT
            MAX(Max_Discharge_MW),
            MAX(Capacity_MWh * Current_Charge_Percent / 100)
        INTO v_max_mw, v_energy
        FROM Energy_Storage_Unit
        WHERE Storage_ID = NEW.Storage_ID
          AND Unit_Status IN ('Available', 'In Use');

        IF v_max_mw IS NULL OR v_energy IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Storage unit is unavailable for allocation';
        END IF;

        IF NEW.Allocated_Power_MW > v_max_mw THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Allocated MW exceeds unit max discharge';
        END IF;

        IF NEW.Allocated_Power_MW * NEW.Allocation_Duration_Hours > v_energy THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Allocation MWh exceeds stored energy';
        END IF;

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
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_allocation_before_update` BEFORE UPDATE ON `resource_allocation` FOR EACH ROW BEGIN
    DECLARE v_max_mw DECIMAL(10,2) DEFAULT NULL;
    DECLARE v_energy DECIMAL(12,2) DEFAULT NULL;

    IF NEW.Allocation_Status IN ('Planned', 'Active') THEN

        SELECT
            MAX(Max_Discharge_MW),
            MAX(Capacity_MWh * Current_Charge_Percent / 100)
        INTO v_max_mw, v_energy
        FROM Energy_Storage_Unit
        WHERE Storage_ID = NEW.Storage_ID
          AND Unit_Status IN ('Available', 'In Use');

        IF v_max_mw IS NULL OR v_energy IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Storage unit is unavailable for allocation';
        END IF;

        IF NEW.Allocated_Power_MW > v_max_mw THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Allocated MW exceeds unit max discharge';
        END IF;

        IF NEW.Allocated_Power_MW * NEW.Allocation_Duration_Hours > v_energy THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Allocation MWh exceeds stored energy';
        END IF;

    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Storage_Alert`
--

DROP TABLE IF EXISTS `Storage_Alert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Storage_Alert` (
  `Alert_ID` int NOT NULL AUTO_INCREMENT,
  `Storage_ID` int NOT NULL,
  `Alert_Type` enum('Low Charge','Maintenance Due','Unit Fault','Capacity Warning') NOT NULL,
  `Alert_Message` varchar(255) NOT NULL,
  `Created_At` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Alert_Status` enum('Active','Acknowledged','Closed') NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`Alert_ID`),
  KEY `idx_alert_storage_status` (`Storage_ID`,`Alert_Status`),
  CONSTRAINT `fk_alert_storage` FOREIGN KEY (`Storage_ID`) REFERENCES `Energy_Storage_Unit` (`Storage_ID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Storage_Alert`
--

LOCK TABLES `Storage_Alert` WRITE;
/*!40000 ALTER TABLE `Storage_Alert` DISABLE KEYS */;
INSERT INTO `Storage_Alert` VALUES (1,2,'Low Charge','Storage unit charge is below 40 percent','2026-10-30 18:20:00','Active'),(2,3,'Low Charge','Storage unit charge is critically low','2026-10-30 18:21:00','Active'),(3,4,'Maintenance Due','Scheduled inspection is approaching','2026-10-29 09:00:00','Acknowledged');
/*!40000 ALTER TABLE `Storage_Alert` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Storage_Technology`
--

DROP TABLE IF EXISTS `Storage_Technology`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Storage_Technology` (
  `Technology_ID` int NOT NULL AUTO_INCREMENT,
  `Technology_Name` varchar(80) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Typical_Life_Years` decimal(4,1) DEFAULT NULL,
  PRIMARY KEY (`Technology_ID`),
  UNIQUE KEY `Technology_Name` (`Technology_Name`),
  CONSTRAINT `chk_technology_life` CHECK (((`Typical_Life_Years` is null) or (`Typical_Life_Years` > 0)))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Storage_Technology`
--

LOCK TABLES `Storage_Technology` WRITE;
/*!40000 ALTER TABLE `Storage_Technology` DISABLE KEYS */;
INSERT INTO `Storage_Technology` VALUES (1,'Lithium-Ion','High efficiency electrochemical battery',12.0),(2,'Flow Battery','Rechargeable liquid electrolyte battery',20.0),(3,'Pumped Hydro','Water-based gravitational energy storage',40.0);
/*!40000 ALTER TABLE `Storage_Technology` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Technician`
--

DROP TABLE IF EXISTS `Technician`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Technician` (
  `Technician_ID` int NOT NULL AUTO_INCREMENT,
  `Technician_Name` varchar(120) NOT NULL,
  `Phone_Number` varchar(20) DEFAULT NULL,
  `Email` varchar(120) DEFAULT NULL,
  `Specialization` varchar(100) NOT NULL,
  PRIMARY KEY (`Technician_ID`),
  UNIQUE KEY `Phone_Number` (`Phone_Number`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Technician`
--

LOCK TABLES `Technician` WRITE;
/*!40000 ALTER TABLE `Technician` DISABLE KEYS */;
INSERT INTO `Technician` VALUES (1,'Rohit Sharma','9876500001','rohit.tech@example.com','Battery Systems'),(2,'Neha Verma','9876500002','neha.tech@example.com','Electrical Maintenance'),(3,'Aman Khan','9876500003','aman.tech@example.com','Grid Equipment');
/*!40000 ALTER TABLE `Technician` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_zone_latest_stress`
--

DROP TABLE IF EXISTS `vw_zone_latest_stress`;
/*!50001 DROP VIEW IF EXISTS `vw_zone_latest_stress`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_zone_latest_stress` AS SELECT 
 1 AS `Zone_ID`,
 1 AS `Zone_Name`,
 1 AS `Stress_ID`,
 1 AS `Grid_Stress_Score`,
 1 AS `Stress_Level`,
 1 AS `Assessed_At`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_zone_storage_summary`
--

DROP TABLE IF EXISTS `vw_zone_storage_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_zone_storage_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_zone_storage_summary` AS SELECT 
 1 AS `Zone_ID`,
 1 AS `Zone_Name`,
 1 AS `Storage_Unit_Count`,
 1 AS `Total_Capacity_MWh`,
 1 AS `Stored_Energy_MWh`,
 1 AS `Available_Stored_MWh`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_zone_latest_stress`
--

/*!50001 DROP VIEW IF EXISTS `vw_zone_latest_stress`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_zone_latest_stress` AS select `z`.`Zone_ID` AS `Zone_ID`,`z`.`Zone_Name` AS `Zone_Name`,`gs`.`Stress_ID` AS `Stress_ID`,`gs`.`Grid_Stress_Score` AS `Grid_Stress_Score`,`gs`.`Stress_Level` AS `Stress_Level`,`gs`.`Assessed_At` AS `Assessed_At` from (`grid_zone` `z` left join `grid_stress` `gs` on(((`gs`.`Zone_ID` = `z`.`Zone_ID`) and (`gs`.`Assessed_At` = (select max(`g2`.`Assessed_At`) from `grid_stress` `g2` where (`g2`.`Zone_ID` = `z`.`Zone_ID`)))))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_zone_storage_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_zone_storage_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_zone_storage_summary` AS select `z`.`Zone_ID` AS `Zone_ID`,`z`.`Zone_Name` AS `Zone_Name`,count(`es`.`Storage_ID`) AS `Storage_Unit_Count`,coalesce(sum(`es`.`Capacity_MWh`),0) AS `Total_Capacity_MWh`,coalesce(sum(((`es`.`Capacity_MWh` * `es`.`Current_Charge_Percent`) / 100)),0) AS `Stored_Energy_MWh`,coalesce(sum((case when (`es`.`Unit_Status` = 'Available') then ((`es`.`Capacity_MWh` * `es`.`Current_Charge_Percent`) / 100) else 0 end)),0) AS `Available_Stored_MWh` from ((`grid_zone` `z` left join `power_station` `p` on((`p`.`Zone_ID` = `z`.`Zone_ID`))) left join `energy_storage_unit` `es` on((`es`.`Station_ID` = `p`.`Station_ID`))) group by `z`.`Zone_ID`,`z`.`Zone_Name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-24 13:40:50
