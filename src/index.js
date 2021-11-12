import { initializeApp } from "https://www.gstatic.com/firebasejs/9.4.0/firebase-app.js";;
import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/9.4.0/firebase-auth.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/9.4.0/firebase-analytics.js";

  // TODO: Add SDKs for Firebase products that you want to use
  // https://firebase.google.com/docs/web/setup#available-libraries

  // Your web app's Firebase configuration
  // For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = initializeApp({
        apiKey: "AIzaSyCNgatpOy3AZbiXAcM_56esZ4aDQfLVuwY",
        authDomain: "olympic-analysis.firebaseapp.com",
        projectId: "olympic-analysis",
        storageBucket: "olympic-analysis.appspot.com",
        messagingSenderId: "717565412399",
        appId: "1:717565412399:web:b44a143a94d7e7ab4232da",
        measurementId: "G-S1R7H6N3N4"
    });
const auth = getAuth(firebaseApp);

// Detect auth state
onAuthStateChanged(auth, user => {
    if(user != null){
        console.log('logged in!');
    }
    else{
        console.log('No user');
    }
});

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);