# Generated TypeScript README
This README will guide you through the process of using the generated JavaScript SDK package for the connector `content`. It will also provide examples on how to use your generated SDK to call your Data Connect queries and mutations.

***NOTE:** This README is generated alongside the generated SDK. If you make changes to this file, they will be overwritten when the SDK is regenerated.*

# Table of Contents
- [**Overview**](#generated-javascript-readme)
- [**Accessing the connector**](#accessing-the-connector)
  - [*Connecting to the local Emulator*](#connecting-to-the-local-emulator)
- [**Queries**](#queries)
  - [*GetContentById*](#getcontentbyid)
  - [*GetContentBySlug*](#getcontentbyslug)
  - [*ListContent*](#listcontent)
  - [*ListAllContent*](#listallcontent)
  - [*SyncContentUpdates*](#synccontentupdates)
- [**Mutations**](#mutations)
  - [*UpsertContent*](#upsertcontent)
  - [*DeleteContent*](#deletecontent)

# Accessing the connector
A connector is a collection of Queries and Mutations. One SDK is generated for each connector - this SDK is generated for the connector `content`. You can find more information about connectors in the [Data Connect documentation](https://firebase.google.com/docs/data-connect#how-does).

You can use this generated SDK by importing from the package `@vrindavaani/dataconnect` as shown below. Both CommonJS and ESM imports are supported.

You can also follow the instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#set-client).

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@vrindavaani/dataconnect';

const dataConnect = getDataConnect(connectorConfig);
```

## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code.
You can also follow the emulator instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#instrument-clients).

```typescript
import { connectDataConnectEmulator, getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@vrindavaani/dataconnect';

const dataConnect = getDataConnect(connectorConfig);
connectDataConnectEmulator(dataConnect, 'localhost', 9399);
```

After it's initialized, you can call your Data Connect [queries](#queries) and [mutations](#mutations) from your generated SDK.

# Queries

There are two ways to execute a Data Connect Query using the generated Web SDK:
- Using a Query Reference function, which returns a `QueryRef`
  - The `QueryRef` can be used as an argument to `executeQuery()`, which will execute the Query and return a `QueryPromise`
- Using an action shortcut function, which returns a `QueryPromise`
  - Calling the action shortcut function will execute the Query and return a `QueryPromise`

The following is true for both the action shortcut function and the `QueryRef` function:
- The `QueryPromise` returned will resolve to the result of the Query once it has finished executing
- If the Query accepts arguments, both the action shortcut function and the `QueryRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Query
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `content` connector's generated functions to execute each query. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-queries).

## GetContentById
You can execute the `GetContentById` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getContentById(vars: GetContentByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetContentByIdData, GetContentByIdVariables>;

interface GetContentByIdRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetContentByIdVariables): QueryRef<GetContentByIdData, GetContentByIdVariables>;
}
export const getContentByIdRef: GetContentByIdRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getContentById(dc: DataConnect, vars: GetContentByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetContentByIdData, GetContentByIdVariables>;

interface GetContentByIdRef {
  ...
  (dc: DataConnect, vars: GetContentByIdVariables): QueryRef<GetContentByIdData, GetContentByIdVariables>;
}
export const getContentByIdRef: GetContentByIdRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getContentByIdRef:
```typescript
const name = getContentByIdRef.operationName;
console.log(name);
```

### Variables
The `GetContentById` query requires an argument of type `GetContentByIdVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetContentByIdVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetContentById` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetContentByIdData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetContentById`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getContentById, GetContentByIdVariables } from '@vrindavaani/dataconnect';

// The `GetContentById` query requires an argument of type `GetContentByIdVariables`:
const getContentByIdVars: GetContentByIdVariables = {
  id: ..., 
};

// Call the `getContentById()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getContentById(getContentByIdVars);
// Variables can be defined inline as well.
const { data } = await getContentById({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getContentById(dataConnect, getContentByIdVars);

console.log(data.content);

// Or, you can use the `Promise` API.
getContentById(getContentByIdVars).then((response) => {
  const data = response.data;
  console.log(data.content);
});
```

### Using `GetContentById`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getContentByIdRef, GetContentByIdVariables } from '@vrindavaani/dataconnect';

// The `GetContentById` query requires an argument of type `GetContentByIdVariables`:
const getContentByIdVars: GetContentByIdVariables = {
  id: ..., 
};

// Call the `getContentByIdRef()` function to get a reference to the query.
const ref = getContentByIdRef(getContentByIdVars);
// Variables can be defined inline as well.
const ref = getContentByIdRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getContentByIdRef(dataConnect, getContentByIdVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.content);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.content);
});
```

## GetContentBySlug
You can execute the `GetContentBySlug` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getContentBySlug(vars: GetContentBySlugVariables, options?: ExecuteQueryOptions): QueryPromise<GetContentBySlugData, GetContentBySlugVariables>;

interface GetContentBySlugRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetContentBySlugVariables): QueryRef<GetContentBySlugData, GetContentBySlugVariables>;
}
export const getContentBySlugRef: GetContentBySlugRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getContentBySlug(dc: DataConnect, vars: GetContentBySlugVariables, options?: ExecuteQueryOptions): QueryPromise<GetContentBySlugData, GetContentBySlugVariables>;

interface GetContentBySlugRef {
  ...
  (dc: DataConnect, vars: GetContentBySlugVariables): QueryRef<GetContentBySlugData, GetContentBySlugVariables>;
}
export const getContentBySlugRef: GetContentBySlugRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getContentBySlugRef:
```typescript
const name = getContentBySlugRef.operationName;
console.log(name);
```

### Variables
The `GetContentBySlug` query requires an argument of type `GetContentBySlugVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetContentBySlugVariables {
  slug: string;
}
```
### Return Type
Recall that executing the `GetContentBySlug` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetContentBySlugData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `GetContentBySlug`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getContentBySlug, GetContentBySlugVariables } from '@vrindavaani/dataconnect';

// The `GetContentBySlug` query requires an argument of type `GetContentBySlugVariables`:
const getContentBySlugVars: GetContentBySlugVariables = {
  slug: ..., 
};

// Call the `getContentBySlug()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getContentBySlug(getContentBySlugVars);
// Variables can be defined inline as well.
const { data } = await getContentBySlug({ slug: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getContentBySlug(dataConnect, getContentBySlugVars);

console.log(data.content);

// Or, you can use the `Promise` API.
getContentBySlug(getContentBySlugVars).then((response) => {
  const data = response.data;
  console.log(data.content);
});
```

### Using `GetContentBySlug`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getContentBySlugRef, GetContentBySlugVariables } from '@vrindavaani/dataconnect';

// The `GetContentBySlug` query requires an argument of type `GetContentBySlugVariables`:
const getContentBySlugVars: GetContentBySlugVariables = {
  slug: ..., 
};

// Call the `getContentBySlugRef()` function to get a reference to the query.
const ref = getContentBySlugRef(getContentBySlugVars);
// Variables can be defined inline as well.
const ref = getContentBySlugRef({ slug: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getContentBySlugRef(dataConnect, getContentBySlugVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.content);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.content);
});
```

## ListContent
You can execute the `ListContent` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listContent(vars: ListContentVariables, options?: ExecuteQueryOptions): QueryPromise<ListContentData, ListContentVariables>;

interface ListContentRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListContentVariables): QueryRef<ListContentData, ListContentVariables>;
}
export const listContentRef: ListContentRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listContent(dc: DataConnect, vars: ListContentVariables, options?: ExecuteQueryOptions): QueryPromise<ListContentData, ListContentVariables>;

interface ListContentRef {
  ...
  (dc: DataConnect, vars: ListContentVariables): QueryRef<ListContentData, ListContentVariables>;
}
export const listContentRef: ListContentRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listContentRef:
```typescript
const name = listContentRef.operationName;
console.log(name);
```

### Variables
The `ListContent` query requires an argument of type `ListContentVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListContentVariables {
  category: string;
  limit?: number | null;
}
```
### Return Type
Recall that executing the `ListContent` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListContentData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `ListContent`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listContent, ListContentVariables } from '@vrindavaani/dataconnect';

// The `ListContent` query requires an argument of type `ListContentVariables`:
const listContentVars: ListContentVariables = {
  category: ..., 
  limit: ..., // optional
};

// Call the `listContent()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listContent(listContentVars);
// Variables can be defined inline as well.
const { data } = await listContent({ category: ..., limit: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listContent(dataConnect, listContentVars);

console.log(data.contents);

// Or, you can use the `Promise` API.
listContent(listContentVars).then((response) => {
  const data = response.data;
  console.log(data.contents);
});
```

### Using `ListContent`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listContentRef, ListContentVariables } from '@vrindavaani/dataconnect';

// The `ListContent` query requires an argument of type `ListContentVariables`:
const listContentVars: ListContentVariables = {
  category: ..., 
  limit: ..., // optional
};

// Call the `listContentRef()` function to get a reference to the query.
const ref = listContentRef(listContentVars);
// Variables can be defined inline as well.
const ref = listContentRef({ category: ..., limit: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listContentRef(dataConnect, listContentVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.contents);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.contents);
});
```

## ListAllContent
You can execute the `ListAllContent` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listAllContent(vars?: ListAllContentVariables, options?: ExecuteQueryOptions): QueryPromise<ListAllContentData, ListAllContentVariables>;

interface ListAllContentRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars?: ListAllContentVariables): QueryRef<ListAllContentData, ListAllContentVariables>;
}
export const listAllContentRef: ListAllContentRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listAllContent(dc: DataConnect, vars?: ListAllContentVariables, options?: ExecuteQueryOptions): QueryPromise<ListAllContentData, ListAllContentVariables>;

interface ListAllContentRef {
  ...
  (dc: DataConnect, vars?: ListAllContentVariables): QueryRef<ListAllContentData, ListAllContentVariables>;
}
export const listAllContentRef: ListAllContentRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listAllContentRef:
```typescript
const name = listAllContentRef.operationName;
console.log(name);
```

### Variables
The `ListAllContent` query has an optional argument of type `ListAllContentVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListAllContentVariables {
  limit?: number | null;
}
```
### Return Type
Recall that executing the `ListAllContent` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListAllContentData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `ListAllContent`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listAllContent, ListAllContentVariables } from '@vrindavaani/dataconnect';

// The `ListAllContent` query has an optional argument of type `ListAllContentVariables`:
const listAllContentVars: ListAllContentVariables = {
  limit: ..., // optional
};

// Call the `listAllContent()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listAllContent(listAllContentVars);
// Variables can be defined inline as well.
const { data } = await listAllContent({ limit: ..., });
// Since all variables are optional for this query, you can omit the `ListAllContentVariables` argument.
const { data } = await listAllContent();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listAllContent(dataConnect, listAllContentVars);

console.log(data.contents);

// Or, you can use the `Promise` API.
listAllContent(listAllContentVars).then((response) => {
  const data = response.data;
  console.log(data.contents);
});
```

### Using `ListAllContent`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listAllContentRef, ListAllContentVariables } from '@vrindavaani/dataconnect';

// The `ListAllContent` query has an optional argument of type `ListAllContentVariables`:
const listAllContentVars: ListAllContentVariables = {
  limit: ..., // optional
};

// Call the `listAllContentRef()` function to get a reference to the query.
const ref = listAllContentRef(listAllContentVars);
// Variables can be defined inline as well.
const ref = listAllContentRef({ limit: ..., });
// Since all variables are optional for this query, you can omit the `ListAllContentVariables` argument.
const ref = listAllContentRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listAllContentRef(dataConnect, listAllContentVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.contents);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.contents);
});
```

## SyncContentUpdates
You can execute the `SyncContentUpdates` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
syncContentUpdates(vars: SyncContentUpdatesVariables, options?: ExecuteQueryOptions): QueryPromise<SyncContentUpdatesData, SyncContentUpdatesVariables>;

interface SyncContentUpdatesRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: SyncContentUpdatesVariables): QueryRef<SyncContentUpdatesData, SyncContentUpdatesVariables>;
}
export const syncContentUpdatesRef: SyncContentUpdatesRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
syncContentUpdates(dc: DataConnect, vars: SyncContentUpdatesVariables, options?: ExecuteQueryOptions): QueryPromise<SyncContentUpdatesData, SyncContentUpdatesVariables>;

interface SyncContentUpdatesRef {
  ...
  (dc: DataConnect, vars: SyncContentUpdatesVariables): QueryRef<SyncContentUpdatesData, SyncContentUpdatesVariables>;
}
export const syncContentUpdatesRef: SyncContentUpdatesRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the syncContentUpdatesRef:
```typescript
const name = syncContentUpdatesRef.operationName;
console.log(name);
```

### Variables
The `SyncContentUpdates` query requires an argument of type `SyncContentUpdatesVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface SyncContentUpdatesVariables {
  lastUpdated: TimestampString;
}
```
### Return Type
Recall that executing the `SyncContentUpdates` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `SyncContentUpdatesData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
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
```
### Using `SyncContentUpdates`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, syncContentUpdates, SyncContentUpdatesVariables } from '@vrindavaani/dataconnect';

// The `SyncContentUpdates` query requires an argument of type `SyncContentUpdatesVariables`:
const syncContentUpdatesVars: SyncContentUpdatesVariables = {
  lastUpdated: ..., 
};

// Call the `syncContentUpdates()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await syncContentUpdates(syncContentUpdatesVars);
// Variables can be defined inline as well.
const { data } = await syncContentUpdates({ lastUpdated: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await syncContentUpdates(dataConnect, syncContentUpdatesVars);

console.log(data.contents);

// Or, you can use the `Promise` API.
syncContentUpdates(syncContentUpdatesVars).then((response) => {
  const data = response.data;
  console.log(data.contents);
});
```

### Using `SyncContentUpdates`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, syncContentUpdatesRef, SyncContentUpdatesVariables } from '@vrindavaani/dataconnect';

// The `SyncContentUpdates` query requires an argument of type `SyncContentUpdatesVariables`:
const syncContentUpdatesVars: SyncContentUpdatesVariables = {
  lastUpdated: ..., 
};

// Call the `syncContentUpdatesRef()` function to get a reference to the query.
const ref = syncContentUpdatesRef(syncContentUpdatesVars);
// Variables can be defined inline as well.
const ref = syncContentUpdatesRef({ lastUpdated: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = syncContentUpdatesRef(dataConnect, syncContentUpdatesVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.contents);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.contents);
});
```

# Mutations

There are two ways to execute a Data Connect Mutation using the generated Web SDK:
- Using a Mutation Reference function, which returns a `MutationRef`
  - The `MutationRef` can be used as an argument to `executeMutation()`, which will execute the Mutation and return a `MutationPromise`
- Using an action shortcut function, which returns a `MutationPromise`
  - Calling the action shortcut function will execute the Mutation and return a `MutationPromise`

The following is true for both the action shortcut function and the `MutationRef` function:
- The `MutationPromise` returned will resolve to the result of the Mutation once it has finished executing
- If the Mutation accepts arguments, both the action shortcut function and the `MutationRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Mutation
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `content` connector's generated functions to execute each mutation. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-mutations).

## UpsertContent
You can execute the `UpsertContent` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
upsertContent(vars: UpsertContentVariables): MutationPromise<UpsertContentData, UpsertContentVariables>;

interface UpsertContentRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpsertContentVariables): MutationRef<UpsertContentData, UpsertContentVariables>;
}
export const upsertContentRef: UpsertContentRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
upsertContent(dc: DataConnect, vars: UpsertContentVariables): MutationPromise<UpsertContentData, UpsertContentVariables>;

interface UpsertContentRef {
  ...
  (dc: DataConnect, vars: UpsertContentVariables): MutationRef<UpsertContentData, UpsertContentVariables>;
}
export const upsertContentRef: UpsertContentRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the upsertContentRef:
```typescript
const name = upsertContentRef.operationName;
console.log(name);
```

### Variables
The `UpsertContent` mutation requires an argument of type `UpsertContentVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
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
```
### Return Type
Recall that executing the `UpsertContent` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpsertContentData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpsertContentData {
  content_upsert: Content_Key;
}
```
### Using `UpsertContent`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, upsertContent, UpsertContentVariables } from '@vrindavaani/dataconnect';

// The `UpsertContent` mutation requires an argument of type `UpsertContentVariables`:
const upsertContentVars: UpsertContentVariables = {
  id: ..., 
  title: ..., 
  sanskritText: ..., // optional
  hindiText: ..., // optional
  englishText: ..., // optional
  englishTranslation: ..., // optional
  category: ..., 
  description: ..., // optional
  contentText: ..., // optional
  tags: ..., // optional
  status: ..., // optional
  author: ..., // optional
  mediaLinks: ..., // optional
  audioUrl: ..., // optional
  imageUrls: ..., // optional
  videoUrls: ..., // optional
  slug: ..., 
};

// Call the `upsertContent()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await upsertContent(upsertContentVars);
// Variables can be defined inline as well.
const { data } = await upsertContent({ id: ..., title: ..., sanskritText: ..., hindiText: ..., englishText: ..., englishTranslation: ..., category: ..., description: ..., contentText: ..., tags: ..., status: ..., author: ..., mediaLinks: ..., audioUrl: ..., imageUrls: ..., videoUrls: ..., slug: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await upsertContent(dataConnect, upsertContentVars);

console.log(data.content_upsert);

// Or, you can use the `Promise` API.
upsertContent(upsertContentVars).then((response) => {
  const data = response.data;
  console.log(data.content_upsert);
});
```

### Using `UpsertContent`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, upsertContentRef, UpsertContentVariables } from '@vrindavaani/dataconnect';

// The `UpsertContent` mutation requires an argument of type `UpsertContentVariables`:
const upsertContentVars: UpsertContentVariables = {
  id: ..., 
  title: ..., 
  sanskritText: ..., // optional
  hindiText: ..., // optional
  englishText: ..., // optional
  englishTranslation: ..., // optional
  category: ..., 
  description: ..., // optional
  contentText: ..., // optional
  tags: ..., // optional
  status: ..., // optional
  author: ..., // optional
  mediaLinks: ..., // optional
  audioUrl: ..., // optional
  imageUrls: ..., // optional
  videoUrls: ..., // optional
  slug: ..., 
};

// Call the `upsertContentRef()` function to get a reference to the mutation.
const ref = upsertContentRef(upsertContentVars);
// Variables can be defined inline as well.
const ref = upsertContentRef({ id: ..., title: ..., sanskritText: ..., hindiText: ..., englishText: ..., englishTranslation: ..., category: ..., description: ..., contentText: ..., tags: ..., status: ..., author: ..., mediaLinks: ..., audioUrl: ..., imageUrls: ..., videoUrls: ..., slug: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = upsertContentRef(dataConnect, upsertContentVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.content_upsert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.content_upsert);
});
```

## DeleteContent
You can execute the `DeleteContent` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
deleteContent(vars: DeleteContentVariables): MutationPromise<DeleteContentData, DeleteContentVariables>;

interface DeleteContentRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteContentVariables): MutationRef<DeleteContentData, DeleteContentVariables>;
}
export const deleteContentRef: DeleteContentRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteContent(dc: DataConnect, vars: DeleteContentVariables): MutationPromise<DeleteContentData, DeleteContentVariables>;

interface DeleteContentRef {
  ...
  (dc: DataConnect, vars: DeleteContentVariables): MutationRef<DeleteContentData, DeleteContentVariables>;
}
export const deleteContentRef: DeleteContentRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteContentRef:
```typescript
const name = deleteContentRef.operationName;
console.log(name);
```

### Variables
The `DeleteContent` mutation requires an argument of type `DeleteContentVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteContentVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteContent` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteContentData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteContentData {
  content_delete?: Content_Key | null;
}
```
### Using `DeleteContent`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteContent, DeleteContentVariables } from '@vrindavaani/dataconnect';

// The `DeleteContent` mutation requires an argument of type `DeleteContentVariables`:
const deleteContentVars: DeleteContentVariables = {
  id: ..., 
};

// Call the `deleteContent()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteContent(deleteContentVars);
// Variables can be defined inline as well.
const { data } = await deleteContent({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteContent(dataConnect, deleteContentVars);

console.log(data.content_delete);

// Or, you can use the `Promise` API.
deleteContent(deleteContentVars).then((response) => {
  const data = response.data;
  console.log(data.content_delete);
});
```

### Using `DeleteContent`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteContentRef, DeleteContentVariables } from '@vrindavaani/dataconnect';

// The `DeleteContent` mutation requires an argument of type `DeleteContentVariables`:
const deleteContentVars: DeleteContentVariables = {
  id: ..., 
};

// Call the `deleteContentRef()` function to get a reference to the mutation.
const ref = deleteContentRef(deleteContentVars);
// Variables can be defined inline as well.
const ref = deleteContentRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteContentRef(dataConnect, deleteContentVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.content_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.content_delete);
});
```

