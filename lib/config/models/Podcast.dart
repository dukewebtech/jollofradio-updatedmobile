import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/models/Episode.dart';

class Podcast {
  final int id;
  final Creator creator;
  final String title;
  final String slug;
  final String logo;
  final String? description;
  final bool latest;
  final bool subscribed;
  final bool approved;
  final bool active;
  final Map category;
  final int episodeCount;
  final List<Episode>? episodes;
  final String createdAt;

  Podcast({
    required this.id,
    required this.creator,
    required this.title,
    required this.slug,
    required this.logo,
    required this.description,
    required this.latest,
    required this.subscribed,
    required this.approved,
    required this.active,
    required this.category,
    required this.episodeCount,
    required this.episodes,
    required this.createdAt,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) => Podcast(
      id: json["id"] as int,
      creator: Creator.fromJson(
        json['creator']
      ),
      
      title: json['title'],
      slug: json['slug'],
      logo: json['logo'],
      description: json['description'],
      latest: json['latest'],
      subscribed: json['subscribed'],
      approved: json['approved'] == 1,
      active: json['active'] == 1,
      category: json['category'],
      episodeCount: json['item_count'],

      episodes: json['episodes']?.map
      <Episode>((episode) => Episode.fromJson(episode)).toList()
      ?? [],
      
      createdAt: json['created_at'],
      
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'creator': creator,
    'title': title,
    'slug': slug,
    'logo': logo,
    'description': description,
    'latest': latest,
    'subscribed': subscribed,
    'approved': approved,
    'active': active,
    'category': category,
    'item_count': episodeCount,
    'episodes': episodes,
    'created_at': createdAt,
  };
    
}
