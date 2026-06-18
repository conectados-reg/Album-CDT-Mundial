/**
 * seed-tiendas.js
 * Registra las 237 tiendas y crea sus fichas en la base de datos.
 * Uso: node backend/scripts/seed-tiendas.js
 * Requiere: SUPABASE_URL, SUPABASE_SERVICE_KEY, DATABASE_URL en .env
 */
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// [codigo, nombre, pais, hc]
const TIENDAS = [
  // ── Colombia (91) ──
  ['1107','NIKE SANTA FE','Colombia',3],
  ['1108','SLA PORTAL 80','Colombia',1],
  ['1109','SLA PORTAL DEL PRADO','Colombia',4],
  ['1111','SLA UNICO 3','Colombia',7],
  ['1112','NIKE CHIPICHAPE','Colombia',5],
  ['1113','SLA CARIBE PLAZA','Colombia',7],
  ['1114','SLA BUENAVISTA','Colombia',9],
  ['1115','NIKE VALUE STORE BARRANQUILLA','Colombia',7],
  ['1118','NIKE PREMIUM','Colombia',5],
  ['1119','SLA CENTRO MAYOR','Colombia',11],
  ['1120','SLA SANTAFE MEDELLIN','Colombia',6],
  ['1121','NIKE SANTAFE MEDELLIN','Colombia',11],
  ['1122','NIKE ARBOLEDA','Colombia',6],
  ['1125','SLA MOLINOS','Colombia',12],
  ['1127','SLA TITAN PLAZA','Colombia',12],
  ['1128','SPORTLINE MALL PLAZA NQS','Colombia',4],
  ['1130','SLA VILLAVICENCIO','Colombia',5],
  ['1131','NIKE VALUE STORE CALI','Colombia',11],
  ['1134','SLA CHIPICHAPE','Colombia',8],
  ['1135','NIKE VALUE STORE TOBERIN','Colombia',10],
  ['1136','SLA NEIVA','Colombia',4],
  ['1140','SLA FONTANAR','Colombia',8],
  ['1144','NIKE PLAZA CENTRAL','Colombia',3],
  ['1145','SLA PLAZA CENTRAL','Colombia',4],
  ['1146','NIKE JARDIN PLAZA - CALI','Colombia',4],
  ['1147','SLA KIDS COLINA','Colombia',2],
  ['1148','NIKE COLINA','Colombia',6],
  ['1149','SLA COLINA','Colombia',5],
  ['1150','NIKE VALUE STORE AMERICAS','Colombia',14],
  ['1151','NIKE FELICIDAD','Colombia',4],
  ['1152','SLA FELICIDAD','Colombia',5],
  ['1153','SLA KIDS FELICIDAD','Colombia',2],
  ['1154','KICKS FELICIDAD','Colombia',4],
  ['1155','KICKS COLINA','Colombia',4],
  ['1157','NIKE VALUE STORE DOS QUEBRADAS','Colombia',6],
  ['1158','NIKE VALUE STORE VALLEDUPAR','Colombia',4],
  ['1159','NIKE VALUE STORE GUAYABAL','Colombia',9],
  ['1160','NIKE VALUE STORE MONTERÍA','Colombia',4],
  ['1161','NIKE UNICENTRO CALI','Colombia',5],
  ['1162','NIKE MALL PLAZA MANIZALES','Colombia',3],
  ['1163','NIKE VIVA ENVIGADO','Colombia',7],
  ['1164','KICKS ENVIGADO','Colombia',3],
  ['1165','SLA JARDIN PLAZA - CUCUTA','Colombia',4],
  ['1166','KICKS SERREZUELA','Colombia',3],
  ['1167','NIKE BUENAVISTA','Colombia',5],
  ['1168','KICKS BUENAVISTA','Colombia',3],
  ['1169','NIKE GRAN ESTACIÓN','Colombia',4],
  ['1171','KICKS CACIQUE BUCARAMANGA','Colombia',3],
  ['1173','NIKE TESORO MEDELLIN','Colombia',11],
  ['1174','KICKS ARCADIA MEDELLIN','Colombia',2],
  ['1175','KICKS UNICENTRO BOGOTÁ','Colombia',4],
  ['1177','SLA MAYORCA MEDELLIN','Colombia',9],
  ['1178','KICKS TESORO MEDELLIN','Colombia',3],
  ['1179','SLA ARKADIA MEDELLIN','Colombia',5],
  ['1180','SLA ALEGRA BARRANQUILLA','Colombia',5],
  ['1182','SLA KIDS FABRICATO MEDELLIN','Colombia',3],
  ['1183','SLA PLAZA FABRICATO MEDELLIN','Colombia',6],
  ['1185','SLA NUESTRO CARTAGO','Colombia',4],
  ['1186','KICKS JARDIN PLAZA CALI','Colombia',3],
  ['1190','SLA NUESTRO BOGOTÁ','Colombia',4],
  ['1191','SLA JARDIN PLAZA - CALI','Colombia',6],
  ['1196','SLA STA MARTA BUENA VISTA','Colombia',6],
  ['2204','SUPER OUTLET RESTREPO','Colombia',5],
  ['2208','SUPER OUTLET SOPO','Colombia',8],
  ['2211','CONVERSE CALLE 82','Colombia',4],
  ['2215','CONVERSE TESORO','Colombia',5],
  ['2216','CONVERSE CENTRO MAYOR','Colombia',3],
  ['2217','CONVERSE UNICENTRO','Colombia',4],
  ['2218','CONVERSE SANTA FÉ MEDELLIN','Colombia',3],
  ['2219','CONVERSE TOBERIN OUTLETS','Colombia',3],
  ['2220','CONVERSE GRAN ESTACIÓN','Colombia',2],
  ['2221','CONVERSE PLAZA LAS AMERICAS','Colombia',2],
  ['2222','CONVERSE MAYORCA','Colombia',3],
  ['2223','CONVERSE VIVA ENVIGADO','Colombia',2],
  ['2224','CONVERSE VIVA TUNJA','Colombia',3],
  ['2225','CONVERSE FONTANAR','Colombia',3],
  ['2226','CONVERSE MALLPLAZA B/QUILLA','Colombia',3],
  ['2232','CONVERSE LA COLINA','Colombia',3],
  ['2233','CONVERSE FLORIDA MEDELLÍN','Colombia',5],
  ['2251','NIKE RISE-CALI','Colombia',9],
  ['2253','KICKS CENTRO MAYOR','Colombia',3],
  ['2254','NIKE CARRERA SEPTIMA BOGOTA','Colombia',13],
  ['2255','SLA FLORIDA MEDELLIN','Colombia',5],
  ['2256','SLA OUTLET BUCARAMANGA','Colombia',6],
  ['2257','SLA SAN NICOLAS MEDELLIN','Colombia',5],
  ['2258','NIKE CALLE 82 BOGOTÁ','Colombia',24],
  ['2259','SLA OUTLET AMERICAS BOGOTÁ','Colombia',8],
  ['2260','SLA CALLE 82  BOGOTÁ','Colombia',11],
  ['2261','NIKE UNICENTRO BOGOTÁ','Colombia',17],
  ['2262','KICKS FONTANAR','Colombia',3],
  ['2301','KREM PROVENZA','Colombia',2],
  // ── Costa Rica (17) ──
  ['9001','SPORTLINE CITY MALL CR','Costa Rica',6],
  ['9002','SPORTLINE KIDS CITY MALL CR','Costa Rica',4],
  ['9003','KICKS ALAJUELA CITY MALL','Costa Rica',2],
  ['9004','KICKS MP CURRIDABAT','Costa Rica',2],
  ['9005','SPORTLINE AVE. CENTRAL','Costa Rica',6],
  ['9006','SPORTLINE KIDS LINCOLN PLAZA','Costa Rica',3],
  ['9008','KICKS LINCOLN PLAZA','Costa Rica',2],
  ['9009','CONVERSE LINCOLN PLAZA','Costa Rica',3],
  ['9010','UNDER ARMOUR CURRIDABAT','Costa Rica',3],
  ['9012','SPORTLINE PASEO DE LAS FLORES','Costa Rica',6],
  ['9013','KICKS MULTIPLAZA ESCAZU','Costa Rica',2],
  ['9014','SUPER OUTLET PASEO METROPOLI','Costa Rica',3],
  ['9015','CONVERSE CITY MALL ALAJUELA','Costa Rica',2],
  ['9016','CONVERSE MULTIPLAZA ESCAZÚ','Costa Rica',3],
  ['9017','SPORTLINE OUTLET AVE. CENTRAL','Costa Rica',7],
  ['9018','SPORTLINE MULTIPLAZA ESCAZU','Costa Rica',10],
  ['9998','EVENTOS CR','Costa Rica',5],
  // ── El Salvador (22) ──
  ['3001','SPORTLINE PLAZA MUNDO','El Salvador',6],
  ['3002','SPORTLINE LA GRAN VÍA','El Salvador',9],
  ['3003','SPORTLINE METROCENTRO ESV','El Salvador',9],
  ['3005','SPORTLINE MULTIPLAZA','El Salvador',17],
  ['3006','KICKS METROCENTRO ESV','El Salvador',3],
  ['3007','KICKS PLAZA MUNDO ESV','El Salvador',4],
  ['3008','SPORTLINE SAN MIGUEL.','El Salvador',8],
  ['3009','SPORTLINE GALERÍAS','El Salvador',5],
  ['3010','SPORTLINE SANTA ANA','El Salvador',7],
  ['3011','SLA OUTLET. METROSUR','El Salvador',8],
  ['3012','NIKE VALUE STORE PRESIDENTE','El Salvador',6],
  ['3014','KICKS LA GRAN VÍA','El Salvador',4],
  ['3015','KICKS BAMBU','El Salvador',2],
  ['3016','SPORTLINE PLAZA MUNDO APOPA','El Salvador',4],
  ['3017','SPORTLINE SONSONATE','El Salvador',3],
  ['3018','UNDER ARMOUR MULTIPLAZA ESV','El Salvador',3],
  ['3020','SPORTLINE PLAZA PRESIDENTE','El Salvador',0],
  ['3021','CONVERSE LA GRAN VÍA','El Salvador',3],
  ['3022','KIDS LA GRAN VÍA','El Salvador',5],
  ['3024','TIENDA EVENTOS 2 SLA EL SALVA','El Salvador',0],
  ['3025','KICKS MULTIPLAZA','El Salvador',2],
  ['3026','SPORTLINE CENTRO HISTORICO','El Salvador',5],
  // ── Guatemala (21) ──
  ['2001','SPORTLINE PORTALES','Guatemala',10],
  ['2002','SPORTLINE MIRAFLORES','Guatemala',17],
  ['2003','OUTLET SLA','Guatemala',4],
  ['2004','NIKE VALUE STORE CAYALA','Guatemala',8],
  ['2005','SPORTLINE NARANJO','Guatemala',8],
  ['2006','SPORTLINE OAKLAND','Guatemala',18],
  ['2008','NIKE STORE CAYALA','Guatemala',4],
  ['2009','KICKS CAYALA','Guatemala',2],
  ['2010','SPORTLINE KIDS MIRAFLORES','Guatemala',4],
  ['2011','KICKS MIRAFLORES','Guatemala',4],
  ['2013','KICKS OAKLAND MALL','Guatemala',3],
  ['2015','SPORTLINE VISTARES','Guatemala',5],
  ['2016','SPORTLINE XELA','Guatemala',6],
  ['2017','SPORTLINE HUEHUETENANGO','Guatemala',6],
  ['2018','KICKS NARANJO','Guatemala',4],
  ['2019','UNDER ARMOUR OAKLAND MALL','Guatemala',2],
  ['2020','NIKE RISE OAKLAND MALL','Guatemala',6],
  ['2021','SLA PRADERA','Guatemala',0],
  ['2022','SLA COBÁN','Guatemala',6],
  ['2023','SPORTLINE INTERPLAZA XELA','Guatemala',0],
  ['2024','NIKE UNITE MIRAFLORES','Guatemala',4],
  // ── Honduras (28) ──
  ['4001','SPORTLINE MULTIPLAZA-SPS','Honduras',5],
  ['4002','SPORTLINE MULTIPLAZA-TEG','Honduras',11],
  ['4006','SPORTLINE CASCADAS','Honduras',10],
  ['4007','SPORTLINE KIDS SPS','Honduras',5],
  ['4012','SPORTLINE CEIBA','Honduras',8],
  ['4013','SPORTLINE GALERÍAS DEL VALLE','Honduras',6],
  ['4015','NIKE VALUE STORE SPS','Honduras',8],
  ['4016','SPORTLINE CITY MALL TEG','Honduras',8],
  ['4017','SPORTLINE UNIMALL','Honduras',6],
  ['4018','SPORTLINE CITY MALL SPS','Honduras',14],
  ['4019','KIDS MULTIPLAZA TGU','Honduras',5],
  ['4022','KICKS MULTIPLAZA TGU','Honduras',4],
  ['4023','SPORTLINE MEGAMALL HON','Honduras',7],
  ['4025','KICKS CITY MALL SPS','Honduras',5],
  ['4026','SLA KIDS MEGAMALL','Honduras',3],
  ['4027','NIKE VALUE STORE LA GALERÍA TGU','Honduras',8],
  ['4028','SPORTLINE DOWNTOWN SPS','Honduras',4],
  ['4029','SPORTLINE KIDS CEIBA','Honduras',3],
  ['4030','SPORTLINE KIDS CHOLUTECA','Honduras',3],
  ['4031','SLA MALL PREMIER','Honduras',6],
  ['4032','SLA KIDS MALL PREMIER','Honduras',3],
  ['4033','CONVERSE CITY MALL SPS CVS','Honduras',3],
  ['4035','CONVERSE MULTIPLAZA TGU CVT','Honduras',3],
  ['4036','SPORTLINE COMAYAGUA','Honduras',5],
  ['4037','NIKE MALL MULTIPLAZA TEGUCIGAL','Honduras',8],
  ['4038','SLA KIDS CASCADAS TEGUCIGALPA','Honduras',3],
  ['4039','OLIMPIA CITY','Honduras',4],
  ['4040','SPORTLINE OUTLET TOWNCENTER','Honduras',9],
  // ── Nicaragua (10) ──
  ['5001','SPORTLINE METROCENTRO NIC','Nicaragua',9],
  ['5003','SPORTLINE GALERIA STO. DOMINGO','Nicaragua',8],
  ['5004','SPORTLINE OUTLET PLAZA ESTABLO','Nicaragua',7],
  ['5005','SPORTLINE KIDS MANAGUA GALERÍA','Nicaragua',4],
  ['5006','KICKS MANAGUA METROCENTRO NIC','Nicaragua',5],
  ['5007','KIDS METROCENTRO NIC','Nicaragua',4],
  ['5009','CONVERSE METROCENTRO','Nicaragua',5],
  ['5010','CONVERSE GALERIAS SANTO DOMINGO','Nicaragua',4],
  ['5011','KICKS GALERIAS','Nicaragua',4],
  ['5012','SPORTLINE MULTICENTRO','Nicaragua',8],
  // ── Panamá (38) ──
  ['7016','SPORTLINE ED','Panamá',7],
  ['7021','NIKE VALUE STORE LOS PUEBLOS','Panamá',8],
  ['7023','SPORTLINE LP','Panamá',9],
  ['7032','SPORTLINE LA','Panamá',9],
  ['7035','SPORTLINE CHM','Panamá',10],
  ['7041','UNDER ARMOUR MP','Panamá',4],
  ['7043','NIKE SHOP MP','Panamá',7],
  ['7055','SPORTLINE ALLBROOK 55','Panamá',27],
  ['7059','NIKE VALUE STORE PLAZA REGENCY','Panamá',7],
  ['7062','NIKE MEN MP','Panamá',16],
  ['7076','SPORTLINE METROMALL','Panamá',25],
  ['7082','SPORTLINE WM','Panamá',18],
  ['7107','SPORTLINE MULTIPLAZA PTY','Panamá',41],
  ['7112','SPORTLINE MEGAMALL PTY','Panamá',8],
  ['7113','SPORTLINE LOS ANDES PLAZA SHOP','Panamá',8],
  ['7114','SPORTLINE BOULEVARD SANTIAGO','Panamá',7],
  ['7120','SPORTLINE AMERICA TOWN CENTER','Panamá',6],
  ['7121','SPORTLINE CHITRE','Panamá',6],
  ['7122','SPORTLINE AMERICA ALTA PLAZA','Panamá',17],
  ['7137','SPORTLINE OUTLET PLAZA REGENCY','Panamá',5],
  ['7138','NIKE TOWN CENTER','Panamá',7],
  ['7142','SPORTLINE AMERICA PENONOMÉ','Panamá',7],
  ['7143','UNDER ARMOUR TOWN CENTER','Panamá',3],
  ['7145','SPORTLINE AMERICA KIDS TOWN CE','Panamá',4],
  ['7146','KICKS ALBROOK MALL','Panamá',4],
  ['7149','KICKS MULTIPLAZA PTY','Panamá',5],
  ['7153','KICKS TOCUMEN','Panamá',4],
  ['7169','SPORTLINE METRO PARK','Panamá',0],
  ['7170','CONVERSE ALBROOK 1','Panamá',4],
  ['7171','CONVERSE METROMALL','Panamá',4],
  ['7172','CONVERSE MULTIPLAZA','Panamá',4],
  ['7178','NIKE ALBROOK MALL','Panamá',21],
  ['7179','SPORTLINE KIDS BRISAS CAPITAL','Panamá',2],
  ['7181','SPORTLINE OUTLET STORE','Panamá',6],
  ['7183','SPORTLINE CORONADO','Panamá',3],
  ['7185','SPORTLINE MARKET PLAZA','Panamá',4],
  ['7997','SPORTLINE MEGAPOLIS','Panamá',5],
  ['7998','TIENDA EVENTOS SLA PTY','Panamá',1],
  // ── Rep. Dominicana (10) ──
  ['6001','SPORTLINE MEGACENTRO','Rep.Dominicana',7],
  ['6002','SPORTLINE ÁGORA','Rep.Dominicana',11],
  ['6003','SPORTLINE SAMBIL','Rep.Dominicana',6],
  ['6004','NIKE VALUE STORE LINCOLN','Rep.Dominicana',5],
  ['6005','SPORTLINE KIDS ÁGORA MALL','Rep.Dominicana',4],
  ['6006','SPORTLINE DOWNTOWN','Rep.Dominicana',7],
  ['6007','SPORTLINE GALERÍA 360','Rep.Dominicana',6],
  ['6008','SPORTLINE OUTLET PLAZA DUARTE','Rep.Dominicana',7],
  ['6009','KICKS AH AGORA MALL','Rep.Dominicana',4],
  ['6014','SPORTLINE SANTIAGO DE LOS CABALLEROS','Rep.Dominicana',6],
];

