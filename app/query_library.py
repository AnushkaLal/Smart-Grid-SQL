
QUERY_LIBRARY = {
    "01. View all grid zones": {
        "category": "Basic SELECT",
        "sql": """
SELECT *
FROM Grid_Zone;
""",
        "explanation": "Displays all records and columns from Grid_Zone. It gives an overview of the grid zones registered in the database."
    },
    "02. Available storage units": {
        "category": "Filtering and sorting",
        "sql": """
SELECT Storage_ID, Storage_Name, Capacity_MWh, Current_Charge_Percent
FROM Energy_Storage_Unit
WHERE Unit_Status = 'Available'
ORDER BY Current_Charge_Percent DESC;
""",
        "explanation": "Retrieves storage units whose status is Available. Results are sorted by current charge percentage, from highest to lowest."
    },
    "03. Demand between 300 and 500 MW": {
        "category": "Filtering and sorting",
        "sql": """
SELECT Demand_ID, Zone_ID, Recorded_At, Demand_MW
FROM Energy_Demand
WHERE Demand_MW BETWEEN 300 AND 500
ORDER BY Demand_MW DESC;
""",
        "explanation": "Finds demand readings between 300 MW and 500 MW, including both boundaries. The highest demand readings appear first."
    },
    "04. Insert a practice zone": {
        "category": "INSERT",
        "sql": """
INSERT INTO Grid_Zone
(Zone_Name, City, State_Name, Zone_Description)
VALUES
('SQL Practice Zone', 'Noida', 'Uttar Pradesh', 'Temporary practice row');
""",
        "explanation": "Inserts one temporary practice record into Grid_Zone. Run this only once. It modifies the database."
    },
    "05. Update the practice zone": {
        "category": "UPDATE",
        "sql": """
UPDATE Grid_Zone
SET Zone_Description = 'Updated practice row'
WHERE Zone_Name = 'SQL Practice Zone';
""",
        "explanation": "Changes the description of the temporary practice zone. The WHERE condition ensures that only the matching practice record is updated."
    },
    "06. Delete the practice zone": {
        "category": "DELETE",
        "sql": """
DELETE FROM Grid_Zone
WHERE Zone_Name = 'SQL Practice Zone';
""",
        "explanation": "Deletes the temporary practice zone. The WHERE condition restricts deletion to that named practice record."
    },
    "07. Grid zones and power stations": {
        "category": "INNER JOIN",
        "sql": """
SELECT z.Zone_Name, p.Station_Name, p.Station_Type,
       p.Installed_Capacity_MW
FROM Grid_Zone z
JOIN Power_Station p ON p.Zone_ID = z.Zone_ID;
""",
        "explanation": "Uses an INNER JOIN to combine grid zones with their power stations. Only zones having a matching power station are returned."
    },
    "08. Grid zones and incidents": {
        "category": "LEFT JOIN",
        "sql": """
SELECT z.Zone_Name, gi.Incident_ID,
       gi.Incident_Type, gi.Incident_Status
FROM Grid_Zone z
LEFT JOIN Grid_Incident gi ON gi.Zone_ID = z.Zone_ID;
""",
        "explanation": "Uses a LEFT JOIN to show every grid zone, including zones without incidents. Incident columns are NULL when no matching incident exists."
    },
    "09. Storage, station, zone and technology": {
        "category": "Multiple JOINs",
        "sql": """
SELECT z.Zone_Name, p.Station_Name, es.Storage_Name,
       st.Technology_Name, es.Capacity_MWh,
       es.Current_Charge_Percent
FROM Energy_Storage_Unit es
JOIN Power_Station p ON p.Station_ID = es.Station_ID
JOIN Grid_Zone z ON z.Zone_ID = p.Zone_ID
JOIN Storage_Technology st
    ON st.Technology_ID = es.Technology_ID;
""",
        "explanation": "Combines four related tables to show where each storage unit is located, which station it belongs to, its technology, capacity and charge."
    },
    "10. Maintenance and technician details": {
        "category": "Multiple JOINs",
        "sql": """
SELECT m.Maintenance_ID, es.Storage_Name,
       t.Technician_Name, m.Maintenance_Type,
       m.Scheduled_Date, m.Maintenance_Status
FROM Maintenance m
JOIN Energy_Storage_Unit es ON es.Storage_ID = m.Storage_ID
JOIN Technician t ON t.Technician_ID = m.Technician_ID;
""",
        "explanation": "Joins maintenance records with storage units and technicians. It shows which technician is assigned to each maintenance task and its schedule and status."
    },
    "11. Incident and resource allocation": {
        "category": "Multiple JOINs",
        "sql": """
SELECT gi.Incident_ID, gi.Incident_Type, z.Zone_Name,
       es.Storage_Name, ra.Allocated_Power_MW,
       ra.Allocation_Status
FROM Grid_Incident gi
JOIN Grid_Zone z ON z.Zone_ID = gi.Zone_ID
LEFT JOIN Resource_Allocation ra
    ON ra.Incident_ID = gi.Incident_ID
LEFT JOIN Energy_Storage_Unit es
    ON es.Storage_ID = ra.Storage_ID;
""",
        "explanation": "Connects incidents to their grid zones and any associated resource allocations and storage units. LEFT JOIN preserves incidents even when no allocation exists."
    },
    "12. Count stations in each zone": {
        "category": "GROUP BY and COUNT",
        "sql": """
SELECT z.Zone_ID, z.Zone_Name,
       COUNT(p.Station_ID) AS Station_Count
FROM Grid_Zone z
LEFT JOIN Power_Station p ON p.Zone_ID = z.Zone_ID
GROUP BY z.Zone_ID, z.Zone_Name;
""",
        "explanation": "Groups power stations by grid zone and counts them. LEFT JOIN ensures zones with no stations are also included."
    },
    "13. Average, minimum and maximum demand": {
        "category": "Aggregate functions",
        "sql": """
SELECT z.Zone_Name,
       ROUND(AVG(d.Demand_MW), 2) AS Avg_Demand,
       MIN(d.Demand_MW) AS Min_Demand,
       MAX(d.Demand_MW) AS Max_Demand
FROM Grid_Zone z
JOIN Energy_Demand d ON d.Zone_ID = z.Zone_ID
GROUP BY z.Zone_ID, z.Zone_Name;
""",
        "explanation": "Calculates average, minimum and maximum recorded demand for each zone. ROUND displays the average to two decimal places."
    },
    "14. Total generation by zone": {
        "category": "Aggregate functions",
        "sql": """
SELECT z.Zone_Name,
       SUM(g.Generation_MW) AS Total_Generation_MW
FROM Grid_Zone z
JOIN Power_Station p ON p.Zone_ID = z.Zone_ID
JOIN Energy_Generation g ON g.Station_ID = p.Station_ID
GROUP BY z.Zone_ID, z.Zone_Name;
""",
        "explanation": "Joins zones, power stations and generation records, then calculates total generation in MW for each zone."
    },
    "15. Zones with average demand above 350 MW": {
        "category": "HAVING",
        "sql": """
SELECT z.Zone_Name,
       AVG(d.Demand_MW) AS Avg_Demand
FROM Grid_Zone z
JOIN Energy_Demand d ON d.Zone_ID = z.Zone_ID
GROUP BY z.Zone_ID, z.Zone_Name
HAVING AVG(d.Demand_MW) > 350;
""",
        "explanation": "Groups demand readings by zone and uses HAVING to retain only zones whose average demand exceeds 350 MW. HAVING filters groups after aggregation."
    },
    "16. Incident count by severity": {
        "category": "GROUP BY and COUNT",
        "sql": """
SELECT Severity,
       COUNT(*) AS Incident_Count
FROM Grid_Incident
GROUP BY Severity
ORDER BY Incident_Count DESC;
""",
        "explanation": "Counts incidents in each severity category and sorts the categories by incident count in descending order."
    },
    "17. Storage units below average charge": {
        "category": "Subquery",
        "sql": """
SELECT Storage_ID, Storage_Name, Current_Charge_Percent
FROM Energy_Storage_Unit
WHERE Current_Charge_Percent <
    (SELECT AVG(Current_Charge_Percent)
     FROM Energy_Storage_Unit);
""",
        "explanation": "The inner query calculates the average charge across all storage units. The outer query returns units whose charge is below that average."
    },
    "18. Zones with High or Critical stress": {
        "category": "IN subquery",
        "sql": """
SELECT Zone_ID, Zone_Name
FROM Grid_Zone
WHERE Zone_ID IN (
    SELECT Zone_ID
    FROM Grid_Stress
    WHERE Stress_Level IN ('High', 'Critical')
);
""",
        "explanation": "The subquery finds zone IDs with High or Critical stress assessments. IN returns the matching grid zones."
    },
    "19. Latest stress assessment per zone": {
        "category": "Correlated subquery",
        "sql": """
SELECT gs.Zone_ID, z.Zone_Name,
       gs.Grid_Stress_Score, gs.Stress_Level,
       gs.Assessed_At
FROM Grid_Stress gs
JOIN Grid_Zone z ON z.Zone_ID = gs.Zone_ID
WHERE gs.Assessed_At = (
    SELECT MAX(g2.Assessed_At)
    FROM Grid_Stress g2
    WHERE g2.Zone_ID = gs.Zone_ID
);
""",
        "explanation": "For each stress record, the correlated subquery finds the latest assessment time for that same zone. The outer query returns assessments matching that timestamp."
    },
    "20. Available stored energy by zone": {
        "category": "Aggregate functions",
        "sql": """
SELECT z.Zone_Name,
       ROUND(
           SUM(es.Capacity_MWh * es.Current_Charge_Percent / 100),
           2
       ) AS Available_Stored_MWh
FROM Grid_Zone z
JOIN Power_Station p ON p.Zone_ID = z.Zone_ID
JOIN Energy_Storage_Unit es ON es.Station_ID = p.Station_ID
WHERE es.Unit_Status = 'Available'
GROUP BY z.Zone_ID, z.Zone_Name;
""",
        "explanation": "Calculates stored energy for available storage units using capacity multiplied by charge percentage, then sums it by zone."
    },
    "21. Classify storage charge using CASE": {
        "category": "CASE expression",
        "sql": """
SELECT Storage_Name, Current_Charge_Percent,
       CASE
           WHEN Current_Charge_Percent <= 20 THEN 'Critical Charge'
           WHEN Current_Charge_Percent <= 40 THEN 'Low Charge'
           WHEN Current_Charge_Percent <= 70 THEN 'Moderate Charge'
           ELSE 'Healthy Charge'
       END AS Charge_Condition
FROM Energy_Storage_Unit;
""",
        "explanation": "Uses CASE to classify every storage unit into Critical, Low, Moderate or Healthy charge based on its current charge percentage."
    },
    "22. Zones without open or in-progress incidents": {
        "category": "NOT EXISTS",
        "sql": """
SELECT z.Zone_ID, z.Zone_Name
FROM Grid_Zone z
WHERE NOT EXISTS (
    SELECT 1
    FROM Grid_Incident gi
    WHERE gi.Zone_ID = z.Zone_ID
      AND gi.Incident_Status IN ('Open', 'In Progress')
);
""",
        "explanation": "Returns zones for which no matching incident exists with status Open or In Progress. NOT EXISTS checks the absence of qualifying records."
    },
    "23. Storage units per technology": {
        "category": "GROUP BY and COUNT",
        "sql": """
SELECT st.Technology_Name,
       COUNT(es.Storage_ID) AS Unit_Count
FROM Storage_Technology st
LEFT JOIN Energy_Storage_Unit es
    ON es.Technology_ID = st.Technology_ID
GROUP BY st.Technology_ID, st.Technology_Name;
""",
        "explanation": "Counts storage units for each storage technology. LEFT JOIN includes technologies that currently have no associated storage units."
    },
    "24. Pending maintenance per technician": {
        "category": "GROUP BY and COUNT",
        "sql": """
SELECT t.Technician_Name,
       COUNT(m.Maintenance_ID) AS Pending_Jobs
FROM Technician t
LEFT JOIN Maintenance m
    ON m.Technician_ID = t.Technician_ID
   AND m.Maintenance_Status IN ('Scheduled', 'In Progress')
GROUP BY t.Technician_ID, t.Technician_Name;
""",
        "explanation": "Counts Scheduled and In Progress maintenance jobs assigned to each technician. LEFT JOIN keeps technicians with zero pending jobs."
    },
    "25. Stations above average capacity": {
        "category": "Subquery",
        "sql": """
SELECT Station_Name, Installed_Capacity_MW
FROM Power_Station
WHERE Installed_Capacity_MW > (
    SELECT AVG(Installed_Capacity_MW)
    FROM Power_Station
);
""",
        "explanation": "The subquery calculates average installed station capacity. The outer query returns stations whose capacity is greater than that average."
    },
    "26. Demand readings on 30 October 2026": {
        "category": "Date filtering",
        "sql": """
SELECT Zone_ID, Recorded_At, Demand_MW
FROM Energy_Demand
WHERE Recorded_At >= '2026-10-30 00:00:00'
  AND Recorded_At < '2026-10-31 00:00:00'
ORDER BY Zone_ID, Recorded_At;
""",
        "explanation": "Retrieves demand readings recorded on 30 October 2026. The inclusive start and exclusive next-day boundary capture the entire date."
    },
    "27. Allocated power per incident": {
        "category": "GROUP BY and SUM",
        "sql": """
SELECT gi.Incident_ID, gi.Incident_Type,
       COALESCE(SUM(ra.Allocated_Power_MW), 0) AS Allocated_MW
FROM Grid_Incident gi
LEFT JOIN Resource_Allocation ra
    ON ra.Incident_ID = gi.Incident_ID
GROUP BY gi.Incident_ID, gi.Incident_Type;
""",
        "explanation": "Calculates total power allocated to each incident. COALESCE converts a NULL sum into zero for incidents without allocations."
    },
    "28. Active storage alerts": {
        "category": "JOIN and filtering",
        "sql": """
SELECT a.Alert_ID, es.Storage_Name, a.Alert_Type,
       a.Alert_Message, a.Created_At
FROM Storage_Alert a
JOIN Energy_Storage_Unit es
    ON es.Storage_ID = a.Storage_ID
WHERE a.Alert_Status = 'Active'
ORDER BY a.Created_At DESC;
""",
        "explanation": "Displays active alerts with their associated storage-unit names, alert types, messages and creation times. The newest alerts appear first."
    }
}
