import 'package:equatable/equatable.dart';
import '../models/video_model.dart';

abstract class VideoGameState extends Equatable {
  const VideoGameState();

  @override
  List<Object?> get props => [];
}

class VideoGameInitial extends VideoGameState {}

class VideoGameLoading extends VideoGameState {}

class VideoGamePlaying extends VideoGameState {
  final GameRound currentRound;
  final int currentVideoIndex;

  const VideoGamePlaying({
    required this.currentRound,
    required this.currentVideoIndex,
  });

  @override
  List<Object?> get props => [currentRound, currentVideoIndex];
}

class VideoGameTransitioning extends VideoGameState {
  final int nextRoundNumber;
  final int likedVideosCount;

  const VideoGameTransitioning({
    required this.nextRoundNumber,
    required this.likedVideosCount,
  });

  @override
  List<Object?> get props => [nextRoundNumber, likedVideosCount];
}

class VideoGameFinished extends VideoGameState {
  final List<Video> finalResults;
  final int totalRounds;

  const VideoGameFinished({
    required this.finalResults,
    required this.totalRounds,
  });

  @override
  List<Object?> get props => [finalResults, totalRounds];
}

class VideoGameError extends VideoGameState {
  final String message;

  const VideoGameError(this.message);

  @override
  List<Object?> get props => [message];
}

class VideoGameAllLiked extends VideoGameState {
  final int eliminatedCount;
  final int remainingCount;

  const VideoGameAllLiked({
    required this.eliminatedCount,
    required this.remainingCount,
  });

  @override
  List<Object?> get props => [eliminatedCount, remainingCount];
}