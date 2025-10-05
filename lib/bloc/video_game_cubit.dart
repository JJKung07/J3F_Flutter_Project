import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_game_state.dart';
import '../models/video_model.dart';
import '../repositories/video_repository.dart';

class VideoGameCubit extends Cubit<VideoGameState> {
  final VideoRepository repository;
  
  GameRound? _currentRound;
  int _totalRounds = 0;

  VideoGameCubit(this.repository) : super(VideoGameInitial());

  Future<void> startNewGame() async {
    emit(VideoGameLoading());
    try {
      final videos = await repository.getAllVideos();
      _totalRounds = 1;
      _currentRound = GameRound(
        roundNumber: 1,
        videos: videos,
        likedVideos: [],
      );

      emit(VideoGamePlaying(
        currentRound: _currentRound!,
        currentVideoIndex: 0,
      ));
    } catch (e) {
      emit(VideoGameError('Failed to start game: $e'));
    }
  }

  void swipeVideo({required int videoIndex, required bool isLiked}) {
    if (_currentRound == null) return;

    final video = _currentRound!.videos[videoIndex];
    final updatedLikedVideos = List<Video>.from(_currentRound!.likedVideos);
    
    if (isLiked) {
      updatedLikedVideos.add(video);
    }

    _currentRound = _currentRound!.copyWith(
      likedVideos: updatedLikedVideos,
      currentVideoIndex: videoIndex + 1,
    );

    // Check if this was the last video in the round
    if (videoIndex + 1 >= _currentRound!.videos.length) {
      _handleRoundEnd();
    } else {
      emit(VideoGamePlaying(
        currentRound: _currentRound!,
        currentVideoIndex: videoIndex + 1,
      ));
    }
  }

  Future<void> _handleRoundEnd() async {
    if (_currentRound == null) return;

    final likedVideos = _currentRound!.likedVideos;

    // Check if we have a winner (exactly 1 video)
    if (likedVideos.length == 1) {
      emit(VideoGameFinished(
        finalResults: likedVideos,
        totalRounds: _totalRounds,
      ));
      return;
    }

    // If user liked NONE, end the game with no favorites
    if (likedVideos.isEmpty) {
      emit(VideoGameFinished(
        finalResults: [],
        totalRounds: _totalRounds,
      ));
      return;
    }

    // If user liked ALL videos, we need to eliminate some
    List<Video> videosForNextRound = likedVideos;
    if (likedVideos.length == _currentRound!.videos.length) {
      videosForNextRound = repository.eliminateHalfVideos(likedVideos);
      
      // Emit special state to show message to user
      emit(VideoGameAllLiked(
        eliminatedCount: likedVideos.length - videosForNextRound.length,
        remainingCount: videosForNextRound.length,
      ));
      
      // Wait a bit for the message to be shown
      await Future.delayed(const Duration(seconds: 3));
    }

    // Continue to next round if we have more than 1 video
    if (videosForNextRound.length > 1) {
      await _startNextRound(videosForNextRound);
    } else {
      emit(VideoGameFinished(
        finalResults: videosForNextRound,
        totalRounds: _totalRounds,
      ));
    }
  }

  Future<void> _startNextRound(List<Video> videos) async {
    _totalRounds++;
    
    emit(VideoGameTransitioning(
      nextRoundNumber: _totalRounds,
      likedVideosCount: videos.length,
    ));

    await Future.delayed(const Duration(seconds: 2));

    try {
      _currentRound = GameRound(
        roundNumber: _totalRounds,
        videos: videos,
        likedVideos: [],
      );

      emit(VideoGamePlaying(
        currentRound: _currentRound!,
        currentVideoIndex: 0,
      ));
    } catch (e) {
      emit(VideoGameError('Failed to start next round: $e'));
    }
  }

  void restartGame() {
    _currentRound = null;
    _totalRounds = 0;
    startNewGame();
  }
}