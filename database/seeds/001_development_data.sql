-- Development Seed Data for Metabase Description Generator
-- Description: Insert sample data for development and testing
-- Created: 2024-01-01

-- =================== USERS ===================

-- Insert test users (passwords are hashed using bcrypt)
-- Default password for all test users: "password123"
INSERT INTO users (id, email, password_hash, first_name, last_name, role, is_active) VALUES
-- Admin user
('11111111-1111-1111-1111-111111111111', 'admin@example.com', '$2b$10$K7L1OJ45/4Y.aKqFvRDzLO9OX8mFuihKCnF7FdVQ1pN9z4F5v5l3C', 'Alice', 'Admin', 'admin', true),
-- Editor users
('22222222-2222-2222-2222-222222222222', 'editor1@example.com', '$2b$10$K7L1OJ45/4Y.aKqFvRDzLO9OX8mFuihKCnF7FdVQ1pN9z4F5v5l3C', 'Bob', 'Editor', 'editor', true),
('33333333-3333-3333-3333-333333333333', 'editor2@example.com', '$2b$10$K7L1OJ45/4Y.aKqFvRDzLO9OX8mFuihKCnF7FdVQ1pN9z4F5v5l3C', 'Carol', 'Writer', 'editor', true),
-- Viewer users
('44444444-4444-4444-4444-444444444444', 'viewer1@example.com', '$2b$10$K7L1OJ45/4Y.aKqFvRDzLO9OX8mFuihKCnF7FdVQ1pN9z4F5v5l3C', 'David', 'Viewer', 'viewer', true),
('55555555-5555-5555-5555-555555555555', 'viewer2@example.com', '$2b$10$K7L1OJ45/4Y.aKqFvRDzLO9OX8mFuihKCnF7FdVQ1pN9z4F5v5l3C', 'Eva', 'Reader', 'viewer', true);

-- =================== METABASE CONNECTIONS ===================

-- Insert test Metabase connections
INSERT INTO metabase_connections (id, name, url, encrypted_credentials, is_active, last_sync_at) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Production Metabase', 'https://metabase.company.com', 'encrypted_api_key_data_here', true, NOW() - INTERVAL '1 hour'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Staging Metabase', 'https://staging-metabase.company.com', 'encrypted_api_key_data_here', true, NOW() - INTERVAL '2 hours'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Development Metabase', 'https://dev-metabase.company.com', 'encrypted_api_key_data_here', false, NOW() - INTERVAL '1 day');

-- =================== COLLECTIONS ===================

