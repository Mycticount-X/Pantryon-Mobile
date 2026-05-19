import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Timing — routes feel deliberate; tabs feel instant.
// ---------------------------------------------------------------------------

/// Full-screen pushes (Login, Register, Main, Scanner, Profile logout).
const Duration kAppPageRouteDuration = Duration(milliseconds: 320);

/// Bottom-nav tab changes — shorter for a snappy, native tab-bar feel.
const Duration kAppTabTransitionDuration = Duration(milliseconds: 200);

// ---------------------------------------------------------------------------
// Motion — fade-first, micro-translate (Notion / Linear / iOS-adjacent).
// ---------------------------------------------------------------------------

/// Soft deceleration on enter; gentle on exit.
const Curve _kRouteEnterCurve = Cubic(0.22, 1, 0.36, 1);
const Curve _kRouteExitCurve = Cubic(0.4, 0, 0.68, 0.06);

/// Even lighter curves for tab switches.
const Curve _kTabEnterCurve = Cubic(0.33, 1, 0.68, 1);
const Curve _kTabExitCurve = Cubic(0.32, 0, 0.67, 0);

/// ~1% vertical rise — reads as content settling in, not a full slide.
const Offset _kRouteSlideBegin = Offset(0, 0.01);

/// Half the route offset; tabs should feel almost like a cross-fade.
const Offset _kTabSlideBegin = Offset(0, 0.005);

// ---------------------------------------------------------------------------
// Core transition builders
// ---------------------------------------------------------------------------

bool _prefersReducedMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;

Widget _fadeMicroSlide({
  required Animation<double> animation,
  required Widget child,
  required Offset slideBegin,
  required Curve enterCurve,
  required Curve exitCurve,
}) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: enterCurve,
    reverseCurve: exitCurve,
  );

  // Opacity leads slightly so motion feels fade-first, not slide-first.
  final opacity = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.9, curve: Curves.easeOut),
      reverseCurve: const Interval(0.1, 1, curve: Curves.easeIn),
    ),
  );

  final offset = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(
    curved,
  );

  return FadeTransition(
    opacity: opacity,
    child: SlideTransition(
      position: offset,
      child: child,
    ),
  );
}

/// Route / modal stack transitions (via theme or [AppPageRoute]).
Widget buildAppRouteTransition(
  BuildContext context, {
  required Animation<double> animation,
  required Widget child,
}) {
  if (_prefersReducedMotion(context)) return child;

  return _fadeMicroSlide(
    animation: animation,
    child: child,
    slideBegin: _kRouteSlideBegin,
    enterCurve: _kRouteEnterCurve,
    exitCurve: _kRouteExitCurve,
  );
}

/// Bottom-nav tab transitions — faster and lighter than routes.
Widget buildAppTabTransition(
  BuildContext context, {
  required Animation<double> animation,
  required Widget child,
}) {
  if (_prefersReducedMotion(context)) return child;

  return _fadeMicroSlide(
    animation: animation,
    child: child,
    slideBegin: _kTabSlideBegin,
    enterCurve: _kTabEnterCurve,
    exitCurve: _kTabExitCurve,
  );
}

// ---------------------------------------------------------------------------
// Global route theme
// ---------------------------------------------------------------------------

class FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return buildAppRouteTransition(
      context,
      animation: animation,
      child: child,
    );
  }
}

const PageTransitionsTheme kAppPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeSlidePageTransitionsBuilder(),
    TargetPlatform.iOS: FadeSlidePageTransitionsBuilder(),
    TargetPlatform.macOS: FadeSlidePageTransitionsBuilder(),
    TargetPlatform.windows: FadeSlidePageTransitionsBuilder(),
    TargetPlatform.linux: FadeSlidePageTransitionsBuilder(),
    TargetPlatform.fuchsia: FadeSlidePageTransitionsBuilder(),
  },
);

// ---------------------------------------------------------------------------
// Route wrapper — consistent 320ms on every platform (iOS default is 350ms).
// ---------------------------------------------------------------------------

class AppPageRoute<T> extends MaterialPageRoute<T> {
  AppPageRoute({
    required super.builder,
    super.settings,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => kAppPageRouteDuration;

  @override
  Duration get reverseTransitionDuration => kAppPageRouteDuration;
}
