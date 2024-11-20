import 'package:flutter/material.dart';
import 'package:health_lens/applications/assets/i_assets.dart';
import 'package:health_lens/applications/components/button/i_button_component.dart';
import 'package:health_lens/applications/components/image/i_image_component.dart';
import 'package:health_lens/applications/theme/i_colors.dart';

class IDialog {
  static final instance = IDialog._internal();

  IDialog._internal();

  factory IDialog() {
    return instance;
  }

  Future info(
    BuildContext context, {
    required String title,
    required String description,
    String? image,
    List<Widget>? actions,
    bool barrierDismissible = false,
    VoidCallback? onTapOk,
    WarningInfoModel? warningInfo,
    Widget? additionalWidget,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          backgroundColor: Palette.neutral10,
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: IImage(
                    image: image ?? IAssets.imgBannerLogin,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: actions ??
              [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: IButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onTapOk != null) {
                          onTapOk();
                        }
                      },
                      name: 'OK',
                    ),
                  ),
                )
              ],
        );
      },
    );
  }
}

class WarningInfoModel {
  final String title;
  final String description;

  WarningInfoModel({required this.title, required this.description});
}
