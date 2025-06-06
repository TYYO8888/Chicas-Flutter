import 'package:flutter/material.dart';

/// GSAP-inspired custom curves
class GSAPCurves {
  // Mimics GSAP's power2.inOut
  static const Curve power2InOut = Cubic(0.645, 0.045, 0.355, 1.0);
  
  // Mimics GSAP's back.out
  static const Curve backOut = Cubic(0.175, 0.885, 0.32, 1.275);
  
  // Mimics GSAP's elastic.out
  static const Curve elasticOut = ElasticOutCurve(0.4);
}

/// Stagger delay calculator (similar to GSAP stagger)
double calculateStaggerDelay(int index, {double baseDelay = 0.1}) {
  return baseDelay * index;
}

/// Animation durations
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
}

/// Page transition that mimics GSAP's page transitions
class PageTransition extends PageRouteBuilder {
  final Widget page;
  
  PageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = GSAPCurves.power2InOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: AnimationDurations.normal,
        );
}
