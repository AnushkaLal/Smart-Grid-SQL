USE energy_grid_db;

-- ============================================================
-- ENERGY STORAGE & GRID STRESS MANAGEMENT SYSTEM
-- ADVANCED SQL OBJECTS
-- 2 VIEWS, 2 FUNCTIONS, 2 PROCEDURES, 4 TRIGGERS, 3 INDEXES
-- ============================================================


-- ------------------------------------------------------------
-- 1. VIEWS
-- ------------------------------------------------------------

DROP VIEW IF EXISTS vw_zone_latest_stress;

CREATE VIEW vw_zone_latest_stress AS
SELECT
    z.Zone_ID,
    z.Zone_Name,
    gs.Stress_ID,
    gs.Grid_Stress_Score,
    gs.Stress_Level,
    gs.Assessed_At
FROM Grid_Zone z
LEFT JOIN Grid_Stress gs
    ON gs.Zone_ID = z.Zone_ID
   AND gs.Assessed_At = (
       SELECT MAX(g2.Assessed_At)
       FROM Grid_Stress g2
       WHERE g2.Zone_ID = z.Zone_ID
   );


DROP VIEW IF EXISTS vw_zone_storage_summary;

CREATE VIEW vw_zone_storage_summary AS
SELECT
    z.Zone_ID,
    z.Zone_Name,
    COUNT(es.Storage_ID) AS Storage_Unit_Count,
    COALESCE(SUM(es.Capacity_MWh), 0) AS Total_Capacity_MWh,
    COALESCE(
        SUM(es.Capacity_MWh * es.Current_Charge_Percent / 100),
        0
    ) AS Stored_Energy_MWh,
    COALESCE(
        SUM(
            CASE
                WHEN es.Unit_Status = 'Available'
                THEN es.Capacity_MWh * es.Current_Charge_Percent / 100
                ELSE 0
            END
        ),
        0
    ) AS Available_Stored_MWh
FROM Grid_Zone z
LEFT JOIN Power_Station p
    ON p.Zone_ID = z.Zone_ID
LEFT JOIN Energy_Storage_Unit es
    ON es.Station_ID = p.Station_ID
GROUP BY z.Zone_ID, z.Zone_Name;


-- ------------------------------------------------------------
-- 2. FUNCTIONS
-- ------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_available_energy_mwh;
DROP FUNCTION IF EXISTS fn_stress_level;

DELIMITER $$

