/// Field a folder's images can be ordered by.
enum ImageSortField { name, modified, size, type }

/// How the images of a folder are ordered in the gallery.
class ImageSortOrder {
  const ImageSortOrder({
    this.field = ImageSortField.name,
    this.ascending = true,
  });

  /// Restores an order persisted with [storageKey], falling back to the
  /// default for unknown or missing values.
  factory ImageSortOrder.fromStorageKey(String? key) {
    if (key == null) {
      return const ImageSortOrder();
    }

    final parts = key.split(':');
    final field = ImageSortField.values
        .where((candidate) => candidate.name == parts.first)
        .firstOrNull;
    if (field == null) {
      return const ImageSortOrder();
    }

    return ImageSortOrder(
      field: field,
      ascending: parts.length < 2 || parts[1] != 'desc',
    );
  }

  final ImageSortField field;
  final bool ascending;

  String get storageKey => '${field.name}:${ascending ? 'asc' : 'desc'}';

  ImageSortOrder copyWith({ImageSortField? field, bool? ascending}) {
    return ImageSortOrder(
      field: field ?? this.field,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ImageSortOrder &&
      other.field == field &&
      other.ascending == ascending;

  @override
  int get hashCode => Object.hash(field, ascending);
}
