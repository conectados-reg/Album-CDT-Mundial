-- =====================================================
-- SEED: 237 Tiendas SLA Corp + Fichas
-- Ejecutar en: Supabase → SQL Editor
-- =====================================================

-- 1. Agregar columna si no existe
ALTER TABLE tiendas ADD COLUMN IF NOT EXISTS password_changed_at TIMESTAMPTZ;

-- 2. Crear semanas 1-6 si no existen
INSERT INTO semanas (numero, nombre, activa) VALUES
  (1,'Semana 1',true),(2,'Semana 2',false),(3,'Semana 3',false),
  (4,'Semana 4',false),(5,'Semana 5',false),(6,'Semana 6',false)
ON CONFLICT DO NOTHING;

-- 3. Insertar / actualizar tiendas y crear fichas
DO $$
DECLARE
  v_id   UUID;
  v_sem  RECORD;
  v_exist INT;
  v_fps  INT;
  i      INT;
BEGIN

  -- 1107 NIKE SANTA FE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1107','NIKE SANTA FE','Colombia','1107@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1107'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1108 SLA PORTAL 80
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1108','SLA PORTAL 80','Colombia','1108@sportline.com','sport123',true,1)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1108'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1109 SLA PORTAL DEL PRADO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1109','SLA PORTAL DEL PRADO','Colombia','1109@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1109'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1111 SLA UNICO 3
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1111','SLA UNICO 3','Colombia','1111@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1111'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1112 NIKE CHIPICHAPE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1112','NIKE CHIPICHAPE','Colombia','1112@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1112'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1113 SLA CARIBE PLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1113','SLA CARIBE PLAZA','Colombia','1113@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1113'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1114 SLA BUENAVISTA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1114','SLA BUENAVISTA','Colombia','1114@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1114'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1115 NIKE VALUE STORE BARRANQUILLA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1115','NIKE VALUE STORE BARRANQUILLA','Colombia','1115@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1115'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1118 NIKE PREMIUM
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1118','NIKE PREMIUM','Colombia','1118@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1118'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1119 SLA CENTRO MAYOR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1119','SLA CENTRO MAYOR','Colombia','1119@sportline.com','sport123',true,11)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1119'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1120 SLA SANTAFE MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1120','SLA SANTAFE MEDELLIN','Colombia','1120@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1120'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1121 NIKE SANTAFE MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1121','NIKE SANTAFE MEDELLIN','Colombia','1121@sportline.com','sport123',true,11)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1121'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1122 NIKE ARBOLEDA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1122','NIKE ARBOLEDA','Colombia','1122@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1122'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1125 SLA MOLINOS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1125','SLA MOLINOS','Colombia','1125@sportline.com','sport123',true,12)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1125'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1127 SLA TITAN PLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1127','SLA TITAN PLAZA','Colombia','1127@sportline.com','sport123',true,12)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1127'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1128 SPORTLINE MALL PLAZA NQS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1128','SPORTLINE MALL PLAZA NQS','Colombia','1128@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1128'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1130 SLA VILLAVICENCIO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1130','SLA VILLAVICENCIO','Colombia','1130@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1130'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1131 NIKE VALUE STORE CALI
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1131','NIKE VALUE STORE CALI','Colombia','1131@sportline.com','sport123',true,11)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1131'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1134 SLA CHIPICHAPE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1134','SLA CHIPICHAPE','Colombia','1134@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1134'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1135 NIKE VALUE STORE TOBERIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1135','NIKE VALUE STORE TOBERIN','Colombia','1135@sportline.com','sport123',true,10)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1135'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1136 SLA NEIVA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1136','SLA NEIVA','Colombia','1136@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1136'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1140 SLA FONTANAR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1140','SLA FONTANAR','Colombia','1140@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1140'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1144 NIKE PLAZA CENTRAL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1144','NIKE PLAZA CENTRAL','Colombia','1144@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1144'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1145 SLA PLAZA CENTRAL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1145','SLA PLAZA CENTRAL','Colombia','1145@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1145'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1146 NIKE JARDIN PLAZA - CALI
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1146','NIKE JARDIN PLAZA - CALI','Colombia','1146@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1146'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1147 SLA KIDS COLINA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1147','SLA KIDS COLINA','Colombia','1147@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1147'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1148 NIKE COLINA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1148','NIKE COLINA','Colombia','1148@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1148'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1149 SLA COLINA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1149','SLA COLINA','Colombia','1149@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1149'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1150 NIKE VALUE STORE AMERICAS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1150','NIKE VALUE STORE AMERICAS','Colombia','1150@sportline.com','sport123',true,14)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1150'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1151 NIKE FELICIDAD
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1151','NIKE FELICIDAD','Colombia','1151@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1151'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1152 SLA FELICIDAD
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1152','SLA FELICIDAD','Colombia','1152@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1152'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1153 SLA KIDS FELICIDAD
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1153','SLA KIDS FELICIDAD','Colombia','1153@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1153'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1154 KICKS FELICIDAD
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1154','KICKS FELICIDAD','Colombia','1154@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1154'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1155 KICKS COLINA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1155','KICKS COLINA','Colombia','1155@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1155'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1157 NIKE VALUE STORE DOS QUEBRADAS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1157','NIKE VALUE STORE DOS QUEBRADAS','Colombia','1157@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1157'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1158 NIKE VALUE STORE VALLEDUPAR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1158','NIKE VALUE STORE VALLEDUPAR','Colombia','1158@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1158'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1159 NIKE VALUE STORE GUAYABAL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1159','NIKE VALUE STORE GUAYABAL','Colombia','1159@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1159'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1160 NIKE VALUE STORE MONTERÍA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1160','NIKE VALUE STORE MONTERÍA','Colombia','1160@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1160'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1161 NIKE UNICENTRO CALI
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1161','NIKE UNICENTRO CALI','Colombia','1161@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1161'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1162 NIKE MALL PLAZA MANIZALES
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1162','NIKE MALL PLAZA MANIZALES','Colombia','1162@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1162'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1163 NIKE VIVA ENVIGADO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1163','NIKE VIVA ENVIGADO','Colombia','1163@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1163'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1164 KICKS ENVIGADO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1164','KICKS ENVIGADO','Colombia','1164@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1164'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1165 SLA JARDIN PLAZA - CUCUTA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1165','SLA JARDIN PLAZA - CUCUTA','Colombia','1165@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1165'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1166 KICKS SERREZUELA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1166','KICKS SERREZUELA','Colombia','1166@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1166'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1167 NIKE BUENAVISTA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1167','NIKE BUENAVISTA','Colombia','1167@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1167'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1168 KICKS BUENAVISTA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1168','KICKS BUENAVISTA','Colombia','1168@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1168'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1169 NIKE GRAN ESTACIÓN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1169','NIKE GRAN ESTACIÓN','Colombia','1169@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1169'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1171 KICKS CACIQUE BUCARAMANGA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1171','KICKS CACIQUE BUCARAMANGA','Colombia','1171@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1171'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1173 NIKE TESORO MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1173','NIKE TESORO MEDELLIN','Colombia','1173@sportline.com','sport123',true,11)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1173'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1174 KICKS ARCADIA MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1174','KICKS ARCADIA MEDELLIN','Colombia','1174@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1174'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1175 KICKS UNICENTRO BOGOTÁ
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1175','KICKS UNICENTRO BOGOTÁ','Colombia','1175@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1175'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1177 SLA MAYORCA MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1177','SLA MAYORCA MEDELLIN','Colombia','1177@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1177'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1178 KICKS TESORO MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1178','KICKS TESORO MEDELLIN','Colombia','1178@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1178'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1179 SLA ARKADIA MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1179','SLA ARKADIA MEDELLIN','Colombia','1179@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1179'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1180 SLA ALEGRA BARRANQUILLA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1180','SLA ALEGRA BARRANQUILLA','Colombia','1180@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1180'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1182 SLA KIDS FABRICATO MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1182','SLA KIDS FABRICATO MEDELLIN','Colombia','1182@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1182'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1183 SLA PLAZA FABRICATO MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1183','SLA PLAZA FABRICATO MEDELLIN','Colombia','1183@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1183'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1185 SLA NUESTRO CARTAGO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1185','SLA NUESTRO CARTAGO','Colombia','1185@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1185'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1186 KICKS JARDIN PLAZA CALI
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1186','KICKS JARDIN PLAZA CALI','Colombia','1186@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1186'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1190 SLA NUESTRO BOGOTÁ
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1190','SLA NUESTRO BOGOTÁ','Colombia','1190@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1190'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1191 SLA JARDIN PLAZA - CALI
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1191','SLA JARDIN PLAZA - CALI','Colombia','1191@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1191'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 1196 SLA STA MARTA BUENA VISTA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('1196','SLA STA MARTA BUENA VISTA','Colombia','1196@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='1196'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2204 SUPER OUTLET RESTREPO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2204','SUPER OUTLET RESTREPO','Colombia','2204@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2204'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2208 SUPER OUTLET SOPO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2208','SUPER OUTLET SOPO','Colombia','2208@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2208'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2211 CONVERSE CALLE 82
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2211','CONVERSE CALLE 82','Colombia','2211@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2211'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2215 CONVERSE TESORO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2215','CONVERSE TESORO','Colombia','2215@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2215'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2216 CONVERSE CENTRO MAYOR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2216','CONVERSE CENTRO MAYOR','Colombia','2216@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2216'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2217 CONVERSE UNICENTRO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2217','CONVERSE UNICENTRO','Colombia','2217@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2217'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2218 CONVERSE SANTA FÉ MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2218','CONVERSE SANTA FÉ MEDELLIN','Colombia','2218@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2218'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2219 CONVERSE TOBERIN OUTLETS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2219','CONVERSE TOBERIN OUTLETS','Colombia','2219@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2219'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2220 CONVERSE GRAN ESTACIÓN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2220','CONVERSE GRAN ESTACIÓN','Colombia','2220@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2220'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2221 CONVERSE PLAZA LAS AMERICAS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2221','CONVERSE PLAZA LAS AMERICAS','Colombia','2221@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2221'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2222 CONVERSE MAYORCA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2222','CONVERSE MAYORCA','Colombia','2222@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2222'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2223 CONVERSE VIVA ENVIGADO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2223','CONVERSE VIVA ENVIGADO','Colombia','2223@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2223'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2224 CONVERSE VIVA TUNJA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2224','CONVERSE VIVA TUNJA','Colombia','2224@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2224'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2225 CONVERSE FONTANAR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2225','CONVERSE FONTANAR','Colombia','2225@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2225'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2226 CONVERSE MALLPLAZA B/QUILLA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2226','CONVERSE MALLPLAZA B/QUILLA','Colombia','2226@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2226'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2232 CONVERSE LA COLINA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2232','CONVERSE LA COLINA','Colombia','2232@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2232'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2233 CONVERSE FLORIDA MEDELLÍN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2233','CONVERSE FLORIDA MEDELLÍN','Colombia','2233@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2233'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2251 NIKE RISE-CALI
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2251','NIKE RISE-CALI','Colombia','2251@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2251'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2253 KICKS CENTRO MAYOR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2253','KICKS CENTRO MAYOR','Colombia','2253@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2253'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2254 NIKE CARRERA SEPTIMA BOGOTA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2254','NIKE CARRERA SEPTIMA BOGOTA','Colombia','2254@sportline.com','sport123',true,13)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2254'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2255 SLA FLORIDA MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2255','SLA FLORIDA MEDELLIN','Colombia','2255@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2255'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2256 SLA OUTLET BUCARAMANGA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2256','SLA OUTLET BUCARAMANGA','Colombia','2256@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2256'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2257 SLA SAN NICOLAS MEDELLIN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2257','SLA SAN NICOLAS MEDELLIN','Colombia','2257@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2257'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2258 NIKE CALLE 82 BOGOTÁ
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2258','NIKE CALLE 82 BOGOTÁ','Colombia','2258@sportline.com','sport123',true,24)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2258'; END IF;
  v_fps := 10;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2259 SLA OUTLET AMERICAS BOGOTÁ
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2259','SLA OUTLET AMERICAS BOGOTÁ','Colombia','2259@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2259'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2260 SLA CALLE 82  BOGOTÁ
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2260','SLA CALLE 82  BOGOTÁ','Colombia','2260@sportline.com','sport123',true,11)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2260'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2261 NIKE UNICENTRO BOGOTÁ
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2261','NIKE UNICENTRO BOGOTÁ','Colombia','2261@sportline.com','sport123',true,17)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2261'; END IF;
  v_fps := 9;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2262 KICKS FONTANAR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2262','KICKS FONTANAR','Colombia','2262@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2262'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2301 KREM PROVENZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2301','KREM PROVENZA','Colombia','2301@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2301'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9001 SPORTLINE CITY MALL CR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9001','SPORTLINE CITY MALL CR','Costa Rica','9001@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9001'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9002 SPORTLINE KIDS CITY MALL CR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9002','SPORTLINE KIDS CITY MALL CR','Costa Rica','9002@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9002'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9003 KICKS ALAJUELA CITY MALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9003','KICKS ALAJUELA CITY MALL','Costa Rica','9003@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9003'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9004 KICKS MP CURRIDABAT
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9004','KICKS MP CURRIDABAT','Costa Rica','9004@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9004'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9005 SPORTLINE AVE. CENTRAL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9005','SPORTLINE AVE. CENTRAL','Costa Rica','9005@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9005'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9006 SPORTLINE KIDS LINCOLN PLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9006','SPORTLINE KIDS LINCOLN PLAZA','Costa Rica','9006@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9006'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9008 KICKS LINCOLN PLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9008','KICKS LINCOLN PLAZA','Costa Rica','9008@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9008'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9009 CONVERSE LINCOLN PLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9009','CONVERSE LINCOLN PLAZA','Costa Rica','9009@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9009'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9010 UNDER ARMOUR CURRIDABAT
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9010','UNDER ARMOUR CURRIDABAT','Costa Rica','9010@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9010'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9012 SPORTLINE PASEO DE LAS FLORES
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9012','SPORTLINE PASEO DE LAS FLORES','Costa Rica','9012@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9012'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9013 KICKS MULTIPLAZA ESCAZU
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9013','KICKS MULTIPLAZA ESCAZU','Costa Rica','9013@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9013'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9014 SUPER OUTLET PASEO METROPOLI
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9014','SUPER OUTLET PASEO METROPOLI','Costa Rica','9014@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9014'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9015 CONVERSE CITY MALL ALAJUELA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9015','CONVERSE CITY MALL ALAJUELA','Costa Rica','9015@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9015'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9016 CONVERSE MULTIPLAZA ESCAZÚ
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9016','CONVERSE MULTIPLAZA ESCAZÚ','Costa Rica','9016@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9016'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9017 SPORTLINE OUTLET AVE. CENTRAL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9017','SPORTLINE OUTLET AVE. CENTRAL','Costa Rica','9017@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9017'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9018 SPORTLINE MULTIPLAZA ESCAZU
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9018','SPORTLINE MULTIPLAZA ESCAZU','Costa Rica','9018@sportline.com','sport123',true,10)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9018'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 9998 EVENTOS CR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('9998','EVENTOS CR','Costa Rica','9998@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='9998'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3001 SPORTLINE PLAZA MUNDO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3001','SPORTLINE PLAZA MUNDO','El Salvador','3001@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3001'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3002 SPORTLINE LA GRAN VÍA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3002','SPORTLINE LA GRAN VÍA','El Salvador','3002@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3002'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3003 SPORTLINE METROCENTRO ESV
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3003','SPORTLINE METROCENTRO ESV','El Salvador','3003@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3003'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3005 SPORTLINE MULTIPLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3005','SPORTLINE MULTIPLAZA','El Salvador','3005@sportline.com','sport123',true,17)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3005'; END IF;
  v_fps := 9;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3006 KICKS METROCENTRO ESV
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3006','KICKS METROCENTRO ESV','El Salvador','3006@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3006'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3007 KICKS PLAZA MUNDO ESV
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3007','KICKS PLAZA MUNDO ESV','El Salvador','3007@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3007'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3008 SPORTLINE SAN MIGUEL.
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3008','SPORTLINE SAN MIGUEL.','El Salvador','3008@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3008'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3009 SPORTLINE GALERÍAS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3009','SPORTLINE GALERÍAS','El Salvador','3009@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3009'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3010 SPORTLINE SANTA ANA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3010','SPORTLINE SANTA ANA','El Salvador','3010@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3010'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3011 SLA OUTLET. METROSUR
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3011','SLA OUTLET. METROSUR','El Salvador','3011@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3011'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3012 NIKE VALUE STORE PRESIDENTE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3012','NIKE VALUE STORE PRESIDENTE','El Salvador','3012@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3012'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3014 KICKS LA GRAN VÍA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3014','KICKS LA GRAN VÍA','El Salvador','3014@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3014'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3015 KICKS BAMBU
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3015','KICKS BAMBU','El Salvador','3015@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3015'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3016 SPORTLINE PLAZA MUNDO APOPA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3016','SPORTLINE PLAZA MUNDO APOPA','El Salvador','3016@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3016'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3017 SPORTLINE SONSONATE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3017','SPORTLINE SONSONATE','El Salvador','3017@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3017'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3018 UNDER ARMOUR MULTIPLAZA ESV
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3018','UNDER ARMOUR MULTIPLAZA ESV','El Salvador','3018@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3018'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3020 SPORTLINE PLAZA PRESIDENTE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3020','SPORTLINE PLAZA PRESIDENTE','El Salvador','3020@sportline.com','sport123',true,0)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3020'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3021 CONVERSE LA GRAN VÍA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3021','CONVERSE LA GRAN VÍA','El Salvador','3021@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3021'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3022 KIDS LA GRAN VÍA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3022','KIDS LA GRAN VÍA','El Salvador','3022@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3022'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3024 TIENDA EVENTOS 2 SLA EL SALVA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3024','TIENDA EVENTOS 2 SLA EL SALVA','El Salvador','3024@sportline.com','sport123',true,0)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3024'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3025 KICKS MULTIPLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3025','KICKS MULTIPLAZA','El Salvador','3025@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3025'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 3026 SPORTLINE CENTRO HISTORICO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('3026','SPORTLINE CENTRO HISTORICO','El Salvador','3026@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='3026'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2001 SPORTLINE PORTALES
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2001','SPORTLINE PORTALES','Guatemala','2001@sportline.com','sport123',true,10)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2001'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2002 SPORTLINE MIRAFLORES
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2002','SPORTLINE MIRAFLORES','Guatemala','2002@sportline.com','sport123',true,17)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2002'; END IF;
  v_fps := 9;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2003 OUTLET SLA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2003','OUTLET SLA','Guatemala','2003@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2003'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2004 NIKE VALUE STORE CAYALA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2004','NIKE VALUE STORE CAYALA','Guatemala','2004@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2004'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2005 SPORTLINE NARANJO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2005','SPORTLINE NARANJO','Guatemala','2005@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2005'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2006 SPORTLINE OAKLAND
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2006','SPORTLINE OAKLAND','Guatemala','2006@sportline.com','sport123',true,18)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2006'; END IF;
  v_fps := 9;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2008 NIKE STORE CAYALA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2008','NIKE STORE CAYALA','Guatemala','2008@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2008'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2009 KICKS CAYALA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2009','KICKS CAYALA','Guatemala','2009@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2009'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2010 SPORTLINE KIDS MIRAFLORES
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2010','SPORTLINE KIDS MIRAFLORES','Guatemala','2010@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2010'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2011 KICKS MIRAFLORES
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2011','KICKS MIRAFLORES','Guatemala','2011@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2011'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2013 KICKS OAKLAND MALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2013','KICKS OAKLAND MALL','Guatemala','2013@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2013'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2015 SPORTLINE VISTARES
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2015','SPORTLINE VISTARES','Guatemala','2015@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2015'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2016 SPORTLINE XELA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2016','SPORTLINE XELA','Guatemala','2016@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2016'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2017 SPORTLINE HUEHUETENANGO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2017','SPORTLINE HUEHUETENANGO','Guatemala','2017@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2017'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2018 KICKS NARANJO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2018','KICKS NARANJO','Guatemala','2018@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2018'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2019 UNDER ARMOUR OAKLAND MALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2019','UNDER ARMOUR OAKLAND MALL','Guatemala','2019@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2019'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2020 NIKE RISE OAKLAND MALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2020','NIKE RISE OAKLAND MALL','Guatemala','2020@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2020'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2021 SLA PRADERA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2021','SLA PRADERA','Guatemala','2021@sportline.com','sport123',true,0)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2021'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2022 SLA COBÁN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2022','SLA COBÁN','Guatemala','2022@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2022'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2023 SPORTLINE INTERPLAZA XELA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2023','SPORTLINE INTERPLAZA XELA','Guatemala','2023@sportline.com','sport123',true,0)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2023'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 2024 NIKE UNITE MIRAFLORES
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('2024','NIKE UNITE MIRAFLORES','Guatemala','2024@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='2024'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4001 SPORTLINE MULTIPLAZA-SPS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4001','SPORTLINE MULTIPLAZA-SPS','Honduras','4001@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4001'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4002 SPORTLINE MULTIPLAZA-TEG
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4002','SPORTLINE MULTIPLAZA-TEG','Honduras','4002@sportline.com','sport123',true,11)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4002'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4006 SPORTLINE CASCADAS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4006','SPORTLINE CASCADAS','Honduras','4006@sportline.com','sport123',true,10)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4006'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4007 SPORTLINE KIDS SPS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4007','SPORTLINE KIDS SPS','Honduras','4007@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4007'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4012 SPORTLINE CEIBA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4012','SPORTLINE CEIBA','Honduras','4012@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4012'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4013 SPORTLINE GALERÍAS DEL VALLE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4013','SPORTLINE GALERÍAS DEL VALLE','Honduras','4013@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4013'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4015 NIKE VALUE STORE SPS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4015','NIKE VALUE STORE SPS','Honduras','4015@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4015'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4016 SPORTLINE CITY MALL TEG
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4016','SPORTLINE CITY MALL TEG','Honduras','4016@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4016'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4017 SPORTLINE UNIMALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4017','SPORTLINE UNIMALL','Honduras','4017@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4017'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4018 SPORTLINE CITY MALL SPS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4018','SPORTLINE CITY MALL SPS','Honduras','4018@sportline.com','sport123',true,14)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4018'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4019 KIDS MULTIPLAZA TGU
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4019','KIDS MULTIPLAZA TGU','Honduras','4019@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4019'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4022 KICKS MULTIPLAZA TGU
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4022','KICKS MULTIPLAZA TGU','Honduras','4022@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4022'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4023 SPORTLINE MEGAMALL HON
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4023','SPORTLINE MEGAMALL HON','Honduras','4023@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4023'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4025 KICKS CITY MALL SPS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4025','KICKS CITY MALL SPS','Honduras','4025@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4025'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4026 SLA KIDS MEGAMALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4026','SLA KIDS MEGAMALL','Honduras','4026@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4026'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4027 NIKE VALUE STORE LA GALERÍA TGU
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4027','NIKE VALUE STORE LA GALERÍA TGU','Honduras','4027@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4027'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4028 SPORTLINE DOWNTOWN SPS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4028','SPORTLINE DOWNTOWN SPS','Honduras','4028@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4028'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4029 SPORTLINE KIDS CEIBA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4029','SPORTLINE KIDS CEIBA','Honduras','4029@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4029'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4030 SPORTLINE KIDS CHOLUTECA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4030','SPORTLINE KIDS CHOLUTECA','Honduras','4030@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4030'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4031 SLA MALL PREMIER
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4031','SLA MALL PREMIER','Honduras','4031@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4031'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4032 SLA KIDS MALL PREMIER
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4032','SLA KIDS MALL PREMIER','Honduras','4032@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4032'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4033 CONVERSE CITY MALL SPS CVS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4033','CONVERSE CITY MALL SPS CVS','Honduras','4033@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4033'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4035 CONVERSE MULTIPLAZA TGU CVT
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4035','CONVERSE MULTIPLAZA TGU CVT','Honduras','4035@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4035'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4036 SPORTLINE COMAYAGUA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4036','SPORTLINE COMAYAGUA','Honduras','4036@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4036'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4037 NIKE MALL MULTIPLAZA TEGUCIGAL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4037','NIKE MALL MULTIPLAZA TEGUCIGAL','Honduras','4037@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4037'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4038 SLA KIDS CASCADAS TEGUCIGALPA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4038','SLA KIDS CASCADAS TEGUCIGALPA','Honduras','4038@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4038'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4039 OLIMPIA CITY
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4039','OLIMPIA CITY','Honduras','4039@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4039'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 4040 SPORTLINE OUTLET TOWNCENTER
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('4040','SPORTLINE OUTLET TOWNCENTER','Honduras','4040@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='4040'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5001 SPORTLINE METROCENTRO NIC
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5001','SPORTLINE METROCENTRO NIC','Nicaragua','5001@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5001'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5003 SPORTLINE GALERIA STO. DOMINGO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5003','SPORTLINE GALERIA STO. DOMINGO','Nicaragua','5003@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5003'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5004 SPORTLINE OUTLET PLAZA ESTABLO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5004','SPORTLINE OUTLET PLAZA ESTABLO','Nicaragua','5004@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5004'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5005 SPORTLINE KIDS MANAGUA GALERÍA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5005','SPORTLINE KIDS MANAGUA GALERÍA','Nicaragua','5005@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5005'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5006 KICKS MANAGUA METROCENTRO NIC
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5006','KICKS MANAGUA METROCENTRO NIC','Nicaragua','5006@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5006'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5007 KIDS METROCENTRO NIC
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5007','KIDS METROCENTRO NIC','Nicaragua','5007@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5007'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5009 CONVERSE METROCENTRO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5009','CONVERSE METROCENTRO','Nicaragua','5009@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5009'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5010 CONVERSE GALERIAS SANTO DOMINGO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5010','CONVERSE GALERIAS SANTO DOMINGO','Nicaragua','5010@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5010'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5011 KICKS GALERIAS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5011','KICKS GALERIAS','Nicaragua','5011@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5011'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 5012 SPORTLINE MULTICENTRO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('5012','SPORTLINE MULTICENTRO','Nicaragua','5012@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='5012'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7016 SPORTLINE ED
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7016','SPORTLINE ED','Panamá','7016@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7016'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7021 NIKE VALUE STORE LOS PUEBLOS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7021','NIKE VALUE STORE LOS PUEBLOS','Panamá','7021@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7021'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7023 SPORTLINE LP
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7023','SPORTLINE LP','Panamá','7023@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7023'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7032 SPORTLINE LA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7032','SPORTLINE LA','Panamá','7032@sportline.com','sport123',true,9)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7032'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7035 SPORTLINE CHM
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7035','SPORTLINE CHM','Panamá','7035@sportline.com','sport123',true,10)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7035'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7041 UNDER ARMOUR MP
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7041','UNDER ARMOUR MP','Panamá','7041@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7041'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7043 NIKE SHOP MP
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7043','NIKE SHOP MP','Panamá','7043@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7043'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7055 SPORTLINE ALLBROOK 55
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7055','SPORTLINE ALLBROOK 55','Panamá','7055@sportline.com','sport123',true,27)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7055'; END IF;
  v_fps := 11;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7059 NIKE VALUE STORE PLAZA REGENCY
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7059','NIKE VALUE STORE PLAZA REGENCY','Panamá','7059@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7059'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7062 NIKE MEN MP
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7062','NIKE MEN MP','Panamá','7062@sportline.com','sport123',true,16)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7062'; END IF;
  v_fps := 9;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7076 SPORTLINE METROMALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7076','SPORTLINE METROMALL','Panamá','7076@sportline.com','sport123',true,25)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7076'; END IF;
  v_fps := 10;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7082 SPORTLINE WM
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7082','SPORTLINE WM','Panamá','7082@sportline.com','sport123',true,18)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7082'; END IF;
  v_fps := 9;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7107 SPORTLINE MULTIPLAZA PTY
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7107','SPORTLINE MULTIPLAZA PTY','Panamá','7107@sportline.com','sport123',true,41)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7107'; END IF;
  v_fps := 13;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7112 SPORTLINE MEGAMALL PTY
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7112','SPORTLINE MEGAMALL PTY','Panamá','7112@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7112'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7113 SPORTLINE LOS ANDES PLAZA SHOP
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7113','SPORTLINE LOS ANDES PLAZA SHOP','Panamá','7113@sportline.com','sport123',true,8)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7113'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7114 SPORTLINE BOULEVARD SANTIAGO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7114','SPORTLINE BOULEVARD SANTIAGO','Panamá','7114@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7114'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7120 SPORTLINE AMERICA TOWN CENTER
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7120','SPORTLINE AMERICA TOWN CENTER','Panamá','7120@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7120'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7121 SPORTLINE CHITRE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7121','SPORTLINE CHITRE','Panamá','7121@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7121'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7122 SPORTLINE AMERICA ALTA PLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7122','SPORTLINE AMERICA ALTA PLAZA','Panamá','7122@sportline.com','sport123',true,17)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7122'; END IF;
  v_fps := 9;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7137 SPORTLINE OUTLET PLAZA REGENCY
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7137','SPORTLINE OUTLET PLAZA REGENCY','Panamá','7137@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7137'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7138 NIKE TOWN CENTER
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7138','NIKE TOWN CENTER','Panamá','7138@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7138'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7142 SPORTLINE AMERICA PENONOMÉ
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7142','SPORTLINE AMERICA PENONOMÉ','Panamá','7142@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7142'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7143 UNDER ARMOUR TOWN CENTER
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7143','UNDER ARMOUR TOWN CENTER','Panamá','7143@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7143'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7145 SPORTLINE AMERICA KIDS TOWN CE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7145','SPORTLINE AMERICA KIDS TOWN CE','Panamá','7145@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7145'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7146 KICKS ALBROOK MALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7146','KICKS ALBROOK MALL','Panamá','7146@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7146'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7149 KICKS MULTIPLAZA PTY
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7149','KICKS MULTIPLAZA PTY','Panamá','7149@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7149'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7153 KICKS TOCUMEN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7153','KICKS TOCUMEN','Panamá','7153@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7153'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7169 SPORTLINE METRO PARK
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7169','SPORTLINE METRO PARK','Panamá','7169@sportline.com','sport123',true,0)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7169'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7170 CONVERSE ALBROOK 1
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7170','CONVERSE ALBROOK 1','Panamá','7170@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7170'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7171 CONVERSE METROMALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7171','CONVERSE METROMALL','Panamá','7171@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7171'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7172 CONVERSE MULTIPLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7172','CONVERSE MULTIPLAZA','Panamá','7172@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7172'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7178 NIKE ALBROOK MALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7178','NIKE ALBROOK MALL','Panamá','7178@sportline.com','sport123',true,21)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7178'; END IF;
  v_fps := 10;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7179 SPORTLINE KIDS BRISAS CAPITAL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7179','SPORTLINE KIDS BRISAS CAPITAL','Panamá','7179@sportline.com','sport123',true,2)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7179'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7181 SPORTLINE OUTLET STORE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7181','SPORTLINE OUTLET STORE','Panamá','7181@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7181'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7183 SPORTLINE CORONADO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7183','SPORTLINE CORONADO','Panamá','7183@sportline.com','sport123',true,3)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7183'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7185 SPORTLINE MARKET PLAZA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7185','SPORTLINE MARKET PLAZA','Panamá','7185@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7185'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7997 SPORTLINE MEGAPOLIS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7997','SPORTLINE MEGAPOLIS','Panamá','7997@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7997'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 7998 TIENDA EVENTOS SLA PTY
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('7998','TIENDA EVENTOS SLA PTY','Panamá','7998@sportline.com','sport123',true,1)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='7998'; END IF;
  v_fps := 6;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6001 SPORTLINE MEGACENTRO
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6001','SPORTLINE MEGACENTRO','Rep.Dominicana','6001@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6001'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6002 SPORTLINE ÁGORA
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6002','SPORTLINE ÁGORA','Rep.Dominicana','6002@sportline.com','sport123',true,11)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6002'; END IF;
  v_fps := 8;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6003 SPORTLINE SAMBIL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6003','SPORTLINE SAMBIL','Rep.Dominicana','6003@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6003'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6004 NIKE VALUE STORE LINCOLN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6004','NIKE VALUE STORE LINCOLN','Rep.Dominicana','6004@sportline.com','sport123',true,5)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6004'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6005 SPORTLINE KIDS ÁGORA MALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6005','SPORTLINE KIDS ÁGORA MALL','Rep.Dominicana','6005@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6005'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6006 SPORTLINE DOWNTOWN
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6006','SPORTLINE DOWNTOWN','Rep.Dominicana','6006@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6006'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6007 SPORTLINE GALERÍA 360
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6007','SPORTLINE GALERÍA 360','Rep.Dominicana','6007@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6007'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6008 SPORTLINE OUTLET PLAZA DUARTE
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6008','SPORTLINE OUTLET PLAZA DUARTE','Rep.Dominicana','6008@sportline.com','sport123',true,7)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6008'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6009 KICKS AH AGORA MALL
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6009','KICKS AH AGORA MALL','Rep.Dominicana','6009@sportline.com','sport123',true,4)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6009'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

  -- 6014 SPORTLINE SANTIAGO DE LOS CABALLEROS
  INSERT INTO tiendas (codigo,nombre,region,email,password_hash,activa,total_empleados)
  VALUES ('6014','SPORTLINE SANTIAGO DE LOS CABALLEROS','Rep.Dominicana','6014@sportline.com','sport123',true,6)
  ON CONFLICT (codigo) DO UPDATE SET total_empleados = EXCLUDED.total_empleados
  RETURNING id INTO v_id;
  IF v_id IS NULL THEN SELECT id INTO v_id FROM tiendas WHERE codigo='6014'; END IF;
  v_fps := 7;
  FOR v_sem IN SELECT id FROM semanas ORDER BY numero LOOP
    SELECT COUNT(*) INTO v_exist FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id AND desbloqueado=false;
    FOR i IN 1..GREATEST(0, v_fps - v_exist) LOOP
      INSERT INTO fichas_tienda (tienda_id,semana_id,numero_ficha,desbloqueado)
      VALUES (v_id, v_sem.id,
        (SELECT COALESCE(MAX(numero_ficha),0)+1 FROM fichas_tienda WHERE tienda_id=v_id AND semana_id=v_sem.id),
        false);
    END LOOP;
  END LOOP;

END $$;

SELECT COUNT(*) as tiendas_total FROM tiendas;
SELECT COUNT(*) as fichas_total  FROM fichas_tienda;
