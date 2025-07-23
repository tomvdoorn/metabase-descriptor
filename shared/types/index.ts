// Shared TypeScript types for Metabase Description Generator
// This file provides end-to-end type safety across frontend and backend

// =================== CORE ENTITY TYPES ===================

export interface BaseEntity {
  id: string; // UUID
  createdAt: Date;
  updatedAt: Date;
}

export interface User extends BaseEntity {
  email: string;
  passwordHash: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  isActive: boolean;
  lastLoginAt?: Date;
}

export enum UserRole {
  ADMIN = 'admin',
  EDITOR = 'editor',
  VIEWER = 'viewer',
}

export interface MetabaseConnection extends BaseEntity {
  name: string;
  url: string;
  encryptedCredentials: string; // Encrypted API key or username/password
  isActive: boolean;
  lastSyncAt?: Date;
}

export interface Collection extends BaseEntity {
  metabaseId: number;
  connectionId: string;
  name: string;
  parentId?: string;
  path: string; // Hierarchical path like "/Marketing/Reports"
  description?: string;
}

export interface Dashboard extends BaseEntity {
  metabaseId: number;
  collectionId: string;
  name: string;
  description?: string;
  questionCount: number;
}

export interface Question extends BaseEntity {
  metabaseId: number;
  dashboardId: string;
  name: string;
  queryType: QueryType;
  queryData: Record<string, any>; // Raw query JSON from Metabase
  metadata?: QuestionMetadata;
  createdBy?: string;
}

export enum QueryType {
  QUERY = 'query',
  NATIVE = 'native',
  MODEL = 'model',
}

export interface QuestionMetadata {
  tables: string[];
  columns: string[];
  aggregations: string[];
  filters: string[];
  joins: string[];
  businessContext?: string;
}

export interface Description extends BaseEntity {
  questionId: string;
  generatedText?: string;
  approvedText?: string;
  status: DescriptionStatus;
  createdBy: string;
  approvedBy?: string;
  aiProvider?: string;
  aiModel?: string;
  generationCost?: number; // In cents
  qualityScore?: number; // 0-100
}

export enum DescriptionStatus {
  DRAFT = 'draft',
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}

export interface GenerationJob extends BaseEntity {
  type: JobType;
  status: JobStatus;
  progress: number; // 0-100
  totalItems: number;
  processedItems: number;
  errorMessage?: string;
  createdBy: string;
  parameters: Record<string, any>;
}

export enum JobType {
  BULK_GENERATE = 'bulk_generate',
  SYNC_METABASE = 'sync_metabase',
  QUALITY_ANALYSIS = 'quality_analysis',
}

