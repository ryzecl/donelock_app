import 'dart:math' as math;
import 'package:flutter/material.dart';

class BrutalistLoading extends StatefulWidget {
  final double size;
  final Color color;

  const BrutalistLoading({
    super.key,
    this.size = 40.0,
    this.color = Colors.black,
  });

  @override
  State<BrutalistLoading> createState() => _BrutalistLoadingState();
}

class _BrutalistLoadingState extends State<BrutalistLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBlack = widget.color == Colors.black;
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Brutalist discrete rotation step (every 90 degrees or smooth?)
          // Let's do a smooth rotation but with a very thick bordered box
          return Transform.rotate(
            angle: _controller.value * 2.0 * math.pi,
            child: child,
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            border: Border.all(
              color: isBlack ? Colors.transparent : Colors.black, 
              width: 3,
            ),
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.3,
              height: widget.size * 0.3,
              color: isBlack ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
