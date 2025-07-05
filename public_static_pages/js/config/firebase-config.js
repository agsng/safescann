// public/js/config/firebase-config.js
import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

// IMPORTANT: For local debugging with Live Server, hardcode your actual Firebase project configuration here.
// You can find this in your Firebase project settings -> General -> Your apps -> Web app -> "Firebase SDK snippet" -> Config
// Example:

const firebaseConfig = {
apiKey: "AIzaSyCsAuX1KfXOjy-OT_xBS13VXBlHGbK4llw",
  authDomain: "safescann-aa466.firebaseapp.com",
  projectId: "safescann-aa466",
  storageBucket: "safescann-aa466.firebasestorage.app",
  messagingSenderId: "220626158058",
  appId: "1:220626158058:web:d232e4683556a46f433293",
  measurementId: "G-BJ7NHCLGP1",
};

// Initialize Firebase app
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Export the Firestore database instance for use in other modules
export { db };
