-- arrow
INSTALL arrow FROM community;
LOAD arrow;

-- spatial
INSTALL spatial;
LOAD spatial;

CREATE TABLE t1 AS
SELECT
    ST_MakeLine(
        ST_Point2D(x,                 y                ),
        ST_Point2D(x + RANDOM() * 10, y + RANDOM() * 10)
    )::LINESTRING_2D as geom,
    RANDOM() as "value"
FROM (
    SELECT RANDOM() * 360 - 180 as x,
           RANDOM() * 180 - 90  as y
    FROM range(10000)
);

COPY t1 TO 'static/lines.arrow';
