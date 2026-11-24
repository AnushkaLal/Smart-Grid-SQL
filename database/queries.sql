USE energy_grid_db;

-- ============================================================
-- ENERGY STORAGE & GRID STRESS MANAGEMENT SYSTEM
-- 28 SQL QUERIES
-- ============================================================


-- ------------------------------------------------------------
-- BASIC RETRIEVAL AND FILTERING
-- ------------------------------------------------------------

-- 1. Display all grid zones
SELECT * FROM Grid_Zone;


-- 2. Available storage units, ordered by charge
SELECT Storage_ID, Storage_Name, Capacity_MWh,
       Current_Charge_Percent
FROM Energy_Storage_Unit
WHERE Unit_Status = 'Available'
ORDER BY Current_Charge_Percent DESC;


-- 3. Demand readings between 300 and 500 MW
SELECT Demand_ID, Zone_ID, Recorded_At, Demand_MW
FROM Energy_Demand
WHERE Demand_MW BETWEEN 300 AND 500
ORDER BY Demand_MW DESC;


-- ------------------------------------------------------------
-- INSERT, UPDATE AND DELETE DEMONSTRATION
-- Run these individually only when you want to demonstrate
-- data modification. They are commented out intentionally.
-- ------------------------------------------------------------

-- 4. INSERT demo row
-- INSERT INTO Grid_Zone
-- (Zone_Name, City, State_Name, Zone_Description)
-- VALUES
-- ('SQL Practice Zone', 'Noida', 'Uttar Pradesh',
--  'Temporary practice row');


-- 5. UPDATE demo row
-- UPDATE Grid_Zone
-- SET Zone_Description = 'Updated practice row'
-- WHERE Zone_Name = 'SQL Practice Zone';


-- 6. DELETE demo row
-- DELETE FROM Grid_Zone
-- WHERE Zone_Name = 'SQL Practice Zone';


-- ------------------------------------------------------------
-- JOINS
-- ------------------------------------------------------------

-- 7. INNER JOIN: zones and their power stations
SELECT z.Zone_Name, p.Station_Name, p.Station_Type,
       p.Installed_Capacity_MW
FROM Grid_Zone z
JOIN Power_Station p
    ON p.Zone_ID = z.Zone_ID;


-- 8. LEFT JOIN: zones and their incidents
SELECT z.Zone_Name, gi.Incident_ID,
       gi.Incident_Type, gi.Incident_Status
FROM Grid_Zone z
LEFT JOIN Grid_Incident gi
    ON gi.Zone_ID = z.Zone_ID;


-- 9. Multiple JOINs: storage units, stations, zones and technology
SELECT z.Zone_Name, p.Station_Name, es.Storage_Name,
       st.Technology_Name, es.Capacity_MWh,
       es.Current_Charge_Percent
FROM Energy_Storage_Unit es
JOIN Power_Station p
    ON p.Station_ID = es.Station_ID
JOIN Grid_Zone z
    ON z.Zone_ID = p.Zone_ID
JOIN Storage_Technology st
    ON st.Technology_ID = es.Technology_ID;


-- 10. Maintenance JOIN: maintenance records and technicians
SELECT m.Maintenance_ID, es.Storage_Name,
       t.Technician_Name, m.Maintenance_Type,
       m.Scheduled_Date, m.Maintenance_Status
FROM Maintenance m
JOIN Energy_Storage_Unit es
    ON es.Storage_ID = m.Storage_ID
JOIN Technician t
    ON t.Technician_ID = m.Technician_ID;


-- 11. Incident and resource allocation JOIN
SELECT gi.Incident_ID, gi.Incident_Type,
       z.Zone_Name, es.Storage_Name,
       ra.Allocated_Power_MW, ra.Allocation_Status
FROM Grid_Incident gi
JOIN Grid_Zone z
    ON z.Zone_ID = gi.Zone_ID
LEFT JOIN Resource_Allocation ra
    ON ra.Incident_ID = gi.Incident_ID
LEFT JOIN Energy_Storage_Unit es
    ON es.Storage_ID = ra.Storage_ID;


-- ------------------------------------------------------------
-- AGGREGATE FUNCTIONS AND GROUPING
-- ------------------------------------------------------------

-- 12. Count power stations in each zone
SELECT z.Zone_ID, z.Zone_Name,
       COUNT(p.Station_ID) AS Station_Count
FROM Grid_Zone z
LEFT JOIN Power_Station p
    ON p.Zone_ID = z.Zone_ID
GROUP BY z.Zone_ID, z.Zone_Name;


-- 13. Average, minimum and maximum demand per zone
SELECT z.Zone_Name,
       ROUND(AVG(d.Demand_MW), 2) AS Avg_Demand,
       MIN(d.Demand_MW) AS Min_Demand,
       MAX(d.Demand_MW) AS Max_Demand
FROM Grid_Zone z
JOIN Energy_Demand d
    ON d.Zone_ID = z.Zone_ID
GROUP BY z.Zone_ID, z.Zone_Name;


-- 14. Total generation per zone
SELECT z.Zone_Name,
       SUM(g.Generation_MW) AS Total_Generation_MW
FROM Grid_Zone z
JOIN Power_Station p
    ON p.Zone_ID = z.Zone_ID
JOIN Energy_Generation g
    ON g.Station_ID = p.Station_ID
GROUP BY z.Zone_ID, z.Zone_Name;


