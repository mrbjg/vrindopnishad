// Firebase configuration
// This file connects the Web App to the same Firebase project as the Mobile App ("santvaanig")

import { initializeApp, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getDatabase } from "firebase/database";

const firebaseConfig = {
    apiKey: "AIzaSyC4oSs_XYXyxAyOptMC8yTa1oscW9G16cY",
    authDomain: "vrindavaanig.firebaseapp.com",
    projectId: "vrindavaanig",
    storageBucket: "vrindavaanig.firebasestorage.app",
    messagingSenderId: "373857631114",
    appId: "1:373857631114:web:f341d8a54711ca85a82673",
    measurementId: "G-YKQSX1MCDE"
};

// Initialize Default Firebase App (for Auth / standard Firestore)
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);

// Isolated Config for Sketch/SantVaanig Content (Realtime Database)
const santVaanigConfig = {
    databaseURL: "https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "santvaanig"
};

// Initialize Secondary App for RTDB Content
let contentApp;
const contentAppName = "santvaanig_content";

try {
    contentApp = getApp(contentAppName);
} catch (e) {
    contentApp = initializeApp(santVaanigConfig, contentAppName);
}

// Export the RTDB instance for the API service
export const contentDb = getDatabase(contentApp);

export default app;
