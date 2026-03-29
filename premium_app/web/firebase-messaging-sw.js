importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
firebase.initializeApp({
  apiKey: "AIzaSyCx-fake-key-for-initialization",
  authDomain: "tilimltxgeucefxzerqi.firebaseapp.com",
  projectId: "tilimltxgeucefxzerqi",
  storageBucket: "tilimltxgeucefxzerqi.appspot.com",
  messagingSenderId: "38459275193",
  appId: "1:38459275193:web:fake-appid-for-initialization"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log(
    "[firebase-messaging-sw.js] Received background message ",
    payload
  );
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
