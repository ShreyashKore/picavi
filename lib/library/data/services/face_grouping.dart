import 'dart:math' as math;
import 'dart:typed_data';

import '../../domain/entities/face.dart';

/// Faces closer than this (unit-length fingerprints) are grouped together
/// as probably the same person. Deliberately strict: a group that mixes two
/// people is worse than one person split over two groups. Not tuned on a
/// real photo collection yet.
const double faceGroupThreshold = 0.55;

/// Unnamed faces closer than this to someone's faces are offered as "might
/// be them" for the user to confirm.
const double faceSuggestThreshold = 0.7;

Float32List normalizedPrint(Float32List print) {
  var sum = 0.0;
  for (final value in print) {
    sum += value * value;
  }
  final length = math.sqrt(sum);
  if (length == 0) {
    return print;
  }
  return Float32List.fromList([for (final value in print) value / length]);
}

/// Euclidean distance between unit-length fingerprints: 0 (same) to 2.
double faceDistance(Float32List a, Float32List b) {
  if (a.length != b.length) {
    return double.infinity;
  }
  var sum = 0.0;
  for (var i = 0; i < a.length; i++) {
    final d = a[i] - b[i];
    sum += d * d;
  }
  return math.sqrt(sum);
}

/// Greedy grouping: each face joins the nearest group whose average is
/// within [threshold], else starts a new one. Largest groups first.
List<List<CatalogFace>> groupFaces(
  List<CatalogFace> faces, {
  double threshold = faceGroupThreshold,
}) {
  final groups = <List<CatalogFace>>[];
  final centroids = <Float32List>[];
  final loose = <CatalogFace>[];
  for (final face in faces) {
    final print = face.print;
    if (print == null || print.isEmpty) {
      loose.add(face);
      continue;
    }
    final normalized = normalizedPrint(print);
    var best = -1;
    var bestDistance = double.infinity;
    for (var i = 0; i < centroids.length; i++) {
      final distance = faceDistance(normalized, centroids[i]);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = i;
      }
    }
    if (best >= 0 && bestDistance < threshold) {
      final group = groups[best]..add(face);
      final centroid = centroids[best];
      final n = group.length;
      for (var i = 0; i < centroid.length; i++) {
        centroid[i] = (centroid[i] * (n - 1) + normalized[i]) / n;
      }
      centroids[best] = normalizedPrint(centroid);
    } else {
      groups.add([face]);
      centroids.add(Float32List.fromList(normalized));
    }
  }
  groups.sort((a, b) => b.length.compareTo(a.length));
  // Faces without a fingerprint can't be grouped: one group each.
  return [
    ...groups,
    for (final face in loose) [face],
  ];
}

/// Unnamed faces that look like [person]'s faces, best match first.
List<CatalogFace> suggestFaces(
  List<CatalogFace> person,
  List<CatalogFace> candidates, {
  double threshold = faceSuggestThreshold,
}) {
  final known = [
    for (final face in person)
      if (face.print != null) normalizedPrint(face.print!),
  ];
  if (known.isEmpty) {
    return const [];
  }
  final scored = <(CatalogFace, double)>[];
  for (final candidate in candidates) {
    if (candidate.print == null || candidate.name != null) {
      continue;
    }
    final normalized = normalizedPrint(candidate.print!);
    final distance = known
        .map((print) => faceDistance(normalized, print))
        .reduce(math.min);
    if (distance < threshold) {
      scored.add((candidate, distance));
    }
  }
  scored.sort((a, b) => a.$2.compareTo(b.$2));
  return [for (final (face, _) in scored) face];
}
