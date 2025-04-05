#!/bin/bash

# Script to fix the PostgreSQL dump import issue
# Usage: ./fix_import.sh <path_to_dump_file>

if [ -z "$1" ]; then
  echo "Error: Please provide the path to the database dump file"
  echo "Usage: ./fix_import.sh <path_to_dump_file>"
  exit 1
fi

DUMP_FILE=$1

echo "Starting database import fix process..."

# 1. Reset the database to ensure a clean import
echo "Resetting database..."
docker exec -i aed_postgres psql -U postgres -c "DROP DATABASE IF EXISTS aed;"
docker exec -i aed_postgres psql -U postgres -c "CREATE DATABASE aed;"

# 2. Create the necessary schemas and extensions
echo "Creating schemas and extensions..."
docker exec -i aed_postgres psql -U postgres -d aed -c "CREATE SCHEMA IF NOT EXISTS beta;"
docker exec -i aed_postgres psql -U postgres -d aed -c "CREATE SCHEMA IF NOT EXISTS dev;"
docker exec -i aed_postgres psql -U postgres -d aed -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

# 3. Create the role 'bryan' if it's referenced in the dump
echo "Creating roles if needed..."
docker exec -i aed_postgres psql -U postgres -d aed -c "DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'bryan') THEN
    CREATE ROLE bryan;
  END IF;
END
\$\$;"

# 4. Extract and run the schema creation part (before the COPY statements)
echo "Creating tables from dump file..."
grep -n "COPY" "$DUMP_FILE" | head -1 | cut -d: -f1 | xargs -I{} head -n {} "$DUMP_FILE" > /tmp/schema.sql
cat /tmp/schema.sql | docker exec -i aed_postgres psql -U postgres -d aed

# 5. Process each COPY statement separately with proper handling of tab-separated values
echo "Importing data..."
for table in "collection_resources" "collection_tags" "collections" "resource_status" "resources"; do
  echo "Processing table: beta.$table"
  
  # Extract the data section for this table (between COPY and \.)
  sed -n "/COPY beta.$table/,/\\\\\\./p" "$DUMP_FILE" > /tmp/table_data.sql
  
  # Import the data using psql with proper handling of tab-separated values
  cat /tmp/table_data.sql | docker exec -i aed_postgres psql -U postgres -d aed
done

# 6. Run any post-data SQL (constraints, indexes, etc.)
echo "Creating indexes and constraints..."
grep -n "\\\\\\.$" "$DUMP_FILE" | tail -1 | cut -d: -f1 | xargs -I{} tail -n +{} "$DUMP_FILE" > /tmp/post_data.sql
cat /tmp/post_data.sql | docker exec -i aed_postgres psql -U postgres -d aed

# 7. Verify the import
echo "Verifying import..."
docker exec -i aed_postgres psql -U postgres -d aed -c "SELECT COUNT(*) FROM beta.resources;"
docker exec -i aed_postgres psql -U postgres -d aed -c "SELECT COUNT(*) FROM beta.resource_status;"

echo "Database import process completed!"
