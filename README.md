# AED Web Application with PostgreSQL

This repository contains a Dockerized web application connected to a PostgreSQL database for the AED (Access to Essential Data) project.

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Git
- Access to the database dump file (`aed_database_dump_20250402.sql` or similar)

1. **Start the Docker containers**

```bash
docker-compose up -d
```

This will start three containers:
- PostgreSQL database (`aed_postgres`)
- pgAdmin web interface (`aed_pgadmin`)
- Web application (`aed_webapp`)

2. **Import the database**

```bash
./init-scripts/db-tools/fix_import.sh /path/to/aed_database_dump_20250402.sql
```

3. **Access the web application**

The web application will be available at http://localhost:5001/data-and-tools/

## Configuration

### Environment Variables

The application uses the following environment variables, defined in the `.env` file:

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=aed
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/aed
```

## Development

### Database Tools

The `init-scripts/db-tools` directory contains scripts for managing the database:

- `fix_import.sh` - Imports the database dump file


### Modifying the Web Application

The web application code is in the `app` directory. Key files:
- `app/app.py` - Main application entry point
- `app/data_access/db.py` - Database connection code
- `app/data_access/resource.py` - Resource repository
- `app/data_access/resource_status.py` - Resource status repository

## Troubleshooting

### Database Connection Issues

If the web application can't connect to the database, check:
1. The `DATABASE_URL` environment variable in the `.env` file
2. The PostgreSQL container is running: `docker ps | grep aed_postgres`
3. The database has been properly imported: `docker exec -i aed_postgres psql -U postgres -d aed -c "SELECT COUNT(*) FROM beta.resources;"`

### Missing Data

If the web application is not displaying data:
1. Make sure the database has been imported correctly
2. Check that the application is using the correct schema (`beta`)
3. Restart the web application: `docker restart aed_webapp`

