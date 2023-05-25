import 'package:jollofradio/config/models/Creator.dart';

class Episode {
  final int id;
  final Creator? creator;
  final String title;
  final String slug;
  final String logo;
  final String? description;
  final String source;
  final String duration;
  final Map streams;
  final Map meta;
  final String podcast;
  final int podcastId;
  final bool liked;
  final bool? active;
  final String createdAt;

  Episode({
    required this.id,
    required this.creator,
    required this.title,
    required this.slug,
    required this.logo,
    required this.description,
    required this.source,
    required this.duration,
    required this.streams,
    required this.meta,
    required this.podcast,
    required this.podcastId,
    required this.liked,
    this.active = true,
    required this.createdAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
      id: json["id"] as int,
      creator: json['creator'] == null ? null : Creator.fromJson(
        json['creator']
      ),
      title: json['title'],
      slug: json['slug'],
      logo: json['logo'],
      description: json['description'],
      source: json['source'],
      duration: json['duration'],
      streams: json['streams'],
      meta: json['meta'],
      podcast: json['podcast'],
      podcastId: json['podcast_id'],
      liked: json['liked'],
      active: json['active'],
      createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'creator': creator?.toJson(),
    'title': title,
    'slug': slug,
    'logo': logo,
    'description': description,
    'source': source,
    'duration': duration,
    'streams': streams,
    'meta': meta,
    'podcast': podcast,
    'podcast_id': podcastId,
    'liked': liked,
    'active': active,
    'created_at': createdAt,
  };
}