-- Insert root collections
INSERT INTO collections (id, metabase_id, connection_id, name, parent_id, path, description) VALUES
-- Root collections for Production Metabase
('c0000001-0000-0000-0000-000000000001', 1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Marketing', NULL, '/Marketing', 'Marketing team dashboards and reports'),
('c0000002-0000-0000-0000-000000000002', 2, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Sales', NULL, '/Sales', 'Sales performance and analytics'),
('c0000003-0000-0000-0000-000000000003', 3, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Product', NULL, '/Product', 'Product metrics and user analytics'),
('c0000004-0000-0000-0000-000000000004', 4, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Finance', NULL, '/Finance', 'Financial reporting and budgets');

-- Insert sub-collections
INSERT INTO collections (id, metabase_id, connection_id, name, parent_id, path, description) VALUES
-- Marketing sub-collections
('c0000011-0000-0000-0000-000000000011', 11, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Campaigns', 'c0000001-0000-0000-0000-000000000001', '/Marketing/Campaigns', 'Marketing campaign performance'),
('c0000012-0000-0000-0000-000000000012', 12, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Website Analytics', 'c0000001-0000-0000-0000-000000000001', '/Marketing/Website Analytics', 'Website traffic and conversion metrics'),
-- Sales sub-collections
('c0000021-0000-0000-0000-000000000021', 21, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Revenue Reports', 'c0000002-0000-0000-0000-000000000002', '/Sales/Revenue Reports', 'Monthly and quarterly revenue analysis'),
('c0000022-0000-0000-0000-000000000022', 22, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Lead Generation', 'c0000002-0000-0000-0000-000000000002', '/Sales/Lead Generation', 'Lead quality and conversion tracking'),
-- Product sub-collections
('c0000031-0000-0000-0000-000000000031', 31, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'User Behavior', 'c0000003-0000-0000-0000-000000000003', '/Product/User Behavior', 'User engagement and feature usage'),
('c0000032-0000-0000-0000-000000000032', 32, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Performance Metrics', 'c0000003-0000-0000-0000-000000000003', '/Product/Performance Metrics', 'Application performance and reliability');

-- =================== DASHBOARDS ===================

-- Insert test dashboards
INSERT INTO dashboards (id, metabase_id, collection_id, name, description) VALUES
-- Marketing dashboards
('d0000001-0000-0000-0000-000000000001', 101, 'c0000011-0000-0000-0000-000000000011', 'Campaign Performance Overview', 'High-level metrics for all marketing campaigns'),
('d0000002-0000-0000-0000-000000000002', 102, 'c0000011-0000-0000-0000-000000000011', 'Email Campaign Deep Dive', 'Detailed analysis of email marketing performance'),
('d0000003-0000-0000-0000-000000000003', 103, 'c0000012-0000-0000-0000-000000000012', 'Website Traffic Report', 'Daily website analytics and visitor behavior'),

-- Sales dashboards
('d0000004-0000-0000-0000-000000000004', 104, 'c0000021-0000-0000-0000-000000000021', 'Monthly Revenue Dashboard', 'Monthly revenue breakdown by product and region'),
('d0000005-0000-0000-0000-000000000005', 105, 'c0000022-0000-0000-0000-000000000022', 'Lead Conversion Funnel', 'Lead progression through sales pipeline'),

-- Product dashboards
('d0000006-0000-0000-0000-000000000006', 106, 'c0000031-0000-0000-0000-000000000031', 'User Engagement Metrics', 'Daily active users and feature adoption'),
('d0000007-0000-0000-0000-000000000007', 107, 'c0000032-0000-0000-0000-000000000032', 'System Performance Dashboard', 'Application uptime and response times');

-- =================== QUESTIONS ===================

-- Insert test questions with realistic query data
INSERT INTO questions (id, metabase_id, dashboard_id, name, query_type, query_data, metadata, created_by) VALUES
-- Campaign Performance Overview questions
('q0000001-0000-0000-0000-000000000001', 1001, 'd0000001-0000-0000-0000-000000000001', 'Total Campaign Impressions', 'query', 
'{"database": 1, "query": {"source-table": 5, "aggregation": [["sum", ["field", 15, null]]], "breakout": [["field", 12, {"temporal-unit": "month"}]]}}',
'{"tables": ["campaigns"], "columns": ["impressions", "date"], "aggregations": ["sum"], "filters": [], "joins": []}',
'22222222-2222-2222-2222-222222222222'),

('q0000002-0000-0000-0000-000000000002', 1002, 'd0000001-0000-0000-0000-000000000001', 'Campaign Click-Through Rate', 'query',
'{"database": 1, "query": {"source-table": 5, "aggregation": [["avg", ["field", 16, null]]], "breakout": [["field", 13, null]]}}',
'{"tables": ["campaigns"], "columns": ["ctr", "campaign_type"], "aggregations": ["avg"], "filters": [], "joins": []}',
'22222222-2222-2222-2222-222222222222'),

('q0000003-0000-0000-0000-000000000003', 1003, 'd0000001-0000-0000-0000-000000000001', 'Cost Per Acquisition by Channel', 'query',
'{"database": 1, "query": {"source-table": 5, "aggregation": [["avg", ["field", 18, null]]], "breakout": [["field", 14, null]]}}',
'{"tables": ["campaigns"], "columns": ["cpa", "channel"], "aggregations": ["avg"], "filters": [], "joins": []}',
'22222222-2222-2222-2222-222222222222'),

-- Website Traffic Report questions
('q0000004-0000-0000-0000-000000000004', 1004, 'd0000003-0000-0000-0000-000000000003', 'Daily Unique Visitors', 'query',
'{"database": 2, "query": {"source-table": 8, "aggregation": [["count-distinct", ["field", 25, null]]], "breakout": [["field", 22, {"temporal-unit": "day"}]]}}',
'{"tables": ["web_analytics"], "columns": ["visitor_id", "visit_date"], "aggregations": ["count-distinct"], "filters": [], "joins": []}',
'22222222-2222-2222-2222-222222222222'),

('q0000005-0000-0000-0000-000000000005', 1005, 'd0000003-0000-0000-0000-000000000003', 'Top Landing Pages', 'query',
'{"database": 2, "query": {"source-table": 8, "aggregation": [["count", ["field", 26, null]]], "breakout": [["field", 23, null]], "order-by": [["desc", ["aggregation", 0]]], "limit": 10}}',
'{"tables": ["web_analytics"], "columns": ["page_views", "landing_page"], "aggregations": ["count"], "filters": [], "joins": []}',
'22222222-2222-2222-2222-222222222222'),

-- Revenue Dashboard questions
('q0000006-0000-0000-0000-000000000006', 1006, 'd0000004-0000-0000-0000-000000000004', 'Monthly Revenue Trend', 'query',
'{"database": 3, "query": {"source-table": 12, "aggregation": [["sum", ["field", 35, null]]], "breakout": [["field", 32, {"temporal-unit": "month"}]]}}',
'{"tables": ["orders"], "columns": ["revenue", "order_date"], "aggregations": ["sum"], "filters": [], "joins": []}',
'33333333-3333-3333-3333-333333333333'),

('q0000007-0000-0000-0000-000000000007', 1007, 'd0000004-0000-0000-0000-000000000004', 'Revenue by Product Category', 'query',
'{"database": 3, "query": {"source-table": 12, "aggregation": [["sum", ["field", 35, null]]], "breakout": [["field", 38, null]], "joins": [{"source-table": 15, "condition": ["=", ["field", 36, null], ["field", 45, {"join-alias": "Products"}]]}]}}',
'{"tables": ["orders", "products"], "columns": ["revenue", "category"], "aggregations": ["sum"], "filters": [], "joins": ["products"]}',
'33333333-3333-3333-3333-333333333333'),

-- User Engagement questions
('q0000008-0000-0000-0000-000000000008', 1008, 'd0000006-0000-0000-0000-000000000006', 'Daily Active Users', 'query',
'{"database": 4, "query": {"source-table": 18, "aggregation": [["count-distinct", ["field", 55, null]]], "breakout": [["field", 52, {"temporal-unit": "day"}]]}}',
'{"tables": ["user_events"], "columns": ["user_id", "event_date"], "aggregations": ["count-distinct"], "filters": [], "joins": []}',
'22222222-2222-2222-2222-222222222222'),

('q0000009-0000-0000-0000-000000000009', 1009, 'd0000006-0000-0000-0000-000000000006', 'Feature Usage Distribution', 'query',
'{"database": 4, "query": {"source-table": 18, "aggregation": [["count", ["field", 56, null]]], "breakout": [["field", 53, null]]}}',
'{"tables": ["user_events"], "columns": ["event_count", "feature_name"], "aggregations": ["count"], "filters": [], "joins": []}',
'22222222-2222-2222-2222-222222222222'),

-- Native SQL example
('q0000010-0000-0000-0000-000000000010', 1010, 'd0000007-0000-0000-0000-000000000007', 'System Response Time P99', 'native',
'{"database": 5, "native": {"query": "SELECT DATE_TRUNC(''hour'', timestamp) as hour, PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY response_time_ms) as p99_response_time FROM system_metrics WHERE timestamp >= NOW() - INTERVAL ''24 hours'' GROUP BY hour ORDER BY hour"}}',
'{"tables": ["system_metrics"], "columns": ["timestamp", "response_time_ms"], "aggregations": ["percentile"], "filters": ["time_range"], "joins": []}',
'22222222-2222-2222-2222-222222222222');

-- =================== DESCRIPTIONS ===================

-- Insert test descriptions with various statuses
INSERT INTO descriptions (id, question_id, generated_text, approved_text, status, created_by, approved_by, ai_provider, ai_model, generation_cost, quality_score) VALUES
-- Approved descriptions
('desc0001-0000-0000-0000-000000000001', 'q0000001-0000-0000-0000-000000000001', 
'This chart displays the total number of impressions across all marketing campaigns, grouped by month. It helps track the overall reach and visibility of marketing efforts over time.',
'This chart shows the total monthly impressions across all marketing campaigns, providing insight into the overall reach and visibility of our marketing efforts.',
'approved', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'openai', 'gpt-4', 15, 92),

('desc0002-0000-0000-0000-000000000002', 'q0000002-0000-0000-0000-000000000002',
'This visualization shows the average click-through rate (CTR) for different campaign types. CTR is calculated as clicks divided by impressions and indicates how engaging your campaigns are to the target audience.',
'This chart displays the average click-through rate by campaign type, showing how effectively different campaign formats engage our target audience.',
'approved', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'openai', 'gpt-4', 18, 88),

-- Pending descriptions
('desc0003-0000-0000-0000-000000000003', 'q0000003-0000-0000-0000-000000000003',
'This chart presents the average Cost Per Acquisition (CPA) broken down by marketing channel. CPA represents the total cost spent to acquire one customer and is crucial for understanding the efficiency of different marketing channels.',
NULL, 'pending', '22222222-2222-2222-2222-222222222222', NULL, 'anthropic', 'claude-3-opus', 22, 85),

('desc0004-0000-0000-0000-000000000004', 'q0000004-0000-0000-0000-000000000004',
'This line chart tracks the number of unique daily visitors to the website over time. It counts each visitor only once per day, providing insights into audience growth and website traffic patterns.',
NULL, 'pending', '22222222-2222-2222-2222-222222222222', NULL, 'openai', 'gpt-4', 16, 90),

-- Draft descriptions
('desc0005-0000-0000-0000-000000000005', 'q0000005-0000-0000-0000-000000000005',
'This bar chart ranks the top 10 landing pages by the number of page views they receive. Landing pages are the first pages visitors see when they arrive at your website, making this metric important for understanding entry point performance.',
NULL, 'draft', '33333333-3333-3333-3333-333333333333', NULL, 'openai', 'gpt-4', 14, 82),

('desc0006-0000-0000-0000-000000000006', 'q0000006-0000-0000-0000-000000000006',
'This trend line shows monthly revenue totals over time, calculated by summing all order values within each month. This is a key business metric for tracking growth and identifying seasonal patterns.',
NULL, 'draft', '33333333-3333-3333-3333-333333333333', NULL, 'anthropic', 'claude-3-opus', 20, 87);

-- =================== GENERATION JOBS ===================

-- Insert test generation jobs
INSERT INTO generation_jobs (id, type, status, progress, total_items, processed_items, parameters, created_by, started_at, completed_at) VALUES
-- Completed jobs
('job00001-0000-0000-0000-000000000001', 'bulk_generate', 'completed', 100, 25, 25, 
'{"collection_ids": ["c0000011-0000-0000-0000-000000000011"], "ai_provider": "openai", "ai_model": "gpt-4", "batch_size": 5}',
'22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '1 hour'),

('job00002-0000-0000-0000-000000000002', 'sync_metabase', 'completed', 100, 150, 150,
'{"connection_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "sync_type": "full"}',
'11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '4 hours'),

-- Running job
('job00003-0000-0000-0000-000000000003', 'bulk_generate', 'running', 60, 50, 30,
'{"question_ids": ["q0000007-0000-0000-0000-000000000007", "q0000008-0000-0000-0000-000000000008"], "ai_provider": "anthropic", "ai_model": "claude-3-opus", "batch_size": 10}',
'33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '30 minutes', NULL),

-- Failed job
('job00004-0000-0000-0000-000000000004', 'quality_analysis', 'failed', 25, 100, 25,
'{"analysis_type": "comprehensive", "collection_ids": ["c0000001-0000-0000-0000-000000000001"]}',
'22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '1 day', NULL);

-- Update the failed job with error message
UPDATE generation_jobs 
SET error_message = 'AI service rate limit exceeded. Please try again later.' 
WHERE id = 'job00004-0000-0000-0000-000000000004';

-- =================== AUDIT LOGS ===================

-- Insert sample audit log entries
INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, changed_by) VALUES
-- User login tracking
('users', '22222222-2222-2222-2222-222222222222', 'UPDATE', 
'{"last_login_at": null}', 
'{"last_login_at": "' || (NOW() - INTERVAL '1 hour')::text || '"}',
'22222222-2222-2222-2222-222222222222'),

-- Description approval
('descriptions', 'desc0001-0000-0000-0000-000000000001', 'UPDATE',
'{"status": "pending", "approved_by": null, "approved_text": null}',
'{"status": "approved", "approved_by": "11111111-1111-1111-1111-111111111111", "approved_text": "This chart shows the total monthly impressions across all marketing campaigns, providing insight into the overall reach and visibility of our marketing efforts."}',
'11111111-1111-1111-1111-111111111111'),

-- Job completion
('generation_jobs', 'job00001-0000-0000-0000-000000000001', 'UPDATE',
'{"status": "running", "progress": 80, "processed_items": 20, "completed_at": null}',
'{"status": "completed", "progress": 100, "processed_items": 25, "completed_at": "' || (NOW() - INTERVAL '1 hour')::text || '"}',
'22222222-2222-2222-2222-222222222222');

-- =================== VERIFICATION QUERIES ===================

-- These queries can be used to verify the seed data was inserted correctly
-- Uncomment to run verification during seeding

/*
SELECT 'Users' as table_name, count(*) as record_count FROM users
UNION ALL
SELECT 'Metabase Connections', count(*) FROM metabase_connections
UNION ALL  
SELECT 'Collections', count(*) FROM collections
UNION ALL
SELECT 'Dashboards', count(*) FROM dashboards
UNION ALL
SELECT 'Questions', count(*) FROM questions
UNION ALL
SELECT 'Descriptions', count(*) FROM descriptions
UNION ALL
SELECT 'Generation Jobs', count(*) FROM generation_jobs
UNION ALL
SELECT 'Audit Logs', count(*) FROM audit_logs;

-- Verify hierarchical relationships
SELECT 
    c1.name as parent_collection,
    c2.name as child_collection,
    c2.path as full_path
FROM collections c1
RIGHT JOIN collections c2 ON c1.id = c2.parent_id
ORDER BY c2.path;

-- Verify description status distribution
SELECT 
    status,
    count(*) as count,
    round(avg(quality_score), 1) as avg_quality_score
FROM descriptions 
GROUP BY status
ORDER BY status;
*/