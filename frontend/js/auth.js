const API_URL = "https://album-cdt-mundial.onrender.com/api"; // Cambiar por tu URL de Render en producción

document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('loginForm');
  if (!form) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const codigo   = document.getElementById('storeCode').value.trim();
    const password = document.getElementById('password').value.trim();
    const errorEl  = document.getElementById('loginError');

    errorEl.textContent = '';
    if (!codigo || !password) {
      errorEl.textContent = 'Por favor, ingresa tus datos completos.';
      return;
    }

    try {
      const response = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ codigo, password })
      });

      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Error al conectar.');

      sessionStorage.setItem('token', data.token);
      sessionStorage.setItem('nombre', data.nombre);
      sessionStorage.setItem('esAdmin', data.esAdmin);

      if (data.esAdmin) {
        window.location.href = 'admin.html';
      } else {
        window.location.href = `album.html?id=${data.tiendaId}`;
      }
    } catch (err) {
      errorEl.textContent = err.message;
    }
  });
});

function requireAuth(adminOnly = false) {
  const token = sessionStorage.getItem('token');
  const esAdmin = sessionStorage.getItem('esAdmin') === 'true';

  if (!token) {
    window.location.href = 'index.html';
    return null;
  }
  if (adminOnly && !esAdmin) {
    window.location.href = 'index.html';
    return null;
  }
  return { token, esAdmin };
}

function logout() {
  sessionStorage.clear();
  window.location.href = 'index.html';
}
