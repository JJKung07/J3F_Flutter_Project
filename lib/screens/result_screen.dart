import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ResultScreen extends StatefulWidget {
  final List<String> likedVideos;
  final VoidCallback onRestart;

  const ResultScreen({
    super.key,
    required this.likedVideos,
    required this.onRestart,
  });

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
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _favoriteController!.value.aspectRatio,
                        child: VideoPlayer(_favoriteController!),
                      ),
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
