import '../models/collection_item.dart';

class CoinService {
  static List<CollectionItem> coinList = [];

  static void add(CollectionItem item) {
    coinList.add(item);
  }

  static void delete(int index) {
    coinList.removeAt(index);
  }

  static void update(int index, CollectionItem item) {
    coinList[index] = item;
  }
}
