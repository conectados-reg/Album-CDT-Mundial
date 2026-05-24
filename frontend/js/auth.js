<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Álbum Estrellas - Iniciar Sesión</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #0b1329;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      color: white;
    }
    .login-container {
      background: #1c2541;
      padding: 40px;
      border-radius: 12px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.3);
      width: 100%;
      max-width: 360px;
      border: 1px solid #3a506b;
    }
    h2 {
      text-align: center;
      margin-bottom: 25px;
      color: #ffcc00;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    label {
      display: block;
      margin-bottom: 6px;
      font-size: 14px;
      color: #cbd5e1;
    }
    input {
      width: 100%;
      padding: 10px;
      margin-bottom: 20px;
      border: 1px solid #3a506b;
      background: #0b1329;
      border-radius: 6px;
      color: white;
      box-sizing: border-box;
    }
    input:focus {
      border-color: #ffcc00;
      outline: none;
    }
    button {
      width: 100%;
      padding: 12px;
      background: #ffcc00;
      border: none;
      color: #0b1329;
      font-weight: bold;
      font-size: 16px;
      border-radius: 6px;
      cursor: pointer;
      transition: background 0.2s;
    }
    button:hover {
      background: #e6b800;
    }
    .error-msg {
      color: #ff4d4d;
      text-align: center;
      font-size: 14px;
      margin-bottom: 15px;
    }
  </style>
</head>
<body>

  <div class="login-container">
    <h2>Álbum Estrellas</h2>
    <div id="loginError" class="error-msg"></div>
    
    <form id="loginForm">
      <label for="storeCode">Código o Email de Tienda:</label>
      <input type="text" id="storeCode" placeholder="ej: admin@empresa.com o tda-centro" required>
      
      <label for="password">Contraseña:</label>
      <input type="password" id="password" placeholder="••••••••" required>
      
      <button type="submit">INGRESAR</button>
    </form>

    <div style="text-align: center; margin-top: 20px;">
      <a href="#" id="btnAbrirRegistro" style="color: #cbd5e1; text-decoration: none; margin-right: 15px; font-size: 13px;">📝 Registrar Tienda</a>
      <a href="#" id="btnOlvidePassword" style="color: #ffcc00; text-decoration: none; font-size: 13px;">❓ Olvidé mi clave</a>
    </div>
  </div>

  <div id="modalRegistro" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); justify-content: center; align-items: center; z-index: 999;">
    <div style="background: #1c2541; padding: 30px; border-radius: 12px; width: 90%; max-width: 380px; color: white; border: 2px solid #ffcc00; box-shadow: 0 10px 30px rgba(0,0,0,0.5);">
      <h3 style="margin-top: 0; color: #ffcc00; text-align: center; text-transform: uppercase;">Nueva Cuenta</h3>
      <form id="formRegistro">
        <label>Nombre de la Sucursal:</label>
        <input type="text" id="regNombre" placeholder="Ej: Tienda Centro" required>
        
        <label>Correo Electrónico:</label>
        <input type="email" id="regEmail" placeholder="correo@tienda.com" required>
        
        <label>Crea tu Contraseña:</label>
        <input type="password" id="regPassword" placeholder="Mínimo 6 caracteres" required>
        
        <label>Región / Ciudad (Opcional):</label>
        <input type="text" id="regRegion" placeholder="Ej: Zona Norte">
        
        <button type="submit" style="margin-top: 10px;">REGISTRARSE</button>
        <button type="button" id="btnCerrarRegistro" style="width: 100%; padding: 10px; background: #3a506b; border: none; border-radius: 6px; color: white; cursor: pointer; margin-top: 8px; font-weight: bold;">Cancelar</button>
      </form>
    </div>
  </div>

  <script src="js/auth.js"></script>
</body>
</html>
