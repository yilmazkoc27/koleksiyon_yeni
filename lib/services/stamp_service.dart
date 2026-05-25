import '../models/collection_item.dart';

class StampService {
  static List<CollectionItem> stampList = [];

  static void add(CollectionItem item) {
    stampList.add(item);
  }

  static void delete(int index) {
    stampList.removeAt(index);
  }

  static void update(int index, CollectionItem item) {
    stampList[index] = item;
  }
}
