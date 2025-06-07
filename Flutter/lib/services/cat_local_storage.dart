import '../models/liked_cat.dart';

abstract class CatLocalStorage {
  Future<void> saveLikedCats(List<LikedCat> cats);
  Future<List<LikedCat>> loadLikedCats();
}