export enum JobStatus {
  PENDING = 'pending',
  RUNNING = 'running',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

// =================== API REQUEST/RESPONSE TYPES ===================

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: {
    message: string;
    statusCode: number;
    timestamp: string;
    path?: string;
    method?: string;
  };
  pagination?: PaginationMeta;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface PaginationQuery {
  page?: number;
  limit?: number;
  sort?: string;
  order?: 'asc' | 'desc';
}

// Authentication Types
export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  user: Omit<User, 'passwordHash'>;
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface RefreshTokenResponse {
  accessToken: string;
  expiresIn: number;
}

// Collection Types
export interface CollectionTreeNode {
  id: string;
  name: string;
  path: string;
  children: CollectionTreeNode[];
  dashboardCount: number;
  questionCount: number;
  descriptionProgress: {
    total: number;
    approved: number;
    pending: number;
    draft: number;
  };
}

export interface CollectionListQuery extends PaginationQuery {
  search?: string;
  parentId?: string;
}

// Question Types
export interface QuestionListQuery extends PaginationQuery {
  dashboardId?: string;
  status?: DescriptionStatus;
  search?: string;
  queryType?: QueryType;
}

export interface QuestionWithDescription extends Question {
  description?: Description;
  dashboard: Pick<Dashboard, 'id' | 'name'>;
  collection: Pick<Collection, 'id' | 'name' | 'path'>;
}

// Description Generation Types
export interface GenerateDescriptionRequest {
  questionId: string;
  useTemplate?: boolean;
  customPrompt?: string;
  aiProvider?: 'openai' | 'anthropic';
  aiModel?: string;
}

export interface GenerateDescriptionResponse {
  description: Description;
  generationMetrics: {
    tokensUsed: number;
    cost: number;
    responseTime: number;
    qualityScore: number;
  };
}

export interface BulkGenerateRequest {
  questionIds: string[];
  filters?: {
    dashboardId?: string;
    collectionId?: string;
    status?: DescriptionStatus;
  };
  options: {
    useTemplate: boolean;
    customPrompt?: string;
    aiProvider: 'openai' | 'anthropic';
    aiModel: string;
    batchSize: number;
  };
}

export interface UpdateDescriptionRequest {
  approvedText?: string;
  status?: DescriptionStatus;
}

// Job Management Types
export interface JobListQuery extends PaginationQuery {
  type?: JobType;
  status?: JobStatus;
  createdBy?: string;
}

export interface CreateJobRequest {
  type: JobType;
  parameters: Record<string, any>;
}

// =================== FRONTEND-SPECIFIC TYPES ===================

export interface TreeViewProps {
  collections: CollectionTreeNode[];
  selectedCollectionId?: string;
  onCollectionSelect: (collectionId: string) => void;
  onQuestionSelect: (questionId: string) => void;
  expandedNodes: Set<string>;
  onNodeToggle: (nodeId: string) => void;
}

export interface DescriptionEditorProps {
  question: QuestionWithDescription;
  onSave: (description: UpdateDescriptionRequest) => Promise<void>;
  onGenerate: (request: GenerateDescriptionRequest) => Promise<void>;
  isGenerating: boolean;
  canApprove: boolean;
}

export interface BulkOperationModalProps {
  isOpen: boolean;
  onClose: () => void;
  selectedQuestions: string[];
  onBulkGenerate: (request: BulkGenerateRequest) => Promise<void>;
}

// =================== AI SERVICE TYPES ===================

export interface AIProvider {
  name: 'openai' | 'anthropic';
  models: string[];
  maxTokens: number;
  costPerToken: number; // In cents
}

export interface AIGenerationRequest {
  provider: 'openai' | 'anthropic';
  model: string;
  prompt: string;
  maxTokens: number;
  temperature: number;
  questionContext: {
    name: string;
    queryType: QueryType;
    queryData: Record<string, any>;
    metadata?: QuestionMetadata;
  };
}

export interface AIGenerationResponse {
  text: string;
  tokensUsed: number;
  cost: number;
  responseTime: number;
  provider: string;
  model: string;
}

// =================== CONFIGURATION TYPES ===================

export interface AppConfig {
  database: {
    url: string;
    ssl: boolean;
    maxConnections: number;
  };
  auth: {
    jwtSecret: string;
    jwtRefreshSecret: string;
    accessTokenExpiry: string;
    refreshTokenExpiry: string;
  };
  ai: {
    defaultProvider: 'openai' | 'anthropic';
    providers: {
      openai: {
        apiKey: string;
        defaultModel: string;
        maxTokens: number;
        temperature: number;
      };
      anthropic: {
        apiKey: string;
        defaultModel: string;
        maxTokens: number;
        temperature: number;
      };
    };
  };
  rateLimit: {
    windowMs: number;
    maxRequests: number;
  };
  features: {
    bulkOperations: boolean;
    aiGeneration: boolean;
    realTimeSync: boolean;
  };
}

// =================== UTILITY TYPES ===================

export type Omit<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;
export type Partial<T> = { [P in keyof T]?: T[P] };
export type Required<T> = { [P in keyof T]-?: T[P] };

export type WithTimestamps<T> = T & {
  createdAt: Date;
  updatedAt: Date;
};

export type WithUser<T> = T & {
  createdBy: string;
};

export type WithPagination<T> = {
  data: T[];
  pagination: PaginationMeta;
};

// =================== ERROR TYPES ===================

export interface ValidationError {
  field: string;
  message: string;
  value?: any;
}

export interface ApiError extends Error {
  statusCode: number;
  isOperational: boolean;
  validationErrors?: ValidationError[];
}

// =================== EXPORTS ===================

export * from './database';
export * from './api';
export * from './frontend';