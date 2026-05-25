import '../models/collection_item.dart';

class GemService {
  static List<CollectionItem> gemsList = [];

  static void add(CollectionItem item) {
    gemsList.add(item);
  }

  static void delete(int index) {
    gemsList.removeAt(index);
  }

  static void update(int index, CollectionItem item) {
    gemsList[index] = item;
  }
}
