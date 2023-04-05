import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/responsive/responsive_screen.dart';
import 'package:instagram_clone/screens/default_user_profile.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/notifications_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;
import '../widgets/base_gradient_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Widget _feedScreen, _profileScreen, _notifScreen, _searchScreen;
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    addData();
    _feedScreen = FeedScreen();
    _notifScreen = NotificationsScreen();
    _searchScreen = SearchScreen();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    model.User? user = Provider.of<UserProvider>(context).getUser;
    _profileScreen = ProfileScreen(uid: user?.uid);
    var bottomNavBar = Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: CupertinoTabBar(
        // selectedLabelStyle: TextStyle(
        //   color: Colors.red,
        //   fontWeight: FontWeight.w900,
        //   fontSize: 18
        // ),
        // showUnselectedLabels: true,
        // showSelectedLabels: true,
        // unselectedLabelStyle: TextStyle(
        //   color: Colors.red,
        //   fontWeight: FontWeight.w900,
        //   fontSize: 18
        // ),
        // type: BottomNavigationBarType.fixed,
        onTap: navigationTapped,
        backgroundColor: mobileBgColor,
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _page == 0 ? Icons.home : Icons.home_outlined,
              color: Colors.white,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Text(
              String.fromCharCode(CupertinoIcons.search.codePoint),
              style: TextStyle(
                  fontFamily: CupertinoIcons.search.fontFamily,
                  package: CupertinoIcons.search.fontPackage,
                  fontWeight: _page == 1 ? FontWeight.w900 : FontWeight.w300,
                  color: Colors.white,
                  fontSize: 24),
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _page == 2
                  ? 'assets/svg/reel_icon_filled.svg'
                  : 'assets/svg/reel_icon.svg',
              height: 24.0,
              width: 24.0,
              color: Colors.white,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              _page == 3 ? Icons.favorite : Icons.favorite_outline,
              color: Colors.white,
            ),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: DefaultUserProfileView(
              radius: 7,
              borderWidth: _page == 4 ? 1 : 0.1,
              borderColor: primaryColor,
              imagePath: user?.photoUrl,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
        ],
      ),
    );

    var mobileScreen = SafeArea(
      child: Scaffold(
        body: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _feedScreen,
            _searchScreen,
            Center(
              child: Text(
                'Not Available Yet :)',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            _notifScreen,
            _profileScreen,
          ],
        ),
        bottomNavigationBar: bottomNavBar,
      ),
    );

    // var webScreen = Text('webScreen ${user?.name ?? 'null'}');
    var respLayout = ResponsiveLayout(
        mobileScreenLayout: mobileScreen, webScreenLayout: mobileScreen);

    var consumerBuilder = Consumer<UserProvider>(
      builder: ((context, value, child) {
        if (value.getUser == null) {
          return Center(
            child: BaseGradientIndicator(),
          );
        } else {
          return respLayout;
        }
      }),
    );
    return consumerBuilder;
  }

  void addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }
}
