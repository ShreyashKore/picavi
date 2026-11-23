import 'dart:math' as math;

import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/geo_point.dart';

/// Photos taken close together, shown as one marker on the map.
class PlaceCluster {
  const PlaceCluster(this.center, this.images);

  final GeoPoint center;
  final List<CatalogImage> images;
}

/// Groups photos into map cells about [cellPixels] wide at [zoom] (web
/// Mercator, 256-pixel tiles), so markers never pile up.
List<PlaceCluster> clusterPlaces(
  List<CatalogImage> images,
  double zoom, {
  double cellPixels = 64,
}) {
  final worldPixels = 256 * math.pow(2, zoom);
  final cellDegrees = 360 * cellPixels / worldPixels;
  final cells = <(int, int), List<CatalogImage>>{};
  for (final image in images) {
    final location = image.location;
    if (location == null) {
      continue;
    }
    final key = (
      (location.latitude / cellDegrees).floor(),
      (location.longitude / cellDegrees).floor(),
    );
    (cells[key] ??= []).add(image);
  }
  return [
    for (final members in cells.values)
      PlaceCluster(
        GeoPoint(
          members.map((i) => i.location!.latitude).reduce((a, b) => a + b) /
              members.length,
          members.map((i) => i.location!.longitude).reduce((a, b) => a + b) /
              members.length,
        ),
        members,
      ),
  ]..sort((a, b) => b.images.length.compareTo(a.images.length));
}
