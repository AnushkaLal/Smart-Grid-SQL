
# Energy Storage & Grid Stress Management System

A database-driven smart grid management system built using **MySQL and Streamlit** to monitor electricity demand, generation, energy storage, grid stress, incidents, and maintenance operations.

The project demonstrates how a relational database can support the monitoring and management of a distributed energy grid through structured SQL queries, database views, data analysis, and interactive visualizations.

## Overview

Modern electricity grids must continuously balance power demand and generation while managing energy storage, responding to grid incidents, and maintaining infrastructure.

This project models these operations through a centralized relational database. It provides an interactive dashboard for understanding grid conditions and a SQL Query Console for executing predefined queries and exploring the underlying database operations.

## Key Features

### 1. Grid Overview
- Monitor the total number of grid zones.
- View the latest electricity demand and generation.
- Track active grid incidents.
- Monitor total energy storage capacity and stored energy.

### 2. Grid Stress Monitoring
- Analyze stress levels across different grid zones.
- Identify zones experiencing high or critical stress.
- Visualize stress distribution and compare zones.
- Use database views to retrieve the latest stress assessments.

### 3. Demand and Generation Analysis
- Compare electricity demand and generation across grid zones.
- Identify differences between consumption and available generation.
- Understand how demand patterns affect grid stability.

### 4. Energy Storage Management
- Monitor storage capacity and current stored energy.
- Compare available stored energy across zones.
- Track storage unit charge percentages and operational status.
- Identify storage units that may require attention.

### 5. Incident Management
- Monitor grid incidents by severity and status.
- View active incidents and their associated zones.
- Analyze how incidents are distributed across the grid.

### 6. Emergency Resource Allocation
- Monitor power allocated to individual incidents.
- Understand how available resources are distributed during grid emergencies.

### 7. Maintenance and Alerts
- Track maintenance operations and technician assignments.
- Monitor storage alerts and their status.
- Identify operational issues requiring attention.

### 8. SQL Query Console
- Execute 28 predefined SQL queries.
- Select queries from a dropdown menu.
- View the corresponding query explanation.
- Manually execute queries and inspect their results.
- Explore database operations without automatic query execution.

## Technology Stack

| Component | Technology |
|---|---|
| Frontend | Streamlit |
| Database | MySQL |
| Backend | Python |
| Database Connectivity | mysql-connector-python |
| Data Processing | Pandas |
| Visualization | Streamlit Charts |

## Project Structure

```text
smart-grid-dbms-app/
│
├── app/
│   ├── main.py
│   ├── db.py
│   ├── query_library.py
│   │
│   └── pages/
│       └── 2_SQL_Query_Console.py
│
├── .env
├── .gitignore
├── requirements.txt
└── README.md
```

## Database Design

The database is named `energy_grid_db` and models the major entities involved in smart grid operations.

The system includes entities for:

- Grid zones
- Energy demand
- Energy generation
- Power stations
- Energy storage units
- Grid stress assessments
- Grid incidents
- Resource allocation
- Technicians
- Maintenance
- Storage alerts

Database views are also used to simplify the retrieval of summarized information, including:

- `vw_zone_latest_stress`
- `vw_zone_storage_summary`

These views support dashboard visualizations without requiring complex aggregation queries to be repeated throughout the application.

## Application Setup

### Prerequisites

Make sure you have installed:

- Python 3.10 or later
- MySQL Server
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/smart-grid-dbms-app.git
cd smart-grid-dbms-app
```

### 2. Create a Virtual Environment

```bash
python3 -m venv .venv
```

Activate it:

**macOS / Linux**
```bash
source .venv/bin/activate
```

**Windows**
```bash
.venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Create a `.env` file in the project root directory.

Add your MySQL connection details:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=energy_grid_db
```

Replace `your_mysql_password` with your local MySQL password.

**Important:** Do not commit your `.env` file or expose database credentials on GitHub.

### 5. Set Up the Database

Create the database in MySQL:

```sql
CREATE DATABASE energy_grid_db;
```

Import your database schema and sample data using your SQL setup script.

Make sure the required tables and views have been created before running the application.

### 6. Run the Application

From the project root:

```bash
streamlit run app/main.py
```

The application will open in your browser.

The SQL Query Console can be accessed through the Streamlit navigation sidebar.

## Application Workflow

```text
          MySQL Database
                |
                |
       Python Database Layer
                |
         +------+------+
         |             |
         v             v
   Main Dashboard   SQL Query Console
         |             |
         v             v
   Charts, KPIs     Query Execution
   and Tables       and Explanations
         |             |
         +------+------+
                |
                v
       Grid Monitoring
       and Analysis
```

## Learning Outcomes

This project demonstrates practical applications of database management concepts:

- Relational database design and entity relationships.
- SQL queries involving filtering, sorting, joins, and aggregation.
- Database views for reusable data retrieval.
- Transaction handling and database connectivity.
- Data retrieval and presentation through Python.
- Interactive dashboard development.
- Applying DBMS concepts to a real-world energy management scenario.

## Future Scope

Potential extensions include:

- Historical demand and generation trend analysis.
- More detailed grid stress prediction.
- Automated recommendations for energy storage allocation.
- Real-time integration with smart meters and grid sensors.
- Advanced monitoring of grid reliability and operational efficiency.

## Contributors

Developed as an academic DBMS project to demonstrate the application of relational database concepts in smart grid and energy storage management.

---

**Energy Storage & Grid Stress Management System**  
*Database-driven monitoring and analysis for smarter energy grid operations.*
