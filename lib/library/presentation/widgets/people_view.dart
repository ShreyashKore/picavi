import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../data/services/thumbnail_cache.dart';
import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/face.dart';
import '../controllers/people_controller.dart';
import 'library_dialogs.dart';
import 'library_grid.dart';

/// The library's People view: named people, unnamed faces grouped by
/// likeness, and each person's photos.
class PeopleView extends StatefulWidget {
  const PeopleView({
    super.key,
    required this.controller,
    required this.cache,
    required this.onOpen,
  });

  final PeopleController controller;
  final ThumbnailCache cache;
  final ValueChanged<CatalogImage> onOpen;

  @override
  State<PeopleView> createState() => _PeopleViewState();
}

class _PeopleViewState extends State<PeopleView> {
  /// How many unnamed groups to show before "Show more".
  int _groupLimit = 30;
  Set<String> _personSelection = const {};

  PeopleController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (_controller.state.saveFailed && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.photoInfoSaveFailedNotice)),
        );
    }
    setState(() {});
  }

  Future<void> _name(List<CatalogFace> faces, {String initial = ''}) async {
    final name = await showPersonNameDialog(
      context,
      names: [for (final person in _controller.state.people) person.name],
      initial: initial,
      faceCount: faces.length,
    );
    if (name != null) {
      await _controller.nameFaces(faces, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = _controller.state;
    final theme = Theme.of(context);

    if (!state.isAvailable) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            l10n.peopleUnavailable,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ),
      );
    }
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final scan = state.scan;
    final status = Material(
      color: AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (state.isScanning) ...[
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  value: scan!.found == 0 ? null : scan.processed / scan.found,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.peopleScanning(scan.processed, scan.found)),
              ),
            ] else
              Expanded(
                child: Text(
                  l10n.peopleSummary(state.people.length, state.unnamedCount),
                ),
              ),
            Text(
              l10n.peoplePrivacy,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      children: [
        status,
        Expanded(
          child: state.person == null
              ? _buildOverview(state)
              : _buildPerson(state, state.person!),
        ),
      ],
    );
  }

  Widget _buildOverview(PeopleState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final groups = state.groups.take(_groupLimit).toList();
    if (state.people.isEmpty && state.groups.isEmpty) {
      return Center(
        child: Text(
          state.isScanning ? l10n.peopleLookingForFaces : l10n.peopleNoFaces,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.people.isNotEmpty) ...[
          Text(l10n.peopleNamed, style: theme.textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final person in state.people)
                _PersonCard(
                  person: person,
                  onTap: () => unawaited(_controller.openPerson(person.name)),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        if (state.groups.isNotEmpty) ...[
          Text(l10n.peopleUnnamed, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            l10n.peopleUnnamedHint,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 10),
          for (final group in groups)
            _GroupCard(
              group: group,
              selected: state.selectedFaces,
              onToggle: _controller.toggleFace,
              onName: () => unawaited(_name(_controller.targetsIn(group))),
              onIgnore: () => unawaited(
                _controller.ignoreFaces(_controller.targetsIn(group)),
              ),
            ),
          if (state.groups.length > groups.length)
            Align(
              child: TextButton(
                onPressed: () => setState(() => _groupLimit += 30),
                child: Text(
                  l10n.peopleShowMore(state.groups.length - groups.length),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildPerson(PeopleState state, String person) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.peopleBack,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => unawaited(_controller.openPerson(null)),
              ),
              Expanded(
                child: Text(
                  '$person · ${l10n.libraryPhotoCount(state.personImages.length)}',
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final name = await showPersonNameDialog(
                    context,
                    names: [for (final p in state.people) p.name],
                    initial: person,
                    faceCount: state.personFaces.length,
                  );
                  if (name != null && name != person) {
                    await _controller.renamePerson(person, name);
                  }
                },
                child: Text(l10n.peopleRename),
              ),
              TextButton(
                onPressed: () async {
                  final ok = await confirm(
                    context,
                    title: l10n.peopleForgetTitle(person),
                    message: l10n.peopleForgetMessage,
                    confirmLabel: l10n.peopleForget,
                  );
                  if (ok) {
                    await _controller.removePerson(person);
                  }
                },
                child: Text(l10n.peopleForget),
              ),
            ],
          ),
        ),
        if (state.suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.peopleIsThis(person),
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 108,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.suggestions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final face = state.suggestions[index];
                      return Column(
                        children: [
                          _FaceCrop(face: face, size: 72),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: l10n.peopleYes,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.check, size: 18),
                                onPressed: () => unawaited(
                                  _controller.acceptSuggestion(face),
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.peopleNo,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () =>
                                    _controller.rejectSuggestion(face),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: LibraryGrid(
            images: state.personImages,
            selection: _personSelection,
            cache: widget.cache,
            tileExtent: 170,
            groupByMonth: true,
            onTap: (image) => setState(() => _personSelection = {image.path}),
            onOpen: widget.onOpen,
          ),
        ),
      ],
    );
  }
}

class _FaceCrop extends StatelessWidget {
  const _FaceCrop({required this.face, required this.size, this.circle = true});

  final CatalogFace face;
  final double size;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final crop = face.crop;
    final child = SizedBox.square(
      dimension: size,
      child: crop == null
          ? const ColoredBox(
              color: AppColors.brokenImage,
              child: Icon(Icons.face_outlined),
            )
          : Image.memory(crop, fit: BoxFit.cover, gaplessPlayback: true),
    );
    return circle
        ? ClipOval(child: child)
        : ClipRRect(borderRadius: BorderRadius.circular(6), child: child);
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person, required this.onTap});

  final PersonSummary person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        width: 112,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              _FaceCrop(face: person.cover, size: 88),
              const SizedBox(height: 6),
              Text(
                person.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                context.l10n.libraryPhotoCount(person.photoCount),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.selected,
    required this.onToggle,
    required this.onName,
    required this.onIgnore,
  });

  static const int _shown = 18;

  final List<CatalogFace> group;
  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final VoidCallback onName;
  final VoidCallback onIgnore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final picked = group.where((face) => selected.contains(face.id)).length;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final face in group.take(_shown))
                Semantics(
                  button: true,
                  selected: selected.contains(face.id),
                  label: l10n.peopleFace,
                  child: GestureDetector(
                    onTap: () => onToggle(face.id),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected.contains(face.id)
                              ? primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: _FaceCrop(face: face, size: 64, circle: false),
                    ),
                  ),
                ),
              if (group.length > _shown)
                SizedBox.square(
                  dimension: 70,
                  child: Center(child: Text('+${group.length - _shown}')),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  picked > 0
                      ? l10n.peopleFacesPicked(picked, group.length)
                      : l10n.peopleFaceCount(group.length),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              TextButton(onPressed: onIgnore, child: Text(l10n.peopleIgnore)),
              const SizedBox(width: 4),
              FilledButton.tonal(
                onPressed: onName,
                child: Text(l10n.peopleName),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Asks who a face is, suggesting names already used. Returns the name, or
/// null if cancelled.
Future<String?> showPersonNameDialog(
  BuildContext context, {
  required List<String> names,
  required int faceCount,
  String initial = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) =>
        _PersonNameDialog(names: names, faceCount: faceCount, initial: initial),
  );
}

class _PersonNameDialog extends StatefulWidget {
  const _PersonNameDialog({
    required this.names,
    required this.faceCount,
    required this.initial,
  });

  final List<String> names;
  final int faceCount;
  final String initial;

  @override
  State<_PersonNameDialog> createState() => _PersonNameDialogState();
}

class _PersonNameDialogState extends State<_PersonNameDialog> {
  String _text = '';

  @override
  void initState() {
    super.initState();
    _text = widget.initial;
  }

  void _submit(String value) {
    final name = value.trim();
    if (name.isNotEmpty) {
      Navigator.of(context).pop(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.peopleWhoIsThis(widget.faceCount)),
      content: SizedBox(
        width: 360,
        child: Autocomplete<String>(
          initialValue: TextEditingValue(text: widget.initial),
          optionsBuilder: (value) {
            final query = value.text.trim().toLowerCase();
            if (query.isEmpty) {
              return widget.names;
            }
            return widget.names.where(
              (name) => name.toLowerCase().contains(query),
            );
          },
          onSelected: (name) => setState(() => _text = name),
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.peopleNameLabel),
              onChanged: (value) => setState(() => _text = value),
              onSubmitted: (value) => _submit(value),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelLabel),
        ),
        FilledButton(
          onPressed: _text.trim().isEmpty ? null : () => _submit(_text),
          child: Text(l10n.saveLabel),
        ),
      ],
    );
  }
}
