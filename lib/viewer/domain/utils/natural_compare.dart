final RegExp _chunkPattern = RegExp(r'(\d+|\D+)');

/// Case-insensitive comparison that orders embedded numbers by value, so
/// `IMG_2.jpg` sorts before `IMG_10.jpg`.
int compareNaturally(String left, String right) {
  final leftChunks = _chunkPattern
      .allMatches(left.toLowerCase())
      .map((match) => match.group(0)!)
      .toList(growable: false);
  final rightChunks = _chunkPattern
      .allMatches(right.toLowerCase())
      .map((match) => match.group(0)!)
      .toList(growable: false);

  final sharedLength = leftChunks.length < rightChunks.length
      ? leftChunks.length
      : rightChunks.length;
  for (var index = 0; index < sharedLength; index++) {
    final leftChunk = leftChunks[index];
    final rightChunk = rightChunks[index];
    final leftNumber = BigInt.tryParse(leftChunk);
    final rightNumber = BigInt.tryParse(rightChunk);

    final result = leftNumber != null && rightNumber != null
        ? leftNumber.compareTo(rightNumber)
        : leftChunk.compareTo(rightChunk);
    if (result != 0) {
      return result;
    }
  }

  final lengthResult = leftChunks.length.compareTo(rightChunks.length);
  return lengthResult != 0 ? lengthResult : left.compareTo(right);
}
