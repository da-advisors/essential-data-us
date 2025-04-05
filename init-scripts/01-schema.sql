-- Database schema initialization for America's Essential Data
-- This script will run when the PostgreSQL container starts

-- Create beta schema
CREATE SCHEMA IF NOT EXISTS beta;

-- Enable UUID extension for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Resources table to store information about monitored URLs
CREATE TABLE IF NOT EXISTS beta.resources (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT,
    url TEXT,
    normalized_url TEXT UNIQUE,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Resource status table to store status checks
CREATE TABLE IF NOT EXISTS beta.resource_status (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    resource_id TEXT REFERENCES beta.resources(id),
    status TEXT NOT NULL,
    status_code INTEGER,
    content_length INTEGER,
    checked_at TIMESTAMP NOT NULL,
    source TEXT,
    run_id TEXT,
    run_url TEXT,
    CONSTRAINT unique_resource_check UNIQUE (resource_id, checked_at, source)
);

-- Collections table to organize resources
CREATE TABLE IF NOT EXISTS beta.collections (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    omb_control_number TEXT,
    config_file_name TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Collection resources table to link collections and resources
CREATE TABLE IF NOT EXISTS beta.collection_resources (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    collection_id TEXT REFERENCES beta.collections(id),
    resource_id TEXT REFERENCES beta.resources(id),
    is_primary BOOLEAN DEFAULT FALSE,
    begin_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    UNIQUE(collection_id, resource_id)
);

-- Collection tags table
CREATE TABLE IF NOT EXISTS beta.collection_tags (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    collection_id TEXT REFERENCES beta.collections(id),
    tag TEXT NOT NULL,
    begin_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    UNIQUE(collection_id, tag)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_resource_status_resource_id ON beta.resource_status(resource_id);
CREATE INDEX IF NOT EXISTS idx_resource_status_checked_at ON beta.resource_status(checked_at);
CREATE INDEX IF NOT EXISTS idx_resources_normalized_url ON beta.resources(normalized_url);
