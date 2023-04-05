// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class StickySliverHeader extends StatefulWidget {
  final Widget child;
  const StickySliverHeader({super.key, required this.child});

  @override
  State<StickySliverHeader> createState() => _StickySliverHeaderState();
}

class _StickySliverHeaderState extends State<StickySliverHeader> {
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: StickyHeaderDelegate(child: widget.child),
    );
  }
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  StickyHeaderDelegate({
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  // @override
  // OverScrollHeaderStretchConfiguration get stretchConfiguration =>
  //     OverScrollHeaderStretchConfiguration(
  //       stretchTriggerOffset: maxExtent,
  //     );

  // double get maxShrinkOffset => maxExtent - minExtent;
}
