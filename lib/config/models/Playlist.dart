import 'package:jollofradio/config/models/Episode.dart';

class Playlist {
    final int id;
    final String name;
    final String logo;
    final List<Episode> collection;

    Playlist({
      required this.id,
      required this.name,
      required this.logo,
      required this.collection,
    });

    factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json["id"] as int,
        name: json['name'],
        logo: json['logo'],
        collection: json[
          'collection'
        ].map<Episode>((episode) => Episode.fromJson(episode)).toList(),
    );

    Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'logo': logo,
      'collection': collection
    };
}
