import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/landing_screen.dart';
import 'bloc/video_game_cubit.dart';
import 'repositories/video_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoGameCubit(VideoRepository()),
      child: MaterialApp(
        title: 'VidSwipe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const LandingScreen(),
      ),
    );
  }
}
