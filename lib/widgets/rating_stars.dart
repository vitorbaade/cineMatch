import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final ValueChanged<double>? onChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating.round();
        final icon = Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.accent,
          size: size,
        );
        if (onChanged == null) return icon;
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onChanged!((index + 1).toDouble()),
          child: Padding(padding: const EdgeInsets.all(2), child: icon),
        );
      }),
    );
  }
}
