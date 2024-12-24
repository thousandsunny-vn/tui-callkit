import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tencent_calls_uikit/src/gen/colors.gen.dart';

abstract class FuncButton extends StatelessWidget {
  const FuncButton({
    Key? key,
    required this.path,
    required this.padding,
    required this.buttonSize,
    required this.fit,
    required this.iconWidth,
    required this.iconHeight,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  final String path;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double buttonSize;
  final double iconWidth;
  final double iconHeight;
  final Color? backgroundColor;
  final Color? iconColor;
  final BoxFit fit;

  factory FuncButton.circle({
    required String path,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? iconColor,
    EdgeInsetsGeometry padding = const EdgeInsets.all(6),
    double buttonSize = 48,
    double iconWidth = 24,
    double iconHeight = 24,
    BoxFit fit = BoxFit.cover,
  }) {
    return _CircleButton(
      path: path,
      onPressed: onPressed,
      padding: padding,
      buttonSize: buttonSize,
      backgroundColor:
          backgroundColor ?? ColorName.color0xFFFFFFFF.withOpacity(0.20),
      iconColor: iconColor,
      fit: fit,
      iconHeight: iconHeight,
      iconWidth: iconWidth,
    );
  }

  factory FuncButton.circleTips({
    required String path,
    required String tips,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? iconColor,
    EdgeInsetsGeometry padding = const EdgeInsets.all(6),
    double buttonSize = 48,
    double iconWidth = 24,
    double iconHeight = 24,
    BoxFit fit = BoxFit.cover,
    TextStyle tipsTextStyle = const TextStyle(
      fontSize: 12,
      color: ColorName.color0xFFFFFFFF,
    ),
  }) {
    return _CircleTipsButton(
      path: path,
      padding: padding,
      buttonSize: buttonSize,
      tips: tips,
      tipsTextStyle: tipsTextStyle,
      fit: fit,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      onPressed: onPressed,
      iconHeight: iconHeight,
      iconWidth: iconWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildWidget(context);
  }

  Widget _buildWidget(BuildContext context);
}

class _CircleButton extends FuncButton {
  const _CircleButton({
    required double buttonSize,
    required double iconHeight,
    required double iconWidth,
    required String path,
    required EdgeInsetsGeometry padding,
    required BoxFit fit,
    Color? backgroundColor,
    Color? iconColor,
    VoidCallback? onPressed,
  }) : super(
          path: path,
          onPressed: onPressed,
          padding: padding,
          buttonSize: buttonSize,
          fit: fit,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          iconHeight: iconHeight,
          iconWidth: iconWidth,
        );

  @override
  Widget _buildWidget(BuildContext context) {
    return IconButton(
      onPressed: onPressed?.call,
      icon: SvgPicture.asset(
        path,
        package: 'tencent_calls_uikit',
        width: iconWidth,
        height: iconHeight,
        fit: fit,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
            : null,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(backgroundColor),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStatePropertyAll(padding),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        iconSize: WidgetStatePropertyAll(buttonSize),
      ),
    );
  }
}

class _CircleTipsButton extends FuncButton {
  const _CircleTipsButton({
    required String path,
    required this.tips,
    required this.tipsTextStyle,
    required double buttonSize,
    required EdgeInsetsGeometry padding,
    required BoxFit fit,
    required double iconHeight,
    required double iconWidth,
    Color? backgroundColor,
    Color? iconColor,
    VoidCallback? onPressed,
  }) : super(
          path: path,
          onPressed: onPressed,
          padding: padding,
          buttonSize: buttonSize,
          fit: fit,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          iconHeight: iconHeight,
          iconWidth: iconWidth,
        );

  final String tips;
  final TextStyle tipsTextStyle;

  @override
  Widget _buildWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          buttonSize: buttonSize,
          path: path,
          padding: padding,
          fit: fit,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          onPressed: onPressed,
          iconHeight: iconHeight,
          iconWidth: iconWidth,
        ),
        Container(
          width: 100,
          height: 15,
          margin: const EdgeInsets.only(top: 10),
          alignment: Alignment.center,
          child: Text(
            tips,
            textScaler: const TextScaler.linear(1.0),
            style: tipsTextStyle,
          ),
        ),
      ],
    );
  }
}
