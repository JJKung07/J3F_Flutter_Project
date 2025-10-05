import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String url;
  final String title;
  final bool isLiked;

  const Video({
    required this.id,
    required this.url,
    required this.title,
    this.isLiked = false,
  });

  Video copyWith({
    String? id,
    String? url,
    String? title,
    bool? isLiked,
  }) {
    return Video(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [id, url, title, isLiked];
}

class GameRound extends Equatable {
  final int roundNumber;
  final List<Video> videos;
  final List<Video> likedVideos;
  final int currentVideoIndex;

  const GameRound({
    required this.roundNumber,
    required this.videos,
    required this.likedVideos,
    this.currentVideoIndex = 0,
  });

  GameRound copyWith({
    int? roundNumber,
    List<Video>? videos,
    List<Video>? likedVideos,
    int? currentVideoIndex,
  }) {
    return GameRound(
      roundNumber: roundNumber ?? this.roundNumber,
      videos: videos ?? this.videos,
      likedVideos: likedVideos ?? this.likedVideos,
      currentVideoIndex: currentVideoIndex ?? this.currentVideoIndex,
    );
  }

  @override
  List<Object?> get props => [roundNumber, videos, likedVideos, currentVideoIndex];
}

enum GameStatus {
  initial,
  loading,
  playing,
  transitioning,
  finished,
}