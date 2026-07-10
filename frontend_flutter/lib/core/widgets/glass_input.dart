import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassInput extends StatelessWidget {
  final String placeholder;
  final Widget? icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const GlassInput({
    Key? key,
    required this.placeholder,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.glassBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.glassBorderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: context.textSecondary, size: 20),
              child: icon!,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: TextStyle(color: context.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: context.textSecondary, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (suffixIcon != null) ...[
            const SizedBox(width: 12),
            suffixIcon!,
          ],
        ],
      ),
    );
  }
}
