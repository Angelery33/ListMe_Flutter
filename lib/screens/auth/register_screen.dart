import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../providers/auth/auth_provider.dart';

/// Pantalla de registro con diseño Premium (Glassmorphism).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// Estado para [RegisterScreen].
///
/// Gestiona cuatro controladores de texto (nombre de usuario, correo electrónico, contraseña, confirmar contraseña),
/// los nodos de enfoque correspondientes y la visibilidad de la contraseña. Delega la creación de la cuenta
/// a [AuthProvider.register].
class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late FocusNode _userFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  /// Indica si los campos de contraseña muestran sus caracteres en texto plano.
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _userFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// Valida todos los campos, llama a [AuthProvider.register] y vuelve a la
  /// pantalla de inicio de sesión con un [SnackBar] de bienvenida si tiene éxito, o muestra un error si
  /// falla.
  void _handleRegister(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final username = _userController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authFillAll)),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authPasswordsMismatch)),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authInvalidEmail)),
      );
      return;
    }

    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authPasswordRequirements)),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final welcomeMsg = context.l10n.authWelcome;
    final errorMsg = context.l10n.authRegisterError;
    final success = await auth.register(username, password, email);
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(content: Text(welcomeMsg)),
      );
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
          // Capa de oscurecimiento
          Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: size.width > 600 ? 500 : double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Botón de atrás flotante (Cambiamos Positioned para que sea absoluto al Stack)
                            Positioned(
                              left: -10,
                              top: -10,
                              child: ClipOval(
                                child: Material(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.arrow_back_ios_rounded,
                                          color: Colors.white, size: 32),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Contenido central
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_add_rounded,
                                  size: 56,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.l10n.authCreateAccount,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (authProvider.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                          color: Colors.redAccent, fontSize: 13),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                _buildTextField(
                                  controller: _userController,
                                  label: context.l10n.authUsername,
                                  icon: Icons.person_outline,
                                  focusNode: _userFocusNode,
                                  onSubmitted: () => _emailFocusNode.requestFocus(),
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _emailController,
                                  label: context.l10n.authEmail,
                                  icon: Icons.email_outlined,
                                  focusNode: _emailFocusNode,
                                  onSubmitted: () => _passwordFocusNode.requestFocus(),
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _passwordController,
                                  label: context.l10n.authPassword,
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  focusNode: _passwordFocusNode,
                                  onSubmitted: () => _confirmPasswordFocusNode.requestFocus(),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    context.l10n.authPasswordRequirements,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  label: context.l10n.authConfirmPassword,
                                  icon: Icons.lock_reset_outlined,
                                  isPassword: true,
                                  focusNode: _confirmPasswordFocusNode,
                                  onSubmitted: () => _handleRegister(context),
                                ),
                                const SizedBox(height: 24),
                                _buildRegisterButton(context, theme, authProvider),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    context.l10n.authHasAccount,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un campo de texto con estilo glassmorphism vinculado al [controller].
  ///
  /// Soporta la ocultación de la contraseña a través de [isPassword] y enfoca el siguiente campo
  /// o activa [onSubmitted] cuando el usuario envía a través del teclado.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onSubmitted,
    FocusNode? focusNode,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword && !_isPasswordVisible,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => onSubmitted?.call(),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  /// Construye el botón de registro principal que activa [_handleRegister].
  ///
  /// Muestra un [CircularProgressIndicator] mientras [auth] está cargando para evitar
  /// el doble envío.
  Widget _buildRegisterButton(BuildContext context, ThemeData theme, AuthProvider auth) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: auth.isLoading ? null : () => _handleRegister(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: auth.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                context.l10n.authSignUp,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}
