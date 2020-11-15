CREATE TYPE step_type AS ENUM ('given', 'when', 'then');

CREATE TABLE features (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(256) UNIQUE NOT NULL,
  description TEXT,
  tags TEXT[] DEFAULT '{}',
  search TSVECTOR GENERATED ALWAYS AS (
    (
      setweight(to_tsvector('english', array2string(tags)), 'A') || ' ' ||
      setweight(to_tsvector('english', name), 'B') || ' ' ||
      setweight(to_tsvector('english', description), 'C')
    )::tsvector
  ) STORED,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE features OWNER TO odin;

-- CREATE TRIGGER notify_features
-- AFTER INSERT OR UPDATE
-- ON main.features
-- FOR EACH ROW
--   EXECUTE PROCEDURE main.tg_notify('notifications');

CREATE TABLE scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  feature UUID REFERENCES features(id) ON DELETE CASCADE,
  name VARCHAR(256) NOT NULL,
  tags TEXT[] DEFAULT '{}',
  search TSVECTOR GENERATED ALWAYS AS (
    (
      setweight(to_tsvector('english', array2string(tags)), 'A') || ' ' ||
      setweight(to_tsvector('english', name), 'B')
    )::tsvector
  ) STORED,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (feature, name) -- We cannot have multiple scenarios with the same name under one feature
);

ALTER TABLE scenarios OWNER TO odin;

-- CREATE TRIGGER notify_scenarios
-- AFTER INSERT OR UPDATE
-- ON main.scenarios
-- FOR EACH ROW
--   EXECUTE PROCEDURE main.tg_notify('scenarios');

CREATE TABLE backgrounds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  feature UUID REFERENCES features(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (feature) -- A feature can have only at most one background
);

ALTER TABLE backgrounds OWNER TO odin;

-- CREATE TRIGGER notify_backgrounds
-- AFTER INSERT OR UPDATE
-- ON main.backgrounds
-- FOR EACH ROW
--   EXECUTE PROCEDURE main.tg_notify('backgrounds');

CREATE TABLE steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  step_type step_type,
  value VARCHAR(256),
  docstring VARCHAR(256),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE steps OWNER TO odin;

CREATE TABLE background_step_map (
  background UUID REFERENCES backgrounds(id) ON DELETE CASCADE,
  step UUID REFERENCES steps(id) ON DELETE CASCADE,
  PRIMARY KEY (background, step)
);

ALTER TABLE background_step_map OWNER TO odin;

CREATE TABLE scenario_step_map (
  scenario UUID REFERENCES scenarios(id) ON DELETE CASCADE,
  step UUID REFERENCES steps(id) ON DELETE CASCADE,
  PRIMARY KEY (scenario, step)
);

ALTER TABLE scenario_step_map OWNER TO odin;
