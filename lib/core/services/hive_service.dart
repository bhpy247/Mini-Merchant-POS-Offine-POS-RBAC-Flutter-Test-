import 'package:hive/hive.dart';

class HiveService {
  static const String ordersBox = "ordersBox";

  static Future<void> init() async {
    await Hive.openBox(ordersBox);
  }

  static Box getOrderBox() {
    return Hive.box(ordersBox);
  }
}
