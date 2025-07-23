-- Migration: 001_initial_schema
-- Description: Create initial database schema for Metabase Description Generator
-- Created: 2024-01-01
-- Author: System

-- =================== EXTENSIONS ===================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto for encryption functions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =================== USERS TABLE ===================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'editor', 'viewer')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role_active ON users(role, is_active);

-- =================== METABASE CONNECTIONS TABLE ===================

CREATE TABLE metabase_connections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    url VARCHAR(512) NOT NULL,
    encrypted_credentials TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_sync_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Metabase connections indexes
CREATE INDEX idx_connections_name ON metabase_connections(name);
CREATE INDEX idx_connections_active ON metabase_connections(is_active);

-- =================== COLLECTIONS TABLE ===================

CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    metabase_id INTEGER NOT NULL,
    connection_id UUID NOT NULL REFERENCES metabase_connections(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    parent_id UUID REFERENCES collections(id) ON DELETE CASCADE,
    path TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Ensure unique metabase_id per connection
    CONSTRAINT unique_metabase_collection UNIQUE(metabase_id, connection_id)
);

-- Collections indexes
CREATE INDEX idx_collections_metabase_connection ON collections(metabase_id, connection_id);
CREATE INDEX idx_collections_parent_id ON collections(parent_id);
CREATE INDEX idx_collections_path ON collections(path);
CREATE INDEX idx_collections_connection_id ON collections(connection_id);

-- =================== DASHBOARDS TABLE ===================

CREATE TABLE dashboards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    metabase_id INTEGER NOT NULL,
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Ensure unique metabase_id per collection
    CONSTRAINT unique_metabase_dashboard UNIQUE(metabase_id, collection_id)
);

-- Dashboards indexes
CREATE INDEX idx_dashboards_metabase_collection ON dashboards(metabase_id, collection_id);
CREATE INDEX idx_dashboards_collection_id ON dashboards(collection_id);

-- =================== QUESTIONS TABLE ===================

CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    metabase_id INTEGER NOT NULL,
    dashboard_id UUID NOT NULL REFERENCES dashboards(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    query_type VARCHAR(50) NOT NULL CHECK (query_type IN ('query', 'native', 'model')),
    query_data JSONB NOT NULL,
    metadata JSONB,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Ensure unique metabase_id per dashboard
    CONSTRAINT unique_metabase_question UNIQUE(metabase_id, dashboard_id)
);

-- Questions indexes
CREATE INDEX idx_questions_metabase_dashboard ON questions(metabase_id, dashboard_id);
CREATE INDEX idx_questions_dashboard_id ON questions(dashboard_id);
CREATE INDEX idx_questions_query_type ON questions(query_type);
CREATE INDEX idx_questions_created_by ON questions(created_by);

-- =================== DESCRIPTIONS TABLE ===================

CREATE TABLE descriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    generated_text TEXT,
    approved_text TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'pending', 'approved', 'rejected')),
    created_by UUID NOT NULL REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    ai_provider VARCHAR(50),
    ai_model VARCHAR(100),
    generation_cost INTEGER, -- Cost in cents
    quality_score INTEGER CHECK (quality_score >= 0 AND quality_score <= 100),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Ensure one description per question
    CONSTRAINT unique_question_description UNIQUE(question_id)
);

-- Descriptions indexes
CREATE INDEX idx_descriptions_question_id ON descriptions(question_id);
CREATE INDEX idx_descriptions_status ON descriptions(status);
CREATE INDEX idx_descriptions_created_by ON descriptions(created_by);
CREATE INDEX idx_descriptions_approved_by ON descriptions(approved_by);
CREATE INDEX idx_descriptions_status_created ON descriptions(status, created_at);

-- =================== GENERATION JOBS TABLE ===================

