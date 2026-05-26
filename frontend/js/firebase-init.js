// Reemplaza estos valores con los de tu proyecto Firebase
// Firebase Console → Configuración del proyecto → Tus apps
const firebaseConfig = {
  apiKey:            "TU_API_KEY",
  authDomain:        "TU_PROJECT_ID.firebaseapp.com",
  projectId:         "TU_PROJECT_ID",
  storageBucket:     "TU_PROJECT_ID.firebasestorage.app",
  messagingSenderId: "TU_SENDER_ID",
  appId:             "TU_APP_ID"
};

if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

// Mantiene localStorage.token sincronizado con el ID token de Firebase
// Firebase renueva el token automáticamente antes de que expire (cada ~1 hora)
firebase.auth().onIdTokenChanged(async (user) => {
  if (user) {
    const token = await user.getIdToken();
    localStorage.setItem('token', token);
  } else {
    const enLogin = window.location.pathname.endsWith('index.html') || window.location.pathname === '/';
    if (!enLogin) {
      localStorage.clear();
      window.location.href = 'index.html';
    }
  }
});
