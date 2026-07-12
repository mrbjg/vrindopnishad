# Data Fetching and Routing Flow Report

Since disabling **Firebase Data Connect** to avoid database egress quotas and costs, the application employs a highly efficient local-first caching architecture. Below is the precise map of how data is fetched, cached, and served during different phases of the application.

---

## 1. Build-Time Data Flow (`npm run build`)

During static page generation, Next.js worker processes call `ensureDataLoaded()` to resolve the content database. The flow is as follows:

```mermaid
graph TD
    A["npm run build / next build"] --> B["ensureDataLoaded()"]
    B --> C{"Is contentCache in-memory?"}
    C -- Yes --> D["Return in-memory contentCache"]
    C -- No --> E{"Is processed_cache.json present?"}
    
    E -- Yes --> F["Load flat processed cache from file"]
    F --> G["Parse verses and saintsRaw"]
    G --> H["Build relations (saints, books, ragas)"]
    H --> I["Set global.contentCache & Return"]
    
    E -- No --> J["Rebuild Cache from Scratch"]
    J --> K["fetchAllFromDataConnect()"]
    K --> L["BLOCKED: returns []"]
    L --> M["loadLocalJSONFallback()"]
    
    M --> N["Read public/data/content_backup.json (~8,075 items)"]
    N --> O["Read data/saints_formatted.json"]
    O --> P["Clean categories & generate slugs"]
    P --> Q["Build relational database graph"]
    Q --> R["Save to data/processed_cache.json (Fast startup for next workers)"]
    R --> S["Set global.contentCache & Return"]
```

---

## 2. API Route & Serverless Handler Data Flow (`/content/[slug]`)

When crawlers, search engines, or users request a specific content page dynamically (e.g. via `/content/[slug]` serverless routes handled by Vercel), the application retrieves the details dynamically:

```mermaid
graph TD
    A["Vercel Serverless Request (/content/slug)"] --> B["handler(req, res) in [slug].js"]
    B --> C["Query Supabase REST API by Slug"]
    C --> D{"Content found?"}
    
    D -- Yes --> G["Generate HTML with meta tags & hydrate"]
    D -- No --> E["Query Supabase REST API by Title Match"]
    E --> F{"Content found?"}
    
    F -- Yes --> G
    F -- No --> H["Read local fallback: data/vrindavaani_content.json"]
    H --> I{"Slug match in file?"}
    
    I -- Yes --> G
    I -- No --> J["Render default Vrindopnishad metadata"]
```

### Data Sources & Source of Truth:
1. **Supabase Database:** Acts as the active cloud source of truth for dynamic queries.
2. **Local Backup (`public/data/content_backup.json` & `vrindavaani_content.json`):** Acts as the offline local fail-safe, containing the complete corpus of ~8,075 items.
3. **Data Connect:** Fully bypassed (queries are blocked at the code level and return `[]`).

---

## Summary of Optimization Benefits
- **Zero Firebase Egress:** Build workers compile the site using local cache files, entirely eliminating billing and API rate limits.
- **Fast Build Times:** Local JSON parses in milliseconds, compared to minutes of slow network queries.
- **Resiliency:** If the Supabase API is down or rate-limited, the system falls back gracefully to local files to serve SEO meta tags.
