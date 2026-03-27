import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../../data/database_helper.dart';
import '../../providers/library_provider.dart';
import '../../providers/auth_provider.dart';

import 'library_details_screen.dart';
import 'library_entry_screen.dart';
import '../app_theme.dart'; // Corrected import path

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load libraries on startup
    Future.microtask(() {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final libProvider = Provider.of<LibraryProvider>(context, listen: false);

      libProvider.loadLibraries(
        userId: auth.user?.uid,
        userEmail: auth.user?.email,
      );

      if (auth.user != null && auth.user!.email != null) {
        libProvider.startRealTimeSync(auth.user!.email!, auth.user!.uid);
      }
    });
  }

  void _navigateToLibraryEntry(BuildContext context) {
    // Wait, LibraryEntryScreen takes a Library object?
    // Let's check LibraryEntryScreen constructor: const LibraryEntryScreen({super.key, this.library});
    // So I need to pass the Library object if editing.
    // In HomeScreen, I have LibraryWithItemCount which is a DTO.
    // I might need to fetch the full Library object or update LibraryEntryScreen to take just ID and fetch it?
    // Or, for now, if I only have DTO, I can fetch it in HomeScreen before navigating or just pass null for new.
    // For editing (onLongPress?), I should fetch full library details.
    // Wait, the requirement was "Library Creation".
    // Let's implement _navigateToLibraryEntry for Creation (null) and handle Editing later if needed or if I have the object.
    // Actually, LibraryEntryScreen logic: if widget.library is not null, it pre-fills.

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LibraryEntryScreen()),
    ).then((_) {
      if (!mounted) return;
      // Refresh list
      Provider.of<LibraryProvider>(context, listen: false).loadLibraries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0C0C0C)
          : const Color(0xFFFCFBF9),
      appBar: AppBar(
        flexibleSpace: AppTheme.getAppBarGradient(context),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logobiblio.png',
              height: 48,
              errorBuilder: (_, __, ___) => const Icon(Icons.library_books),
            ),
            const SizedBox(width: 12),
            const Text('ListMe'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<LibraryProvider>(
            context,
            listen: false,
          ).loadLibraries();
          if (!mounted) return;
        },
        child: Consumer<LibraryProvider>(
          builder: (context, libraryProvider, child) {
            if (libraryProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (libraryProvider.error != null) {
              return Center(child: Text('Error: ${libraryProvider.error}'));
            }

            final personalLibs = libraryProvider.personalLibraries;
            final sharedLibs = libraryProvider.sharedLibraries;
            final pendingLibs = libraryProvider.pendingLibraries;

            if (personalLibs.isEmpty &&
                sharedLibs.isEmpty &&
                pendingLibs.isEmpty) {
              return _buildEmptyState();
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                if (pendingLibs.isNotEmpty) ...[
                  _SectionHeader(title: "Solicitudes Pendientes"),
                  ...pendingLibs
                      .map((lib) => _buildPendingLibraryTile(context, lib))
                      .toList(),
                ],
                if (sharedLibs.isNotEmpty) ...[
                  _SectionHeader(title: "Compartidas conmigo"),
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      final list = List<LibraryWithItemCount>.from(sharedLibs);
                      final item = list.removeAt(oldIndex);
                      list.insert(newIndex, item);
                      libraryProvider.reorderLibraries(list);
                    },
                    children: sharedLibs
                        .map(
                          (lib) => _buildLibraryTile(
                            context,
                            lib,
                            libraryProvider,
                            isShared: true,
                            key: ValueKey('shared_${lib.idLibrary}'),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (personalLibs.isNotEmpty) ...[
                  _SectionHeader(title: "Mis Listas"),
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      final list = List<LibraryWithItemCount>.from(
                        personalLibs,
                      );
                      final item = list.removeAt(oldIndex);
                      list.insert(newIndex, item);
                      libraryProvider.reorderLibraries(list);
                    },
                    children: personalLibs
                        .map(
                          (lib) => _buildLibraryTile(
                            context,
                            lib,
                            libraryProvider,
                            key: ValueKey('personal_${lib.idLibrary}'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FloatingActionButton(
          onPressed: () => _navigateToLibraryEntry(context),
          elevation: 4,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.collections_bookmark_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            "No hay listas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("Crea una pulsando el botón +"),
        ],
      ),
    );
  }

  Widget _buildLibraryTile(
    BuildContext context,
    LibraryWithItemCount lib,
    LibraryProvider provider, {
    bool isShared = false,
    Key? key,
  }) {
    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(isShared ? Icons.cloud_download : Icons.library_books),
        title: Text(
          lib.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: isShared
            ? Text(
                '${lib.itemCount} elementos • De: ${lib.ownerEmail ?? lib.ownerId ?? "Desconocido"}',
              )
            : Text('${lib.itemCount} elementos'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'edit') {
                  final fullLib = await DatabaseHelper.instance.getLibraryById(
                    lib.idLibrary,
                  );
                  if (fullLib != null && context.mounted) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LibraryEntryScreen(library: fullLib),
                      ),
                    );
                    if (!context.mounted) return;
                    Provider.of<LibraryProvider>(
                      context,
                      listen: false,
                    ).loadLibraries();
                  }
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, lib);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LibraryDetailsScreen(
                idLibrary: lib.idLibrary,
                libraryName: lib.name,
                remoteId: null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingLibraryTile(
    BuildContext context,
    LibraryWithItemCount lib,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.mail_outline, color: Colors.orange),
        title: Text(lib.name),
        subtitle: Text("Invitación de ${lib.ownerEmail ?? 'Desconocido'}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () {
                if (lib.remoteId != null && lib.ownerEmail != null) {
                  Provider.of<LibraryProvider>(
                    context,
                    listen: false,
                  ).acceptInvitation(
                    lib.remoteId!,
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).user!.email!,
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                if (lib.remoteId != null && lib.ownerEmail != null) {
                  Provider.of<LibraryProvider>(
                    context,
                    listen: false,
                  ).rejectInvitation(
                    lib.remoteId!,
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).user!.email!,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    LibraryWithItemCount libDto,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lista'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la lista "${libDto.name}"? Esta acción no se puede deshacer y se borrarán todos sus elementos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<LibraryProvider>(
                context,
                listen: false,
              ).deleteLibrary(libDto.idLibrary);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lista "${libDto.name}" eliminada')),
              );
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
