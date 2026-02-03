import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../features/products/presentation/products_page.dart';
import '../../features/inventory/presentation/inventory_page.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final current = ref.read(localeProvider);

              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'en'
                      ? const Locale('ar')
                      : const Locale('en');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // logout later
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: Colors.grey.shade200,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  String t(String key) =>
                      AppLocalizations.of(context)?.translate(key) ?? key;
                  return Column(
                    children: [
                      _SidebarItem(
                          title: t('home'), icon: Icons.home, onTap: () {}),
                      _SidebarItem(
                        title: t('products'),
                        icon: Icons.inventory,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProductsPage()));
                        },
                      ),
                      _SidebarItem(
                          title: t('inventory'),
                          icon: Icons.warehouse,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const InventoryPage()));
                          }),
                      _SidebarItem(
                          title: t('sales'),
                          icon: Icons.point_of_sale,
                          onTap: () {}),
                      _SidebarItem(
                          title: t('reports'),
                          icon: Icons.bar_chart,
                          onTap: () {}),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _SidebarItem({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
