// Firebase configuration
// This file connects the Web App to the same Firebase project as the Mobile App ("santvaanig")

import { initializeApp, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getDatabase } from "firebase/database";

const firebaseConfig = {
    apiKey: "AIzaSyCxBytUXjMdhBQfSjjuaIGfcXZe8N0WkH0",
    authDomain: "login-me-vrinda.firebaseapp.com",
    projectId: "login-me-vrinda",
    storageBucket: "login-me-vrinda.firebasestorage.app",
    messagingSenderId: "1019370299171",
    appId: "1:1019370299171:web:1a6df319b2fbfd6fcd3696",
    measurementId: "G-NN88X7N454"
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
