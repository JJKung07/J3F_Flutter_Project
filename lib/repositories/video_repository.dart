import '../models/video_model.dart';

class VideoRepository {
  static const List<String> _videoUrls = [
    'https://res.cloudinary.com/dc4de2jdr/video/upload/v1759671036/cat-fly_rutekq.mp4',
    'https://res.cloudinary.com/dc4de2jdr/video/upload/v1759671355/green-alien2_huxheo.mp4',
    'https://res.cloudinary.com/dc4de2jdr/video/upload/v1759671355/dog-dance_kqyjml.mp4',
    'https://res.cloudinary.com/dc4de2jdr/video/upload/v1759671355/cat-tried_z7cfhh.mp4',
    'https://res.cloudinary.com/dc4de2jdr/video/upload/v1759671355/green-alien_vdpc8j.mp4',
    'https://res.cloudinary.com/dc4de2jdr/video/upload/v1759671356/labubu_tkcgdd.mp4',
    'https://res.cloudinary.com/dc4de2jdr/video/upload/v1759671356/roblox-face_fgwiir.mp4',
  ];

  static const List<String> _videoTitles = [
    'Cat Flying',
    'Green Alien 2',
    'Dog Dance',
    'Cat Tried',
    'Green Alien',
    'Labubu',
    'Roblox Face',
  ];

  Future<List<Video>> getAllVideos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return List.generate(
      _videoUrls.length,
      (index) => Video(
        id: 'video_$index',
        url: _videoUrls[index],
        title: _videoTitles[index],
      ),
    );
  }

  Future<List<Video>> getVideosForNextRound(List<Video> likedVideos) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // If user liked all videos, automatically eliminate half to ensure progress
    if (likedVideos.isEmpty) {
      return [];
    }
    
    return List.from(likedVideos);
  }

  List<Video> eliminateHalfVideos(List<Video> videos) {
    if (videos.length <= 1) return videos;
    
    final half = (videos.length / 2).ceil();
    return videos.take(half).toList();
  }
}