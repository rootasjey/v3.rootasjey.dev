import 'package:flutter/material.dart';

/// A widget that displays application icon.
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.size = 40.0,
    this.onLongPress,
  });

  /// The size of the icon.
  final double size;

  /// The margin of the icon.
  final EdgeInsetsGeometry margin;

  /// Called when the icon is tapped.
  final void Function()? onTap;

  /// Called when the icon is long pressed.
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    final String iconSize = getIconSize();

    return Padding(
      padding: margin,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Image.asset(
          "assets/images/app_icon/$iconSize.png",
          width: size,
          height: size,
        ),
      ),
    );
  }

  String getIconSize() {
    if (size <= 12) {
      return "16";
    }

    if (size <= 16) {
      return "32";
    }

    if (size <= 32) {
      return "64";
    }

    if (size <= 64) {
      return "128";
    }

    return "128";
  }
}
