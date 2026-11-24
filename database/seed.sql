
USE energy_grid_db;

-- 1. Grid zones
INSERT INTO Grid_Zone
(Zone_Name, City, State_Name, Zone_Description)
VALUES
('Noida Central', 'Noida', 'Uttar Pradesh',
 'Central commercial and residential zone'),
('Greater Noida East', 'Greater Noida', 'Uttar Pradesh',
 'Industrial and residential zone'),
('Delhi South', 'New Delhi', 'Delhi',
 'Mixed-use urban zone');

-- 2. Power stations
INSERT INTO Power_Station
(Zone_ID, Station_Name, Station_Type,
 Installed_Capacity_MW, Operational_Status)
VALUES
(1, 'Noida Thermal Station', 'Thermal', 500.00, 'Operational'),
(1, 'Noida Solar Park', 'Solar', 120.00, 'Operational'),
(2, 'Greater Noida Gas Station', 'Gas', 350.00, 'Operational'),
(3, 'South Delhi Grid Station', 'Mixed', 420.00, 'Operational');

-- 3. Storage technologies
INSERT INTO Storage_Technology
(Technology_Name, Description, Typical_Life_Years)
VALUES
('Lithium-Ion', 'High efficiency electrochemical battery', 12.0),
('Flow Battery', 'Rechargeable liquid electrolyte battery', 20.0),
('Pumped Hydro', 'Water-based gravitational energy storage', 40.0);

-- 4. Energy storage units
INSERT INTO Energy_Storage_Unit
(Station_ID, Technology_ID, Storage_Name, Capacity_MWh,
 Current_Charge_Percent, Max_Discharge_MW, Unit_Status,
 Commissioned_Date)
VALUES
(1, 1, 'Noida Battery A', 100.00, 85.00, 25.00,
 'Available', '2023-04-01'),
(2, 1, 'Solar Backup B', 60.00, 35.00, 15.00,
 'Available', '2024-01-15'),
(3, 2, 'Industrial Storage C', 150.00, 20.00, 30.00,
 'Available', '2022-08-10'),
(4, 1, 'South Delhi Battery D', 80.00, 90.00, 20.00,
 'In Use', '2023-11-20'),
(4, 3, 'South Delhi Hydro E', 200.00, 70.00, 40.00,
 'Available', '2021-06-01');

-- 5. Energy demand
INSERT INTO Energy_Demand
(Zone_ID, Recorded_At, Demand_MW,
 Peak_Demand_Flag, Source_Description)
VALUES
(1, '2026-10-30 10:00:00', 410.00, FALSE, 'Hourly meter reading'),
(1, '2026-10-30 18:00:00', 485.00, TRUE, 'Evening peak reading'),
(2, '2026-10-30 10:00:00', 300.00, FALSE, 'Hourly meter reading'),
(2, '2026-10-30 18:00:00', 390.00, TRUE, 'Industrial evening peak'),
(3, '2026-10-30 10:00:00', 280.00, FALSE, 'Hourly meter reading'),
(3, '2026-10-30 18:00:00', 320.00, TRUE, 'Evening peak reading');

-- 6. Grid stress
INSERT INTO Grid_Stress
(Zone_ID, Assessed_At, Grid_Stress_Score,
 Stress_Level, Assessment_Notes)
VALUES
(1, '2026-10-30 18:15:00', 78.00, 'High',
 'High evening demand; storage available'),
(2, '2026-10-30 18:15:00', 91.00, 'Critical',
 'Industrial demand spike and low storage charge'),
(3, '2026-10-30 18:15:00', 42.00, 'Moderate',
 'Demand elevated but manageable');

-- 7. Grid incidents
INSERT INTO Grid_Incident
(Zone_ID, Incident_Type, Incident_Description, Severity,
 Started_At, Resolved_At, Incident_Status)
VALUES
(1, 'Demand Surge',
 'Unexpected rise in evening electricity demand',
 'High', '2026-10-30 17:45:00', NULL, 'In Progress'),

(2, 'Equipment Overload',
 'Transformer operating near its rated limit',
 'Critical', '2026-10-30 17:30:00', NULL, 'Open'),

(3, 'Voltage Fluctuation',
 'Short voltage fluctuation reported',
 'Medium', '2026-10-30 16:20:00',
 '2026-10-30 17:00:00', 'Resolved');

-- 8. Energy consumption
INSERT INTO Energy_Consumption
(Zone_ID, Recorded_At, Energy_Consumed_MWh, Consumer_Category)
VALUES
(1, '2026-10-30 18:00:00', 420.00, 'Residential'),
(1, '2026-10-30 18:00:00', 65.00, 'Commercial'),
(2, '2026-10-30 18:00:00', 310.00, 'Industrial'),
(2, '2026-10-30 18:00:00', 55.00, 'Residential'),
(3, '2026-10-30 18:00:00', 250.00, 'Residential'),
(3, '2026-10-30 18:00:00', 45.00, 'Commercial');

-- 9. Energy generation
INSERT INTO Energy_Generation
(Station_ID, Recorded_At, Generation_MW, Energy_Source)
VALUES
(1, '2026-10-30 18:00:00', 390.00, 'Thermal'),
(2, '2026-10-30 18:00:00', 90.00, 'Solar'),
(3, '2026-10-30 18:00:00', 280.00, 'Gas'),
(4, '2026-10-30 18:00:00', 300.00, 'Mixed');

-- 10. Technicians
INSERT INTO Technician
(Technician_Name, Phone_Number, Email, Specialization)
VALUES
('Rohit Sharma', '9876500001',
 'rohit.tech@example.com', 'Battery Systems'),
('Neha Verma', '9876500002',
 'neha.tech@example.com', 'Electrical Maintenance'),
('Aman Khan', '9876500003',
 'aman.tech@example.com', 'Grid Equipment');

-- 11. Maintenance
INSERT INTO Maintenance
(Storage_ID, Technician_ID, Scheduled_Date, Completed_Date,
 Maintenance_Type, Maintenance_Description, Maintenance_Status)
VALUES
(1, 1, '2026-11-05', NULL, 'Routine Inspection',
 'Check battery health and terminal connections', 'Scheduled'),

(2, 2, '2026-10-25', '2026-10-25', 'Battery Calibration',
 'Charge calibration completed', 'Completed'),

(3, 1, '2026-11-02', NULL, 'Capacity Test',
 'Investigate reduced charge retention', 'Scheduled'),

(4, 2, '2026-10-28', NULL, 'Cooling Check',
 'Inspect cooling system', 'In Progress');

-- 12. Storage alerts
INSERT INTO Storage_Alert
(Storage_ID, Alert_Type, Alert_Message, Created_At, Alert_Status)
VALUES
(2, 'Low Charge',
 'Storage unit charge is below 40 percent',
 '2026-10-30 18:20:00', 'Active'),

(3, 'Low Charge',
 'Storage unit charge is critically low',
 '2026-10-30 18:21:00', 'Active'),

(4, 'Maintenance Due',
 'Scheduled inspection is approaching',
 '2026-10-29 09:00:00', 'Acknowledged');

-- 13. Resource allocation
INSERT INTO Resource_Allocation
(Storage_ID, Incident_ID, Allocated_At,
 Allocated_Power_MW, Allocation_Duration_Hours, Allocation_Status)
VALUES
(1, 1, '2026-10-30 18:30:00', 10.00, 2.00, 'Active'),
(3, 2, '2026-10-30 18:35:00', 12.00, 3.00, 'Planned'),
(4, 3, '2026-10-30 16:30:00', 5.00, 1.00, 'Completed');
