import 'package:flutter/material.dart';
import 'package:mydaymate/core/theme/app_colors.dart';

class AnimatedGradient extends StatefulWidget {
  final Alignment begin;
  final Alignment end;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;
  final Widget child;
  final double minHeight;

  const AnimatedGradient({
    super.key,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius,
    this.boxShadow,
    required this.child,
    required this.minHeight,
  });

  @override
  _AnimatedGradientState createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<AnimatedGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  late Animation<Color?> _color3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5), // Duration of one cycle
      vsync: this,
    )..repeat(reverse: true); // Loop and reverse for smooth animation

    // Define color transitions
    _color1 = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: AppColors.secondaryVariant, // Rich Amber
          end: AppColors.primary, // White
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: AppColors.primary,
          end: AppColors.primaryVariant, // Warm Amber
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: AppColors.primaryVariant,
          end: AppColors.secondaryVariant,
        ),
        weight: 1.0,
      ),
    ]).animate(_controller);

    _color2 = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: AppColors.primaryVariant,
          end: AppColors.secondaryVariant,
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: AppColors.surface,
          end: AppColors.primary,
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: AppColors.primary,
          end: AppColors.primaryVariant,
        ),
        weight: 1.0,
      ),
    ]).animate(_controller);

    _color3 = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: AppColors.primary,
          end: AppColors.primaryVariant,
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: AppColors.primaryVariant,
          end: AppColors.secondaryVariant,
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: AppColors.secondaryVariant,
          end: AppColors.primary,
        ),
        weight: 1.0,
      ),
    ]).animate(_controller);
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
      builder: (context, child) {
        return Container(
          constraints: BoxConstraints(
            minHeight: widget.minHeight,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _color1.value ?? AppColors.secondaryVariant,
                _color2.value ?? AppColors.primaryVariant,
                _color3.value ?? AppColors.primary,
              ],
              begin: widget.begin,
              end: widget.end,
            ),
            borderRadius: widget.borderRadius,
            boxShadow: widget.boxShadow != null ? [widget.boxShadow!] : null,
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
