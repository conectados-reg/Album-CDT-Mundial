// Configuración de la URL de tu backend en Render
const API_URL = "https://album-cdt-mundial.onrender.com/api";

// === LOGICA 1: INICIO DE SESIÓN (LOGIN) ===
const loginForm = document.getElementById('loginForm');
const loginError = document.getElementById('loginError');

if (loginForm) {
  loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    if (loginError) loginError.textContent = '';

    const codigo = document.getElementById('storeCode').value;
    const password = document.getElementById('password').value;

    try {
      const response = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ codigo, password })
      });

      const data = await response.json();

      if (!response.ok) {
        if (loginError) loginError.textContent = data.error || 'Error al iniciar sesión.';
        return;
      }

      // Guardar el token de sesión y los datos del usuario en el navegador
      localStorage.setItem('token', data.token);
      localStorage.setItem('esAdmin', data.esAdmin);
      localStorage.setItem('nombreUsuario', data.nombre);
      if (data.tiendaId) localStorage.setItem('tiendaId', data.tiendaId);

      // Redirigir según el rol
      if (data.esAdmin) {
        window.location.href = 'admin.html'; // Va al panel de jefe
      } else {
        window.location.href = 'album.html'; // Va al álbum de la tienda
      }

    } catch (error) {
      console.error(error);
      if (loginError) loginError.textContent = 'No se pudo conectar con el servidor. Inténtalo más tarde.';
    }
  });
}

// === LOGICA 2: REGISTRO DE NUEVAS TIENDAS (MODAL) ===
const modalRegistro = document.getElementById('modalRegistro');
const btnAbrirRegistro = document.getElementById('btnAbrirRegistro');
const btnCerrarRegistro = document.getElementById('btnCerrarRegistro');
const formRegistro = document.getElementById('formRegistro');

// Abrir Ventana Flotante
if (btnAbrirRegistro) {
  btnAbrirRegistro.onclick = (e) => {
    e.preventDefault();
    if (modalRegistro) modalRegistro.style.display = 'flex';
  };
}

// Cerrar Ventana Flotante
if (btnCerrarRegistro) {
  btnCerrarRegistro.onclick = () => {
    if (modalRegistro) modalRegistro.style.display = 'none';
  };
}

// Enviar el formulario de registro al Backend de Render
if (formRegistro) {
  formRegistro.addEventListener('submit', async (e) => {
    e.preventDefault();

    const datos = {
      nombre: document.getElementById('regNombre').value,
      email: document.getElementById('regEmail').value,
      password: document.getElementById('regPassword').value,
      region: document.getElementById('regRegion').value
    };

    try {
      const response = await fetch(`${API_URL}/tiendas/registrar`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(datos)
      });

      const resData = await response.json();

      if (response.ok || resData.success) {
        alert('¡Cuenta creada con éxito! Ya puedes iniciar sesión con tu correo.');
        if (modalRegistro) modalRegistro.style.display = 'none';
        formRegistro.reset();
      } else {
        alert('Error: ' + (resData.error || 'No se pudo crear la cuenta.'));
      }
    } catch (error) {
      console.error(error);
      alert('Error al conectar con el servidor para registrar la tienda.');
    }
  });
}

// === LOGICA 3: REESTABLECER CONTRASEÑA VÍA WHATSAPP ===
const btnOlvidePassword = document.getElementById('btnOlvidePassword');

if (btnOlvidePassword) {
  btnOlvidePassword.onclick = (e) => {
    e.preventDefault();
    const correo = prompt("Por favor, introduce tu correo de tienda:");
    
    if (correo) {
      // ⚠️ PON AQUÍ TU NÚMERO REAL DE WHATSAPP (Con código de tu país adelante, sin el signo +)
      const tuTelefonoWhatsApp = "50760000000"; 
      
      const mensaje = encodeURIComponent(`Hola Administrador, soy de la sucursal con correo ${correo.trim()} y olvidé mi contraseña del Álbum Estrellas. ¿Me la podrías restablecer?`);
      window.open(`https://wa.me/${tuTelefonoWhatsApp}?text=${mensaje}`, '_blank');
    }
  };
}
