import 'package:flutter/material.dart';

class StarRating extends StatelessWidget { // 星级评分组件
  final double rating; // 当前评分
  final int maxRating; // 最大评分
  final double size; // 星星大小
  final bool readonly; // 是否只读
  final ValueChanged<int>? onRatingChange; // 评分变化回调
  final bool showText; // 是否显示文本

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
        ...List.generate(maxRating, (index) { // 生成星星列表
          final starValue = index + 1; // 当前星星值
          final isFilled = starValue <= rating; // 是否填充
          final isHalfFilled = starValue - 0.5 <= rating && rating < starValue; // 是否半填充

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

