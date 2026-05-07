import 'package:hive/hive.dart';

class PurchaseCacheService {
  static const String boxName = 'purchaseBox';

  Box get box => Hive.box(boxName);

  Future<void> savePurchases(List data) async {
    await box.put('purchases', data);
  }

  List getPurchases() {
    return box.get('purchases', defaultValue: []);
  }

  Future<void> clear() async {
    await box.delete('purchases');
  }
}