-- 15. Zones with average demand above 350 MW
SELECT z.Zone_Name,
       AVG(d.Demand_MW) AS Avg_Demand
FROM Grid_Zone z
JOIN Energy_Demand d
    ON d.Zone_ID = z.Zone_ID
GROUP BY z.Zone_ID, z.Zone_Name
HAVING AVG(d.Demand_MW) > 350;


-- 16. Incident counts grouped by severity
SELECT Severity,
       COUNT(*) AS Incident_Count
FROM Grid_Incident
GROUP BY Severity
ORDER BY Incident_Count DESC;


-- ------------------------------------------------------------
-- SUBQUERIES
-- ------------------------------------------------------------

-- 17. Storage units below average charge percentage
SELECT Storage_ID, Storage_Name,
       Current_Charge_Percent
FROM Energy_Storage_Unit
WHERE Current_Charge_Percent <
    (SELECT AVG(Current_Charge_Percent)
     FROM Energy_Storage_Unit);


-- 18. Zones with High or Critical grid stress
SELECT Zone_ID, Zone_Name
FROM Grid_Zone
WHERE Zone_ID IN
    (SELECT Zone_ID
     FROM Grid_Stress
     WHERE Stress_Level IN ('High', 'Critical'));


-- 19. Latest stress assessment for each zone
SELECT gs.Zone_ID, z.Zone_Name,
       gs.Grid_Stress_Score, gs.Stress_Level,
       gs.Assessed_At
FROM Grid_Stress gs
JOIN Grid_Zone z
    ON z.Zone_ID = gs.Zone_ID
WHERE gs.Assessed_At =
    (SELECT MAX(g2.Assessed_At)
     FROM Grid_Stress g2
     WHERE g2.Zone_ID = gs.Zone_ID);


-- 20. Available stored energy per zone in MWh
SELECT z.Zone_Name,
       ROUND(
           SUM(es.Capacity_MWh * es.Current_Charge_Percent / 100),
           2
       ) AS Available_Stored_MWh
FROM Grid_Zone z
JOIN Power_Station p
    ON p.Zone_ID = z.Zone_ID
JOIN Energy_Storage_Unit es
    ON es.Station_ID = p.Station_ID
WHERE es.Unit_Status = 'Available'
GROUP BY z.Zone_ID, z.Zone_Name;


-- ------------------------------------------------------------
-- CASE, EXISTS AND ADDITIONAL ANALYTICAL QUERIES
-- ------------------------------------------------------------

-- 21. Classify storage units based on charge percentage
SELECT Storage_Name, Current_Charge_Percent,
       CASE
           WHEN Current_Charge_Percent <= 20
               THEN 'Critical Charge'
           WHEN Current_Charge_Percent <= 40
               THEN 'Low Charge'
           WHEN Current_Charge_Percent <= 70
               THEN 'Moderate Charge'
           ELSE 'Healthy Charge'
       END AS Charge_Condition
FROM Energy_Storage_Unit;


-- 22. Zones without any open or in-progress incidents
SELECT z.Zone_ID, z.Zone_Name
FROM Grid_Zone z
WHERE NOT EXISTS
    (SELECT 1
     FROM Grid_Incident gi
     WHERE gi.Zone_ID = z.Zone_ID
       AND gi.Incident_Status IN ('Open', 'In Progress'));


-- 23. Number of storage units per technology
SELECT st.Technology_Name,
       COUNT(es.Storage_ID) AS Unit_Count
FROM Storage_Technology st
LEFT JOIN Energy_Storage_Unit es
    ON es.Technology_ID = st.Technology_ID
GROUP BY st.Technology_ID, st.Technology_Name;


-- 24. Pending maintenance jobs per technician
SELECT t.Technician_Name,
       COUNT(m.Maintenance_ID) AS Pending_Jobs
FROM Technician t
LEFT JOIN Maintenance m
    ON m.Technician_ID = t.Technician_ID
   AND m.Maintenance_Status IN ('Scheduled', 'In Progress')
GROUP BY t.Technician_ID, t.Technician_Name;


-- 25. Power stations with capacity above average
SELECT Station_Name, Installed_Capacity_MW
FROM Power_Station
WHERE Installed_Capacity_MW >
    (SELECT AVG(Installed_Capacity_MW)
     FROM Power_Station);


-- 26. Demand readings for 30 October 2026
SELECT Zone_ID, Recorded_At, Demand_MW
FROM Energy_Demand
WHERE Recorded_At >= '2026-10-30 00:00:00'
  AND Recorded_At < '2026-10-31 00:00:00'
ORDER BY Zone_ID, Recorded_At;


-- 27. Total allocated power per incident
SELECT gi.Incident_ID, gi.Incident_Type,
       COALESCE(SUM(ra.Allocated_Power_MW), 0) AS Allocated_MW
FROM Grid_Incident gi
LEFT JOIN Resource_Allocation ra
    ON ra.Incident_ID = gi.Incident_ID
GROUP BY gi.Incident_ID, gi.Incident_Type;


-- 28. Display active storage alerts
SELECT a.Alert_ID, es.Storage_Name,
       a.Alert_Type, a.Alert_Message, a.Created_At
FROM Storage_Alert a
JOIN Energy_Storage_Unit es
    ON es.Storage_ID = a.Storage_ID
WHERE a.Alert_Status = 'Active'
ORDER BY a.Created_At DESC;


-- ============================================================
-- END OF 28 QUERIES
-- ============================================================
