import 'package:flutter/material.dart';
import 'package:health_lens/applications/theme/i_colors.dart';

class IButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final Widget? prefixIcon, suffixIcon;
  final double? height, width, widthSuffix, widthPrefix;
  final EdgeInsetsGeometry? contentPadding;
  final bool isSecondaryColor, isOutlined, heightWrapContent, disabled;
  final Color? backgroundColor, textColor;
  final MainAxisAlignment? mainAxisAlignmentContent;
  final _widthBtn = 255.0;
  final _heightBtn = 70.0;
  final FontWeight? textWeight;
  final double? textSize, sizeBorderRadius;
  final int? maxLines;

  const IButton(
      {super.key,
      required this.name,
      required this.onPressed,
      this.prefixIcon,
      this.suffixIcon,
      this.widthPrefix,
      this.widthSuffix,
      this.height,
      this.width,
      this.contentPadding,
      this.backgroundColor,
      this.textColor,
      this.textWeight = FontWeight.bold,
      this.textSize,
      this.mainAxisAlignmentContent,
      this.disabled = false,
      this.heightWrapContent = false,
      this.isSecondaryColor = false,
      this.isOutlined = false,
      this.maxLines = 2,
      this.sizeBorderRadius})
      : assert(
          suffixIcon == null || prefixIcon == null,
          "Cannot provide both a suffixIcon and a prefixIcon, select one",
        );

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final widthSuffix = this.widthSuffix ??
        (heightWrapContent ? width! / 4.7 : _widthBtn / 4.7);
    final widthPrefix =
        this.widthPrefix ?? (heightWrapContent ? width! / 7 : _widthBtn / 7);

    return SizedBox(
      width: width ?? _widthBtn,
      height: heightWrapContent ? null : height ?? _heightBtn,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: isOutlined ? Colors.white : color.surface,
          padding: contentPadding,
          backgroundColor: backgroundColor ??
              (isSecondaryColor ? Palette.blueDarkColor : Palette.primaryColor),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizeBorderRadius ?? 14),
            side: isOutlined
                ? BorderSide(
                    color: disabled
                        ? color.surface
                        : isSecondaryColor
                            ? color.secondary
                            : color.primary.withOpacity(0.5),
                  )
                : BorderSide.none,
          ),
        ),
        onPressed: disabled ? null : onPressed,
        child: Row(
          mainAxisAlignment: mainAxisAlignmentContent ??
              (prefixIcon != null
                  ? MainAxisAlignment.start
                  : suffixIcon != null
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.center),
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              SizedBox(width: widthPrefix),
            ] else
              Container(),
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: textWeight,
                  color: textColor ??
                      (disabled
                          ? Colors.white
                          : isSecondaryColor
                              ? color.secondary
                              : Colors.white),
                ),
              ),
            ),
            if (suffixIcon != null) ...[
              SizedBox(width: widthSuffix),
              suffixIcon!
            ] else
              Container()
          ],
        ),
      ),
    );
  }
}
