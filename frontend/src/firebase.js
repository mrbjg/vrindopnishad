import { initializeApp, getApps } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getDatabase } from "firebase/database";
import { getDataConnect } from "firebase/data-connect";
import { connectorConfig } from "./lib/dataconnect";

const firebaseConfig = {
    apiKey: process.env.REACT_APP_FIREBASE_API_KEY || "AIzaSyDMfZW8Oyk06yAquISCPz5Vl18FW0uQ4dI",
    authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN || "login-me-vrinda-1ce89.firebaseapp.com",
    projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID || "login-me-vrinda-1ce89",
    storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET || "login-me-vrinda-1ce89.firebasestorage.app",
    messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID || "290097593691",
    appId: process.env.REACT_APP_FIREBASE_APP_ID || "1:290097593691:web:1b7894ba8420e3d90b6e7e",
    measurementId: process.env.REACT_APP_FIREBASE_MEASUREMENT_ID || "G-BZSSQNF7BW"
};

const app = !getApps().length ? initializeApp(firebaseConfig) : getApps()[0];
export const auth = typeof window !== 'undefined' ? getAuth(app) : null;
export const db = typeof window !== 'undefined' ? getFirestore(app) : null;
export const contentDb = typeof window !== 'undefined' ? getDatabase(app) : null;
export const dataConnect = typeof window !== 'undefined' ? getDataConnect(app, connectorConfig) : null;

export default app;