async function runMigration(client) {
  await client.query(`
    ALTER TABLE tiendas
      ADD COLUMN IF NOT EXISTS password_changed_at TIMESTAMPTZ;
  `);
  console.log('[Migration] Columna password_changed_at verificada.');
}

async function main() {
  const client = await pool.connect();
  try {
    await runMigration(client);

    // Obtener semanas existentes
    const { rows: semanas } = await client.query(
      'SELECT id, numero FROM semanas ORDER BY numero'
    );

    // Crear semanas 1-6 si no existen
    const existentes = new Set(semanas.map(s => s.numero));
    for (let n = 1; n <= 6; n++) {
      if (!existentes.has(n)) {
        await client.query(
          `INSERT INTO semanas (numero, nombre, activa)
           VALUES ($1, $2, $3)
           ON CONFLICT DO NOTHING`,
          [n, `Semana ${n}`, n === 1]
        );
        console.log(`[Semanas] Creada Semana ${n}`);
      }
    }

    const { rows: todasSemanas } = await client.query(
      'SELECT id, numero FROM semanas ORDER BY numero'
    );
    const semanaMap = {};
    for (const s of todasSemanas) semanaMap[s.numero] = s.id;

    let creadas = 0, actualizadas = 0, fichasCreadas = 0;

    for (const [codigo, nombre, pais, hc] of TIENDAS) {
      const email = `${codigo}@sportline.com`;
      const fichasPorSemana = Math.round(6 + hc / 6);

      // Verificar si la tienda ya existe
      const { rows: existente } = await client.query(
        'SELECT id, total_empleados FROM tiendas WHERE codigo = $1',
        [codigo]
      );

      let tiendaId;

      if (!existente.length) {
        // Crear tienda nueva
        const { rows: nueva } = await client.query(
          `INSERT INTO tiendas (codigo, nombre, region, email, password_hash, activa, total_empleados)
           VALUES ($1, $2, $3, $4, 'sport123', true, $5)
           RETURNING id`,
          [codigo, nombre.trim(), pais, email, hc]
        );
        tiendaId = nueva[0].id;
        creadas++;
      } else {
        tiendaId = existente[0].id;
        // Actualizar HC si cambió
        if (existente[0].total_empleados !== hc) {
          await client.query(
            'UPDATE tiendas SET total_empleados = $1 WHERE id = $2',
            [hc, tiendaId]
          );
          actualizadas++;
        }
      }

      // Crear fichas por semana
      for (let semNum = 1; semNum <= 6; semNum++) {
        const semanaId = semanaMap[semNum];
        if (!semanaId) continue;

        const { rows: fichasExist } = await client.query(
          'SELECT id, desbloqueado FROM fichas_tienda WHERE tienda_id = $1 AND semana_id = $2',
          [tiendaId, semanaId]
        );

        const totalExist = fichasExist.length;
        const diff = fichasPorSemana - totalExist;

        if (diff > 0) {
          // Agregar fichas bloqueadas faltantes
          for (let i = 0; i < diff; i++) {
            await client.query(
              `INSERT INTO fichas_tienda (tienda_id, semana_id, numero_ficha, desbloqueado)
               VALUES ($1, $2, $3, false)`,
              [tiendaId, semanaId, totalExist + i + 1]
            );
            fichasCreadas++;
          }
        } else if (diff < 0) {
          // Eliminar fichas bloqueadas sobrantes (nunca tocar desbloqueadas)
          const bloqueadas = fichasExist.filter(f => !f.desbloqueado);
          const aEliminar = Math.min(-diff, bloqueadas.length);
          if (aEliminar > 0) {
            const ids = bloqueadas.slice(-aEliminar).map(f => f.id);
            await client.query(
              'DELETE FROM fichas_tienda WHERE id = ANY($1)',
              [ids]
            );
          }
        }
      }
    }

    console.log(`\n✓ Seed completado:`);
    console.log(`  Tiendas creadas:    ${creadas}`);
    console.log(`  Tiendas actualizadas: ${actualizadas}`);
    console.log(`  Fichas creadas:     ${fichasCreadas}`);
    console.log(`  Total tiendas:      ${TIENDAS.length}`);

  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(err => {
  console.error('Error en seed:', err.message);
  process.exit(1);
});
