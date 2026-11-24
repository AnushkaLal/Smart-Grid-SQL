
from pathlib import Path
import re


PROJECT_ROOT = Path(__file__).resolve().parent.parent
QUERIES_FILE = PROJECT_ROOT / "database" / "queries.sql"


def load_demo_queries():
    if not QUERIES_FILE.exists():
        raise FileNotFoundError(
            f"Could not find {QUERIES_FILE}"
        )

    content = QUERIES_FILE.read_text(encoding="utf-8")

    # Handle numbered comment lines such as:
    # -- 1 SELECT * FROM Grid_Zone;
    # Some SQL files put the query itself after the number.
    cleaned_lines = []

    for line in content.splitlines():
        numbered = re.match(
            r"^\s*--\s*(\d+)\s+(.+?)\s*$",
            line
        )

        if numbered:
            remainder = numbered.group(2).strip()

            if re.match(
                r"^(SELECT|INSERT|UPDATE|DELETE|SHOW|DESCRIBE|DESC|CALL)\b",
                remainder,
                flags=re.IGNORECASE
            ):
                cleaned_lines.append(remainder)

            continue

        stripped = line.strip()

        # Ignore ordinary SQL comment lines.
        if stripped.startswith("--") or stripped.startswith("//"):
            continue

        cleaned_lines.append(line)

    cleaned = "\n".join(cleaned_lines)

    # Remove USE statements; the connection already selects the database.
    statements = [
        statement.strip()
        for statement in cleaned.split(";")
        if statement.strip()
    ]

    statements = [
        statement for statement in statements
        if not re.match(
            r"^\s*USE\s+",
            statement,
            flags=re.IGNORECASE
        )
    ]

    queries = {}

    for index, statement in enumerate(statements, start=1):
        queries[f"Query {index:02d}"] = statement + ";"

    return queries
