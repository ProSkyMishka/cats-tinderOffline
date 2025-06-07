class Cat {
  final String imageUrl;
  final String breedName;
  final String breedDescription;

  Cat({
    required this.imageUrl,
    required this.breedName,
    required this.breedDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'breedName': breedName,
      'description': breedDescription,
    };
  }

  factory Cat.fromJson(Map<String, dynamic> json) {
    var breeds = json['breeds'];
    return Cat(
      imageUrl: json['url'] ?? '',
      breedName: (breeds != null && breeds is List && breeds.isNotEmpty)
          ? breeds[0]['name'] as String
          : 'Неизвестная порода',
      breedDescription: (breeds != null && breeds is List && breeds.isNotEmpty)
          ? breeds[0]['description'] as String
          : 'Описание отсутствует',
    );
  }

  factory Cat.fromLocalJson(Map<String, dynamic> json) {
    return Cat(
      imageUrl: json['imageUrl'] as String,
      breedName: json['breedName'] as String,
      breedDescription: json['description'] as String,
    );
  }
}
