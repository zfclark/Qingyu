/// Flip Digit Widget
/// Author: ZF_Clark
/// Description: A flip animation digit widget for time display with smooth 200-300ms transitions and enhanced visual effects.
/// Last Modified: 2026/03/01
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlipDigit extends StatefulWidget {
  final int digit;
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;
  final Duration animationDuration;

  const FlipDigit({
    super.key,
    required this.digit,
    required this.fontSize,
    required this.textColor,
    required this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentDigit = 0;
  int _nextDigit = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.digit;
    _nextDigit = widget.digit;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _animation.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _currentDigit = _nextDigit;
        _isAnimating = false;
      });
      _controller.reset();
    }
  }

  @override
  void didUpdateWidget(FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit && !_isAnimating) {
      _startFlipAnimation(widget.digit);
    }
  }

  void _startFlipAnimation(int newDigit) {
    if (_currentDigit == newDigit) return;

    setState(() {
      _nextDigit = newDigit;
      _isAnimating = true;
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _animation.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.fontSize * 0.7,
      height: widget.fontSize * 1.15,
      child: Stack(
        children: [
          _buildStaticDigit(_currentDigit),
          if (_isAnimating) _buildFlipAnimation(),
        ],
      ),
    );
  }

  Widget _buildStaticDigit(int digit) {
    return Center(
      child: Text(
        digit.toString(),
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w500,
          color: widget.textColor,
          height: 1.0,
          letterSpacing: -2,
        ),
      ),
    );
  }

  Widget _buildFlipAnimation() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        return Stack(
          children: [
            _buildTopHalf(value),
            _buildBottomHalf(value),
            _buildMiddleLine(),
          ],
        );
      },
    );
  }

  Widget _buildTopHalf(double progress) {
    final angle = progress * math.pi / 2;

    return ClipRect(
      clipper: _HalfClipper(isTop: true),
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(-angle),
        child: Opacity(
          opacity: (1.0 - progress * 0.5).clamp(0.4, 1.0),
          child: Center(
            child: Text(
              _currentDigit.toString(),
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w500,
                color: widget.textColor,
                height: 1.0,
                letterSpacing: -2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomHalf(double progress) {
    final angle = (progress - 0.5).clamp(0.0, 1.0) * math.pi / 2;

    if (progress < 0.5) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      clipper: _HalfClipper(isTop: false),
      child: Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(math.pi / 2 - angle),
        child: Opacity(
          opacity: ((progress - 0.5) * 2).clamp(0.4, 1.0),
          child: Center(
            child: Text(
              _nextDigit.toString(),
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w500,
                color: widget.textColor,
                height: 1.0,
                letterSpacing: -2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleLine() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          height: 1,
          color: widget.textColor.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final bool isTop;

  _HalfClipper({required this.isTop});

  @override
  Rect getClip(Size size) {
    return isTop
        ? Rect.fromLTWH(0, 0, size.width, size.height / 2)
        : Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2);
  }

  @override
  bool shouldReclip(covariant _HalfClipper oldClipper) {
    return oldClipper.isTop != isTop;
  }
}

class FlipDigitGroup extends StatelessWidget {
  final int value;
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;
  final Duration animationDuration;

  const FlipDigitGroup({
    super.key,
    required this.value,
    required this.fontSize,
    required this.textColor,
    required this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    final tens = (value ~/ 10) % 10;
    final ones = value % 10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlipDigit(
          digit: tens,
          fontSize: fontSize,
          textColor: textColor,
          backgroundColor: backgroundColor,
          animationDuration: animationDuration,
        ),
        SizedBox(width: fontSize * 0.06),
        FlipDigit(
          digit: ones,
          fontSize: fontSize,
          textColor: textColor,
          backgroundColor: backgroundColor,
          animationDuration: animationDuration,
        ),
      ],
    );
  }
}

class TimeSeparator extends StatelessWidget {
  final double fontSize;
  final Color color;
  final bool visible;

  const TimeSeparator({
    super.key,
    required this.fontSize,
    required this.color,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: visible ? 1.0 : 0.25,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: fontSize * 0.12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(),
            SizedBox(height: fontSize * 0.35),
            _buildDot(),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: fontSize * 0.14,
      height: fontSize * 0.14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class FlipTimeBlock extends StatefulWidget {
  final String value;
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;
  final Duration animationDuration;

  const FlipTimeBlock({
    super.key,
    required this.value,
    required this.fontSize,
    required this.textColor,
    required this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<FlipTimeBlock> createState() => _FlipTimeBlockState();
}

class _FlipTimeBlockState extends State<FlipTimeBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _currentValue = '';
  String _nextValue = '';
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _nextValue = widget.value;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _animation.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _currentValue = _nextValue;
        _isAnimating = false;
      });
      _controller.reset();
    }
  }

  @override
  void didUpdateWidget(FlipTimeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isAnimating) {
      _startFlipAnimation(widget.value);
    }
  }

  void _startFlipAnimation(String newValue) {
    if (_currentValue == newValue) return;

    setState(() {
      _nextValue = newValue;
      _isAnimating = true;
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _animation.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.fontSize * 1.45,
        height: widget.fontSize * 1.15,
        child: Stack(
          children: [
            _buildStaticValue(_currentValue),
            if (_isAnimating) _buildFlipAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticValue(String value) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < value.length; i++)
            Padding(
              padding: EdgeInsets.only(
                right: i < value.length - 1 ? widget.fontSize * 0.06 : 0,
              ),
              child: Text(
                value[i],
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w500,
                  color: widget.textColor,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFlipAnimation() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final value = _animation.value;
          return Stack(
            children: [
              _buildTopHalf(value),
              _buildBottomHalf(value),
              _buildMiddleLine(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopHalf(double progress) {
    final angle = progress * math.pi / 2;

    return ClipRect(
      clipper: _HalfClipper(isTop: true),
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(-angle),
        child: Opacity(
          opacity: (1.0 - progress * 0.5).clamp(0.4, 1.0),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < _currentValue.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: i < _currentValue.length - 1
                          ? widget.fontSize * 0.06
                          : 0,
                    ),
                    child: Text(
                      _currentValue[i],
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w500,
                        color: widget.textColor,
                        height: 1.0,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomHalf(double progress) {
    final angle = (progress - 0.5).clamp(0.0, 1.0) * math.pi / 2;

    if (progress < 0.5) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      clipper: _HalfClipper(isTop: false),
      child: Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(math.pi / 2 - angle),
        child: Opacity(
          opacity: ((progress - 0.5) * 2).clamp(0.4, 1.0),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < _nextValue.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: i < _nextValue.length - 1
                          ? widget.fontSize * 0.06
                          : 0,
                    ),
                    child: Text(
                      _nextValue[i],
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w500,
                        color: widget.textColor,
                        height: 1.0,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleLine() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          height: 1,
          color: widget.textColor.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
