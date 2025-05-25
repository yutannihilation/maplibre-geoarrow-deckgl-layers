-- arrow
INSTALL arrow FROM community;
LOAD arrow;

-- spatial
INSTALL spatial;
LOAD spatial;

CREATE TABLE t1 AS
SELECT
    ST_Point2D(
        RANDOM() * 360 - 180,  -- Longitude: random between -180 and 180
        RANDOM() * 180 - 90    -- Latitude: random between -90 and 90
    ) AS geom,
    RANDOM() as "value"
FROM range(100000);

COPY t1 TO 'static/points.arrow';