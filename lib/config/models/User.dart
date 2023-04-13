class User {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? telephone;
  final String photo;
  final String? country;
  final String? state;
  final String? address;
  final String? city;
  final String? about;
  final List interests;
  final List notifications;
  final List playlist;
  final dynamic settings;
  final List subscriptions;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.telephone,
    required this.photo,
    required this.country,
    required this.state,
    required this.address,
    required this.city,
    required this.about,
    required this.interests,
    required this.notifications,
    required this.playlist,
    required this.settings,
    required this.subscriptions,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json["id"] as int,
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      telephone: json['telephone'] ?? '',
      photo: json['photo'],
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      about: json['about'] ?? '',
      interests: json['interests'],
      notifications: json['notifications'],
      playlist: json['playlist'],
      settings: json['settings'],
      subscriptions: json['subscriptions'],
  );

  String username() => ('$firstname $lastname').toString( );

  bool setting(String key){
    if(settings is Map && settings.containsKey(key)==true) {

      return settings[key];

    }

    return false;
  }

}
