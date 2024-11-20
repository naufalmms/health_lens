import 'dart:io';
import 'package:flutter/material.dart';

class IImage extends StatelessWidget {
  final dynamic image;
  final double? height, width;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Color? loadingColor, color;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const IImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.loadingWidget,
    this.color,
    this.loadingColor,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final errWidget = errorWidget ??
        const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        );
    if (image is String) {
      var image = this.image as String;
      if (image.isNotEmpty) {
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.asset(
            image,
            height: height,
            width: width,
            fit: fit,
            color: color,
          ),
        );
      }
    }
    if (image is File) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.file(
          image,
          height: height,
          width: width,
          fit: fit,
          color: color,
        ),
      );
    }
    return errWidget;
  }
}
