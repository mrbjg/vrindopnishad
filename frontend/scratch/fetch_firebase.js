const { initializeApp } = require('firebase/app');
const { getDatabase, ref, get, child } = require('firebase/database');
const { getFirestore, collection, getDocs, limit, query } = require('firebase/firestore');

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
const rtdb = getDatabase(app);
const firestore = getFirestore(app);

async function checkRTDB() {
  console.log('Checking Realtime Database...');
  try {
    const dbRef = ref(rtdb);
    // Let's try to get content count or a small slice first
    const snapshot = await get(child(dbRef, 'content'));
    if (snapshot.exists()) {
      const data = snapshot.val();
      const count = Array.isArray(data) ? data.length : Object.keys(data).length;
      console.log('RTDB Content count:', count);
      // print first item
      const firstKey = Array.isArray(data) ? 0 : Object.keys(data)[0];
      console.log('RTDB First Item:', JSON.stringify(data[firstKey]).substring(0, 500));
    } else {
      console.log('No content node in RTDB');
    }
  } catch (e) {
    console.error('RTDB check failed:', e);
  }
}

async function checkFirestore() {
  console.log('Checking Firestore...');
  try {
    const contentRef = collection(firestore, 'content');
    const q = query(contentRef, limit(5));
    const querySnapshot = await getDocs(q);
    console.log('Firestore limit 5 results count:', querySnapshot.size);
    querySnapshot.forEach((doc) => {
      console.log(doc.id, '=>', JSON.stringify(doc.data()).substring(0, 200));
    });
  } catch (e) {
    console.error('Firestore check failed:', e);
  }
}

async function run() {
  await checkRTDB();
  await checkFirestore();
  process.exit(0);
}

run();
