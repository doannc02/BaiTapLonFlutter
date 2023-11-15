import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final int itemCount;
  final double itemHeight;
  final double itemWidth;
  final EdgeInsets itemMargin;

  SkeletonLoading({
    required this.itemCount,
    required this.itemHeight,
    required this.itemWidth,
    this.itemMargin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  });

  @override
  _SkeletonLoadingState createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(top:9),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              const begin = 0.5;
              const end = 0.8;
              final animation = CurvedAnimation(
                parent: _animationController,
                curve: Interval(0, 1, curve: Curves.fastOutSlowIn),
              );

              final width = widget.itemWidth * (begin + animation.value * (end - begin));

              return Padding(
                padding: widget.itemMargin,
                child: Container(
                  height: widget.itemHeight,
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15.0), // Điều chỉnh độ cong của góc
                  ),
                ),
              );

            },
          )
        );
      },
    );
  }
}