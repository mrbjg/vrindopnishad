import { ensureDataLoaded } from '../src/lib/contentData.js';

async function run() {
  console.log("Initializing data load and backup generation...");
  await ensureDataLoaded();
  
  console.log("Waiting 10 seconds for all asynchronous file writes to complete...");
  await new Promise(resolve => setTimeout(resolve, 10000));
  
  console.log("Backups generation complete.");
  process.exit(0);
}

run().catch(err => {
  console.error("Failed:", err);
  process.exit(1);
});
