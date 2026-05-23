import 'package:flutter/material.dart';
import 'package:list_me/core/i18n/l10n_extension.dart';
import 'package:list_me/providers/friends/friends_provider.dart';

/// Muestra un diálogo para enviar una solicitud de amistad por nombre de usuario.
///
/// Al confirmar llama a [FriendsProvider.sendRequest] y muestra un snackbar
/// con el resultado. El botón de enviar se desactiva mientras la operación
/// está en curso para evitar doble pulsación.
void showAddFriendDialog(BuildContext context, FriendsProvider friends) {
  final controller = TextEditingController();
  bool sending = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          title: Text(context.l10n.socialAddFriend),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) async {
              final username = controller.text.trim();
              if (username.isEmpty || sending) return;
              setState(() => sending = true);
              final success = await friends.sendRequest(username);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(success
                    ? context.l10n.socialRequestSentTo(username)
                    : (friends.errorMessage ?? context.l10n.socialRequestError)),
              ));
              if (success) friends.clearError();
            },
            decoration: InputDecoration(
              labelText: context.l10n.socialUsernameLabel,
              hintText: context.l10n.socialUsernameHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      final username = controller.text.trim();
                      if (username.isEmpty) return;
                      setState(() => sending = true);
                      final success = await friends.sendRequest(username);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(success
                            ? context.l10n.socialRequestSentTo(username)
                            : (friends.errorMessage ??
                                context.l10n.socialRequestError)),
                      ));
                      if (success) friends.clearError();
                    },
              child: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.commonSend),
            ),
          ],
        );
      },
    ),
  );
}

/// Muestra un diálogo de confirmación antes de eliminar a [username] de amigos.
void confirmRemoveFriend(
  BuildContext context,
  String username,
  FriendsProvider friends,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.socialRemoveFriendTitle),
      content: Text(context.l10n.socialRemoveFriendConfirm(username)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            await friends.removeFriend(username);
          },
          child: Text(context.l10n.commonDelete),
        ),
      ],
    ),
  );
}
