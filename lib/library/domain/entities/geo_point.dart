/// A place on Earth in degrees (WGS 84, as cameras record it).
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  bool get isValid =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180 &&
      !(latitude == 0 && longitude == 0);

  List<double> toJson() => [latitude, longitude];

  static GeoPoint? fromJson(Object? json) {
    if (json is! List || json.length != 2) {
      return null;
    }
    final values = json.whereType<num>().map((v) => v.toDouble()).toList();
    if (values.length != 2) {
      return null;
    }
    final point = GeoPoint(values[0], values[1]);
    return point.isValid ? point : null;
  }

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}

/// A latitude/longitude box (not crossing the antimeridian).
class GeoBounds {
  const GeoBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final double south;
  final double west;
  final double north;
  final double east;

  bool contains(GeoPoint point) =>
      point.latitude >= south &&
      point.latitude <= north &&
      point.longitude >= west &&
      point.longitude <= east;
}
