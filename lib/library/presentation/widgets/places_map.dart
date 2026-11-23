import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../data/services/thumbnail_cache.dart';
import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/geo_point.dart';
import '../models/place_clusters.dart';

/// OpenStreetMap tiles. Their usage policy asks apps to identify themselves
/// and to show the attribution.
const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const String osmUserAgentPackage = 'com.gyanoba.oiv';

TileLayer osmTileLayer() => TileLayer(
  urlTemplate: osmTileUrl,
  userAgentPackageName: osmUserAgentPackage,
  maxNativeZoom: 19,
);

Widget osmAttribution() =>
    const SimpleAttributionWidget(source: Text('OpenStreetMap contributors'));

LatLng toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);

/// The library's Places view: photos clustered on a map. Tapping a
/// cluster calls [onClusterSelected] with its photos.
class PlacesMap extends StatefulWidget {
  const PlacesMap({
    super.key,
    required this.images,
    required this.cache,
    required this.onClusterSelected,
  });

  final List<CatalogImage> images;
  final ThumbnailCache cache;
  final ValueChanged<List<CatalogImage>> onClusterSelected;

  @override
  State<PlacesMap> createState() => _PlacesMapState();
}

class _PlacesMapState extends State<PlacesMap> {
  double _zoom = 3;

  @override
  Widget build(BuildContext context) {
    final points = [
      for (final image in widget.images)
        if (image.location != null) toLatLng(image.location!),
    ];
    final clusters = clusterPlaces(widget.images, _zoom);
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(20, 0),
        initialZoom: 2,
        minZoom: 2,
        maxZoom: 18,
        initialCameraFit: points.length > 1
            ? CameraFit.coordinates(
                coordinates: points,
                padding: const EdgeInsets.all(60),
                maxZoom: 14,
              )
            : null,
        onPositionChanged: (camera, _) {
          final zoom = camera.zoom.roundToDouble();
          if (zoom != _zoom) {
            setState(() => _zoom = zoom);
          }
        },
      ),
      children: [
        osmTileLayer(),
        MarkerLayer(
          markers: [
            for (final cluster in clusters)
              Marker(
                point: toLatLng(cluster.center),
                width: 64,
                height: 64,
                child: _ClusterMarker(
                  cluster: cluster,
                  cache: widget.cache,
                  onTap: () => widget.onClusterSelected(cluster.images),
                ),
              ),
          ],
        ),
        osmAttribution(),
      ],
    );
  }
}

class _ClusterMarker extends StatelessWidget {
  const _ClusterMarker({
    required this.cluster,
    required this.cache,
    required this.onTap,
  });

  final PlaceCluster cluster;
  final ThumbnailCache cache;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = cluster.images.length;
    return Tooltip(
      message: context.l10n.libraryPhotoCount(count),
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(blurRadius: 6, color: Colors.black54),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image(
                      image: CachedThumbnailImage(cache, cluster.images.first),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Colors.black45),
                    ),
                  ),
                ),
              ),
              if (count > 1)
                PositionedDirectional(
                  top: -8,
                  end: -8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Text(
                        '$count',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets the user tap the map to choose where photos were taken. Returns
/// the chosen point, [LocationChoice.remove], or null if cancelled.
Future<LocationChoice?> showLocationPicker(
  BuildContext context, {
  GeoPoint? initial,
  required bool canRemove,
}) {
  return showDialog<LocationChoice>(
    context: context,
    builder: (context) =>
        _LocationPickerDialog(initial: initial, canRemove: canRemove),
  );
}

/// The result of the location picker.
class LocationChoice {
  const LocationChoice(this.point);

  static const LocationChoice remove = LocationChoice(null);

  /// The chosen place; null means "remove the location set by hand".
  final GeoPoint? point;
}

class _LocationPickerDialog extends StatefulWidget {
  const _LocationPickerDialog({required this.initial, required this.canRemove});

  final GeoPoint? initial;
  final bool canRemove;

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  late GeoPoint? _point = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final point = _point;
    return AlertDialog(
      title: Text(l10n.placesSetLocation),
      content: SizedBox(
        width: 640,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.placesPickHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point == null
                        ? const LatLng(20, 0)
                        : toLatLng(point),
                    initialZoom: point == null ? 2 : 12,
                    minZoom: 2,
                    maxZoom: 18,
                    onTap: (_, latLng) => setState(
                      () =>
                          _point = GeoPoint(latLng.latitude, latLng.longitude),
                    ),
                  ),
                  children: [
                    osmTileLayer(),
                    if (point != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: toLatLng(point),
                            width: 40,
                            height: 40,
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                              shadows: const [Shadow(blurRadius: 4)],
                            ),
                          ),
                        ],
                      ),
                    osmAttribution(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              point == null
                  ? l10n.placesNoPointYet
                  : '${point.latitude.toStringAsFixed(5)}, '
                        '${point.longitude.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      actions: [
        if (widget.canRemove)
          TextButton(
            onPressed: () => Navigator.of(context).pop(LocationChoice.remove),
            child: Text(l10n.placesRemoveLocation),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelLabel),
        ),
        FilledButton(
          onPressed: point == null
              ? null
              : () => Navigator.of(context).pop(LocationChoice(point)),
          child: Text(l10n.saveLabel),
        ),
      ],
    );
  }
}
