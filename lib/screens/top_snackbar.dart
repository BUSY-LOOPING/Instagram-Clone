// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class TopSnackBar extends StatefulWidget {
  final Widget toast;
  bool showSnackBar;

  TopSnackBar({
    super.key,
    required this.toast,
    this.showSnackBar = false,
  });

  @override
  State<TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<TopSnackBar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetFloat;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetFloat = Tween(begin: Offset.zero, end: Offset(0.0, 1.0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    _offsetFloat.addListener(() {
      setState(() {
        
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_controller.status) {
      case AnimationStatus.completed:
        if (!widget.showSnackBar) {
          print('reverse');
          _controller.reverse();
        }
        break;
      case AnimationStatus.dismissed:
        if (widget.showSnackBar) {
          print('forward');
          _controller.forward();
        }
        break;
      default:
    }
    return SlideTransition(
      position: _offsetFloat,
      child: widget.toast,
    );
  }
}

Widget BaseSnackbarWidget({required String content, Color color = Colors.red}) {
  return Container(
    color: color,
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}
