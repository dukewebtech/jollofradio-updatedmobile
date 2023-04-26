class Category {
  final int id;
  final String name;
  final String logo;
  final int podcasts;

  Category({
    required this.id,
    required this.name,
    required this.logo,
    required this.podcasts,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
      id: json["id"] as int,
      name: json['name'],
      logo: json['logo'],
      podcasts: json['podcasts_count'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'podcasts_count': podcasts,
  };
}
