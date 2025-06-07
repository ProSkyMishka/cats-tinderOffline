import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/liked_cat.dart';
import 'cat_local_storage.dart';

class CatLocalStorageImpl implements CatLocalStorage {
  static const _key = 'liked_cats';

  @override
  Future<void> saveLikedCats(List<LikedCat> cats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cats.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<LikedCat>> loadLikedCats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((item) => LikedCat.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
