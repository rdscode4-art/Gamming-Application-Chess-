import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dart:ui';

class BgBlobs extends StatelessWidget {
  const BgBlobs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Left Purple Blob
        Positioned(
          top: -60,
          left: -80,
          child: _buildBlob(
            color: AppColors.purpleLight,
            size: 280,
            opacity: 0.2,
            blurRadius: 80,
          ),
        ),
        // Middle Right Gold Blob
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          right: -60,
          child: _buildBlob(
            color: AppColors.gold,
            size: 220,
            opacity: 0.15,
            blurRadius: 100,
          ),
        ),
        // Bottom Left Blue Blob
        Positioned(
          bottom: -80,
          left: MediaQuery.of(context).size.width * 0.2,
          child: _buildBlob(
            color: AppColors.blue,
            size: 300,
            opacity: 0.1,
            blurRadius: 120,
          ),
        ),
      ],
    );
  }

  Widget _buildBlob({
    required Color color,
    required double size,
    required double opacity,
    required double blurRadius,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha((opacity * 255).toInt()),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}
