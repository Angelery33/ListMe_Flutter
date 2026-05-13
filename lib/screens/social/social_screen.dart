import 'package:flutter/material.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_shell.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 3,
      appBar: CustomGradientAppBar(
        title: context.l10n.socialTitle,
        showBackButton: false,
      ),
      body: const Center(child: Text('—')),
    );
  }
}
