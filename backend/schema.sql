CREATE TABLE tiendas (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  codigo           VARCHAR(20)  UNIQUE NOT NULL,
  nombre           VARCHAR(150) NOT NULL,
  region           VARCHAR(100),
  ciudad           VARCHAR(100),
  total_empleados  INTEGER DEFAULT 0,
  password_hash    TEXT NOT NULL,
  activa           BOOLEAN DEFAULT TRUE,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE semanas (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  numero       INTEGER NOT NULL CHECK (numero BETWEEN 1 AND 6),
  nombre       VARCHAR(100),
  fecha_inicio DATE NOT NULL,
  fecha_fin    DATE NOT NULL,
  activa       BOOLEAN DEFAULT FALSE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (numero)
);

CREATE TABLE empleados (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tienda_id        UUID REFERENCES tiendas(id) ON DELETE CASCADE,
  nombre           VARCHAR(150) NOT NULL,
  cargo            VARCHAR(100),
  foto_url         TEXT,
  semana_asignada  INTEGER NOT NULL CHECK (semana_asignada BETWEEN 1 AND 6),
  activo           BOOLEAN DEFAULT TRUE,
  sheets_row_id    TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE resultados_ventas (
  id                  UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  empleado_id         UUID REFERENCES empleados(id) ON DELETE CASCADE,
  semana_id           UUID REFERENCES semanas(id),
  porcentaje_cumplido DECIMAL(6,2) DEFAULT 0,
  cumplio_meta        BOOLEAN DEFAULT FALSE,
  fecha_registro      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (empleado_id, semana_id)
);

CREATE TABLE espacios_album (
  id                UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  empleado_id       UUID REFERENCES empleados(id) ON DELETE CASCADE,
  semana_id         UUID REFERENCES semanas(id),
  desbloqueado      BOOLEAN DEFAULT FALSE,
  fecha_desbloqueo  TIMESTAMPTZ,
  UNIQUE (empleado_id, semana_id)
);

CREATE TABLE admins (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email         VARCHAR(150) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  nombre        VARCHAR(100),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_empleados_tienda  ON empleados(tienda_id);
CREATE INDEX idx_empleados_semana  ON empleados(semana_asignada);
CREATE INDEX idx_empleados_activo  ON empleados(activo);
CREATE INDEX idx_resultados_emp    ON resultados_ventas(empleado_id);
CREATE INDEX idx_espacios_emp      ON espacios_album(empleado_id);

INSERT INTO semanas (numero, nombre, fecha_inicio, fecha_fin, activa) VALUES
  (1, 'Semana 1 — Fase de Grupos',  '2026-06-09', '2026-06-15', FALSE),
  (2, 'Semana 2 — Fase de Grupos',  '2026-06-16', '2026-06-22', TRUE),
  (3, 'Semana 3 — Octavos de Final','2026-06-23', '2026-06-29', FALSE),
  (4, 'Semana 4 — Cuartos de Final','2026-06-30', '2026-07-06', FALSE),
  (5, 'Semana 5 — Semifinal',       '2026-07-07', '2026-07-13', FALSE),
  (6, 'Semana 6 — Gran Final',      '2026-07-14', '2026-07-19', FALSE);

CREATE OR REPLACE FUNCTION avanzar_semana()
RETURNS void AS $$
DECLARE
  semana_actual INTEGER;
BEGIN
  SELECT numero INTO semana_actual FROM semanas WHERE activa = TRUE LIMIT 1;
  IF semana_actual IS NULL OR semana_actual >= 6 THEN RETURN; END IF;
  UPDATE semanas SET activa = FALSE WHERE activa = TRUE;
  UPDATE semanas SET activa = TRUE  WHERE numero = semana_actual + 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION desbloquear_espacios_automatico()
RETURNS void AS $$
DECLARE
  sem RECORD;
BEGIN
  SELECT * INTO sem FROM semanas WHERE activa = TRUE LIMIT 1;
  IF sem IS NULL THEN RETURN; END IF;

  INSERT INTO espacios_album (empleado_id, semana_id, desbloqueado, fecha_desbloqueo)
  SELECT rv.empleado_id, rv.semana_id, TRUE, NOW()
  FROM resultados_ventas rv
  JOIN empleados e ON e.id = rv.empleado_id
  WHERE rv.semana_id = sem.id
    AND rv.cumplio_meta = TRUE
    AND e.activo = TRUE
    AND e.semana_asignada = sem.numero
  ON CONFLICT (empleado_id, semana_id)
  DO UPDATE SET desbloqueado = TRUE, fecha_desbloqueo = NOW()
  WHERE espacios_album.desbloqueado = FALSE;
END;
$$ LANGUAGE plpgsql;
