CREATE TABLE IF NOT EXISTS media (
  id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  guid UUID DEFAULT uuidv7(),
  filename TEXT,
  data OID
);

CREATE OR REPLACE PROCEDURE insert_text_file(
  p_filename TEXT,
  p_content TEXT
) AS $$
DECLARE
  v_data BYTEA;
  v_oid OID;
BEGIN
  v_data := convert_to(p_content, 'UTF8');
  v_oid := lo_create(0);

  PERFORM lo_put(v_oid, 0, v_data);

  INSERT INTO media (filename, data) VALUES (p_filename, v_oid);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION read_text_file(
  p_filename TEXT
) RETURNS TEXT AS $$
DECLARE
  v_oid OID;
BEGIN
  SELECT data INTO v_oid FROM media m WHERE m.filename = p_filename;

  RETURN convert_from(lo_get(v_oid), 'UTF8');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE update_text_file(
  p_filename TEXT,
  p_text TEXT,
  p_offset BIGINT DEFAULT 0
) AS $$
DECLARE
  v_oid OID;
BEGIN
  SELECT data INTO v_oid FROM media m WHERE m.filename = p_filename;

  PERFORM lo_put(v_oid, p_offset, convert_to(p_text, 'UTF8'));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE remove_text_file(
  p_filename TEXT
) AS $$
DECLARE
  v_oid OID;
BEGIN
  SELECT data INTO v_oid FROM media m WHERE m.filename = p_filename;

  PERFORM lo_unlink(v_oid);

  DELETE FROM media m WHERE m.filename = p_filename;
END;
$$ LANGUAGE plpgsql;
