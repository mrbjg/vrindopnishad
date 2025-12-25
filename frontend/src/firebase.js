// Firebase configuration
// This file connects the Web App to the same Firebase project as the Mobile App ("santvaanig")

import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
    apiKey: "AIzaSyBV89ziohwoKmshLiZLxKm5JnbVPrYWL_o",
    authDomain: "santvaanig.firebaseapp.com",
    projectId: "santvaanig",
    storageBucket: "santvaanig.firebasestorage.app",
    messagingSenderId: "1027361942428",
    appId: "1:1027361942428:web:c71feffde5f3567853b659",
    measurementId: "G-Z4XX4EPYW3"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);

export default app;
