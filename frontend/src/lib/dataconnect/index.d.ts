import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, ExecuteQueryOptions, MutationRef, MutationPromise } from 'firebase/data-connect';

export const connectorConfig: ConnectorConfig;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;


export enum ContentStatus {
  DRAFT = "DRAFT",
  PUBLISHED = "PUBLISHED",
  ARCHIVED = "ARCHIVED",
};



export interface Content_Key {
  id: UUIDString;
  __typename?: 'Content_Key';
}

export interface DeleteContentData {
  content_delete?: Content_Key | null;
}

export interface DeleteContentVariables {
  id: UUIDString;
}

export interface GetContentByIdData {
  content?: {
    id: UUIDString;
    title: string;
    sanskritText?: string | null;
    hindiText?: string | null;
    englishText?: string | null;
    englishTranslation?: string | null;
    category: string;
    description?: string | null;
    contentText?: string | null;
    tags?: string[] | null;
    status: ContentStatus;
    author?: string | null;
    mediaLinks?: unknown | null;
    audioUrl?: string | null;
    imageUrls?: string[] | null;
    videoUrls?: string[] | null;
    slug: string;
    createdAt: TimestampString;
    updatedAt: TimestampString;
  } & Content_Key;
}

export interface GetContentByIdVariables {
  id: UUIDString;
}

export interface GetContentBySlugData {
  content?: {
    id: UUIDString;
    title: string;
    sanskritText?: string | null;
    hindiText?: string | null;
    englishText?: string | null;
    englishTranslation?: string | null;
    category: string;
    description?: string | null;
    contentText?: string | null;
    tags?: string[] | null;
    status: ContentStatus;
    author?: string | null;
    mediaLinks?: unknown | null;
    audioUrl?: string | null;
    imageUrls?: string[] | null;
    videoUrls?: string[] | null;
    slug: string;
    createdAt: TimestampString;
    updatedAt: TimestampString;
  } & Content_Key;
}

export interface GetContentBySlugVariables {
  slug: string;
}

export interface ListAllContentData {
  contents: ({
    id: UUIDString;
    title: string;
    sanskritText?: string | null;
    hindiText?: string | null;
    englishText?: string | null;
    englishTranslation?: string | null;
    category: string;
    description?: string | null;
    contentText?: string | null;
    tags?: string[] | null;
    status: ContentStatus;
    author?: string | null;
    mediaLinks?: unknown | null;
    audioUrl?: string | null;
    imageUrls?: string[] | null;
    videoUrls?: string[] | null;
    slug: string;
    createdAt: TimestampString;
    updatedAt: TimestampString;
  } & Content_Key)[];
}

export interface ListAllContentVariables {
  limit?: number | null;
}

export interface ListContentData {
  contents: ({
    id: UUIDString;
    title: string;
    sanskritText?: string | null;
    hindiText?: string | null;
    englishText?: string | null;
    englishTranslation?: string | null;
    category: string;
    description?: string | null;
    contentText?: string | null;
    tags?: string[] | null;
    status: ContentStatus;
    author?: string | null;
    mediaLinks?: unknown | null;
    audioUrl?: string | null;
    imageUrls?: string[] | null;
    videoUrls?: string[] | null;
    slug: string;
    createdAt: TimestampString;
    updatedAt: TimestampString;
  } & Content_Key)[];
}

export interface ListContentVariables {
  category: string;
  limit?: number | null;
}

export interface SyncContentUpdatesData {
  contents: ({
    id: UUIDString;
    title: string;
    sanskritText?: string | null;
    hindiText?: string | null;
    englishText?: string | null;
    englishTranslation?: string | null;
    category: string;
    description?: string | null;
    contentText?: string | null;
    tags?: string[] | null;
    status: ContentStatus;
    author?: string | null;
    mediaLinks?: unknown | null;
    audioUrl?: string | null;
    imageUrls?: string[] | null;
    videoUrls?: string[] | null;
    slug: string;
    createdAt: TimestampString;
    updatedAt: TimestampString;
  } & Content_Key)[];
}

export interface SyncContentUpdatesVariables {
  lastUpdated: TimestampString;
}

export interface UpsertContentData {
  content_upsert: Content_Key;
}

