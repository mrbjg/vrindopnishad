import { initializeApp } from "firebase/app";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { getDatabase, ref, get } from "firebase/database";

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
const db = getDatabase(app);

async function run() {
  const email = `testuser-${Math.floor(Math.random() * 100000)}@example.com`;
  const password = "password123";
  
  try {
    console.log(`Creating user in santvaanig: ${email}...`);
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    console.log(`User created! UID: ${userCredential.user.uid}`);
    
    // Check root
    try {
      console.log("Reading root '/'...");
      const snapshot = await get(ref(db, '/'));
      if (snapshot.exists()) {
        const val = snapshot.val();
        console.log("Root keys:", Object.keys(val));
        console.log("Success! We can read the database.");
        process.exit(0);
      } else {
        console.log("Database is empty.");
        process.exit(0);
      }
    } catch (err) {
      console.error("Root read failed:", err.message);
    }
    
    // Check /content
    try {
      console.log("Reading '/content'...");
      const snapshot = await get(ref(db, 'content'));
      if (snapshot.exists()) {
        const val = snapshot.val();
        console.log("Content size:", Object.keys(val).length);
        console.log("Success! We can read /content.");
        process.exit(0);
      } else {
        console.log("Content path is empty.");
        process.exit(0);
      }
    } catch (err) {
      console.error("Content read failed:", err.message);
    }
    
    process.exit(1);
  } catch (e) {
    console.error("Error creating user:", e.message);
    process.exit(1);
  }
}

run();
