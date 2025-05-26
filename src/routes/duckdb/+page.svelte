<script lang="ts">
	import { MapLibre } from 'svelte-maplibre-gl';
	import { DeckGLOverlay } from 'svelte-maplibre-gl/deckgl';
	import { GeoArrowScatterplotLayer } from '@geoarrow/deck.gl-layers';

	import * as duckdb from '@duckdb/duckdb-wasm';
	import duckdb_wasm_eh from '@duckdb/duckdb-wasm/dist/duckdb-eh.wasm?url';
	import eh_worker from '@duckdb/duckdb-wasm/dist/duckdb-browser-eh.worker.js?url';

	import * as arrow from 'apache-arrow';

	import { onMount } from 'svelte';

	let nPoints = $state(0);

	let dataPoints: arrow.Table | undefined = $state();
	const updateDataPoints = async (nPoints: number) => {
		if (stmt) {
			const result = await stmt.query(nPoints);
			dataPoints = result as unknown as arrow.Table;
		}
	};

	$effect(() => {
		updateDataPoints(nPoints);
	});

	let db: duckdb.AsyncDuckDB | undefined;
	let conn: duckdb.AsyncDuckDBConnection | undefined;
	let stmt: duckdb.AsyncPreparedStatement | undefined;

	onMount(async () => {
		const worker = new Worker(eh_worker);
		const logger = new duckdb.ConsoleLogger();

		db = new duckdb.AsyncDuckDB(logger, worker);
		await db.instantiate(duckdb_wasm_eh, eh_worker);

		await db.open({});
		conn = await db.connect();
		await conn.query('LOAD spatial');

		stmt = await conn.prepare(
			`
SELECT
    ST_Point2D(
        RANDOM() * 360 - 180,  -- Longitude: random between -180 and 180
        RANDOM() * 180 - 90    -- Latitude: random between -90 and 90
    ) AS geom,
    RANDOM() as "value"
FROM range(?::BIGINT);
			`
		);

		nPoints = 10000; // initial value
	});
</script>

<div class="px-10 text-2xl">
	<label>
		number of points:
		<input type="number" bind:value={nPoints} min="10000" max="1000000" step="10000" />
	</label>
</div>

<MapLibre
	class="h-[60vh] w-[60vw]"
	style="https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"
>
	<DeckGLOverlay
		interleaved
		layers={[
			dataPoints
				? new GeoArrowScatterplotLayer({
						id: 'geoarrow-points',
						data: dataPoints,
						getPosition: dataPoints.getChild('geom')!,
						radiusMinPixels: 0.4,
						radiusUnits: 'pixels'
					})
				: null
		]}
	/>
</MapLibre>
