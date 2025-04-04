import os
import psycopg2
import psycopg2.extras
from typing import List, Dict, Any, Optional
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class DatabaseInstance:
    def __init__(self, connection_string=None):
        """Initialize database connection using connection string or environment variable.
        
        Args:
            connection_string: PostgreSQL connection string. If None, uses DATABASE_URL env var.
        """
        if connection_string is None:
            connection_string = os.getenv('DATABASE_URL')
            if not connection_string:
                raise ValueError("No database connection string provided and DATABASE_URL not set")
                
        self.connection_string = connection_string
        # Don't connect immediately - connect on first query to avoid holding connections
        self.conn = None
    
    def _ensure_connection(self):
        """Ensure we have an active database connection."""
        if self.conn is None or self.conn.closed:
            self.conn = psycopg2.connect(self.connection_string)
    
    def query(self, query: str, parameters: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """Execute a query and return results as a list of dictionaries.
        
        Args:
            query: SQL query string
            parameters: Query parameters
            
        Returns:
            List of dictionaries with query results
        """
        self._ensure_connection()
        
        with self.conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
            cursor.execute(query, parameters)
            return cursor.fetchall()
    
    def close(self):
        """Close the database connection."""
        if self.conn and not self.conn.closed:
            self.conn.close()
