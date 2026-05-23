import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../data/lists/library_genre_model.dart';
import '../../../providers/lists/lists_provider.dart';

/// Muestra un [AlertDialog] con un campo de texto para añadir un nuevo género a la
/// biblioteca [listId]. Devuelve un registro con la lista de géneros actualizada y el
/// nombre del género recién creado, o `null` si el usuario cancela.
Future<({List<LibraryGenreModel> genres, String genre})?> showAddGenreDialog(
  BuildContext context,
  int listId,
  ListsProvider listsProvider,
) async {
  final controller = TextEditingController();
  ({List<LibraryGenreModel> genres, String genre})? result;

  Future<void> submit(BuildContext ctx) async {
    final name = controller.text.trim();
    if (name.isNotEmpty) {
      await listsProvider.addLibraryGenre(listId, name);
      final genres = await listsProvider.getLibraryGenres(listId);
      result = (genres: genres, genre: name);
      if (ctx.mounted) Navigator.pop(ctx);
    }
  }

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.l10n.genreAddTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => submit(ctx),
        decoration: InputDecoration(labelText: ctx.l10n.genreName),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(ctx.l10n.commonCancel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => submit(ctx),
          child: Text(ctx.l10n.commonAdd.toUpperCase()),
        ),
      ],
    ),
  );

  controller.dispose();
  return result;
}

/// Muestra un [AlertDialog] con un campo de texto para introducir el nombre de un
/// nuevo tipo de atributo. Devuelve el nombre introducido, o `null` si se cancela.
Future<String?> showCreateAttributeTypeDialog(BuildContext context) async {
  final controller = TextEditingController();
  try {
    return await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.attributeNewType),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) {
            final name = controller.text.trim();
            if (name.isNotEmpty) Navigator.pop(ctx, name);
          },
          decoration: InputDecoration(
            labelText: ctx.l10n.attributesNewTypeName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) Navigator.pop(ctx, name);
            },
            child: Text(ctx.l10n.commonCreate),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}
