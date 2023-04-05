import 'package:flutter/material.dart';

import '../utils/gradient_circular_progress_indicator.dart';

class BaseGradientIndicator extends StatefulWidget {
  final double radius;
  const BaseGradientIndicator({
    super.key,
    this.radius = 20,
  });

  @override
  State<BaseGradientIndicator> createState() => _BaseGradientIndicatorState();
}

class _BaseGradientIndicatorState extends State<BaseGradientIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _loadingAnimController;

  @override
  void initState() {
    super.initState();
    _loadingAnimController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    // _loadingAnimController.addListener(() => setState(() {}));
    _loadingAnimController.repeat();
  }

  @override
  void dispose() {
    _loadingAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_loadingAnimController),
      child: GradientCircularProgressIndicator(
        radius: widget.radius,
        gradientColors: [
          Colors.black,
          Colors.white,
        ],
        strokeWidth: 2.0,
      ),
    );
  }
}
