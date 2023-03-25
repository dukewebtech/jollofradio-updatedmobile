import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/models/Episode.dart';

class Podcast {
    final int id;
    final Creator creator;
    final String title;
    final String logo;
    final String? description;
    final bool latest;
    final bool subscribed;
    final bool approved;
    final bool active;
    final Map category;
    final List<Episode> episodes;
    final String createdAt;

    Podcast({
      required this.id,
      required this.creator,
      required this.title,
      required this.logo,
      required this.description,
      required this.latest,
      required this.subscribed,
      required this.approved,
      required this.active,
      required this.category,
      required this.episodes,
      required this.createdAt,
    });

    factory Podcast.fromJson(Map<String, dynamic> json) => Podcast(
        id: json["id"] as int,
        creator: Creator.fromJson(
          json['creator']
        ),
        title: json['title'],
        logo: json['logo'],
        description: json['description'],
        latest: json['latest'],
        subscribed: json['subscribed'],
        approved: json['approved'] == 1,
        active: json['active'] == 1,
        category: json['category'],

        episodes: json['episodes'].map
        <Episode>((episode) => Episode.fromJson(episode)).toList(),
        
        createdAt: json['created_at'],
    );

    Map<String, dynamic> toJson() => {
      'id': id,
      'creator': creator,
      'title': title,
      'logo': logo,
      'description': description,
      'latest': latest,
      'subscribed': subscribed,
      'approved': approved,
      'active': active,
      'category': category,
      'episodes': episodes,
      'created_at': createdAt,
    };
    
}
