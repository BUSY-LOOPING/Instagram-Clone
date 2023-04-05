import 'package:flutter/material.dart';

import 'no_glow_scroll.dart';

class BaseScreen extends StatefulWidget {
  final Widget child;
  const BaseScreen({super.key, required this.child});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: RawScrollbar(
              radius: Radius.circular(20),
              thickness: 4,
              child: CustomScrollView(
                scrollBehavior: NoGlow(),
                physics: ClampingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
