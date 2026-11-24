
import streamlit as st
import pandas as pd

from db import fetch_all


st.set_page_config(
    page_title="Smart Grid Management",
    page_icon="⚡",
    layout="wide"
)


# ---------------------------------------------------------
# DATA LOADING
# ---------------------------------------------------------

def load_data(query):
    return pd.DataFrame(fetch_all(query))


def metric_value(df, column, default=0):
    if df.empty or column not in df.columns:
        return default

    value = df.iloc[0][column]
    return default if pd.isna(value) else value


def number(value, decimals=2):
    return f"{float(value):,.{decimals}f}"


# ---------------------------------------------------------
# HEADER
# ---------------------------------------------------------

st.title("⚡ Energy Storage & Grid Stress Management")

st.caption(
    "An integrated view of electricity demand, generation, "
    "grid stress, energy storage and incident response."
)

if st.button("↻ Refresh Dashboard"):
    st.rerun()


try:

    # -----------------------------------------------------
    # 1. GRID OVERVIEW
    # -----------------------------------------------------

    zones = load_data("""
        SELECT COUNT(*) AS Total_Zones
        FROM Grid_Zone
    """)

    demand = load_data("""
        SELECT COALESCE(SUM(d.Demand_MW), 0) AS Total_Demand
        FROM Energy_Demand d
        WHERE d.Recorded_At = (
            SELECT MAX(d2.Recorded_At)
            FROM Energy_Demand d2
            WHERE d2.Zone_ID = d.Zone_ID
        )
    """)

    generation = load_data("""
        SELECT COALESCE(SUM(g.Generation_MW), 0) AS Total_Generation
        FROM Energy_Generation g
        WHERE g.Recorded_At = (
            SELECT MAX(g2.Recorded_At)
            FROM Energy_Generation g2
            WHERE g2.Station_ID = g.Station_ID
        )
    """)

    incidents = load_data("""
        SELECT COUNT(*) AS Active_Incidents
        FROM Grid_Incident
        WHERE Incident_Status IN ('Open', 'In Progress')
    """)

    storage_totals = load_data("""
        SELECT
            COALESCE(SUM(Total_Capacity_MWh), 0) AS Total_Capacity,
            COALESCE(SUM(Stored_Energy_MWh), 0) AS Stored_Energy,
            COALESCE(SUM(Available_Stored_MWh), 0) AS Available_Energy
        FROM vw_zone_storage_summary
    """)

    total_zones = int(metric_value(zones, "Total_Zones"))
    total_demand = float(metric_value(demand, "Total_Demand"))
    total_generation = float(metric_value(generation, "Total_Generation"))
    active_incidents = int(metric_value(incidents, "Active_Incidents"))

    total_capacity = float(metric_value(storage_totals, "Total_Capacity"))
    stored_energy = float(metric_value(storage_totals, "Stored_Energy"))
    available_energy = float(metric_value(storage_totals, "Available_Energy"))

    balance = total_generation - total_demand

    st.subheader("1. Grid Overview")

    c1, c2, c3, c4 = st.columns(4)

    c1.metric("Grid Zones", total_zones)
    c2.metric("Latest Demand", f"{number(total_demand)} MW")
    c3.metric("Latest Generation", f"{number(total_generation)} MW")
    c4.metric("Active Incidents", active_incidents)

    c5, c6, c7 = st.columns(3)

    c5.metric("Storage Capacity", f"{number(total_capacity)} MWh")
    c6.metric("Stored Energy", f"{number(stored_energy)} MWh")
    c7.metric("Available Stored Energy", f"{number(available_energy)} MWh")

    st.caption(
        f"Latest generation-demand difference: {number(balance)} MW. "
        "A negative value indicates that recorded generation is below demand."
    )

    st.divider()


    # -----------------------------------------------------
    # 2. DEMAND VS GENERATION
    # -----------------------------------------------------

    st.subheader("2. Electricity Demand vs Generation")

    st.write(
        "Compare the latest recorded electricity demand in each zone "
        "with the latest recorded generation from its power stations."
    )

    demand_by_zone = load_data("""
        SELECT
            z.Zone_ID,
            z.Zone_Name,
            COALESCE(d.Demand_MW, 0) AS Demand_MW
        FROM Grid_Zone z
        LEFT JOIN Energy_Demand d
            ON d.Zone_ID = z.Zone_ID
            AND d.Recorded_At = (
                SELECT MAX(d2.Recorded_At)
                FROM Energy_Demand d2
                WHERE d2.Zone_ID = z.Zone_ID
            )
        ORDER BY z.Zone_ID
    """)

    generation_by_zone = load_data("""
        SELECT
            z.Zone_ID,
            z.Zone_Name,
            COALESCE(SUM(g.Generation_MW), 0) AS Generation_MW
        FROM Grid_Zone z
        LEFT JOIN Power_Station p
            ON p.Zone_ID = z.Zone_ID
        LEFT JOIN Energy_Generation g
            ON g.Station_ID = p.Station_ID
            AND g.Recorded_At = (
                SELECT MAX(g2.Recorded_At)
                FROM Energy_Generation g2
                WHERE g2.Station_ID = p.Station_ID
            )
        GROUP BY z.Zone_ID, z.Zone_Name
        ORDER BY z.Zone_ID
    """)

    energy_comparison = pd.merge(
        demand_by_zone,
        generation_by_zone,
        on=["Zone_ID", "Zone_Name"],
        how="outer"
    ).fillna(0)

    if not energy_comparison.empty:

        chart = energy_comparison.set_index("Zone_Name")[
            ["Demand_MW", "Generation_MW"]
        ]

        st.bar_chart(chart)

        st.dataframe(
            energy_comparison[
                ["Zone_Name", "Demand_MW", "Generation_MW"]
            ],
            use_container_width=True,
            hide_index=True
        )

    else:
        st.info("No demand or generation data available.")

    st.divider()


    # -----------------------------------------------------
    # 3. GRID STRESS
    # -----------------------------------------------------

    st.subheader("3. Grid Stress Monitoring")

    st.write(
        "The system classifies zones into Normal, Moderate, High "
        "and Critical stress levels using their latest stress assessments."
    )

    stress = load_data("""
        SELECT
            Zone_ID,
            Zone_Name,
            Grid_Stress_Score,
            Stress_Level,
            Assessed_At
        FROM vw_zone_latest_stress
        ORDER BY Grid_Stress_Score DESC
    """)

    if not stress.empty:

        left, right = st.columns([2, 1])

        with left:
            stress_chart = stress.dropna(
                subset=["Grid_Stress_Score"]
            ).set_index("Zone_Name")[["Grid_Stress_Score"]]

            st.bar_chart(stress_chart)

        with right:
            stress_counts = (
                stress["Stress_Level"]
                .fillna("Not Assessed")
                .value_counts()
                .rename_axis("Stress_Level")
                .to_frame("Zone_Count")
            )

            st.write("Stress classification")
            st.bar_chart(stress_counts)

        st.dataframe(
            stress,
            use_container_width=True,
            hide_index=True
        )

    else:
        st.info("No stress assessments available.")

    st.divider()


    # -----------------------------------------------------
    # 4. ENERGY STORAGE
    # -----------------------------------------------------

    st.subheader("4. Energy Storage Infrastructure")

    st.write(
        "Monitor installed storage capacity, currently stored energy "
        "and the energy available from operationally available units."
    )

    storage = load_data("""
        SELECT *
        FROM vw_zone_storage_summary
        ORDER BY Zone_ID
    """)

    if not storage.empty:

        left, right = st.columns(2)

        with left:
            st.write("Storage capacity vs stored energy")

            storage_chart = storage.set_index("Zone_Name")[
                ["Total_Capacity_MWh", "Stored_Energy_MWh"]
            ]

            st.bar_chart(storage_chart)

        with right:
            st.write("Available stored energy by zone")

            available_chart = storage.set_index("Zone_Name")[
                ["Available_Stored_MWh"]
            ]

            st.bar_chart(available_chart)

        st.dataframe(
            storage,
            use_container_width=True,
            hide_index=True
        )

    else:
        st.info("No storage data available.")

    st.divider()


    # -----------------------------------------------------
    # 5. STORAGE UNIT HEALTH
    # -----------------------------------------------------

    st.subheader("5. Storage Unit Health")

    st.write(
        "Classify individual storage units by charge percentage. "
        "This helps identify units that may not be ready for deployment."
    )

    charge_health = load_data("""
        SELECT
            Storage_Name,
            Current_Charge_Percent,
            Unit_Status,
            CASE
                WHEN Current_Charge_Percent <= 20 THEN 'Critical Charge'
                WHEN Current_Charge_Percent <= 40 THEN 'Low Charge'
                WHEN Current_Charge_Percent <= 70 THEN 'Moderate Charge'
                ELSE 'Healthy Charge'
            END AS Charge_Condition
        FROM Energy_Storage_Unit
        ORDER BY Current_Charge_Percent ASC
    """)

    if not charge_health.empty:

        charge_counts = (
            charge_health["Charge_Condition"]
            .value_counts()
            .rename_axis("Charge_Condition")
            .to_frame("Unit_Count")
        )

        st.bar_chart(charge_counts)

        st.dataframe(
            charge_health,
            use_container_width=True,
            hide_index=True
        )

    else:
        st.info("No storage units available.")

    st.divider()


    # -----------------------------------------------------
    # 6. INCIDENT MANAGEMENT
    # -----------------------------------------------------

    st.subheader("6. Grid Incident Management")

    st.write(
        "Examine the severity and status of incidents requiring "
        "operational attention."
    )

    incident_distribution = load_data("""
        SELECT
            Severity,
            COUNT(*) AS Incident_Count
        FROM Grid_Incident
        GROUP BY Severity
        ORDER BY Incident_Count DESC
    """)

    active_incident_data = load_data("""
        SELECT
            i.Incident_ID,
            z.Zone_Name,
            i.Incident_Type,
            i.Severity,
            i.Incident_Status,
            i.Started_At
        FROM Grid_Incident i
        JOIN Grid_Zone z
            ON z.Zone_ID = i.Zone_ID
        WHERE i.Incident_Status IN ('Open', 'In Progress')
        ORDER BY i.Started_At DESC
    """)

    left, right = st.columns(2)

    with left:
        st.write("Incidents by severity")

        if not incident_distribution.empty:
            st.bar_chart(
                incident_distribution.set_index("Severity")
            )
        else:
            st.info("No incident records available.")

    with right:
        st.write("Incident status")

        status_distribution = load_data("""
            SELECT
                Incident_Status,
                COUNT(*) AS Incident_Count
            FROM Grid_Incident
            GROUP BY Incident_Status
        """)

        if not status_distribution.empty:
            st.bar_chart(
                status_distribution.set_index("Incident_Status")
            )
        else:
            st.info("No incident status data available.")

    st.write("Active incidents")

    if not active_incident_data.empty:
        st.dataframe(
            active_incident_data,
            use_container_width=True,
            hide_index=True
        )
    else:
        st.success("There are no active incidents.")

    st.divider()


    # -----------------------------------------------------
    # 7. RESOURCE ALLOCATION
    # -----------------------------------------------------

    st.subheader("7. Emergency Resource Allocation")

    st.write(
        "See how energy storage units are linked to grid incidents "
        "and how much power has been allocated."
    )

    allocation = load_data("""
        SELECT
            gi.Incident_ID,
            gi.Incident_Type,
            gi.Severity,
            COALESCE(SUM(ra.Allocated_Power_MW), 0) AS Allocated_MW
        FROM Grid_Incident gi
        LEFT JOIN Resource_Allocation ra
            ON ra.Incident_ID = gi.Incident_ID
        GROUP BY
            gi.Incident_ID,
            gi.Incident_Type,
            gi.Severity
        ORDER BY Allocated_MW DESC
    """)

    if not allocation.empty:

        st.bar_chart(
            allocation.set_index("Incident_ID")[["Allocated_MW"]]
        )

        st.dataframe(
            allocation,
            use_container_width=True,
            hide_index=True
        )

    else:
        st.info("No resource allocation records available.")

    st.divider()


    # -----------------------------------------------------
    # 8. MAINTENANCE AND ALERTS
    # -----------------------------------------------------

    st.subheader("8. Maintenance & Storage Alerts")

    maintenance = load_data("""
        SELECT
            t.Technician_Name,
            COUNT(m.Maintenance_ID) AS Pending_Jobs
        FROM Technician t
        LEFT JOIN Maintenance m
            ON m.Technician_ID = t.Technician_ID
            AND m.Maintenance_Status IN ('Scheduled', 'In Progress')
        GROUP BY
            t.Technician_ID,
            t.Technician_Name
        ORDER BY Pending_Jobs DESC
    """)

    alerts = load_data("""
        SELECT
            a.Alert_ID,
            es.Storage_Name,
            a.Alert_Type,
            a.Alert_Message,
            a.Created_At
        FROM Storage_Alert a
        JOIN Energy_Storage_Unit es
            ON es.Storage_ID = a.Storage_ID
        WHERE a.Alert_Status = 'Active'
        ORDER BY a.Created_At DESC
    """)

    left, right = st.columns(2)

    with left:
        st.write("Pending maintenance by technician")

        if not maintenance.empty:
            st.bar_chart(
                maintenance.set_index("Technician_Name")
            )

            st.dataframe(
                maintenance,
                use_container_width=True,
                hide_index=True
            )
        else:
            st.info("No maintenance records available.")

    with right:
        st.write("Active storage alerts")

        if not alerts.empty:
            st.dataframe(
                alerts,
                use_container_width=True,
                hide_index=True
            )
        else:
            st.success("No active storage alerts.")

    st.divider()

    st.caption(
        "Energy Storage & Grid Stress Management System | "
        "Database-driven operational dashboard"
    )


except Exception as error:

    st.error("Unable to load dashboard data.")
    st.exception(error)
