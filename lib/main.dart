import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Tinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LandingScreen(),
    );
  }
}

// Make sure you have these assets in pubspec.yaml
final List<String> videoAssets = [
  'assets/first.mp4',
  'assets/slide.mp4',
  'assets/dual.mp4',
];

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Find Your Favorite Video',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Swipe right for videos you like, and left for those you don\'t. Continue until one remains!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const VideoTinderScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MAIN GAME SCREEN ---
enum GameState { loading, playing, finished, transitioning }

class VideoTinderScreen extends StatefulWidget {
  const VideoTinderScreen({super.key});

  @override
  State<VideoTinderScreen> createState() => _VideoTinderScreenState();
}

class _VideoTinderScreenState extends State<VideoTinderScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  GameState _gameState = GameState.loading;
  List<String> _videosForCurrentRound = [];
  final List<String> _likedVideos = [];
  List<VideoPlayerController> _videoControllers = [];
  int _cardIndex = 0;
  int _roundNumber = 1;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startNewGame() {
    _roundNumber = 1;
    _likedVideos.clear();
    _videosForCurrentRound = List.from(videoAssets);
    _initializeControllersForRound();
  }

  void _startNextRound() {
    _videosForCurrentRound = List.from(_likedVideos);
    _likedVideos.clear();
    _roundNumber++;

    // Show nice transition
    setState(() => _gameState = GameState.transitioning);
    Future.delayed(const Duration(seconds: 2), () {
      _initializeControllersForRound();
    });
  }

  Future<void> _initializeControllersForRound() async {
    setState(() => _gameState = GameState.loading);

    await Future.wait(_videoControllers.map((c) async {
      try {
        await c.dispose();
      } catch (_) {}
    }));
    _videoControllers.clear();

    if (_videosForCurrentRound.isEmpty) {
      setState(() => _gameState = GameState.finished);
      return;
    }

    _videoControllers = _videosForCurrentRound
        .map((asset) => VideoPlayerController.asset(asset))
        .toList();

    await Future.wait(_videoControllers.map((c) async {
      await c.initialize();
      c.setLooping(true);
    }));

    if (mounted && _videoControllers.isNotEmpty) {
      _videoControllers[0].setVolume(1.0);
      _videoControllers[0].play();
      setState(() {
        _cardIndex = 0;
        _gameState = GameState.playing;
      });
    }
  }

  // --- UPDATED CODE ---
  bool _onSwipe(int previousIndex, int? newIndex, CardSwiperDirection direction) {
    // Always pause the video that was just swiped.
    if (previousIndex < _videoControllers.length) {
      _videoControllers[previousIndex].pause();
    }

    // If the swipe was to the right, add the video to the liked list.
    if (direction == CardSwiperDirection.right) {
      _likedVideos.add(_videosForCurrentRound[previousIndex]);
    }

    // If there is a new card coming into view, play its video.
    if (newIndex != null && newIndex < _videoControllers.length) {
      _videoControllers[newIndex].setVolume(1.0);
      _videoControllers[newIndex].play();
      setState(() {
        _cardIndex = newIndex;
      });
    }
    
    // Return true to allow the swipe.
    return true;
  }

  Future<void> _onEnd() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (var controller in _videoControllers) {
      controller.pause();
    }

    if (_likedVideos.length > 1) {
      _startNextRound();
    } else {
      setState(() => _gameState = GameState.finished);
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_gameState) {
      case GameState.loading:
        return const Center(child: CircularProgressIndicator());
      case GameState.playing:
        return _buildGameScreen();
      case GameState.transitioning:
        return _buildTransitionScreen();
      case GameState.finished:
        return ResultScreen(
          likedVideos: _likedVideos,
          onRestart: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const VideoTinderScreen()),
            );
          },
        );
    }
  }

  Widget _buildTransitionScreen() {
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
              "Round $_roundNumber",
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Get ready for the next round!",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    final total = _videosForCurrentRound.length;
    final remaining = total - _cardIndex;

    return Stack(
      alignment: Alignment.center,
      children: [
        CardSwiper(
          controller: _swiperController,
          cardsCount: total,
          onSwipe: _onSwipe,
          onEnd: _onEnd,
          isLoop: false,
          allowedSwipeDirection: const AllowedSwipeDirection.only(left: true, right: true),
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            return VideoCard(controller: _videoControllers[index]);
          },
        ),

        // --- Round + Remaining Info ---
        Positioned(
          top: 50,
          child: Column(
            children: [
              Text(
                "Round $_roundNumber",
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

        // --- Action Buttons ---
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: "dislike",
                onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
                backgroundColor: Colors.red,
                child: const Icon(Icons.close, color: Colors.white),
              ),
              FloatingActionButton(
                heroTag: "like",
                onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
                backgroundColor: Colors.green,
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Video Card Widget ---
class VideoCard extends StatefulWidget {
  final VideoPlayerController controller;
  const VideoCard({super.key, required this.controller});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _showPlayPauseIcon = false;
  Timer? _iconVisibilityTimer;

  @override
  void dispose() {
    _iconVisibilityTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!widget.controller.value.isInitialized) return;
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
      _showPlayPauseIcon = true;
    });

    _iconVisibilityTimer?.cancel();
    _iconVisibilityTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showPlayPauseIcon = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: VideoPlayer(widget.controller),
          ),
          AnimatedOpacity(
            opacity: _showPlayPauseIcon ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Result Screen ---
class ResultScreen extends StatefulWidget {
  final List<String> likedVideos;
  final VoidCallback onRestart;

  const ResultScreen({super.key, required this.likedVideos, required this.onRestart});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  VideoPlayerController? _favoriteController;

  @override
  void initState() {
    super.initState();
    if (widget.likedVideos.length == 1) {
      _favoriteController = VideoPlayerController.asset(widget.likedVideos.first)
        ..initialize().then((_) {
          if (mounted) {
            _favoriteController?.setLooping(true);
            _favoriteController?.play();
            setState(() {});
          }
        });
    }
  }

  @override
  void dispose() {
    _favoriteController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFavorite = widget.likedVideos.length == 1;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasFavorite && _favoriteController?.value.isInitialized == true) ...[
                const Text(
                  "Your Favorite Video!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _favoriteController!.value.aspectRatio,
                      child: VideoPlayer(_favoriteController!),
                    ),
                  ),
                ),
              ] else if (hasFavorite) ...[
                const CircularProgressIndicator(),
              ] else ...[
                const Icon(Icons.videocam_off, size: 50, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  "No Favorite Selected",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "You disliked all the videos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 40),
              FloatingActionButton.extended(
                onPressed: widget.onRestart,
                icon: const Icon(Icons.refresh),
                label: const Text('Start Over'),
                backgroundColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}