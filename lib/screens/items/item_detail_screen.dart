import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/l10n_extension.dart';
import '../../core/providers/responsive_provider.dart';
import '../../data/items/item_model.dart';
import '../../data/lists/list_model.dart';
import '../../providers/items/item_details_provider.dart';
import '../../providers/items/items_provider.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_shell.dart';

import '../../widgets/items/detail/detail_image_carousel.dart';
import '../../widgets/items/detail/detail_info_section.dart';
import '../../widgets/items/detail/detail_progress_section.dart';
import '../../widgets/items/detail/detail_rating_section.dart';
import '../../widgets/items/detail/detail_description_section.dart';
import '../../widgets/items/detail/detail_dates_section.dart';
import '../../widgets/items/detail/detail_collection_section.dart';
import '../../widgets/items/detail/detail_gallery_section.dart';
import '../../widgets/items/detail/detail_attributes_section.dart';

class ItemDetailScreen extends StatefulWidget {
  final ItemModel item;
  final ListModel? list;

  const ItemDetailScreen({super.key, required this.item, this.list});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<ItemDetailsProvider>();
        provider.loadItemDetails(widget.item.id!, initialItem: widget.item);
      }
    });
  }

  void _onEditTapped(BuildContext context, ItemModel currentItem) async {
    await Navigator.pushNamed(
      context,
      '/item-entry',
      arguments: {'list': widget.list, 'item': currentItem},
    );

    if (mounted && widget.item.id != null) {
      final provider = context.read<ItemDetailsProvider>();
      provider.loadItemDetails(widget.item.id!);
      final listId = currentItem.idLibrary;
      context.read<ItemsProvider>().fetchItemsByLibrary(listId);
    }
  }

  void _onDeleteTapped(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.itemDeleteTitle),
        content: Text(ctx.l10n.itemDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              ctx.l10n.commonDelete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final itemsProvider = context.read<ItemsProvider>();
      final success = await itemsProvider.deleteItem(widget.item.id!);

      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              itemsProvider.errorMessage ?? context.l10n.commonError,
            ),
          ),
        );
      }
    }
  }

  List<Widget> _detailSections(ItemModel item, ListModel? library) => [
    DetailInfoSection(item: item, library: library),
    const SizedBox(height: 16),
    DetailProgressSection(library: library),
    const SizedBox(height: 16),
    DetailRatingSection(library: library),
    const SizedBox(height: 16),
    DetailDescriptionSection(item: item),
    const SizedBox(height: 16),
    DetailCollectionSection(library: library),
    const SizedBox(height: 16),
    DetailDatesSection(item: item),
    const SizedBox(height: 16),
    DetailAttributesSection(),
    const SizedBox(height: 16),
    DetailGallerySection(item: item),
    const SizedBox(height: 32),
  ];

  @override
  Widget build(BuildContext context) {
    final detailsProvider = context.watch<ItemDetailsProvider>();
    final responsive = context.watch<ResponsiveProvider>();
    final item = detailsProvider.item ?? widget.item;
    final library = widget.list;

    final appBar = CustomGradientAppBar(
      title: item.name,
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _onEditTapped(context, item),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _onDeleteTapped(context),
        ),
      ],
    );

    Widget body;
    if (responsive.isCompact) {
      body = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailImageCarousel(item: item, images: detailsProvider.images),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _detailSections(item, library),
              ),
            ),
          ],
        ),
      );
    } else {
      final imageWidth = responsive.isMedium ? 320.0 : 400.0;
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: imageWidth,
            child: DetailImageCarousel(item: item, images: detailsProvider.images),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _detailSections(item, library),
              ),
            ),
          ),
        ],
      );
    }

    return AppShell(
      currentIndex: 0,
      appBar: appBar,
      body: body,
    );
  }
}
