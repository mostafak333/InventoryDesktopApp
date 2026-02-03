import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product.dart';
import '../../../core/database/app_database.dart';

class ProductsController extends StateNotifier<AsyncValue<List<Product>>> {
  ProductsController() : super(const AsyncData([])) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncLoading();
    try {
      final results = await AppDatabase.instance.getProducts();
      final products = results.map((r) => Product.fromMap(r)).toList();
      state = AsyncData(products);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addProduct({
    required String name,
    required double wholesalePrice,
    required double sellingPrice,
    required int quantity,
  }) async {
    state = const AsyncLoading();
    try {
      await AppDatabase.instance.addProduct(
        name: name,
        wholesalePrice: wholesalePrice,
        sellingPrice: sellingPrice,
        quantity: quantity,
      );
      await loadProducts();
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required double wholesalePrice,
    required double sellingPrice,
    required int quantity,
  }) async {
    state = const AsyncLoading();
    try {
      await AppDatabase.instance.updateProduct(
        id: id,
        name: name,
        wholesalePrice: wholesalePrice,
        sellingPrice: sellingPrice,
        quantity: quantity,
      );
      await loadProducts();
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> toggleLock(int id, String currentStatus) async {
    state = const AsyncLoading();
    try {
      final newStatus = currentStatus == 'available' ? 'locked' : 'available';
      await AppDatabase.instance.setProductStatus(id, newStatus);
      await loadProducts();
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final productsControllerProvider =
    StateNotifierProvider<ProductsController, AsyncValue<List<Product>>>(
  (ref) => ProductsController(),
);
