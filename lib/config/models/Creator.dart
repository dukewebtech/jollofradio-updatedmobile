class Creator {
    final int id;
    final String firstname;
    final String lastname;
    final String email;
    final String telephone;
    final String photo;
    final String banner;
    final String? country;
    final String? state;
    final String? address;
    final String? city;
    final String? about;
    final dynamic settings;
    final List? interests;
    final List? notifications;
    final List? podcasts;
    final List? episodes;
    final List? streams;
    final List? followers;
    final List? engagements;

    Creator({
      required this.id,
      required this.firstname,
      required this.lastname,
      required this.email,
      required this.telephone,
      required this.photo,
      required this.banner,
      required this.country,
      required this.state,
      required this.address,
      required this.city,
      required this.about,
      required this.settings,
      required this.interests,
      required this.notifications,
      required this.podcasts,
      required this.episodes,
      required this.streams,
      required this.followers,
      required this.engagements,
    });

    factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        id: json["id"] as int,
        firstname: json['firstname'],
        lastname: json['lastname'],
        email: json['email'],
        telephone: json['telephone'] ?? '',
        photo: json['photo'],
        banner: json['banner'],
        country: json['country'] ?? '',
        state: json['state'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        about: json['about'] ?? '',
        settings: json['settings'],
        interests: json['interests'],
        notifications: json['notifications'],
        podcasts: json['podcasts'],
        episodes: json['episodes'],
        streams: json['streams'],
        followers: json['followers'],
        engagements: json['engagements'],
    );

    Map<String, dynamic> toJson() => {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'telephone': telephone,
      'photo': photo,
      'banner': banner,
      'country': country,
      'state': state,
      'address': address,
      'city': city,
      'about': about,
      'settings': settings,
      'interests': interests,
      'notifications': notifications,
      'podcasts': podcasts,
      'episodes': episodes,
      'streams': streams,
      'followers': followers,
      'engagements': engagements,
    };

    String username() => (/**/('$firstname $lastname').toString());

    bool subscribed(user) {
      var following = followers!
      .firstWhere(
        (follower) => follower == user.id, orElse: () => ( false )
      );

      return following != false;
    }

}
