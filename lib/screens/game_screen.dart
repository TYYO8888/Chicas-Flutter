import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/game_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/navigation_service.dart';
import 'dart:convert';

/// 🎮 Game Screen - Displays and manages Godot games
/// 
/// This screen handles:
/// - Loading and displaying Godot games via WebView
/// - Game-to-Flutter communication
/// - Reward processing
/// - Performance monitoring
class GameScreen extends StatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final GameService _gameService = GameService();
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  DateTime? _gameStartTime;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Pause game when app goes to background
    if (state == AppLifecycleState.paused) {
      _pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      _resumeGame();
    }
  }

  Future<void> _initializeGame() async {
    try {
      // Keep screen awake during gameplay
      await WakelockPlus.enable();
      
      // Load game configuration
      final success = await _gameService.loadGame(widget.gameId);
      if (!success) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load game: ${widget.gameId}';
        });
        return;
      }
      
      _gameStartTime = DateTime.now();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error initializing game: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _gameService.availableGames[widget.gameId];
    
    if (game == null) {
      return _buildErrorScreen('Game not found');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildGameAppBar(game),
      body: _hasError ? _buildErrorScreen(_errorMessage) : _buildGameContent(game),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1, // Games section
        onItemSelected: (index) {
          _handleNavigation(index);
        },
      ),
    );
  }

  PreferredSizeWidget _buildGameAppBar(GameConfig game) {
    return AppBar(
      title: Text(
        game.name.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: _pauseGame,
          tooltip: 'Pause Game',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitGame,
          tooltip: 'Exit Game',
        ),
      ],
    );
  }

  Widget _buildGameContent(GameConfig game) {
    return Stack(
      children: [
        // Game WebView
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('file:///android_asset/flutter_assets/${game.webUrl}'),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            allowsInlineMediaPlayback: true,
            mediaPlaybackRequiresUserGesture: false,
            transparentBackground: true,
            supportZoom: false,
            disableHorizontalScroll: true,
            disableVerticalScroll: true,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
            _setupGameCommunication();
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isLoading = true;
            });
          },
          onLoadStop: (controller, url) {
            setState(() {
              _isLoading = false;
            });
            _initializeGameSession();
          },
          onReceivedError: (controller, request, error) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Failed to load game: ${error.description}';
              _isLoading = false;
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            _handleGameMessage(consoleMessage.message);
          },
        ),
        
        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading ${game.name}...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Game Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  void _setupGameCommunication() {
    // Add JavaScript interface for game communication
    _webViewController?.addJavaScriptHandler(
      handlerName: 'gameMessage',
      callback: (args) {
        if (args.isNotEmpty) {
          _handleGameMessage(args[0].toString());
        }
      },
    );
  }

  void _initializeGameSession() {
    // Send game configuration to Godot
    final gameConfig = {
      'gameId': widget.gameId,
      'playerData': _getPlayerData(),
      'settings': _getGameSettings(),
    };
    
    _sendMessageToGame('initialize', gameConfig);
  }

  void _handleGameMessage(String message) {
    try {
      final data = json.decode(message);
      final type = data['type'];
      
      switch (type) {
        case 'gameReady':
          _onGameReady();
          break;
        case 'gameCompleted':
          _onGameCompleted(data);
          break;
        case 'gameError':
          _onGameError(data['message']);
          break;
        case 'scoreUpdate':
          _onScoreUpdate(data['score']);
          break;
      }
    } catch (e) {
      debugPrint('🎮 Error parsing game message: $e');
    }
  }

  void _sendMessageToGame(String type, Map<String, dynamic> data) {
    final message = json.encode({
      'type': type,
      'data': data,
    });
    
    _webViewController?.evaluateJavascript(
      source: 'if (window.receiveFlutterMessage) window.receiveFlutterMessage(\'$message\');',
    );
  }

  Map<String, dynamic> _getPlayerData() {
    // Get player data from your existing services
    return {
      'playerId': 'player_123', // Replace with actual player ID
      'level': 1,
      'preferences': {},
    };
  }

  Map<String, dynamic> _getGameSettings() {
    return {
      'soundEnabled': true,
      'vibrationEnabled': true,
      'difficulty': 'normal',
    };
  }

  void _onGameReady() {
    setState(() {
      _isLoading = false;
    });
  }

  void _onGameCompleted(Map<String, dynamic> data) async {
    final score = (data['score'] ?? 0).toDouble();
    final timeSpent = _gameStartTime != null 
        ? DateTime.now().difference(_gameStartTime!).inSeconds 
        : 0;
    
    final result = await _gameService.completeGame(widget.gameId, score, timeSpent);
    
    if (mounted) {
      _showGameResultDialog(result);
    }
  }

  void _onGameError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  void _onScoreUpdate(double score) {
    // Handle real-time score updates if needed
    debugPrint('🎮 Score update: $score');
  }

  void _pauseGame() {
    _sendMessageToGame('pause', {});
    HapticFeedback.lightImpact();
  }

  void _resumeGame() {
    _sendMessageToGame('resume', {});
  }

  void _exitGame() {
    _showExitConfirmationDialog();
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showGameResultDialog(GameResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(result.success ? '🎉 Game Complete!' : '😞 Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result.message),
            if (result.reward != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎁 Reward Earned!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(result.reward!.description),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        NavigationService.navigateToHome();
        break;
      case 1:
        // Already on games section
        break;
      case 2:
        NavigationService.navigateToMenu();
        break;
      case 3:
        NavigationService.navigateToCart();
        break;
      case 4:
        NavigationService.navigateToMore();
        break;
    }
  }
}
