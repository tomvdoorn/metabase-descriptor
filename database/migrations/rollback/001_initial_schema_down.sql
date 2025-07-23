-- Rollback Migration: 001_initial_schema
-- Description: Drop all tables and objects created in initial schema migration
-- Created: 2024-01-01

-- =================== DROP VIEWS ===================

DROP VIEW IF EXISTS questions_with_descriptions;
DROP VIEW IF EXISTS collection_stats;

-- =================== DROP FUNCTIONS ===================

DROP FUNCTION IF EXISTS get_collection_path(UUID);
DROP FUNCTION IF EXISTS get_description_progress(UUID);
DROP FUNCTION IF EXISTS update_updated_at_column();

-- =================== DROP TABLES (in reverse dependency order) ===================

DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS generation_jobs;
DROP TABLE IF EXISTS descriptions;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS dashboards;
DROP TABLE IF EXISTS collections;
DROP TABLE IF EXISTS metabase_connections;
DROP TABLE IF EXISTS users;

-- =================== DROP EXTENSIONS ===================

-- Note: We don't drop extensions as they might be used by other databases
-- DROP EXTENSION IF EXISTS "pgcrypto";
-- DROP EXTENSION IF EXISTS "uuid-ossp";