CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

SET CLIENT_MIN_MESSAGES TO INFO;
SET CLIENT_ENCODING = 'UTF8';

-- For aggregating tags
-- See https://stackoverflow.com/questions/31210790/indexing-an-array-for-full-text-search
--
CREATE OR REPLACE FUNCTION array2string(TEXT[])
  RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$SELECT array_to_string($1, ',')$$;

CREATE OR REPLACE FUNCTION random_signature()
  RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$SELECT MD5(RANDOM()::TEXT)$$;

CREATE OR REPLACE FUNCTION index_signature(VARCHAR(64), VARCHAR(64), TEXT[])
  RETURNS VARCHAR(128) LANGUAGE SQL IMMUTABLE AS $$SELECT MD5($1 || '-' || $2 || '-' || array2string($3))$$;

