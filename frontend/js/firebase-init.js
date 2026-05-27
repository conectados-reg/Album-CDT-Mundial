// Reemplaza estos valores con los de tu proyecto Firebase
// Firebase Console → Configuración del proyecto → Tus apps
const firebaseConfig = {
  apiKey:            "AIzaSyDBrhhvBgi9iEHb_-9AottSSKOjfoM_ECA",
  authDomain:        "album-metat-mundial-59cad.firebaseapp.com",
  projectId:         "album-metat-mundial-59cad",
  storageBucket:     "album-metat-mundial-59cad.firebasestorage.app",
  messagingSenderId: "233395378351",
  appId:             "1:233395378351:web:13f82a4cf0c39815fe5c5a"
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
