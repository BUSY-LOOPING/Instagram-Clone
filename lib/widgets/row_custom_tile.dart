import 'package:flutter/material.dart';

import '../utils/color.dart';

class BaseTile extends StatefulWidget {
  final String title;
  final Widget? leadingIcon;
  final Widget? endIcon;

  const BaseTile(
      {super.key, required this.title, this.leadingIcon, this.endIcon});

  @override
  State<BaseTile> createState() => _BaseTileState();
}

class _BaseTileState extends State<BaseTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: highlightColor,
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          widget.leadingIcon ?? const SizedBox(),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Spacer(),
          widget.endIcon ?? const SizedBox(),
        ],
      ),
    );
  }
}
