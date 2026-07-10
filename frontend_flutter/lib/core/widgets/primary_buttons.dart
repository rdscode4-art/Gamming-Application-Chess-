import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSmall;
  final double? width;

  const GoldButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSmall = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BaseGradientButton(
      text: text,
      onTap: onTap,
      gradient: AppColors.goldGrad,
      textColor: AppColors.navyDeep,
      isSmall: isSmall,
      width: width,
    );
  }
}

class PurpleButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSmall;
  final double? width;

  const PurpleButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSmall = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BaseGradientButton(
      text: text,
      onTap: onTap,
      gradient: AppColors.purpleGrad,
      textColor: Colors.white,
      isSmall: isSmall,
      width: width,
    );
  }
}

class _BaseGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final Color textColor;
  final bool isSmall;
  final double? width;

  const _BaseGradientButton({
    required this.text,
    required this.onTap,
    required this.gradient,
    required this.textColor,
    required this.isSmall,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: isSmall
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 6)
                : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 14 : 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
