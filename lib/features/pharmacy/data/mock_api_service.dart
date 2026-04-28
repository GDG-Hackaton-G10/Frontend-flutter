import 'inventory_repository.dart';
import '../domain/pharmacy_inventory.dart';

class MockApiService implements InventoryRepository {
  final List<PharmacyInventory> _items = [];

  @override
  Future<List<PharmacyInventory>> fetchInventory() async => _items;

  @override
  Future<void> addItem(PharmacyInventory item) async => _items.add(item);

  @override
  Future<void> removeItem(String id) async =>
      _items.removeWhere((item) => item.id == id);

  @override
  Future<void> updateStock(String id, int delta) async {
    final item = _items.firstWhere((item) => item.id == id);
    item.stock += delta;
  }
}
