-- arrow
INSTALL arrow FROM community;
LOAD arrow;

-- spatial
INSTALL spatial;
LOAD spatial;

CREATE TABLE t1 AS
SELECT
    ST_MakePolygon(
        ST_MakeLine([
            ST_Point(x,                 y               ),
            ST_Point(x + RANDOM() * 3,  y + RANDOM() * 3),
            ST_Point(x + RANDOM() * 3,  y + RANDOM() * 3),
            ST_Point(x,                 y               )
        ])
    )::POLYGON_2D as geom,
    RANDOM() as "value"
FROM (
    SELECT RANDOM() * 360 - 180 as x,
           RANDOM() * 180 - 90  as y
    FROM range(10000)
);

COPY t1 TO 'static/polygons.arrow';
