import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class BaseButton extends StatefulWidget {
  final String text;
  final EdgeInsetsGeometry padding;
  final Function onTapAction;
  final Color btnColor;
  final double borderRadius;
  final bool btnActivated, btnLoading;

  const BaseButton(
      {super.key,
      required this.text,
      this.padding = const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      required this.onTapAction,
      required this.btnColor,
      this.btnActivated = true,
      this.borderRadius = 5.0,
      this.btnLoading = false});

  @override
  State<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.btnActivated ? 1.0 : 0.4,
      child: InkWell(
        enableFeedback: widget.btnActivated,
        // focusColor: Colors.red,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          if (widget.btnActivated && !widget.btnLoading) {
            widget.onTapAction();
          }
        },
        child: Container(
          alignment: Alignment.center,
          padding: widget.padding,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius),
            )),
            color: widget.btnColor,
          ),
          child: Visibility(
            visible: !widget.btnLoading,
            replacement: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.transparent,
                strokeWidth: 2,
              ),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
