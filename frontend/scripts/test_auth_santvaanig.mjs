import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
import { getDatabase, ref, get } from "firebase/database";
import { getFirestore, collection, getDocs, limit, query } from "firebase/firestore";

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
const auth = getAuth(app);
const rtdb = getDatabase(app);
const firestoreDb = getFirestore(app, "sant-vrinda");

const credentials = [
  { email: "admin@vrindavaani.com", password: "vrinda123" },
  { email: "admin@vrindopnishad.com", password: "vrinda123" },
  { email: "mdark4025@gmail.com", password: "vrinda123" }
];

async function run() {
  for (const cred of credentials) {
    try {
      console.log(`\nTrying login on santvaanig with ${cred.email}...`);
      const userCredential = await signInWithEmailAndPassword(auth, cred.email, cred.password);
      console.log(`Login successful for ${cred.email}! User ID: ${userCredential.user.uid}`);
      
      // Try Realtime Database
      try {
        console.log("Fetching from Realtime Database ref '/'...");
        const snapshot = await get(ref(rtdb, '/'));
        if (snapshot.exists()) {
          console.log("RTDB root keys:", Object.keys(snapshot.val()));
        } else {
          console.log("RTDB is empty");
        }
      } catch (err) {
        console.warn("RTDB read failed:", err.message);
      }

      try {
        console.log("Fetching from Realtime Database ref '/content'...");
        const snapshot = await get(ref(rtdb, 'content'));
        if (snapshot.exists()) {
          console.log("RTDB content keys size:", Object.keys(snapshot.val()).length);
        } else {
          console.log("RTDB content is empty");
        }
      } catch (err) {
        console.warn("RTDB content read failed:", err.message);
      }
      
      process.exit(0);
    } catch (e) {
      console.warn(`Failed login for ${cred.email}:`, e.message);
    }
  }
  process.exit(1);
}

run();
