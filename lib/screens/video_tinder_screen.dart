import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/video_card.dart';
import '../bloc/video_game_cubit.dart';
import '../bloc/video_game_state.dart';
import '../models/video_model.dart';
import 'result_screen.dart';

class VideoTinderScreen extends StatefulWidget {
  const VideoTinderScreen({super.key});

  @override
  State<VideoTinderScreen> createState() => _VideoTinderScreenState();
}

class _VideoTinderScreenState extends State<VideoTinderScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  List<VideoPlayerController> _videoControllers = [];

  @override
  void dispose() {
    _swiperController.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _currentVideos = null;
    super.dispose();
  }



  bool _onSwipe(int previousIndex, int? newIndex, CardSwiperDirection direction) {
    // Pause the previous video
    if (previousIndex < _videoControllers.length) {
      _videoControllers[previousIndex].pause();
    }

    // Start playing the next video if available
    if (newIndex != null && newIndex < _videoControllers.length) {
      _videoControllers[newIndex].setVolume(1.0);
      _videoControllers[newIndex].play();
    }

    // Handle the swipe action
    final isLiked = direction == CardSwiperDirection.right;
    context.read<VideoGameCubit>().swipeVideo(
      videoIndex: previousIndex,
      isLiked: isLiked,
    );
    
    return true;
  }

  Future<void> _onEnd() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Pause all videos
    for (var controller in _videoControllers) {
      controller.pause();
    }
  }

  List<Video>? _currentVideos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<VideoGameCubit, VideoGameState>(
        listener: (context, state) async {
          if (state is VideoGamePlaying) {
            // Only initialize controllers if we have new videos
            if (_currentVideos == null || 
                _currentVideos!.length != state.currentRound.videos.length ||
                _currentVideos!.first.id != state.currentRound.videos.first.id) {
              _currentVideos = state.currentRound.videos;
              await _initializeVideoControllers(state.currentRound.videos);
            }
          } else if (state is VideoGameAllLiked) {
            // Show message when user liked all videos
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❤️ You liked all! Keeping top ${state.remainingCount} videos'),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is VideoGameFinished) {
            // Navigate to result screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(
                  likedVideos: state.finalResults.map((v) => v.url).toList(),
                  onRestart: () {
                    context.read<VideoGameCubit>().restartGame();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const VideoTinderScreen()),
                    );
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(VideoGameState state) {
    if (state is VideoGameLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is VideoGamePlaying) {
      return _buildGameScreen(state);
    } else if (state is VideoGameTransitioning) {
      return _buildTransitionScreen(state);
    } else if (state is VideoGameAllLiked) {
      return _buildAllLikedScreen(state);
    } else if (state is VideoGameError) {
      return _buildErrorScreen(state);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildErrorScreen(VideoGameError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 80),
          const SizedBox(height: 20),
          Text(
            'Error: ${state.message}',
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<VideoGameCubit>().restartGame(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionScreen(VideoGameTransitioning state) {
    return Center(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill, color: Colors.orangeAccent, size: 80),
            const SizedBox(height: 20),
            Text(
              "Round ${state.nextRoundNumber}",
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Get ready for the next round!\n${state.likedVideosCount} videos remaining",
              style: const TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllLikedScreen(VideoGameAllLiked state) {
    return Center(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: Colors.orange, size: 80),
            const SizedBox(height: 20),
            const Text(
              "You liked all videos!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Keeping top ${state.remainingCount} videos\nEliminated ${state.eliminatedCount} videos",
              style: const TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen(VideoGamePlaying state) {
    final total = state.currentRound.videos.length;
    final remaining = total - state.currentVideoIndex;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (_videoControllers.isNotEmpty)
          CardSwiper(
            controller: _swiperController,
            cardsCount: total,
            onSwipe: _onSwipe,
            onEnd: _onEnd,
            isLoop: false,
            allowedSwipeDirection: const AllowedSwipeDirection.only(
              left: true,
              right: true,
            ),
            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
              return VideoCard(controller: _videoControllers[index]);
            },
          ),

        Positioned(
          top: 50,
          child: Column(
            children: [
              Text(
                "Round ${state.currentRound.roundNumber}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "Videos left: $remaining / $total",
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),

        // TODO: ASSIGNMENT - Implement Like/Dislike Action Buttons
        // Your task is to add action buttons that allow users to programmatically swipe cards
        // Requirements:
        // 1. Add two FloatingActionButton widgets (or similar) at the bottom of the screen
        // 2. One button for "dislike" (swipe left) - use red color and close/X icon
        // 3. One button for "like" (swipe right) - use green color and heart/favorite icon
        // 4. Make sure to set unique heroTag for each FloatingActionButton
        // 5. Position the buttons in a Row with MainAxisAlignment.spaceEvenly
        // 6. Wrap in a Positioned widget with bottom: 40, left: 0, right: 0
        //
        // Hint: Look at how CardSwiperController is used and imported
      ],
    );
  }

  Future<void> _initializeVideoControllers(List<Video> videos) async {
    // Dispose old controllers
    await Future.wait(_videoControllers.map((c) async {
      try {
        await c.dispose();
      } catch (_) {}
    }));
    _videoControllers.clear();

    if (videos.isEmpty) return;

    // Create new controllers
    _videoControllers = videos
        .map((video) => VideoPlayerController.networkUrl(Uri.parse(video.url)))
        .toList();

    // Initialize all controllers
    await Future.wait(_videoControllers.map((c) async {
      await c.initialize();
      c.setLooping(true);
    }));

    // Start playing the first video
    if (mounted && _videoControllers.isNotEmpty) {
      _videoControllers[0].setVolume(1.0);
      _videoControllers[0].play();
      setState(() {});
    }
  }
}
