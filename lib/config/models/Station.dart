class Station {
    final int id;
    final String title;
    final double frequency;
    final String logo;
    final String? website;
    final String link;
    final String country;
    final String state;
    final Map? handles;
    final String type;
    final bool active;
    final String createdAt;

    Station({
      required this.id,
      required this.title,
      required this.frequency,
      required this.logo,
      required this.website,
      required this.link,
      required this.country,
      required this.state,
      required this.handles,
      required this.type,
      required this.active,
      required this.createdAt,
    });

    factory Station.fromJson(Map<String, dynamic> json) => Station(
        id: json["id"] as int,
        title: json['title'],
        frequency: json['frequency'],
        logo: json['logo'],
        website: json['website'],
        link: json['link'],
        country: json['country'],
        state: json['state'],
        handles: json['handles'] ?? {},
        type: json['type'],
        active: json['active'] == 1,
        createdAt: json['created_at'],        
    );

    Map<String, dynamic> toJson() => {
      'id': id,
      'title': title,
      'frequency': frequency,
      'logo': logo,
      'website': website,
      'link': link,
      'country': country,
      'state': state,
      'handles': handles,
      'type': type,
      'active': active,
      'created_at': createdAt,
    };

    String? social(String handle) => /* %%% */ handles!['handle'];

    String signal() => frequency.toString() + ' FM'; //full signal
    
    
}
