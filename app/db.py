
import os

import mysql.connector
from dotenv import load_dotenv

load_dotenv()


def _get_env(*names, default=None):
    """Read the first available environment variable."""
    for name in names:
        value = os.getenv(name)
        if value is not None:
            return value
    return default


def get_connection():
    """Create a MySQL connection using the existing .env settings."""
    return mysql.connector.connect(
        host=_get_env("DB_HOST", "MYSQL_HOST", default="localhost"),
        port=int(_get_env("DB_PORT", "MYSQL_PORT", default="3306")),
        user=_get_env("DB_USER", "MYSQL_USER", default="root"),
        password=_get_env("DB_PASSWORD", "MYSQL_PASSWORD", default=""),
        database=_get_env(
            "DB_NAME", "MYSQL_DATABASE", "DATABASE_NAME",
            default="energy_grid_db"
        ),
        autocommit=False
    )


def validate_sql(sql):
    """Allow one SQL statement per execution."""
    sql = sql.strip()

    if not sql:
        raise ValueError("SQL query cannot be empty.")

    sql = sql.rstrip(";").strip()

    if ";" in sql:
        raise ValueError(
            "Run one SQL statement at a time. "
            "Remove any internal semicolons."
        )

    return sql


def execute_sql(connection, sql, transaction_active=False):
    """
    Execute one SQL statement.

    Explicit transactions remain open across Run clicks.
    Standalone statements are committed automatically.
    """
    sql = validate_sql(sql)
    normalized = sql.strip().upper()

    cursor = connection.cursor(dictionary=True, buffered=True)

    try:
        cursor.execute(sql)

        if normalized.startswith("START TRANSACTION") or normalized == "BEGIN":
            transaction_active = True

        elif normalized.startswith("COMMIT"):
            connection.commit()
            transaction_active = False

        elif normalized.startswith("ROLLBACK"):
            connection.rollback()
            transaction_active = False

        else:
            # Collect result sets. This also handles stored procedures
            # that return one or more SELECT result sets.
            rows = []
            columns = []

            while True:
                if cursor.with_rows:
                    current_rows = cursor.fetchall()

                    if not columns and cursor.description:
                        columns = [item[0] for item in cursor.description]

                    rows.extend(current_rows)

                if not cursor.nextset():
                    break

            # Commit ordinary statements unless the user explicitly
            # started a transaction.
            if not transaction_active:
                connection.commit()

            return {
                "rows": rows,
                "columns": columns,
                "message": (
                    f"Query executed successfully. "
                    f"{len(rows)} row(s) returned."
                    if columns else
                    f"Query executed successfully. "
                    f"{cursor.rowcount} affected row(s)."
                ),
                "transaction_active": transaction_active
            }

        return {
            "rows": [],
            "columns": [],
            "message": "Transaction command executed successfully.",
            "transaction_active": transaction_active
        }

    except Exception:
        connection.rollback()
        transaction_active = False
        raise

    finally:
        cursor.close()


def fetch_all(query, params=None):
    """Execute a read-only query and return all rows as dictionaries."""
    connection = get_connection()
    cursor = connection.cursor(dictionary=True, buffered=True)

    try:
        cursor.execute(query, params or ())
        rows = cursor.fetchall()
        return rows

    finally:
        cursor.close()
        connection.close()
