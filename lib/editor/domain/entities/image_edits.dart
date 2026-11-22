import 'edit_operation.dart';

/// The ordered, non-destructive edits of one image. The original file is
/// never changed; the edits are replayed on top of it.
class ImageEdits {
  const ImageEdits([this.operations = const <EditOperation>[]]);

  static const ImageEdits none = ImageEdits();

  final List<EditOperation> operations;

  bool get isEmpty => operations.isEmpty;
  bool get isNotEmpty => operations.isNotEmpty;

  ImageEdits adding(EditOperation operation) =>
      ImageEdits([...operations, operation]);

  ImageEdits withoutLast() => operations.isEmpty
      ? this
      : ImageEdits(operations.sublist(0, operations.length - 1));

  List<Object?> toJson() => [for (final op in operations) op.toJson()];

  static ImageEdits fromJson(Object? json) {
    if (json is! List) {
      return none;
    }
    return ImageEdits(
      json.map(EditOperation.fromJson).whereType<EditOperation>().toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! ImageEdits || other.operations.length != operations.length) {
      return false;
    }
    for (var i = 0; i < operations.length; i++) {
      if (other.operations[i] != operations[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(operations);
}
