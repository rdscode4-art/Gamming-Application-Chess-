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
              color: imageUrl != null ? Colors.transparent : bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(50), width: 2),
              image: imageUrl != null
                  ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: imageUrl == null
                ? Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size * 0.35,
                      ),
                    ),
                  )
                : null,
          ),
          if (rating != null)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGrad,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.navyDeep, width: 1.5),
                ),
                child: Text(
                  rating.toString(),
                  style: const TextStyle(
                    color: AppColors.navyDeep,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
