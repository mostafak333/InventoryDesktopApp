import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import 'products_controller.dart';
import '../domain/product.dart';
import 'product_form_page.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  String _search = '';
  String _filterStatus = 'all';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  String t(BuildContext context, String key) =>
      AppLocalizations.of(context)?.translate(key) ?? key;

  void _setSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<Product> _applyFilters(List<Product> products) {
    var filtered = products.where((p) {
      final q = _search.toLowerCase();
      final matchesSearch =
          p.name.toLowerCase().contains(q) || p.id.toString().contains(q);
      final matchesStatus = _filterStatus == 'all' || p.status == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsControllerProvider);
    final controller = ref.read(productsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(t(context, 'products'))),
      body: state.when(
        data: (products) {
          final filtered = _applyFilters(products);

          if (_sortColumnIndex != null) {
            switch (_sortColumnIndex) {
              case 0:
                filtered.sort((a, b) => _sortAscending
                    ? a.name.compareTo(b.name)
                    : b.name.compareTo(a.name));
                break;
              case 1:
                filtered.sort((a, b) => _sortAscending
                    ? a.wholesalePrice.compareTo(b.wholesalePrice)
                    : b.wholesalePrice.compareTo(a.wholesalePrice));
                break;
              case 2:
                filtered.sort((a, b) => _sortAscending
                    ? a.sellingPrice.compareTo(b.sellingPrice)
                    : b.sellingPrice.compareTo(a.sellingPrice));
                break;
              case 3:
                filtered.sort((a, b) => _sortAscending
                    ? a.quantity.compareTo(b.quantity)
                    : b.quantity.compareTo(a.quantity));
                break;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Search & Filter Header ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      // Changed Wrap to Row
                      children: [
                        // This Expanded makes the search bar stretch
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: t(context, 'search'),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                            ),
                            onChanged: (v) => setState(() => _search = v),
                          ),
                        ),
                        const SizedBox(width: 12), // Added spacing
                        DropdownButton<String>(
                          value: _filterStatus,
                          items: [
                            DropdownMenuItem(
                                value: 'all', child: Text(t(context, 'all'))),
                            DropdownMenuItem(
                                value: 'available',
                                child: Text(t(context, 'available'))),
                            DropdownMenuItem(
                                value: 'locked',
                                child: Text(t(context, 'locked'))),
                          ],
                          onChanged: (v) =>
                              setState(() => _filterStatus = v ?? 'all'),
                        ),
                        const SizedBox(width: 12),
                        Text('${filtered.length} ${t(context, 'products')}'),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(t(context, 'add_product')),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProductFormPage()),
                            );
                            controller.loadProducts();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Scrollable Table Section ---
                Expanded(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: products.isEmpty
                        ? Center(child: Text(t(context, 'no_products')))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      sortColumnIndex: _sortColumnIndex,
                                      sortAscending: _sortAscending,
                                      columnSpacing: 16,
                                      headingRowColor: WidgetStateProperty.all(
                                          Colors.grey[100]),
                                      columns: [
                                        DataColumn(
                                          label: Expanded(
                                              child: Center(
                                                  child: Text(t(context,
                                                      'product_name')))),
                                          onSort: (i, asc) => _setSort(i, asc),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                              child: Center(
                                                  child: Text(t(context,
                                                      'wholesale_price')))),
                                          onSort: (i, asc) => _setSort(i, asc),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                              child: Center(
                                                  child: Text(t(context,
                                                      'selling_price')))),
                                          onSort: (i, asc) => _setSort(i, asc),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                              child: Center(
                                                  child: Text(
                                                      t(context, 'quantity')))),
                                          onSort: (i, asc) => _setSort(i, asc),
                                        ),
                                        DataColumn(
                                            label: Expanded(
                                                child: Center(
                                                    child: Text(t(context,
                                                        'display_quantity'))))),
                                        DataColumn(
                                            label: Expanded(
                                                child: Center(
                                                    child: Text(t(
                                                        context, 'status'))))),
                                        DataColumn(
                                            label: Expanded(
                                                child: Center(
                                                    child: Text(t(
                                                        context, 'actions'))))),
                                      ],
                                      rows: filtered.map((p) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Center(
                                                child: Text(p.name,
                                                    overflow: TextOverflow
                                                        .ellipsis))),
                                            DataCell(Center(
                                                child: Text(p.wholesalePrice
                                                    .toStringAsFixed(2)))),
                                            DataCell(Center(
                                                child: Text(p.sellingPrice
                                                    .toStringAsFixed(2)))),
                                            DataCell(Center(
                                                child: Text(
                                                    p.quantity.toString()))),
                                            DataCell(Center(
                                                child: Text(p.displayQuantity
                                                    .toString()))),
                                            DataCell(Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: p.status == 'available'
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(p.status,
                                                    style: TextStyle(
                                                        color: p.status ==
                                                                'available'
                                                            ? Colors
                                                                .green.shade800
                                                            : Colors
                                                                .red.shade800)),
                                              ),
                                            )),
                                            DataCell(Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  color: Colors.blue,
                                                  icon: const Icon(Icons.edit,
                                                      size: 18),
                                                  onPressed: () async {
                                                    await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                ProductFormPage(
                                                                    product:
                                                                        p)));
                                                    controller.loadProducts();
                                                  },
                                                ),
                                                const VerticalDivider(
                                                    width: 10,
                                                    indent: 10,
                                                    endIndent: 10),
                                                IconButton(
                                                  icon: Icon(
                                                    p.status == 'available'
                                                        ? Icons.lock_open
                                                        : Icons.lock,
                                                    size: 18,
                                                    color:
                                                        p.status == 'available'
                                                            ? Colors.red
                                                            : Colors.green,
                                                  ),
                                                  onPressed: () async {
                                                    await controller.toggleLock(
                                                        p.id!, p.status);
                                                    controller.loadProducts();
                                                  },
                                                ),
                                              ],
                                            )),
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
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
