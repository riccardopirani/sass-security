import 'package:flutter/material.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    this.height = 18,
    this.width = double.infinity,
    super.key,
  });

  final double height;
  final double width;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.lerp(
              const Color(0xFF1F2937),
              const Color(0xFF374151),
              _controller.value,
            ),
          ),
        );
      },
    );
  }
}
