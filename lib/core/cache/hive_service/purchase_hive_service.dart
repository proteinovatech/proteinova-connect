import 'package:hive/hive.dart';

class PurchaseCacheService {
  final Box box = Hive.box('purchaseBox');

  
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