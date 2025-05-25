<script lang="ts">
	import { MapLibre } from 'svelte-maplibre-gl';
	import { DeckGLOverlay } from 'svelte-maplibre-gl/deckgl';
	import { GeoArrowPathLayer, GeoArrowScatterplotLayer } from '@geoarrow/deck.gl-layers';
	import * as arrow from 'apache-arrow';
	import { onMount } from 'svelte';

	let data_points: arrow.Table | undefined = $state();
	let data_lines: arrow.Table | undefined = $state();

	onMount(async () => {
		const resp1 = await fetch('/points.arrow');
		data_points = await arrow.tableFromIPC(resp1);

		const resp2 = await fetch('/lines.arrow');
		data_lines = await arrow.tableFromIPC(resp2);

		console.log(data_lines);
	});
</script>

<MapLibre
	class="h-[80vh] w-[80vw]"
	style="https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"
>
	<DeckGLOverlay
		interleaved
		layers={[
			data_points
				? new GeoArrowScatterplotLayer({
						id: 'geoarrow-points',
						data: data_points,
						getPosition: data_points.getChild('geom')!,
						radiusMinPixels: 0.4,
						radiusUnits: 'pixels'
					})
				: null,
			data_lines
				? new GeoArrowPathLayer({
						id: 'geoarrow-lines',
						data: data_lines,
						getPath: data_lines.getChild('geom')!,
						positionFormat: 'XY',
						getColor: [255, 0, 0],
						widthMinPixels: 1
					})
				: null
		]}
	/>
</MapLibre>
