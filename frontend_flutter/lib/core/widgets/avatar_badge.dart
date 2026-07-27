import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AvatarBadge extends StatelessWidget {
  final String name;
  final double size;
  final int? rating;
  final String? imageUrl;

  const AvatarBadge({
    Key? key,
    required this.name,
    this.size = 40,
    this.rating,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String initials = '';
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      initials = parts.take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join('');
    }

    final colors = [
      AppColors.purpleLight,
      AppColors.gold,
      AppColors.green,
      AppColors.blue,
      AppColors.red,
    ];
    final colorIndex = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    final bgColor = colors[colorIndex];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: imageUrl != null ? Colors.transparent : Colors.white,
              shape: BoxShape.circle,
              image: imageUrl != null
                  ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: imageUrl == null
                ? Center(
                    child: Text(
                      initials.isNotEmpty ? initials[0] : '', // Only first letter, like "W"
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: size * 0.5,
                      ),
                    ),
                  )
                : null,
          ),
          if (rating != null)
            Positioned(
              bottom: -8,
              left: -10,
              right: -10,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB74D), // Light orange/yellow from mockup
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rating.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
