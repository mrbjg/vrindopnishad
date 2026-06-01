import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs, limit, query } from "firebase/firestore";

const firebaseConfig = {
    apiKey: "AIzaSyBV89ziohwoKmshLiZLxKm5JnbVPrYWL_o",
    authDomain: "santvaanig.firebaseapp.com",
    projectId: "santvaanig",
    storageBucket: "santvaanig.firebasestorage.app",
    messagingSenderId: "1027361942428",
    appId: "1:1027361942428:web:c71feffde5f3567853b659",
    measurementId: "G-Z4XX4EPYW3"
};

const app = initializeApp(firebaseConfig);
// Specify the custom database ID "sant-vrinda"
const db = getFirestore(app, "sant-vrinda");

async function test() {
  try {
    console.log("Fetching first 5 items from Firestore 'content' collection in 'sant-vrinda' database...");
    const contentRef = collection(db, 'content');
    const q = query(contentRef, limit(5));
    const snapshot = await getDocs(q);
    console.log("Query complete! Number of documents returned:", snapshot.size);
    snapshot.forEach(doc => {
      console.log(`Document ID: ${doc.id}`);
      console.log(`Title: ${doc.data().title}`);
      console.log(`Category: ${doc.data().category}`);
      console.log("------------------------");
    });
    process.exit(0);
  } catch (e) {
    console.error("Error fetching from Firestore:", e);
    process.exit(1);
  }
}

test();
