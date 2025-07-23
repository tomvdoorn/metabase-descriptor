// Database-specific types and schemas for Metabase Description Generator

// =================== DATABASE SCHEMA TYPES ===================

export interface DatabaseConnection {
  host: string;
  port: number;
  database: string;
  username: string;
  password: string;
  ssl: boolean;
  maxConnections: number;
  idleTimeoutMillis: number;
  connectionTimeoutMillis: number;
}

export interface MigrationFile {
  version: string;
  name: string;
  up: string;
  down: string;
  checksum: string;
  executedAt?: Date;
}

// =================== TABLE SCHEMAS ===================

// Users table schema
export interface UserSchema {
  id: string; // UUID PRIMARY KEY
  email: string; // UNIQUE NOT NULL
  password_hash: string; // NOT NULL
  first_name: string; // NOT NULL
  last_name: string; // NOT NULL
  role: 'admin' | 'editor' | 'viewer'; // NOT NULL
  is_active: boolean; // DEFAULT true
  last_login_at?: Date;
  created_at: Date; // DEFAULT NOW()
  updated_at: Date; // DEFAULT NOW()
}

// Metabase connections table schema
export interface MetabaseConnectionSchema {
  id: string; // UUID PRIMARY KEY
  name: string; // NOT NULL UNIQUE
  url: string; // NOT NULL
  encrypted_credentials: string; // NOT NULL (encrypted JSON)
  is_active: boolean; // DEFAULT true
  last_sync_at?: Date;
  created_at: Date; // DEFAULT NOW()
  updated_at: Date; // DEFAULT NOW()
}

// Collections table schema
export interface CollectionSchema {
  id: string; // UUID PRIMARY KEY
  metabase_id: number; // NOT NULL
  connection_id: string; // FOREIGN KEY REFERENCES metabase_connections(id)
  name: string; // NOT NULL
  parent_id?: string; // FOREIGN KEY REFERENCES collections(id)
  path: string; // NOT NULL (hierarchical path)
  description?: string;
  created_at: Date; // DEFAULT NOW()
  updated_at: Date; // DEFAULT NOW()
}

// Dashboards table schema
export interface DashboardSchema {
  id: string; // UUID PRIMARY KEY
  metabase_id: number; // NOT NULL
  collection_id: string; // FOREIGN KEY REFERENCES collections(id)
  name: string; // NOT NULL
  description?: string;
  created_at: Date; // DEFAULT NOW()
  updated_at: Date; // DEFAULT NOW()
}

// Questions table schema
export interface QuestionSchema {
  id: string; // UUID PRIMARY KEY
  metabase_id: number; // NOT NULL
  dashboard_id: string; // FOREIGN KEY REFERENCES dashboards(id)
  name: string; // NOT NULL
  query_type: 'query' | 'native' | 'model'; // NOT NULL
  query_data: Record<string, any>; // JSONB NOT NULL
  metadata?: Record<string, any>; // JSONB
  created_by?: string; // FOREIGN KEY REFERENCES users(id)
  created_at: Date; // DEFAULT NOW()
  updated_at: Date; // DEFAULT NOW()
}

// Descriptions table schema
export interface DescriptionSchema {
  id: string; // UUID PRIMARY KEY
  question_id: string; // FOREIGN KEY REFERENCES questions(id)
  generated_text?: string;
  approved_text?: string;
  status: 'draft' | 'pending' | 'approved' | 'rejected'; // NOT NULL DEFAULT 'draft'
  created_by: string; // FOREIGN KEY REFERENCES users(id)
  approved_by?: string; // FOREIGN KEY REFERENCES users(id)
  ai_provider?: string; // 'openai' | 'anthropic'
  ai_model?: string;
  generation_cost?: number; // In cents
  quality_score?: number; // 0-100
  created_at: Date; // DEFAULT NOW()
  updated_at: Date; // DEFAULT NOW()
}