export interface UpsertContentVariables {
  id: UUIDString;
  title: string;
  sanskritText?: string | null;
  hindiText?: string | null;
  englishText?: string | null;
  englishTranslation?: string | null;
  category: string;
  description?: string | null;
  contentText?: string | null;
  tags?: string[] | null;
  status?: ContentStatus | null;
  author?: string | null;
  mediaLinks?: unknown | null;
  audioUrl?: string | null;
  imageUrls?: string[] | null;
  videoUrls?: string[] | null;
  slug: string;
}

interface UpsertContentRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpsertContentVariables): MutationRef<UpsertContentData, UpsertContentVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpsertContentVariables): MutationRef<UpsertContentData, UpsertContentVariables>;
  operationName: string;
}
export const upsertContentRef: UpsertContentRef;

export function upsertContent(vars: UpsertContentVariables): MutationPromise<UpsertContentData, UpsertContentVariables>;
export function upsertContent(dc: DataConnect, vars: UpsertContentVariables): MutationPromise<UpsertContentData, UpsertContentVariables>;

interface DeleteContentRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteContentVariables): MutationRef<DeleteContentData, DeleteContentVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteContentVariables): MutationRef<DeleteContentData, DeleteContentVariables>;
  operationName: string;
}
export const deleteContentRef: DeleteContentRef;

export function deleteContent(vars: DeleteContentVariables): MutationPromise<DeleteContentData, DeleteContentVariables>;
export function deleteContent(dc: DataConnect, vars: DeleteContentVariables): MutationPromise<DeleteContentData, DeleteContentVariables>;

interface GetContentByIdRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetContentByIdVariables): QueryRef<GetContentByIdData, GetContentByIdVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetContentByIdVariables): QueryRef<GetContentByIdData, GetContentByIdVariables>;
  operationName: string;
}
export const getContentByIdRef: GetContentByIdRef;

export function getContentById(vars: GetContentByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetContentByIdData, GetContentByIdVariables>;
export function getContentById(dc: DataConnect, vars: GetContentByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetContentByIdData, GetContentByIdVariables>;

interface GetContentBySlugRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetContentBySlugVariables): QueryRef<GetContentBySlugData, GetContentBySlugVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetContentBySlugVariables): QueryRef<GetContentBySlugData, GetContentBySlugVariables>;
  operationName: string;
}
export const getContentBySlugRef: GetContentBySlugRef;

export function getContentBySlug(vars: GetContentBySlugVariables, options?: ExecuteQueryOptions): QueryPromise<GetContentBySlugData, GetContentBySlugVariables>;
export function getContentBySlug(dc: DataConnect, vars: GetContentBySlugVariables, options?: ExecuteQueryOptions): QueryPromise<GetContentBySlugData, GetContentBySlugVariables>;

interface ListContentRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListContentVariables): QueryRef<ListContentData, ListContentVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: ListContentVariables): QueryRef<ListContentData, ListContentVariables>;
  operationName: string;
}
export const listContentRef: ListContentRef;

export function listContent(vars: ListContentVariables, options?: ExecuteQueryOptions): QueryPromise<ListContentData, ListContentVariables>;
export function listContent(dc: DataConnect, vars: ListContentVariables, options?: ExecuteQueryOptions): QueryPromise<ListContentData, ListContentVariables>;

interface ListAllContentRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars?: ListAllContentVariables): QueryRef<ListAllContentData, ListAllContentVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars?: ListAllContentVariables): QueryRef<ListAllContentData, ListAllContentVariables>;
  operationName: string;
}
export const listAllContentRef: ListAllContentRef;

export function listAllContent(vars?: ListAllContentVariables, options?: ExecuteQueryOptions): QueryPromise<ListAllContentData, ListAllContentVariables>;
export function listAllContent(dc: DataConnect, vars?: ListAllContentVariables, options?: ExecuteQueryOptions): QueryPromise<ListAllContentData, ListAllContentVariables>;

interface SyncContentUpdatesRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: SyncContentUpdatesVariables): QueryRef<SyncContentUpdatesData, SyncContentUpdatesVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: SyncContentUpdatesVariables): QueryRef<SyncContentUpdatesData, SyncContentUpdatesVariables>;
  operationName: string;
}
export const syncContentUpdatesRef: SyncContentUpdatesRef;

export function syncContentUpdates(vars: SyncContentUpdatesVariables, options?: ExecuteQueryOptions): QueryPromise<SyncContentUpdatesData, SyncContentUpdatesVariables>;
export function syncContentUpdates(dc: DataConnect, vars: SyncContentUpdatesVariables, options?: ExecuteQueryOptions): QueryPromise<SyncContentUpdatesData, SyncContentUpdatesVariables>;

