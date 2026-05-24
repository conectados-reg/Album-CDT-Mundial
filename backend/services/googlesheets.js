require('dotenv').config();
const { google } = require('googleapis');

const auth = new google.auth.GoogleAuth({
  keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_FILE,
  scopes: ['https://www.googleapis.com/auth/spreadsheets.readonly'],
});

async function leerDatosVentas() {
  const client = await auth.getClient();
  const sheets = google.sheets({ version: 'v4', auth: client });

  const tab   = process.env.GOOGLE_SHEET_TAB || 'Ventas';
  const range = `${tab}!A2:E`;

  const response = await sheets.spreadsheets.values.get({
    spreadsheetId: process.env.GOOGLE_SHEET_ID,
    range,
  });

  const filas = response.data.values || [];

  return filas
    .filter(fila => fila[0] && fila[1])
    .map(fila => ({
      sheetsId:      fila[0]?.trim(),
      tiendaCodigo:  fila[1]?.trim().toUpperCase(),
      semana:        parseInt(fila[2]) || 0,
      porcentaje:    parseFloat(fila[3]) || 0,
      activo:        fila[4]?.trim().toLowerCase() !== 'inactivo',
    }));
}

module.exports = { leerDatosVentas };
