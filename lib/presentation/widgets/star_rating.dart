import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool readonly;
  final ValueChanged<int>? onRatingChange;
  final bool showText;

  const StarRating({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20.0,
    this.readonly = false,
    this.onRatingChange,
    this.showText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final starValue = index + 1;
          final isFilled = starValue <= rating;
          final isHalfFilled = starValue - 0.5 <= rating && rating < starValue;

          return GestureDetector(
            onTap: readonly
                ? null
                : () {
                    onRatingChange?.call(starValue);
                  },
            child: Icon(
              isFilled
                  ? Icons.star
                  : isHalfFilled
                      ? Icons.star_half
                      : Icons.star_border,
              color: Colors.amber,
              size: size,
            ),
          );
        }),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

