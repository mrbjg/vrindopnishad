const admin = require("firebase-admin");

async function testProject(projectId, databaseId = undefined) {
  try {
    console.log(`\n=== Testing project: ${projectId} (database: ${databaseId || "default"}) ===`);
    
    // Initialize the Admin SDK app for this project
    const app = admin.initializeApp({
      projectId: projectId,
      databaseId: databaseId
    }, projectId + (databaseId || ""));
    
    const db = app.firestore();
    
    console.log("Querying 'content' collection...");
    const snapshot = await db.collection("content").limit(5).get();
    
    console.log(`Success! Total documents returned: ${snapshot.size}`);
    snapshot.forEach(doc => {
      console.log(`Document ID: ${doc.id}`);
      console.log(`Title: ${doc.data().title}`);
      console.log(`Category: ${doc.data().category}`);
      console.log("------------------------");
    });
    
    // Check if there are other collections
    const collections = await db.listCollections();
    console.log("Collections in database:", collections.map(c => c.id));
    
  } catch (e) {
    console.error(`Error on project ${projectId}:`, e.message);
  }
}

async function run() {
  await testProject("login-me-vrinda");
  await testProject("santvaanig", "sant-vrinda");
  await testProject("vihaarvrinda");
}

run();
