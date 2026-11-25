import '../entities/import_models.dart';

/// Copies photos off cameras and memory cards into dated folders. Never
/// deletes anything from the source and never overwrites a file.
abstract class ImportService {
  /// Mounted cameras and cards that have a DCIM folder.
  Future<List<ImportSource>> findSources();

  /// Photos under [sourcePath] (its DCIM folder if it has one), oldest
  /// first, each marked if it was imported into [destinationRoot] before.
  Future<List<ImportCandidate>> scan(String sourcePath, String destinationRoot);

  /// Where [candidate] goes: `<root>/<yyyy>/<yyyy-mm-dd>/<name>`.
  String destinationFolder(ImportCandidate candidate, String destinationRoot);

  Stream<ImportProgress> import(
    List<ImportCandidate> candidates,
    String destinationRoot,
  );
}
