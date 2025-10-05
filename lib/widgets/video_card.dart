import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

    final screenSize = MediaQuery.of(context).size;
    final videoAspectRatio = widget.controller.value.aspectRatio;
    final screenAspectRatio = screenSize.width / screenSize.height;
    
    double videoWidth;
    double videoHeight;
    
    if (videoAspectRatio > screenAspectRatio) {
      videoWidth = screenSize.width;
      videoHeight = videoWidth / videoAspectRatio;
    } else {
      videoHeight = screenSize.height * 0.7;
      videoWidth = videoHeight * videoAspectRatio;
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: videoWidth,
                height: videoHeight,
                child: AspectRatio(
                  aspectRatio: videoAspectRatio,
                  child: VideoPlayer(widget.controller),
                ),
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
        ),
      ),
    );
  }
}
