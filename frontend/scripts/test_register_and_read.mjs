import { initializeApp } from "firebase/app";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { getFirestore, collection, getDocs, limit, query } from "firebase/firestore";

const firebaseConfig = {
    apiKey: "AIzaSyCxBytUXjMdhBQfSjjuaIGfcXZe8N0WkH0",
    authDomain: "login-me-vrinda.firebaseapp.com",
    projectId: "login-me-vrinda",
    storageBucket: "login-me-vrinda.firebasestorage.app",
    messagingSenderId: "1019370299171",
    appId: "1:1019370299171:web:1a6df319b2fbfd6fcd3696",
    measurementId: "G-NN88X7N454"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

async function run() {
  const email = `testuser-${Math.floor(Math.random() * 100000)}@example.com`;
  const password = "password123";
  
  try {
    console.log(`Creating user with email: ${email}...`);
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    console.log(`User created successfully! UID: ${userCredential.user.uid}`);
    
    console.log("Fetching first 5 items from Firestore 'content' collection...");
    const contentRef = collection(db, 'content');
    const q = query(contentRef, limit(5));
    const snapshot = await getDocs(q);
    console.log("Query complete. Number of documents returned:", snapshot.size);
    snapshot.forEach(doc => {
      console.log(`Document ID: ${doc.id}`);
      console.log(`Title: ${doc.data().title}`);
      console.log(`Category: ${doc.data().category}`);
      console.log("------------------------");
    });
    process.exit(0);
  } catch (e) {
    console.error("Error:", e);
    process.exit(1);
  }
}

run();
