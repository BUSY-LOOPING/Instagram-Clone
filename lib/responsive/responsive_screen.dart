import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/dimensions.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  const ResponsiveLayout({
    required this.mobileScreenLayout,
    required this.webScreenLayout,
    super.key,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // if (kIsWeb) {
        //   //web screen layout
        //   if (constraints.maxWidth < webScreenSizeSmall) {
        //     return webScreenLayoutSmall;
        //   } else {
        //     return webScreenLayoutLarge;
        //   }
        // } else {
        //   return mobileScreenLayout;
        // }

        if (constraints.maxWidth > webScreenSize) {
          //web screen layout
          return widget.webScreenLayout;
        } else {
          return widget.mobileScreenLayout;
        }
      },
    );
  }

  
}
