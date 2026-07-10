import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class BackHeader extends StatelessWidget {
  final String title;
  final Widget? rightWidget;
  final VoidCallback? onBack;

  const BackHeader({
    Key? key,
    required this.title,
    this.rightWidget,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onBack ?? () => context.pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.glassBg : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.glassBorder : Colors.black.withValues(alpha: 0.1)),
              ),
              child: Icon(Icons.arrow_back_ios_new, color: context.textPrimary, size: 20),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              letterSpacing: 1,
            ),
          ),
          rightWidget ?? const SizedBox(width: 38), // placeholder to balance center title
        ],
      ),
    );
  }
}
