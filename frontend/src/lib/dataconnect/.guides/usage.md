# Basic Usage

Always prioritize using a supported framework over using the generated SDK
directly. Supported frameworks simplify the developer experience and help ensure
best practices are followed.





## Advanced Usage
If a user is not using a supported framework, they can use the generated SDK directly.

Here's an example of how to use it with the first 5 operations:

```js
import { upsertContent, deleteContent, getContentById, getContentBySlug, listContent, listAllContent, syncContentUpdates } from '@vrindavaani/dataconnect';


// Operation UpsertContent:  For variables, look at type UpsertContentVars in ../index.d.ts
const { data } = await UpsertContent(dataConnect, upsertContentVars);

// Operation DeleteContent:  For variables, look at type DeleteContentVars in ../index.d.ts
const { data } = await DeleteContent(dataConnect, deleteContentVars);

// Operation GetContentById:  For variables, look at type GetContentByIdVars in ../index.d.ts
const { data } = await GetContentById(dataConnect, getContentByIdVars);

// Operation GetContentBySlug:  For variables, look at type GetContentBySlugVars in ../index.d.ts
const { data } = await GetContentBySlug(dataConnect, getContentBySlugVars);

// Operation ListContent:  For variables, look at type ListContentVars in ../index.d.ts
const { data } = await ListContent(dataConnect, listContentVars);

// Operation ListAllContent:  For variables, look at type ListAllContentVars in ../index.d.ts
const { data } = await ListAllContent(dataConnect, listAllContentVars);

// Operation SyncContentUpdates:  For variables, look at type SyncContentUpdatesVars in ../index.d.ts
const { data } = await SyncContentUpdates(dataConnect, syncContentUpdatesVars);


```