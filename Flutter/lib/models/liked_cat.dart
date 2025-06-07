// lib/models/liked_cat.dart
import 'cat.dart';

class LikedCat {
  final Cat cat;
  final DateTime likedAt;

  LikedCat({required this.cat, required this.likedAt});

  Map<String, dynamic> toJson() {
    return {
      'cat': cat.toJson(),
      'likedAt': likedAt.toIso8601String(),
    };
  }

  factory LikedCat.fromJson(Map<String, dynamic> json) {
    return LikedCat(
      cat: Cat.fromLocalJson(json['cat'] as Map<String, dynamic>),
      likedAt: DateTime.parse(json['likedAt'] as String),
    );
  }
}
