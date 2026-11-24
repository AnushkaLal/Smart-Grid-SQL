
-- ============================================================
-- ENERGY STORAGE & GRID STRESS MANAGEMENT SYSTEM
-- Database schema: 13 relational tables
-- ============================================================

CREATE DATABASE IF NOT EXISTS energy_grid_db;
USE energy_grid_db;

-- 1. Grid zones
CREATE TABLE Grid_Zone (
    Zone_ID INT AUTO_INCREMENT PRIMARY KEY,
    Zone_Name VARCHAR(100) NOT NULL UNIQUE,
    City VARCHAR(80) NOT NULL,
    State_Name VARCHAR(80) NOT NULL,
    Zone_Description VARCHAR(255),
    Created_At DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Power stations
CREATE TABLE Power_Station (
    Station_ID INT AUTO_INCREMENT PRIMARY KEY,
    Zone_ID INT NOT NULL,
    Station_Name VARCHAR(120) NOT NULL,
    Station_Type VARCHAR(50) NOT NULL,
    Installed_Capacity_MW DECIMAL(10,2) NOT NULL,
    Operational_Status ENUM(
        'Operational', 'Maintenance', 'Offline'
    ) NOT NULL DEFAULT 'Operational',

    CONSTRAINT chk_station_capacity
        CHECK (Installed_Capacity_MW > 0),

    CONSTRAINT fk_station_zone
        FOREIGN KEY (Zone_ID)
        REFERENCES Grid_Zone(Zone_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    UNIQUE (Zone_ID, Station_Name)
);

-- 3. Storage technologies
CREATE TABLE Storage_Technology (
    Technology_ID INT AUTO_INCREMENT PRIMARY KEY,
    Technology_Name VARCHAR(80) NOT NULL UNIQUE,
    Description VARCHAR(255),
    Typical_Life_Years DECIMAL(4,1),

    CONSTRAINT chk_technology_life
        CHECK (
            Typical_Life_Years IS NULL
            OR Typical_Life_Years > 0
        )
);

-- 4. Energy storage units
CREATE TABLE Energy_Storage_Unit (
    Storage_ID INT AUTO_INCREMENT PRIMARY KEY,
    Station_ID INT NOT NULL,
    Technology_ID INT NOT NULL,
    Storage_Name VARCHAR(120) NOT NULL,
    Capacity_MWh DECIMAL(10,2) NOT NULL,
    Current_Charge_Percent DECIMAL(5,2) NOT NULL,
    Max_Discharge_MW DECIMAL(10,2) NOT NULL,
    Unit_Status ENUM(
        'Available', 'In Use', 'Maintenance', 'Offline'
    ) NOT NULL DEFAULT 'Available',
    Commissioned_Date DATE,

    CONSTRAINT chk_storage_capacity
        CHECK (Capacity_MWh > 0),

    CONSTRAINT chk_storage_charge
        CHECK (Current_Charge_Percent BETWEEN 0 AND 100),

    CONSTRAINT chk_storage_discharge
        CHECK (Max_Discharge_MW > 0),

    CONSTRAINT fk_storage_station
        FOREIGN KEY (Station_ID)
        REFERENCES Power_Station(Station_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_storage_technology
        FOREIGN KEY (Technology_ID)
        REFERENCES Storage_Technology(Technology_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 5. Energy demand
CREATE TABLE Energy_Demand (
    Demand_ID INT AUTO_INCREMENT PRIMARY KEY,
    Zone_ID INT NOT NULL,
    Recorded_At DATETIME NOT NULL,
    Demand_MW DECIMAL(10,2) NOT NULL,
    Peak_Demand_Flag BOOLEAN NOT NULL DEFAULT FALSE,
    Source_Description VARCHAR(120),

    CONSTRAINT chk_demand_nonnegative
        CHECK (Demand_MW >= 0),

    CONSTRAINT fk_demand_zone
        FOREIGN KEY (Zone_ID)
        REFERENCES Grid_Zone(Zone_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_demand_zone_time (Zone_ID, Recorded_At)
);

-- 6. Grid stress assessments
CREATE TABLE Grid_Stress (
    Stress_ID INT AUTO_INCREMENT PRIMARY KEY,
    Zone_ID INT NOT NULL,
    Assessed_At DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Grid_Stress_Score DECIMAL(6,2) NOT NULL,
    Stress_Level ENUM(
        'Normal', 'Moderate', 'High', 'Critical'
    ) NOT NULL,
    Assessment_Notes VARCHAR(255),

    CONSTRAINT chk_stress_score
        CHECK (Grid_Stress_Score BETWEEN 0 AND 100),

    CONSTRAINT fk_stress_zone
        FOREIGN KEY (Zone_ID)
        REFERENCES Grid_Zone(Zone_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_stress_zone_time (Zone_ID, Assessed_At)
);

-- 7. Grid incidents
CREATE TABLE Grid_Incident (
    Incident_ID INT AUTO_INCREMENT PRIMARY KEY,
    Zone_ID INT NOT NULL,
    Incident_Type VARCHAR(80) NOT NULL,
    Incident_Description VARCHAR(255) NOT NULL,
    Severity ENUM(
        'Low', 'Medium', 'High', 'Critical'
    ) NOT NULL,
    Started_At DATETIME NOT NULL,
    Resolved_At DATETIME NULL,
    Incident_Status ENUM(
        'Open', 'In Progress', 'Resolved'
    ) NOT NULL DEFAULT 'Open',

    CONSTRAINT chk_incident_dates
        CHECK (
            Resolved_At IS NULL
            OR Resolved_At >= Started_At
        ),

    CONSTRAINT fk_incident_zone
        FOREIGN KEY (Zone_ID)
        REFERENCES Grid_Zone(Zone_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_incident_zone_status (Zone_ID, Incident_Status)
);

-- 8. Energy consumption
CREATE TABLE Energy_Consumption (
    Consumption_ID INT AUTO_INCREMENT PRIMARY KEY,
    Zone_ID INT NOT NULL,
    Recorded_At DATETIME NOT NULL,
    Energy_Consumed_MWh DECIMAL(12,2) NOT NULL,
    Consumer_Category VARCHAR(60) NOT NULL,

    CONSTRAINT chk_consumption_nonnegative
        CHECK (Energy_Consumed_MWh >= 0),

    CONSTRAINT fk_consumption_zone
        FOREIGN KEY (Zone_ID)
        REFERENCES Grid_Zone(Zone_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_consumption_zone_time (Zone_ID, Recorded_At)
);

-- 9. Energy generation
CREATE TABLE Energy_Generation (
    Generation_ID INT AUTO_INCREMENT PRIMARY KEY,
    Station_ID INT NOT NULL,
    Recorded_At DATETIME NOT NULL,
    Generation_MW DECIMAL(10,2) NOT NULL,
    Energy_Source VARCHAR(60) NOT NULL,

    CONSTRAINT chk_generation_nonnegative
        CHECK (Generation_MW >= 0),

    CONSTRAINT fk_generation_station
        FOREIGN KEY (Station_ID)
        REFERENCES Power_Station(Station_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_generation_station_time (Station_ID, Recorded_At)
);

-- 10. Technicians
CREATE TABLE Technician (
    Technician_ID INT AUTO_INCREMENT PRIMARY KEY,
    Technician_Name VARCHAR(120) NOT NULL,
    Phone_Number VARCHAR(20) UNIQUE,
    Email VARCHAR(120) UNIQUE,
    Specialization VARCHAR(100) NOT NULL
);

-- 11. Maintenance records
CREATE TABLE Maintenance (
    Maintenance_ID INT AUTO_INCREMENT PRIMARY KEY,
    Storage_ID INT NOT NULL,
    Technician_ID INT NOT NULL,
    Scheduled_Date DATE NOT NULL,
    Completed_Date DATE NULL,
    Maintenance_Type VARCHAR(80) NOT NULL,
    Maintenance_Description VARCHAR(255),
    Maintenance_Status ENUM(
        'Scheduled', 'In Progress', 'Completed', 'Cancelled'
    ) NOT NULL DEFAULT 'Scheduled',

    CONSTRAINT chk_maintenance_dates
        CHECK (
            Completed_Date IS NULL
            OR Completed_Date >= Scheduled_Date
        ),

    CONSTRAINT fk_maintenance_storage
        FOREIGN KEY (Storage_ID)
        REFERENCES Energy_Storage_Unit(Storage_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_maintenance_technician
        FOREIGN KEY (Technician_ID)
        REFERENCES Technician(Technician_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_maintenance_storage_date (Storage_ID, Scheduled_Date)
);

-- 12. Storage alerts
CREATE TABLE Storage_Alert (
    Alert_ID INT AUTO_INCREMENT PRIMARY KEY,
    Storage_ID INT NOT NULL,
    Alert_Type ENUM(
        'Low Charge', 'Maintenance Due',
        'Unit Fault', 'Capacity Warning'
    ) NOT NULL,
    Alert_Message VARCHAR(255) NOT NULL,
    Created_At DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Alert_Status ENUM(
        'Active', 'Acknowledged', 'Closed'
    ) NOT NULL DEFAULT 'Active',

    CONSTRAINT fk_alert_storage
        FOREIGN KEY (Storage_ID)
        REFERENCES Energy_Storage_Unit(Storage_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_alert_storage_status (Storage_ID, Alert_Status)
);

-- 13. Resource allocation
-- Associative entity linking storage units and grid incidents
CREATE TABLE Resource_Allocation (
    Allocation_ID INT AUTO_INCREMENT PRIMARY KEY,
    Storage_ID INT NOT NULL,
    Incident_ID INT NOT NULL,
    Allocated_At DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Allocated_Power_MW DECIMAL(10,2) NOT NULL,
    Allocation_Duration_Hours DECIMAL(8,2) NOT NULL,
    Allocation_Status ENUM(
        'Planned', 'Active', 'Completed', 'Cancelled'
    ) NOT NULL DEFAULT 'Planned',

    CONSTRAINT chk_allocation_power
        CHECK (Allocated_Power_MW > 0),

    CONSTRAINT chk_allocation_duration
        CHECK (Allocation_Duration_Hours > 0),

    CONSTRAINT fk_allocation_storage
        FOREIGN KEY (Storage_ID)
        REFERENCES Energy_Storage_Unit(Storage_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_allocation_incident
        FOREIGN KEY (Incident_ID)
        REFERENCES Grid_Incident(Incident_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_allocation_incident (Incident_ID),
    INDEX idx_allocation_storage (Storage_ID)
);
