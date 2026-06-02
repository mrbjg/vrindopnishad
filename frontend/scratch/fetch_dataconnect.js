const { initializeApp } = require('firebase/app');
const { getDataConnect } = require('firebase/data-connect');
const { listAllContent, getContentBySlug, connectorConfig } = require('../src/lib/dataconnect/index.cjs.js');

const firebaseConfig = {
    apiKey: "AIzaSyBV89ziohwoKmshLiZLxKm5JnbVPrYWL_o",
    authDomain: "santvaanig.firebaseapp.com",
    projectId: "santvaanig",
    storageBucket: "santvaanig.firebasestorage.app",
    messagingSenderId: "1027361942428",
    appId: "1:1027361942428:web:c71feffde5f3567853b659",
    measurementId: "G-Z4XX4EPYW3",
    databaseURL: "https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app"
};

const app = initializeApp(firebaseConfig);
const dc = getDataConnect(app, connectorConfig);

async function run() {
  console.log("Querying Firebase Data Connect...");
  try {
    const result = await listAllContent(dc, { limit: 25000 });
    console.log("Data Connect listAllContent result:", !!result);
    if (result && result.data && result.data.contents) {
      console.log("Found contents count:", result.data.contents.length);
      console.log("First item:", JSON.stringify(result.data.contents[0]));
    }
  } catch (e) {
    console.error("Data Connect query failed:", e);
  }
}

run();
