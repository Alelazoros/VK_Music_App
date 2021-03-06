import 'dart:convert';

Song songFromJson(String str) {
  if (str != null && str?.isNotEmpty) {
    final data = json.decode(str);
    return Song.fromJson(data);
  }
}

String songToJson(Song data) {
  final str = data.toJson();
  return json.encode(str);
}

class Song {
  String title;
  String artist;
  String download;
  String image;
  String path;
  int duration;
  int song_id;
  bool in_my_list;

  Song(
      {this.song_id,
      this.artist,
      this.title,
      this.duration,
      this.download,
      this.path,
      this.image,
      this.in_my_list});

  @override
  int get hashCode => song_id.hashCode;

  bool operator ==(o) => song_id == o.song_id;

  @override
  toString() {
    return '$artist - $title';
  }

  toFileName() {
    String formatArtist = artist.replaceAll(' ', '_');
    String formatTitle = title.replaceAll(' ', '_');
    return '$formatArtist-$formatTitle.mp3';
  }

  factory Song.fromJson(Map<String, dynamic> json) => new Song(
      title: json['name'],
      artist: json['artist'],
      duration: json['duration'],
      download: json['download'],
      song_id: json['song_id'],
      image: json['image'],
      path: json['path'],
      in_my_list: json['in_my_list']);

  Map<String, dynamic> toJson() => {
        'name': title,
        'artist': artist,
        'duration': duration,
        'download': download,
        'song_id': song_id,
        'image': image,
        'path': path ?? "",
        'in_my_list': in_my_list ?? false
      };
}
