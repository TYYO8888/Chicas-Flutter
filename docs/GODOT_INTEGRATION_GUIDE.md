# 🎮 Godot Game Integration Guide

## Overview

This guide explains how to integrate Godot games into the Chica's Chicken Flutter ordering app. The integration allows customers to play games and earn rewards (discounts, loyalty points, free items) that can be applied to their orders.

## Architecture

### Integration Methods

1. **Web Export (Recommended)** - Export Godot games as HTML5 and embed via WebView
2. **Native Plugin** - Create custom Flutter plugin for direct Godot integration
3. **Hybrid Approach** - Combine both methods based on game complexity

### Current Implementation

- **Method**: Web Export via WebView
- **Communication**: JavaScript bridge between Godot and Flutter
- **Rewards**: Integrated with existing loyalty system
- **Storage**: Local storage for game progress and rewards

## File Structure

```
lib/
├── services/
│   └── game_service.dart          # Game management and rewards
├── screens/
│   ├── games_hub_screen.dart      # Main games section
│   └── game_screen.dart           # Individual game player
└── widgets/
    └── custom_bottom_nav_bar.dart # Updated with games tab

assets/
└── games/
    ├── chicken_catch/
    │   └── index.html             # Sample HTML5 game
    ├── spice_mixer/
    │   └── index.html             # Puzzle game
    └── delivery_dash/
        └── index.html             # Action game
```

## Game Development Workflow

### 1. Godot Game Development

#### Export Settings
```gdscript
# In Godot export settings:
- Platform: HTML5
- Export Path: assets/games/[game_name]/index.html
- Features: Enable JavaScript evaluation
- Custom HTML Shell: Use provided template
```

#### Communication Script (GDScript)
```gdscript
extends Node

# Send message to Flutter
func send_to_flutter(type: String, data: Dictionary):
    var message = JSON.stringify({"type": type, "data": data})
    JavaScript.eval("sendMessageToFlutter('%s', %s)" % [type, JSON.stringify(data)])

# Receive message from Flutter
func _ready():
    JavaScript.eval("""
        window.receiveFlutterMessage = function(message) {
            var data = JSON.parse(message);
            godot.send_flutter_message(data.type, data.data);
        };
    """)

# Game completion
func complete_game(score: float, time_spent: int):
    send_to_flutter("gameCompleted", {
        "score": score,
        "timeSpent": time_spent
    })
```

### 2. Flutter Integration

#### Add Game Configuration
```dart
// In game_service.dart
final Map<String, GameConfig> _availableGames = {
  'your_game_id': GameConfig(
    id: 'your_game_id',
    name: 'Your Game Name',
    description: 'Game description',
    webUrl: 'assets/games/your_game/index.html',
    rewardType: RewardType.discount,
    maxReward: 15.0,
    category: GameCategory.arcade,
    estimatedPlayTime: 60,
  ),
};
```

#### Launch Game
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => GameScreen(gameId: 'your_game_id'),
  ),
);
```

## Communication Protocol

### Flutter → Godot Messages

```javascript
// Initialize game
{
  "type": "initialize",
  "data": {
    "gameId": "chicken_catch",
    "playerData": {...},
    "settings": {...}
  }
}

// Pause/Resume
{
  "type": "pause"
}
{
  "type": "resume"
}
```

### Godot → Flutter Messages

```javascript
// Game ready
{
  "type": "gameReady"
}

// Score update
{
  "type": "scoreUpdate",
  "score": 150
}

// Game completion
{
  "type": "gameCompleted",
  "score": 200,
  "timeSpent": 45
}

// Error handling
{
  "type": "gameError",
  "message": "Error description"
}
```

## Reward System

### Reward Types

1. **Discount** - Percentage off next order
2. **Points** - Loyalty points added to account
3. **Free Item** - Free side, drink, or dessert

### Reward Calculation

```dart
GameReward _calculateReward(GameConfig game, double score, int timeSpent) {
  double performanceRatio = score / 100.0; // Normalize score
  double timeBonus = timeSpent < game.estimatedPlayTime ? 0.2 : 0.0;
  
  final rewardAmount = game.maxReward * (performanceRatio + timeBonus).clamp(0.0, 1.0);
  
  return GameReward(
    type: game.rewardType,
    amount: rewardAmount,
    description: _getRewardDescription(game.rewardType, rewardAmount),
  );
}
```

## Game Categories

### 1. Arcade Games
- **Examples**: Chicken Catch, Burger Stack
- **Mechanics**: Fast-paced, reaction-based
- **Rewards**: Discounts (5-15%)

### 2. Puzzle Games
- **Examples**: Spice Mixer, Recipe Match
- **Mechanics**: Logic, strategy
- **Rewards**: Loyalty points (50-100)

### 3. Action Games
- **Examples**: Delivery Dash, Kitchen Rush
- **Mechanics**: Time management, coordination
- **Rewards**: Free items

## Performance Optimization

### WebView Settings
```dart
InAppWebViewSettings(
  javaScriptEnabled: true,
  domStorageEnabled: true,
  allowsInlineMediaPlayback: true,
  mediaPlaybackRequiresUserGesture: false,
  transparentBackground: true,
  supportZoom: false,
  disableHorizontalScroll: true,
  disableVerticalScroll: true,
)
```

### Memory Management
- Keep screen awake during gameplay
- Dispose WebView properly
- Cache game assets
- Limit concurrent games

## Testing

### Local Testing
1. Create HTML5 game in `assets/games/[game_name]/`
2. Add game configuration to `GameService`
3. Test in Flutter app
4. Verify communication and rewards

### Device Testing
1. Test on various screen sizes
2. Verify touch controls
3. Check performance on low-end devices
4. Test network connectivity issues

## Deployment

### Assets
- Include all game files in `pubspec.yaml`
- Optimize game assets for mobile
- Test on target platforms

### App Store Considerations
- Ensure games comply with platform policies
- Include appropriate age ratings
- Test in-app purchase integration if applicable

## Troubleshooting

### Common Issues

1. **WebView not loading**
   - Check file paths in assets
   - Verify HTML5 export settings
   - Test JavaScript console for errors

2. **Communication not working**
   - Verify JavaScript bridge setup
   - Check message format
   - Test with console logging

3. **Performance issues**
   - Optimize game assets
   - Reduce particle effects
   - Lower frame rate if needed

### Debug Tools
```dart
// Enable WebView debugging
onConsoleMessage: (controller, consoleMessage) {
  debugPrint('🎮 Game Console: ${consoleMessage.message}');
},
```

## Future Enhancements

### Planned Features
1. **Multiplayer games** - Compete with other customers
2. **Seasonal events** - Special games for holidays
3. **Leaderboards** - Global and local rankings
4. **Achievement system** - Unlock special rewards
5. **Social sharing** - Share scores and rewards

### Advanced Integration
1. **Native Godot plugin** - Better performance
2. **Real-time multiplayer** - WebSocket integration
3. **AR games** - Camera-based experiences
4. **Voice controls** - Accessibility features

## Support

For technical support or questions about game integration:
- Check the Flutter documentation
- Review Godot HTML5 export guides
- Test with provided sample games
- Contact development team for assistance

---

**Note**: This integration is designed to enhance the ordering experience while providing entertainment value. All games should be quick (1-3 minutes) and directly related to the restaurant theme.
