library com.auto_log_mi_nave_ota_labs.app.navigator;

import 'package:flutter/material.dart';

import '../core/enums/enums.dart';
import '../core/utils/utils.dart';
import 'widgets/widgets.dart';

class CustomNavigator {
  static const Logger _log = Logger('CustomNavigator');

  void push(
    BuildContext context,
    Widget view, {
    CustomNavigationAnimation animation = CustomNavigationAnimation.slideRight,
  }) {
    Navigator.of(
      context,
    ).push(AnimationRoute(page: view, animationType: animation));
  }

  void pop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      _log.error('pop: no hay más páginas para hacer pop.');
      if (context.mounted) {
        showErrorSnackBar(context, 'No hay mas páginas');
      }
    }
  }

  bool canPop(BuildContext context) => Navigator.canPop(context);
}

class AnimationRoute extends PageRouteBuilder<Widget> {
  AnimationRoute({
    required this.page,
    CustomNavigationAnimation animationType =
        CustomNavigationAnimation.slideRight,
  }) : super(
         transitionDuration: const Duration(milliseconds: 500),
         pageBuilder:
             (
               BuildContext context,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
             ) => page,
         transitionsBuilder:
             (
               BuildContext context,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
               Widget child,
             ) => switch (animationType) {
               CustomNavigationAnimation.fade => FadeTransition(
                 opacity: Tween<double>(begin: 0, end: 1).animate(animation),
                 child: child,
               ),
               CustomNavigationAnimation.slideRight => SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(1, 0),
                   end: Offset.zero,
                 ).animate(animation),
                 child: child,
               ),
               CustomNavigationAnimation.scale => ScaleTransition(
                 scale: Tween<double>(begin: 0.5, end: 1).animate(animation),
                 child: child,
               ),
               CustomNavigationAnimation.scaleFade => ScaleTransition(
                 scale: Tween<double>(begin: 0.5, end: 1).animate(animation),
                 child: FadeTransition(
                   opacity: Tween<double>(begin: 0, end: 1).animate(animation),
                   child: child,
                 ),
               ),
               CustomNavigationAnimation.slideBottom => SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(0, 1),
                   end: Offset.zero,
                 ).animate(animation),
                 child: child,
               ),
             },
       );
  final Widget page;
}
