import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../domain/product.dart';
import 'products_controller.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  late TextEditingController _nameController;
  late TextEditingController _wholesaleController;
  late TextEditingController _sellingController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _wholesaleController = TextEditingController(
        text: widget.product?.wholesalePrice.toString() ?? '');
    _sellingController = TextEditingController(
        text: widget.product?.sellingPrice.toString() ?? '');
    _quantityController =
        TextEditingController(text: widget.product?.quantity.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wholesaleController.dispose();
    _sellingController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => AppLocalizations.of(context)?.translate(key) ?? key;

    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? t('edit') : t('add_product'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: t('product_name')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wholesaleController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: t('wholesale_price')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sellingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: t('selling_price')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t('quantity')),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final wholesale =
                    double.tryParse(_wholesaleController.text) ?? 0.0;
                final selling = double.tryParse(_sellingController.text) ?? 0.0;
                final quantity = int.tryParse(_quantityController.text) ?? 0;

                try {
                  if (isEditing) {
                    await ref
                        .read(productsControllerProvider.notifier)
                        .updateProduct(
                          id: widget.product!.id!,
                          name: name,
                          wholesalePrice: wholesale,
                          sellingPrice: selling,
                          quantity: quantity,
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t('product_updated'))));
                      Navigator.pop(context);
                    }
                  } else {
                    await ref
                        .read(productsControllerProvider.notifier)
                        .addProduct(
                          name: name,
                          wholesalePrice: wholesale,
                          sellingPrice: selling,
                          quantity: quantity,
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t('product_added'))));
                      Navigator.pop(context);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: Text(t('save')),
            )
          ],
        ),
      ),
    );
  }
}