CREATE FUNCTION fn_available_energy_mwh(p_storage_id INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_energy DECIMAL(12,2) DEFAULT 0.00;

    SELECT COALESCE(
        MAX(Capacity_MWh * Current_Charge_Percent / 100),
        0
    )
    INTO v_energy
    FROM Energy_Storage_Unit
    WHERE Storage_ID = p_storage_id
      AND Unit_Status = 'Available';

    RETURN v_energy;
END$$


CREATE FUNCTION fn_stress_level(p_score DECIMAL(6,2))
RETURNS VARCHAR(20)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CASE
        WHEN p_score < 35 THEN 'Normal'
        WHEN p_score < 55 THEN 'Moderate'
        WHEN p_score < 75 THEN 'High'
        ELSE 'Critical'
    END;
END$$


-- ------------------------------------------------------------
-- 3. STORED PROCEDURES
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_assess_zone_stress;
DROP PROCEDURE IF EXISTS sp_assess_all_zones;


CREATE PROCEDURE sp_assess_zone_stress(IN p_zone_id INT)
BEGIN
    DECLARE v_demand DECIMAL(12,2) DEFAULT 0;
    DECLARE v_capacity DECIMAL(12,2) DEFAULT 0;
    DECLARE v_stored DECIMAL(12,2) DEFAULT 0;
    DECLARE v_incident DECIMAL(6,2) DEFAULT 0;
    DECLARE v_demand_pressure DECIMAL(6,2) DEFAULT 0;
    DECLARE v_storage_deficit DECIMAL(6,2) DEFAULT 0;
    DECLARE v_score DECIMAL(6,2) DEFAULT 0;

    IF NOT EXISTS (
        SELECT 1
        FROM Grid_Zone
        WHERE Zone_ID = p_zone_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Zone_ID does not exist';
    END IF;

    -- Get the latest recorded demand for this zone.
    SELECT COALESCE((
        SELECT d.Demand_MW
        FROM Energy_Demand d
        WHERE d.Zone_ID = p_zone_id
        ORDER BY d.Recorded_At DESC, d.Demand_ID DESC
        LIMIT 1
    ), 0)
    INTO v_demand;

    -- Total operational generation capacity.
    SELECT COALESCE(SUM(Installed_Capacity_MW), 0)
    INTO v_capacity
    FROM Power_Station
    WHERE Zone_ID = p_zone_id
      AND Operational_Status = 'Operational';

    -- Stored energy in available storage units.
    SELECT COALESCE(
        SUM(es.Capacity_MWh * es.Current_Charge_Percent / 100),
        0
    )
    INTO v_stored
    FROM Energy_Storage_Unit es
    JOIN Power_Station ps
        ON ps.Station_ID = es.Station_ID
    WHERE ps.Zone_ID = p_zone_id
      AND es.Unit_Status = 'Available';

    -- Average severity of unresolved incidents.
    SELECT COALESCE(
        AVG(
            CASE Severity
                WHEN 'Low' THEN 25
                WHEN 'Medium' THEN 50
                WHEN 'High' THEN 75
                WHEN 'Critical' THEN 100
            END
        ),
        0
    )
    INTO v_incident
    FROM Grid_Incident
    WHERE Zone_ID = p_zone_id
      AND Incident_Status IN ('Open', 'In Progress');

    -- Demand pressure component.
    IF v_capacity > 0 THEN
        SET v_demand_pressure =
            LEAST(100, (v_demand / v_capacity) * 100);
    ELSE
        SET v_demand_pressure = 100;
    END IF;

    -- Storage deficit component.
    -- Assumes a two-hour demand coverage target.
    IF v_demand > 0 THEN
        SET v_storage_deficit =
            100 - LEAST(100, (v_stored / (v_demand * 2)) * 100);
    ELSE
        SET v_storage_deficit = 0;
    END IF;

    -- Weighted rule-based stress score.
    SET v_score = ROUND(
        0.60 * v_demand_pressure
        + 0.25 * v_storage_deficit
        + 0.15 * v_incident,
        2
    );

    INSERT INTO Grid_Stress (
        Zone_ID,
        Assessed_At,
        Grid_Stress_Score,
        Stress_Level,
        Assessment_Notes
    )
    VALUES (
        p_zone_id,
        NOW(),
        v_score,
        fn_stress_level(v_score),
        'Rule-based: 60% demand pressure, 25% storage deficit, 15% incident pressure'
    );
END$$


CREATE PROCEDURE sp_assess_all_zones()
BEGIN
    DECLARE v_zone_id INT;
    DECLARE v_done BOOLEAN DEFAULT FALSE;

    DECLARE zone_cursor CURSOR FOR
        SELECT Zone_ID
        FROM Grid_Zone
        ORDER BY Zone_ID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = TRUE;

    OPEN zone_cursor;

    zone_loop: LOOP
        FETCH zone_cursor INTO v_zone_id;

        IF v_done THEN
            LEAVE zone_loop;
        END IF;

        CALL sp_assess_zone_stress(v_zone_id);
    END LOOP;

    CLOSE zone_cursor;
END$$


-- ------------------------------------------------------------
-- 4. TRIGGERS
-- ------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_allocation_before_insert;
DROP TRIGGER IF EXISTS trg_allocation_before_update;
DROP TRIGGER IF EXISTS trg_storage_low_charge_after_insert;
DROP TRIGGER IF EXISTS trg_storage_low_charge_after_update;


-- Trigger 1: Validate a new resource allocation.
CREATE TRIGGER trg_allocation_before_insert
BEFORE INSERT ON Resource_Allocation
FOR EACH ROW
BEGIN
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
END$$


-- Trigger 2: Validate an updated resource allocation.
CREATE TRIGGER trg_allocation_before_update
BEFORE UPDATE ON Resource_Allocation
FOR EACH ROW
BEGIN
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
END$$


-- Trigger 3: Automatically create an alert for a newly inserted
-- storage unit whose charge is 30% or lower.
CREATE TRIGGER trg_storage_low_charge_after_insert
AFTER INSERT ON Energy_Storage_Unit
FOR EACH ROW
BEGIN
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
END$$


-- Trigger 4: Automatically create an alert when charge
-- falls from above 30% to 30% or lower.
CREATE TRIGGER trg_storage_low_charge_after_update
AFTER UPDATE ON Energy_Storage_Unit
FOR EACH ROW
BEGIN
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
END$$

DELIMITER ;


-- ------------------------------------------------------------
-- 5. ADDITIONAL INDEXES
-- ------------------------------------------------------------

CREATE INDEX idx_stress_level_time
ON Grid_Stress(Stress_Level, Assessed_At);

CREATE INDEX idx_incident_status_severity
ON Grid_Incident(Incident_Status, Severity);

CREATE INDEX idx_storage_status_charge
ON Energy_Storage_Unit(Unit_Status, Current_Charge_Percent);