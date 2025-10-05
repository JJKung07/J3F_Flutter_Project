# VidSwipe - Flutter Video Tinder App

A Flutter application that implements a "Tinder-like" swiping interface for videos, built with clean **BLoC architecture** for state management.

## 🎯 Features

- **Video Swiping Interface**: Swipe right to like videos, left to dislike
- **Multi-Round Elimination**: Continue swiping until only one favorite video remains

## 🏗️ Architecture

This project follows the **BLoC (Business Logic Component)** architecture pattern:

```
lib/
├── bloc/                   # Business Logic Layer
│   ├── video_game_cubit.dart
│   └── video_game_state.dart
├── models/                 # Data Models
│   └── video_model.dart
├── repositories/           # Data Layer
│   └── video_repository.dart
├── screens/               # UI Screens
│   ├── landing_screen.dart
│   ├── video_tinder_screen.dart
│   └── result_screen.dart
├── widgets/               # Reusable UI Components
│   └── video_card.dart
└── main.dart             # App Entry Point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/JJKung07/J3F_Flutter_Project.git
   cd J3F_Flutter_Project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Chrome (Web)
   flutter run -d chrome
   
   # For Android/iOS device
   flutter run
   
   # For Windows
   flutter run -d windows
   ```

## 📱 How to Use

1. **Launch the app** - You'll see the landing screen with game instructions
2. **Start Game** - Tap the "Start Game" button to begin
3. **Swipe Videos** - 
   - Swipe **right** to **like** a video
   - Swipe **left** to **dislike** a video
4. **Continue Rounds** - Keep swiping until only one video remains
5. **View Results** - See your final favorite video or restart the game

## 🏛️ BLoC Architecture Details

### States (`video_game_state.dart`)
- `VideoGameInitial` - App startup state
- `VideoGameLoading` - Loading videos or processing
- `VideoGamePlaying` - Active game with swipeable videos
- `VideoGameTransitioning` - Between rounds animation
- `VideoGameAllLiked` - Special state when user likes all videos
- `VideoGameFinished` - Game completed with results
- `VideoGameError` - Error handling state

### Cubit (`video_game_cubit.dart`)
- **`startNewGame()`** - Initialize new game session
- **`swipeVideo()`** - Handle video swipe logic
- **`restartGame()`** - Reset and start over
- **`_handleRoundEnd()`** - Process round completion
- **`_startNextRound()`** - Set up next elimination round

### Repository (`video_repository.dart`)
- **`getAllVideos()`** - Fetch initial video collection
- **`getVideosForNextRound()`** - Process videos for next round
- **`eliminateHalfVideos()`** - Smart elimination algorithm

### Models (`video_model.dart`)
- **`Video`** - Individual video data model
- **`GameRound`** - Round information and state
- **`GameStatus`** - Enumeration of possible game states

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1      # State management
  equatable: ^2.0.7         # Value equality
  video_player: ^2.10.0     # Video playback
  flutter_card_swiper: ^7.0.2  # Swipe animations
```

## 🎨 UI Components

### Screens
- **LandingScreen** - Welcome screen with game instructions
- **VideoTinderScreen** - Main game interface with swipeable cards
- **ResultScreen** - Final results and restart option

### Widgets
- **VideoCard** - Reusable video player card component

## 🔄 Data Flow

1. **User Interaction** (swipe/button press) → Cubit method call
2. **Cubit** processes business logic → Emits new state
3. **UI** listens to state changes → Rebuilds accordingly
4. **Repository** handles data operations → Returns results to cubit


## 🎯 Game Logic

1. **Initial Round**: Start with all available videos
2. **Elimination Process**: 
   - User swipes through all videos in current round
   - Liked videos advance to next round
   - If all videos are liked, system automatically eliminates half
   - If no videos are liked, game ends with no favorites
3. **Victory Condition**: Game continues until exactly 1 video remains


## 👨‍💻 Author

- *JJKung07* - [GitHub Profile](https://github.com/JJKung07) 
- *Pattaradanai888* - - [GitHub Profile](https://github.com/Pattaradanai888)
- *chawanakorns* - - [GitHub Profile](https://github.com/chawanakorns)
- *Thanaphat14* - - [GitHub Profile](https://github.com/thanaphat14)


---

**Happy Swiping! 🎬📱**
