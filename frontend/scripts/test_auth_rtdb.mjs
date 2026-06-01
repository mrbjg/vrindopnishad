import { initializeApp } from "firebase/app";
import { getAuth, signInAnonymously } from "firebase/auth";
import { getDatabase, ref, get } from "firebase/database";

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
    console.log(`\n--- Testing ${name} Realtime Database ---`);
    const app = initializeApp(config, name);
    const auth = getAuth(app);
    const db = getDatabase(app);
    
    console.log(`Signing in anonymously on ${name}...`);
    const userCredential = await signInAnonymously(auth);
    console.log(`Signed in on ${name} as ${userCredential.user.uid}`);
    
    // Check root
    try {
      console.log(`Reading root / on ${name}...`);
      const rootSnap = await get(ref(db, '/'));
      if (rootSnap.exists()) {
        const data = rootSnap.val();
        console.log(`Success on root of ${name}! Keys:`, Object.keys(data));
        return true;
      }
    } catch (err) {
      console.log(`Root read failed on ${name}:`, err.message);
    }
    
    // Check /content
    try {
      console.log(`Reading /content on ${name}...`);
      const contentSnap = await get(ref(db, 'content'));
      if (contentSnap.exists()) {
        const data = contentSnap.val();
        console.log(`Success on /content of ${name}! Size:`, Object.keys(data).length);
        return true;
      }
    } catch (err) {
      console.log(`/content read failed on ${name}:`, err.message);
    }
  } catch (e) {
    console.warn(`Failed on ${name} setup:`, e.message);
  }
  return false;
}

async function run() {
  await testConfig("login-me-vrinda", configs["login-me-vrinda"]);
  await testConfig("santvaanig", configs["santvaanig"]);
}

run();