// Generation jobs table schema
export interface GenerationJobSchema {
  id: string; // UUID PRIMARY KEY
  type: 'bulk_generate' | 'sync_metabase' | 'quality_analysis'; // NOT NULL
  status: 'pending' | 'running' | 'completed' | 'failed' | 'cancelled'; // NOT NULL DEFAULT 'pending'
  progress: number; // NOT NULL DEFAULT 0 CHECK (progress >= 0 AND progress <= 100)
  total_items: number; // NOT NULL DEFAULT 0
  processed_items: number; // NOT NULL DEFAULT 0
  error_message?: string;
  parameters: Record<string, any>; // JSONB NOT NULL
  created_by: string; // FOREIGN KEY REFERENCES users(id)
  started_at?: Date;
  completed_at?: Date;
  created_at: Date; // DEFAULT NOW()
  updated_at: Date; // DEFAULT NOW()
}

// =================== INDEX DEFINITIONS ===================

export interface DatabaseIndex {
  name: string;
  table: string;
  columns: string[];
  unique?: boolean;
  partial?: string; // Partial index condition
}

export const DatabaseIndexes: DatabaseIndex[] = [
  // User indexes
  { name: 'idx_users_email', table: 'users', columns: ['email'], unique: true },
  { name: 'idx_users_role_active', table: 'users', columns: ['role', 'is_active'] },

  // Connection indexes
  { name: 'idx_connections_name', table: 'metabase_connections', columns: ['name'], unique: true },
  { name: 'idx_connections_active', table: 'metabase_connections', columns: ['is_active'] },

  // Collection indexes
  { name: 'idx_collections_metabase_connection', table: 'collections', columns: ['metabase_id', 'connection_id'], unique: true },
  { name: 'idx_collections_parent_id', table: 'collections', columns: ['parent_id'] },
  { name: 'idx_collections_path', table: 'collections', columns: ['path'] },

  // Dashboard indexes
  { name: 'idx_dashboards_metabase_collection', table: 'dashboards', columns: ['metabase_id', 'collection_id'], unique: true },
  { name: 'idx_dashboards_collection_id', table: 'dashboards', columns: ['collection_id'] },

  // Question indexes
  { name: 'idx_questions_metabase_dashboard', table: 'questions', columns: ['metabase_id', 'dashboard_id'], unique: true },
  { name: 'idx_questions_dashboard_id', table: 'questions', columns: ['dashboard_id'] },
  { name: 'idx_questions_query_type', table: 'questions', columns: ['query_type'] },
  { name: 'idx_questions_created_by', table: 'questions', columns: ['created_by'] },

  // Description indexes
  { name: 'idx_descriptions_question_id', table: 'descriptions', columns: ['question_id'], unique: true },
  { name: 'idx_descriptions_status', table: 'descriptions', columns: ['status'] },
  { name: 'idx_descriptions_created_by', table: 'descriptions', columns: ['created_by'] },
  { name: 'idx_descriptions_approved_by', table: 'descriptions', columns: ['approved_by'] },
  { name: 'idx_descriptions_status_created', table: 'descriptions', columns: ['status', 'created_at'] },

  // Job indexes
  { name: 'idx_jobs_status_created', table: 'generation_jobs', columns: ['status', 'created_at'] },
  { name: 'idx_jobs_type_status', table: 'generation_jobs', columns: ['type', 'status'] },
  { name: 'idx_jobs_created_by', table: 'generation_jobs', columns: ['created_by'] }
];

// =================== DATABASE QUERY TYPES ===================

export interface QueryOptions {
  limit?: number;
  offset?: number;
  orderBy?: string;
  orderDirection?: 'ASC' | 'DESC';
  where?: Record<string, any>;
  include?: string[]; // For JOIN operations
}

export interface TransactionOptions {
  isolationLevel?: 'READ_UNCOMMITTED' | 'READ_COMMITTED' | 'REPEATABLE_READ' | 'SERIALIZABLE';
  timeout?: number; // milliseconds
}

export interface BulkInsertOptions {
  batchSize?: number;
  onConflict?: 'ignore' | 'update' | 'error';
  updateColumns?: string[];
}

// =================== DATABASE REPOSITORY INTERFACES ===================

