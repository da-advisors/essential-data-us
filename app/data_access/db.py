import os
from typing import Any, Dict, List, Optional
import psycopg2
import psycopg2.extras


class DatabaseInstance:
    def __init__(self):
        self.conn = None
        self.database_url = os.environ.get("DATABASE_URL")

    def _ensure_connection(self):
        if self.conn is None:
            self.conn = psycopg2.connect(self.database_url)

    def query(self, query: str, parameters: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        self._ensure_connection()
        with self.conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
            cursor.execute(query, parameters)
            return cursor.fetchall()
