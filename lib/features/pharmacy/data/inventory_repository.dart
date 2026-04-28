import '../domain/pharmacy_inventory.dart';

abstract class InventoryRepository {
  Future<List<PharmacyInventory>> fetchInventory();
  Future<void> addItem(PharmacyInventory item);
  Future<void> removeItem(String id);
  Future<void> updateStock(String id, int delta);
}
