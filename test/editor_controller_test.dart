import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/export_options.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/editor/presentation/controllers/editor_controller.dart';
import 'package:oiv/editor/presentation/models/editor_state.dart';

import 'support/editor_fakes.dart';

const _path = '/photos/a.jpg';
const _halfCrop = CropEdit(NormalizedRect(0, 0, 0.5, 1));

void main() {
  late InMemoryImageEditRepository repository;
  late FakePixelSource pixels;
  late SyncRenderService renderer;
  late FakeExportService exporter;

  EditorController create() => EditorController(
    path: _path,
    repository: repository,
    pixelSource: pixels,
    renderService: renderer,
    exportService: exporter,
    previewMaxDimension: 512,
  );

  setUp(() {
    repository = InMemoryImageEditRepository();
    pixels = FakePixelSource();
    renderer = SyncRenderService();
    exporter = FakeExportService();
  });

  test('opens with saved edits applied at preview size', () async {
    repository.stored[_path] = const ImageEdits([_halfCrop]);
    final controller = create();

    await controller.open();

    final state = controller.state;
    expect(state.isLoading, isFalse);
    expect(state.edits.operations, [_halfCrop]);
    expect((state.base!.width, state.base!.height), (20, 20));
    expect(pixels.loads.single, (_path, 512));
  });

  test('reports images that cannot be decoded', () async {
    pixels.image = null;
    final controller = create();

    await controller.open();

    expect(controller.state.loadFailed, isTrue);
    controller.selectTool(EditorTool.crop);
    expect(controller.state.tool, EditorTool.none);
  });

  test('applying a tool saves the edit and re-renders', () async {
    final controller = create();
    await controller.open();

    controller.selectTool(EditorTool.crop);
    controller.updateDraft(_halfCrop);
    await controller.applyTool();

    expect(controller.state.tool, EditorTool.none);
    expect(controller.state.draft, isNull);
    expect(repository.stored[_path]?.operations, [_halfCrop]);
    expect(controller.state.base!.width, 20);
    expect(controller.state.canUndo, isTrue);
  });

  test('a draft that changes nothing is not recorded', () async {
    final controller = create();
    await controller.open();

    controller.selectTool(EditorTool.straighten);
    await controller.applyTool();

    expect(controller.state.edits, ImageEdits.none);
    expect(repository.saveCount, 0);
  });

  test('colour drafts are previewed without being saved', () async {
    final controller = create();
    await controller.open();
    final base = controller.state.base!;

    controller.selectEffect(EffectKind.blackAndWhite);
    await pumpEventQueue();

    final preview = controller.state.preview!;
    expect(identical(preview, base), isFalse);
    expect(preview.pixels[0], preview.pixels[1]);
    expect(repository.saveCount, 0);

    controller.cancelTool();
    expect(identical(controller.state.preview, base), isTrue);
  });

  test('undo, redo and revert walk the history', () async {
    final controller = create();
    await controller.open();
    await controller.rotate(1);
    await controller.autoFix(AutoFixKind.autoContrast);

    expect(controller.state.edits.operations, hasLength(2));

    await controller.undo();
    expect(controller.state.edits.operations, [const RotateEdit(1)]);
    expect(controller.state.canRedo, isTrue);

    await controller.redo();
    expect(controller.state.edits.operations, hasLength(2));

    await controller.revert();
    expect(controller.state.edits, ImageEdits.none);
    expect(repository.stored.containsKey(_path), isFalse);

    await controller.undo();
    expect(controller.state.edits.operations, hasLength(2));
    expect(repository.stored[_path]?.operations, hasLength(2));
  });

  test('consecutive rotations merge, and a full turn cancels out', () async {
    final controller = create();
    await controller.open();

    await controller.rotate(1);
    await controller.rotate(1);
    expect(controller.state.edits.operations, [const RotateEdit(2)]);
    expect(
      (controller.state.base!.width, controller.state.base!.height),
      (40, 20),
    );

    await controller.rotate(-1);
    await controller.rotate(-1);
    expect(controller.state.edits, ImageEdits.none);
  });

  test('one-click edits close an open tool first', () async {
    final controller = create();
    await controller.open();
    controller.selectTool(EditorTool.crop);
    controller.updateDraft(_halfCrop);

    await controller.rotate(1);

    expect(controller.state.tool, EditorTool.none);
    expect(controller.state.edits.operations, [const RotateEdit(1)]);
  });

  test('a failed save keeps the edit and tells the user', () async {
    repository.failSaves = true;
    final controller = create();
    await controller.open();

    await controller.rotate(1);

    expect(controller.state.edits.operations, [const RotateEdit(1)]);
    expect(controller.state.notice?.type, EditorNoticeType.saveFailed);
  });

  test('export passes the applied edits on and reports the result', () async {
    final controller = create();
    await controller.open();
    await controller.rotate(1);

    final exported = await controller.export(const ExportOptions(), '/out');

    expect(exported, '/out/a.jpg');
    expect(exporter.calls.single.$2.operations, [const RotateEdit(1)]);
    expect(controller.state.notice?.type, EditorNoticeType.exported);
    expect(controller.state.isBusy, isFalse);

    exporter.failing = {_path};
    await controller.export(const ExportOptions(), '/out');
    expect(controller.state.notice?.type, EditorNoticeType.exportFailed);
  });
}
