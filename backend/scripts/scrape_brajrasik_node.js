const fs = require('fs');
const path = require('path');

const HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Accept': 'application/json, text/plain, */*',
  'Referer': 'https://www.brajrasik.org/tag/all',
  'Accept-Language': 'en-US,en;q=0.9',
  'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
  'sec-ch-ua-mobile': '?0',
  'sec-ch-ua-platform': '"macOS"',
  'sec-fetch-dest': 'empty',
  'sec-fetch-mode': 'cors',
  'sec-fetch-site': 'same-origin',
  'Origin': 'https://www.brajrasik.org'
};

async function fetchBatch(skip, limit) {
  const url = `https://www.brajrasik.org/api/articles?type=all&limit=${limit}&skip=${skip}&sort_type=createdAt&sort_direction=-1&index=false`;
  const res = await fetch(url, { headers: HEADERS });
  if (!res.ok) {
    throw new Error(`HTTP Error ${res.status}: ${res.statusText}`);
  }
  return res.json();
}

async function scrapeAll() {
  const limit = 50;
  const filepath = path.join(__dirname, 'articles_raw.json');
  let allArticles = [];
  
  if (fs.existsSync(filepath)) {
    try {
      const raw = fs.readFileSync(filepath, 'utf8');
      allArticles = JSON.parse(raw);
      if (!Array.isArray(allArticles)) {
        allArticles = [];
      } else {
        console.log(`[Scraper] Found existing articles_raw.json with ${allArticles.length} items. Resuming...`);
      }
    } catch (e) {
      allArticles = [];
    }
  }

  let skip = allArticles.length;
  let totalCount = null;

  console.log("🚀 Starting Brajrasik Articles Scraper...");

  while (true) {
    try {
      console.log(`[Scraper] Fetching articles with skip=${skip}, limit=${limit}...`);
      const payload = await fetchBatch(skip, limit);
      
      if (totalCount === null) {
        totalCount = payload.count || 6607;
        console.log(`[Scraper] Total articles to scrape: ${totalCount}`);
      }

      const data = payload.data || [];
      if (data.length === 0) {
        console.log("[Scraper] No more articles returned. Done.");
        break;
      }

      allArticles.push(...data);
      console.log(`[Scraper] Successfully fetched ${data.length} articles. Progress: ${allArticles.length} / ${totalCount}`);

      if (data.length < limit || allArticles.length >= totalCount) {
        console.log("[Scraper] Reached last batch. Done.");
        break;
      }

      skip += limit;
      // Polite throttle
      await new Promise(resolve => setTimeout(resolve, 300));
    } catch (err) {
      console.error(`[Scraper] Error fetching batch at skip=${skip}:`, err.message);
      const is429 = err.message.includes('429');
      const waitTime = is429 ? 15000 : 3000;
      console.log(`[Scraper] Retrying in ${waitTime / 1000} seconds...`);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }

  // Save to backend/scripts/articles_raw.json
  fs.writeFileSync(filepath, JSON.stringify(allArticles, null, 2), 'utf8');
  console.log(`[Scraper] Scraped data successfully saved to: ${filepath}`);
  console.log(`[Scraper] Total records saved: ${allArticles.length}`);
}

scrapeAll();