export interface BaseRepository<T> {
  findById(id: string): Promise<T | null>;
  findMany(options?: QueryOptions): Promise<T[]>;
  findOne(where: Partial<T>): Promise<T | null>;
  create(data: Omit<T, 'id' | 'createdAt' | 'updatedAt'>): Promise<T>;
  update(id: string, data: Partial<T>): Promise<T>;
  delete(id: string): Promise<boolean>;
  count(where?: Partial<T>): Promise<number>;
  exists(where: Partial<T>): Promise<boolean>;
}

export interface UserRepository extends BaseRepository<UserSchema> {
  findByEmail(email: string): Promise<UserSchema | null>;
  findByRole(role: string): Promise<UserSchema[]>;
  updateLastLoginAt(id: string): Promise<void>;
}

export interface MetabaseConnectionRepository extends BaseRepository<MetabaseConnectionSchema> {
  findByName(name: string): Promise<MetabaseConnectionSchema | null>;
  findActive(): Promise<MetabaseConnectionSchema[]>;
  updateLastSyncAt(id: string): Promise<void>;
}

export interface CollectionRepository extends BaseRepository<CollectionSchema> {
  findByPath(path: string): Promise<CollectionSchema | null>;
  findByParentId(parentId: string): Promise<CollectionSchema[]>;
  findTreeStructure(connectionId: string): Promise<CollectionSchema[]>;
  updatePath(id: string, newPath: string): Promise<void>;
}

export interface QuestionRepository extends BaseRepository<QuestionSchema> {
  findByDashboardId(dashboardId: string): Promise<QuestionSchema[]>;
  findWithDescription(id: string): Promise<QuestionSchema & { description?: DescriptionSchema }>;
  findByQueryType(queryType: string): Promise<QuestionSchema[]>;
  bulkCreate(questions: Omit<QuestionSchema, 'id' | 'createdAt' | 'updatedAt'>[]): Promise<QuestionSchema[]>;
}

export interface DescriptionRepository extends BaseRepository<DescriptionSchema> {
  findByQuestionId(questionId: string): Promise<DescriptionSchema | null>;
  findByStatus(status: string): Promise<DescriptionSchema[]>;
  updateStatus(id: string, status: string, approvedBy?: string): Promise<void>;
  getProgressByCollection(collectionId: string): Promise<{
    total: number;
    approved: number;
    pending: number;
    draft: number;
  }>;
}

export interface GenerationJobRepository extends BaseRepository<GenerationJobSchema> {
  findByType(type: string): Promise<GenerationJobSchema[]>;
  findByStatus(status: string): Promise<GenerationJobSchema[]>;
  updateProgress(id: string, progress: number, processedItems: number): Promise<void>;
  markAsCompleted(id: string): Promise<void>;
  markAsFailed(id: string, errorMessage: string): Promise<void>;
}

// =================== DATABASE CONNECTION POOL ===================

export interface DatabasePool {
  query<T = any>(text: string, params?: any[]): Promise<{ rows: T[]; rowCount: number }>;
  transaction<T>(callback: (client: DatabaseClient) => Promise<T>): Promise<T>;
  end(): Promise<void>;
  totalCount: number;
  idleCount: number;
  waitingCount: number;
}

export interface DatabaseClient {
  query<T = any>(text: string, params?: any[]): Promise<{ rows: T[]; rowCount: number }>;
  release(): void;
}

// =================== MIGRATION SYSTEM ===================

export interface MigrationRunner {
  up(): Promise<void>;
  down(): Promise<void>;
  pending(): Promise<MigrationFile[]>;
  executed(): Promise<MigrationFile[]>;
  latest(): Promise<void>;
  rollback(steps?: number): Promise<void>;
}

export interface SeedRunner {
  run(): Promise<void>;
  runFile(filename: string): Promise<void>;
}

// =================== DATABASE HEALTH CHECK ===================

export interface DatabaseHealth {
  connected: boolean;
  latency: number; // milliseconds
  activeConnections: number;
  idleConnections: number;
  totalConnections: number;
  lastError?: string;
  timestamp: Date;
}