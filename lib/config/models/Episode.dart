import 'package:jollofradio/config/models/Creator.dart';

class Episode {
    final int id;
    final Creator creator;
    final String title;
    final String logo;
    final String? description;
    final String source;
    final String duration;
    final Map streams;
    final String podcast;
    final bool liked;
    final String createdAt;

    Episode({
      required this.id,
      required this.creator,
      required this.title,
      required this.logo,
      required this.description,
      required this.source,
      required this.duration,
      required this.streams,
      required this.podcast,
      required this.liked,
      required this.createdAt,
    });

    factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        id: json["id"] as int,
        creator: Creator.fromJson(
          json['creator']
        ),
        title: json['title'],
        logo: json['logo'],
        description: json['description'],
        source: json['source'],
        duration: json['duration'],
        streams: json['streams'],
        podcast: json['podcast'],
        liked: json['liked'],
        createdAt: json['created_at'],
    );

    Map<String, dynamic> toJson() => {
      'id': id,
      'creator': creator,
      'title': title,
      'logo': logo,
      'description': description,
      'source': source,
      'duration': duration,
      'streams': streams,
      'podcast': podcast,
      'liked': liked,
      'created_at': createdAt,
    };
}
