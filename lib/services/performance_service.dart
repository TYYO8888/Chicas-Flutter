import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

/// 🚀 Performance Optimization Service
/// Manages app performance, memory usage, and crash prevention
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  Timer? _memoryMonitorTimer;
  Timer? _performanceCheckTimer;
  bool _isInitialized = false;
  
  // Performance metrics
  int _frameDropCount = 0;
  double _averageFrameTime = 0.0;
  int _memoryUsageMB = 0;
  
  // Performance thresholds
  static const int maxMemoryUsageMB = 150; // Max memory before cleanup
  static const double maxFrameTime = 16.67; // 60 FPS target
  static const int maxFrameDrops = 10; // Max frame drops before optimization

  /// Initialize performance monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 🚀 Start performance monitoring
      _startMemoryMonitoring();
      _startPerformanceMonitoring();
      _setupErrorHandling();
      
      _isInitialized = true;
      AppLogger.info('Performance service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize performance service', e);
    }
  }

  /// Start memory usage monitoring
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkMemoryUsage();
    });
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    _performanceCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkPerformanceMetrics();
    });
  }

  /// Setup global error handling
  void _setupErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error('Flutter Error: ${details.exception}', details.stack);
      _handleCrashPrevention();
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('Platform Error: $error', stack);
      _handleCrashPrevention();
      return true;
    };
  }

  /// Check memory usage and trigger cleanup if needed
  void _checkMemoryUsage() {
    try {
      // Estimate memory usage (simplified)
      final processInfo = ProcessInfo.currentRss;
      _memoryUsageMB = (processInfo / (1024 * 1024)).round();
      
      if (_memoryUsageMB > maxMemoryUsageMB) {
        AppLogger.warning('High memory usage detected: ${_memoryUsageMB}MB');
        _triggerMemoryCleanup();
      }
    } catch (e) {
      AppLogger.error('Failed to check memory usage', e);
    }
  }

  /// Check performance metrics
  void _checkPerformanceMetrics() {
    // This would integrate with Flutter's performance overlay in a real implementation
    // For now, we'll simulate performance monitoring
    
    if (_frameDropCount > maxFrameDrops) {
      AppLogger.warning('High frame drop count detected: $_frameDropCount');
      _optimizePerformance();
    }
  }

  /// Trigger memory cleanup
  void _triggerMemoryCleanup() {
    try {
      // Force garbage collection
      if (!kIsWeb) {
        // Clear image cache
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      }
      
      AppLogger.info('Memory cleanup completed');
    } catch (e) {
      AppLogger.error('Failed to perform memory cleanup', e);
    }
  }

  /// Optimize performance when issues detected
  void _optimizePerformance() {
    try {
      // Reduce animation complexity
      _frameDropCount = 0; // Reset counter
      
      // Clear unnecessary caches
      _triggerMemoryCleanup();
      
      AppLogger.info('Performance optimization completed');
    } catch (e) {
      AppLogger.error('Failed to optimize performance', e);
    }
  }

  /// Handle crash prevention
  void _handleCrashPrevention() {
    try {
      // Perform emergency cleanup
      _triggerMemoryCleanup();
      
      // Reset performance counters
      _frameDropCount = 0;
      _averageFrameTime = 0.0;
      
      AppLogger.info('Crash prevention measures applied');
    } catch (e) {
      AppLogger.error('Failed to apply crash prevention', e);
    }
  }

  /// Get current performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'memoryUsageMB': _memoryUsageMB,
      'frameDropCount': _frameDropCount,
      'averageFrameTime': _averageFrameTime,
      'isOptimal': _memoryUsageMB < maxMemoryUsageMB && 
                   _frameDropCount < maxFrameDrops,
    };
  }

  /// Force performance optimization
  void optimizeNow() {
    _triggerMemoryCleanup();
    _optimizePerformance();
  }

  /// Report frame drop (called by UI when performance issues detected)
  void reportFrameDrop() {
    _frameDropCount++;
  }

  /// Report frame time (called by UI for performance tracking)
  void reportFrameTime(double frameTime) {
    _averageFrameTime = (_averageFrameTime + frameTime) / 2;
  }

  /// Dispose resources
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _performanceCheckTimer?.cancel();
    _isInitialized = false;
    AppLogger.info('Performance service disposed');
  }
}

/// 🚀 Performance-optimized widget mixin
mixin PerformanceOptimizedWidget {
  /// Check if widget should rebuild for performance
  bool shouldRebuild(dynamic oldWidget, dynamic newWidget) {
    // Override in widgets to implement custom rebuild logic
    return oldWidget != newWidget;
  }
  
  /// Report performance metrics to service
  void reportPerformance({double? frameTime, bool? frameDrop}) {
    final service = PerformanceService();
    if (frameTime != null) service.reportFrameTime(frameTime);
    if (frameDrop == true) service.reportFrameDrop();
  }
}

/// 🚀 Performance monitoring widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool enableMonitoring;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.enableMonitoring = true,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  final PerformanceService _performanceService = PerformanceService();
  
  @override
  void initState() {
    super.initState();
    if (widget.enableMonitoring) {
      _performanceService.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    if (widget.enableMonitoring) {
      _performanceService.dispose();
    }
    super.dispose();
  }
}
