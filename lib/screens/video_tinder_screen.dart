import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../constants/app_constants.dart';
import '../widgets/video_card.dart';
import 'result_screen.dart';

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

  bool _onSwipe(int previousIndex, int? newIndex, CardSwiperDirection direction) {
    if (previousIndex < _videoControllers.length) {
      _videoControllers[previousIndex].pause();
    }

    if (direction == CardSwiperDirection.right) {
      _likedVideos.add(_videosForCurrentRound[previousIndex]);
    }

    if (newIndex != null && newIndex < _videoControllers.length) {
      _videoControllers[newIndex].setVolume(1.0);
      _videoControllers[newIndex].play();
      setState(() {
        _cardIndex = newIndex;
      });
    } else {
      setState(() {
        _cardIndex = previousIndex + 1;
      });
    }
    
    return true;
  }

  Future<void> _onEnd() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (var controller in _videoControllers) {
      controller.pause();
    }

    // Check if we have a winner (exactly 1 video)
    if (_likedVideos.length == 1) {
      setState(() => _gameState = GameState.finished);
      return;
    }

    // If user liked NONE, end the game with no favorites
    if (_likedVideos.isEmpty) {
      setState(() => _gameState = GameState.finished);
      return;
    }

    // If user liked ALL videos, we need to eliminate some
    if (_likedVideos.length == _videosForCurrentRound.length) {
      // Automatically eliminate half (rounded up) to ensure progress
      final half = (_videosForCurrentRound.length / 2).ceil();
      _likedVideos.clear();
      _likedVideos.addAll(_videosForCurrentRound.take(half));
      
      // Show message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❤️ You liked all! Keeping top ${_likedVideos.length} videos'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    // Continue to next round if we have more than 1 video
    if (_likedVideos.length > 1) {
      _startNextRound();
    } else {
      setState(() => _gameState = GameState.finished);
    }
  }

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

        // Action Buttons
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
