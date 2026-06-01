import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
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

const credentials = [
  { email: "admin@vrindavaani.com", password: "vrinda123" },
  { email: "admin@vrindopnishad.com", password: "vrinda123" },
  { email: "mdark4025@gmail.com", password: "vrinda123" }
];

async function tryLoginAndFetch() {
  for (const cred of credentials) {
    try {
      console.log(`Trying login with ${cred.email}...`);
      const userCredential = await signInWithEmailAndPassword(auth, cred.email, cred.password);
      console.log(`Login successful for ${cred.email}! User ID: ${userCredential.user.uid}`);
      
      console.log("Fetching first 5 items from Firestore 'content' collection...");
      const contentRef = collection(db, 'content');
      const q = query(contentRef, limit(5));
      const snapshot = await getDocs(q);
      console.log("Number of documents returned:", snapshot.size);
      snapshot.forEach(doc => {
        console.log(`Document ID: ${doc.id}`);
        console.log(`Title: ${doc.data().title}`);
        console.log(`Category: ${doc.data().category}`);
        console.log("------------------------");
      });
      process.exit(0);
    } catch (e) {
      console.warn(`Failed with ${cred.email}:`, e.message);
    }
  }
  console.error("All credential attempts failed.");
  process.exit(1);
}

tryLoginAndFetch();
