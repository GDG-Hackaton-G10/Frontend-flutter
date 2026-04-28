import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/inventory_repository.dart';
import '../data/mock_api_service.dart';
import '../domain/pharmacy_inventory.dart';

part 'pharmacy_inventory_notifier.g.dart';

@riverpod
class PharmacyInventoryNotifier extends _$PharmacyInventoryNotifier
    with AsyncNotifier<List<PharmacyInventory>> {
  late final InventoryRepository _repo;

  @override
  FutureOr<List<PharmacyInventory>> build() async {
    _repo = MockApiService();
    return _repo.fetchInventory();
  }

  Future<void> addItem(PharmacyInventory item) async {
    await _repo.addItem(item);
    state = AsyncValue.data(await _repo.fetchInventory());
  }

  Future<void> removeItem(String id) async {
    await _repo.removeItem(id);
    state = AsyncValue.data(await _repo.fetchInventory());
  }

  Future<void> updateStock(String id, int delta) async {
    await _repo.updateStock(id, delta);
    state = AsyncValue.data(await _repo.fetchInventory());
  }
}
