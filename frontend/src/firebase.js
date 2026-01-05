// Firebase configuration
// This file connects the Web App to the same Firebase project as the Mobile App ("santvaanig")

import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
    apiKey: "AIzaSyC4oSs_XYXyxAyOptMC8yTa1oscW9G16cY",
    authDomain: "vrindavaanig.firebaseapp.com",
    projectId: "vrindavaanig",
    storageBucket: "vrindavaanig.firebasestorage.app",
    messagingSenderId: "373857631114",
    appId: "1:373857631114:web:f341d8a54711ca85a82673",
    measurementId: "G-YKQSX1MCDE"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);

export default app;
