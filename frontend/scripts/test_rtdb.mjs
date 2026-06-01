import { initializeApp } from "firebase/app";
import { getDatabase, ref, get, child } from "firebase/database";

const configs = {
  "login-me-vrinda": {
    apiKey: "AIzaSyCxBytUXjMdhBQfSjjuaIGfcXZe8N0WkH0",
    authDomain: "login-me-vrinda.firebaseapp.com",
    projectId: "login-me-vrinda",
    databaseURL: "https://login-me-vrinda-default-rtdb.asia-southeast1.firebasedatabase.app"
  },
  "santvaanig": {
    apiKey: "AIzaSyAr78jEl1kzZ_MKRieUBlk5o5lO2p24vQU",
    authDomain: "santvaanig.firebaseapp.com",
    projectId: "santvaanig",
    databaseURL: "https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app"
  }
};

async function testConfig(name, config) {
  try {
    console.log(`\nTesting ${name} Realtime Database at /content...`);
    const app = initializeApp(config, name);
    const db = getDatabase(app);
    
    const contentRef = ref(db, 'content');
    const snapshot = await get(contentRef);
    if (snapshot.exists()) {
      const data = snapshot.val();
      console.log(`Success on ${name}! Number of content entries:`, Object.keys(data).length);
      console.log("Sample entry ID:", Object.keys(data)[0]);
      console.log("Sample details:", Object.values(data)[0]);
      return true;
    } else {
      console.log(`No data at /content on ${name}`);
    }
  } catch (e) {
    console.warn(`Failed on ${name} at /content:`, e.message);
  }
  return false;
}

async function run() {
  await testConfig("login-me-vrinda", configs["login-me-vrinda"]);
  await testConfig("santvaanig", configs["santvaanig"]);
}

run();
