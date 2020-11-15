-- This type is used to return a background to the client. We skip some fields, like search
CREATE TYPE return_background_type AS (
    id UUID
  , created_at TIMESTAMPTZ
  , updated_at TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION create_background (
  _feature UUID    -- feature id  (1)
) RETURNS return_background_type
AS $$
DECLARE
  res return_background_type;
BEGIN
  INSERT INTO backgrounds (feature) VALUES (
    $1 -- feature
  )
  ON CONFLICT (feature) DO
    NOTHING
  RETURNING id, created_at, updated_at INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;