CREATE TABLE generation_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(50) NOT NULL CHECK (type IN ('bulk_generate', 'sync_metabase', 'quality_analysis')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed', 'cancelled')),
    progress INTEGER NOT NULL DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    total_items INTEGER NOT NULL DEFAULT 0,
    processed_items INTEGER NOT NULL DEFAULT 0,
    error_message TEXT,
    parameters JSONB NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Generation jobs indexes
CREATE INDEX idx_jobs_status_created ON generation_jobs(status, created_at);
CREATE INDEX idx_jobs_type_status ON generation_jobs(type, status);
CREATE INDEX idx_jobs_created_by ON generation_jobs(created_by);

-- =================== AUDIT LOG TABLE ===================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Audit logs indexes
CREATE INDEX idx_audit_logs_table_record ON audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_changed_by ON audit_logs(changed_by);
CREATE INDEX idx_audit_logs_changed_at ON audit_logs(changed_at);

-- =================== UPDATED_AT TRIGGER FUNCTION ===================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to all relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_metabase_connections_updated_at BEFORE UPDATE ON metabase_connections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_collections_updated_at BEFORE UPDATE ON collections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_dashboards_updated_at BEFORE UPDATE ON dashboards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON questions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_descriptions_updated_at BEFORE UPDATE ON descriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_generation_jobs_updated_at BEFORE UPDATE ON generation_jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =================== RLS (Row Level Security) SETUP ===================

-- Enable RLS on sensitive tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE descriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE generation_jobs ENABLE ROW LEVEL SECURITY;

-- Users can only see their own profile data (except admins)
CREATE POLICY users_own_data ON users
    FOR ALL
    TO authenticated
    USING (id = current_setting('app.current_user_id')::uuid OR 
           current_setting('app.current_user_role') = 'admin');

-- Users can only see descriptions they created or have permission to view
CREATE POLICY descriptions_access ON descriptions
    FOR ALL
    TO authenticated
    USING (created_by = current_setting('app.current_user_id')::uuid OR 
           current_setting('app.current_user_role') IN ('admin', 'editor'));

-- Users can only see jobs they created or have permission to view
CREATE POLICY jobs_access ON generation_jobs
    FOR ALL
    TO authenticated
    USING (created_by = current_setting('app.current_user_id')::uuid OR 
           current_setting('app.current_user_role') = 'admin');

-- =================== HELPFUL VIEWS ===================

-- View for questions with their descriptions and context
CREATE VIEW questions_with_descriptions AS
SELECT 
    q.id,
    q.metabase_id,
    q.name,
    q.query_type,
    q.query_data,
    q.metadata,
    q.created_at as question_created_at,
    q.updated_at as question_updated_at,
    d.id as description_id,
    d.generated_text,
    d.approved_text,
    d.status as description_status,
    d.ai_provider,
    d.ai_model,
    d.quality_score,
    d.created_at as description_created_at,
    dash.name as dashboard_name,
    coll.name as collection_name,
    coll.path as collection_path,
    u_created.first_name || ' ' || u_created.last_name as created_by_name,
    u_approved.first_name || ' ' || u_approved.last_name as approved_by_name
FROM questions q
LEFT JOIN descriptions d ON q.id = d.question_id
JOIN dashboards dash ON q.dashboard_id = dash.id
JOIN collections coll ON dash.collection_id = coll.id
LEFT JOIN users u_created ON d.created_by = u_created.id
LEFT JOIN users u_approved ON d.approved_by = u_approved.id;

-- View for collection tree with statistics
CREATE VIEW collection_stats AS
SELECT 
    c.id,
    c.name,
    c.path,
    c.parent_id,
    COUNT(DISTINCT d.id) as dashboard_count,
    COUNT(DISTINCT q.id) as question_count,
    COUNT(DISTINCT CASE WHEN desc.status = 'approved' THEN desc.id END) as approved_descriptions,
    COUNT(DISTINCT CASE WHEN desc.status = 'pending' THEN desc.id END) as pending_descriptions,
    COUNT(DISTINCT CASE WHEN desc.status = 'draft' THEN desc.id END) as draft_descriptions,
    COUNT(DISTINCT desc.id) as total_descriptions
FROM collections c
LEFT JOIN dashboards d ON c.id = d.collection_id
LEFT JOIN questions q ON d.id = q.dashboard_id
LEFT JOIN descriptions desc ON q.id = desc.question_id
GROUP BY c.id, c.name, c.path, c.parent_id;

-- =================== HELPFUL FUNCTIONS ===================

-- Function to get collection hierarchy path
CREATE OR REPLACE FUNCTION get_collection_path(collection_id UUID)
RETURNS TEXT AS $$
DECLARE
    result TEXT;
BEGIN
    WITH RECURSIVE collection_hierarchy AS (
        SELECT id, name, parent_id, name as path, 0 as level
        FROM collections
        WHERE id = collection_id
        
        UNION ALL
        
        SELECT c.id, c.name, c.parent_id, c.name || '/' || ch.path, ch.level + 1
        FROM collections c
        JOIN collection_hierarchy ch ON c.id = ch.parent_id
    )
    SELECT path INTO result
    FROM collection_hierarchy
    ORDER BY level DESC
    LIMIT 1;
    
    RETURN COALESCE(result, '');
END;
$$ LANGUAGE plpgsql;

-- Function to calculate description progress for a collection
CREATE OR REPLACE FUNCTION get_description_progress(collection_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    WITH collection_questions AS (
        SELECT q.id
        FROM questions q
        JOIN dashboards d ON q.dashboard_id = d.id
        WHERE d.collection_id = collection_id
    ),
    description_stats AS (
        SELECT 
            COUNT(*) as total,
            COUNT(CASE WHEN desc.status = 'approved' THEN 1 END) as approved,
            COUNT(CASE WHEN desc.status = 'pending' THEN 1 END) as pending,
            COUNT(CASE WHEN desc.status = 'draft' THEN 1 END) as draft
        FROM collection_questions cq
        LEFT JOIN descriptions desc ON cq.id = desc.question_id
    )
    SELECT jsonb_build_object(
        'total', total,
        'approved', approved,
        'pending', pending,
        'draft', draft
    ) INTO result
    FROM description_stats;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =================== INITIAL DATA ===================

-- Insert default admin user (password: 'admin123' - should be changed in production)
INSERT INTO users (email, password_hash, first_name, last_name, role) VALUES
('admin@metabase-descriptor.local', crypt('admin123', gen_salt('bf')), 'System', 'Administrator', 'admin');

-- =================== COMMENTS ===================

COMMENT ON TABLE users IS 'User accounts with role-based access control';
COMMENT ON TABLE metabase_connections IS 'Configuration for connecting to Metabase instances';
COMMENT ON TABLE collections IS 'Hierarchical organization structure from Metabase';
COMMENT ON TABLE dashboards IS 'Metabase dashboards containing questions';
COMMENT ON TABLE questions IS 'Individual questions/charts from Metabase dashboards';
COMMENT ON TABLE descriptions IS 'AI-generated and human-approved descriptions for questions';
COMMENT ON TABLE generation_jobs IS 'Background jobs for bulk operations and sync tasks';
COMMENT ON TABLE audit_logs IS 'Audit trail for all data modifications';

COMMENT ON COLUMN descriptions.generation_cost IS 'Cost in cents for AI generation';
COMMENT ON COLUMN descriptions.quality_score IS 'Automated quality score from 0-100';
COMMENT ON COLUMN generation_jobs.progress IS 'Job completion percentage from 0-100';