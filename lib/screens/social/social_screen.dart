import 'package:flutter/material.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_shell.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 3,
      appBar: const CustomGradientAppBar(
        title: 'Social',
        showBackButton: false,
      ),
      body: const Center(child: Text('Próximamente...')),
    );
  }
}
