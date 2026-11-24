
import pandas as pd
import streamlit as st

from db import get_connection
from query_library import QUERY_LIBRARY

st.title("SQL Query Console")
st.caption("Select a predefined query, review its explanation, and run it manually.")

# 1. Select a query
query_name = st.selectbox(
    "Choose a SQL query",
    options=list(QUERY_LIBRARY.keys())
)

# 2. Fetch the already-written query and explanation
query_info = QUERY_LIBRARY[query_name]

st.subheader("Query Explanation")
st.info(query_info["explanation"])

st.subheader("SQL Statement")
st.code(query_info["sql"], language="sql")

# 3. Execute only when the user clicks the button
sql = query_info["sql"].strip()
first_word = sql.split()[0].upper() if sql else ""

modifying_commands = {
    "INSERT", "UPDATE", "DELETE", "REPLACE",
    "CREATE", "ALTER", "DROP", "TRUNCATE"
}

if first_word in modifying_commands:
    confirmed = st.checkbox(
        "I understand this query will modify the database."
    )
else:
    confirmed = True

if st.button("Run Query", type="primary"):
    if not confirmed:
        st.warning("Please confirm before running this modifying query.")
    else:
        connection = None
        cursor = None

        try:
            connection = get_connection()
            cursor = connection.cursor(
                dictionary=True,
                buffered=True
            )

            cursor.execute(sql)

            if cursor.with_rows:
                results = cursor.fetchall()

                st.subheader("Query Output")

                if results:
                    df = pd.DataFrame(results)
                    st.dataframe(df, use_container_width=True)
                    st.success(f"{len(df)} row(s) returned.")
                else:
                    st.info("The query returned no rows.")

            else:
                connection.commit()
                st.subheader("Query Output")
                st.success(
                    f"Query executed successfully. "
                    f"{cursor.rowcount} row(s) affected."
                )

        except Exception as e:
            if connection:
                connection.rollback()

            st.error(f"Query execution failed: {e}")

        finally:
            if cursor:
                cursor.close()

            if connection:
                connection.close()
