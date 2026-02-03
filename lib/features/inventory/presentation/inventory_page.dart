import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/database/app_database.dart';
import '../../products/presentation/products_controller.dart';
import '../../products/domain/product.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  Future<int?> _showAmountDialog(BuildContext context, String title) async {
    final controller = TextEditingController();
    final t =
        (String key) => AppLocalizations.of(context)?.translate(key) ?? key;

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: t('enter_amount')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(t('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text.trim());
                if (val == null || val <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t('invalid_amount'))),
                  );
                  return;
                }
                Navigator.pop(context, val);
              },
              child: Text(t('confirm')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String t(String key) => AppLocalizations.of(context)?.translate(key) ?? key;
    final productsState = ref.watch(productsControllerProvider);
    final controller = ref.read(productsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(t('inventory'))),
      body: productsState.when(
        data: (products) {
          if (products.isEmpty) return Center(child: Text(t('no_products')));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              clipBehavior: Clip
                  .antiAlias, // Ensures content doesn't bleed over rounded corners
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        // This forces the table to be at least as wide as the screen/card
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          // Adjust these to control the "stretch" feel
                          columnSpacing: 24,
                          headingRowColor:
                              WidgetStateProperty.all(Colors.blueAccent[100]),
                          columns: [
                            DataColumn(
                                label: Expanded(
                                    child: Text(t('product_name'),
                                        textAlign: TextAlign.center))),
                            DataColumn(
                                label: Expanded(
                                    child: Text(t('quantity'),
                                        textAlign: TextAlign.center))),
                            DataColumn(
                                label: Expanded(
                                    child: Text(t('display_quantity'),
                                        textAlign: TextAlign.center))),
                            DataColumn(
                                label: Expanded(
                                    child: Text(t('actions'),
                                        textAlign: TextAlign.center))),
                          ],
                          rows: products.map((p) {
                            return DataRow(
                              cells: [
                                DataCell(Center(child: Text(p.name))),
                                DataCell(
                                    Center(child: Text(p.quantity.toString()))),
                                DataCell(Center(
                                    child: Text(p.displayQuantity.toString()))),
                                DataCell(
                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline,
                                              size: 20,
                                              color: Colors.green),
                                          onPressed: () async {
                                            final amount =
                                                await _showAmountDialog(context,
                                                    t('increase_stock'));
                                            if (amount == null) return;
                                            try {
                                              await AppDatabase.instance
                                                  .increaseProductStock(
                                                      p.id!, amount);
                                              controller.loadProducts();
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content:
                                                          Text('Error: $e')));
                                            }
                                          },
                                        ),
                                        const VerticalDivider(
                                            width: 10,
                                            indent: 10,
                                            endIndent: 10),
                                        IconButton(
                                          icon: const Icon(Icons.send,
                                              size: 20, color: Colors.blue),
                                          onPressed: () async {
                                            final amount =
                                                await _showAmountDialog(context,
                                                    t('send_to_display'));
                                            if (amount == null) return;
                                            try {
                                              await AppDatabase.instance
                                                  .sendProductToDisplay(
                                                      p.id!, amount);
                                              controller.loadProducts();
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content:
                                                          Text(e.toString())));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
