// ignore_for_file: prefer_const_literals_to_create_immutables, unused_local_variable


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/button.dart';
import 'package:instagram_clone/screens/confirm_otp_screen.dart';
import 'package:instagram_clone/screens/text_field_input.dart';
import 'package:instagram_clone/utils/base_holder_screens.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/utils/validate.dart';

class SignUpScreen extends StatefulWidget {
  static String routeName = '/signUpScreen1';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  int _selectedIdx = 0;
  late TabController _tabController;
  bool _btnActivated = false, _btnLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.addListener(() {
        setState(() {
          _selectedIdx = _tabController.index;
          _btnActivated = isBtnActivated(_selectedIdx);
        });
      });
      _phoneController.addListener(() {
        setState(() {
          _btnActivated = isBtnActivated(_selectedIdx);
        });
      });

      _emailController.addListener(() {
        setState(() {
          _btnActivated = isBtnActivated(_selectedIdx);
        });
      });
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  bool isBtnActivated(int tabIdx) {
    if (tabIdx == 0) {
      return validatePhNumber(_phoneController.text.toString());
    } else {
      return validateEmail(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextFieldInput phoneNoInput = TextFieldInput(
      invalidInputString: 'Enter a valid phone number.',
      isPhoneNo: true,
      textEditingController: _phoneController,
      hintText: 'Phone',
      textInputType: TextInputType.phone,
    );
    return BaseScreen(
        child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),

                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: Colors.white,
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/person_outline.svg',
                      width: 60,
                      // height: 60,
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  DecoratedBox(
                    decoration: BoxDecoration(
                      //This is for background color
                      // color: Colors.green.withOpacity(0.0),
                      //This is for bottom border that is needed
                      border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 0.8)),
                    ),
                    // width: double.maxFinite,
                    // color: Colors.transparent,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                      ),
                      child: TabBar(
                        controller: _tabController,
                        splashFactory: NoSplash.splashFactory,
                        isScrollable: false,
                        enableFeedback: false,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.white,
                        tabs: [
                          Tab(
                            text: 'PHONE',
                          ),
                          Tab(
                            text: 'EMAIL',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Builder(builder: (BuildContext buildContext) {
                    if (_selectedIdx == 0) {
                      return Column(
                        children: [
                          phoneNoInput,
                          //TODO

                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            'You may recieve SMS notifications from us for security and login purposes.',
                            style: TextStyle(
                              // fontWeight: FontWeight.300,
                              fontSize: 13,
                              color: Colors.grey[300],
                            ),
                          )
                        ],
                      ); //1st custom tabBarView
                    } else {
                      return TextFieldInput(
                        invalidInputString: 'Enter a valid Email.',
                        textEditingController: _emailController,
                        hintText: 'Email',
                        textInputType: TextInputType.emailAddress,
                      );
                    } //2nd tabView
                  }),

                  const SizedBox(
                    height: 16,
                  ),

                  //button for login
                  BaseButton(
                    btnLoading: _btnLoading,
                    text: 'Next',
                    onTapAction: () async {
                      setState(() {
                        _btnLoading = true;
                      });
                      if (_tabController.index == 0) {
                        Future<
                            Map<String,
                                Object>> m = AuthMethods().authenticatePhNo(
                            phoneCode_phoneNo:
                                '+${phoneNoInput.countrySelected.phoneCode}${_phoneController.text}',
                            otpEntered: () {});
                        await m.then((Map<String, Object> value) => {
                              print(
                                  'id ===========>   ${value['verificationId']}'),
                              Navigator.pushNamed(context, ConfirmOtpScreen.routeName,
                                  arguments: {
                                    'phone_no': _phoneController.text,
                                    'country_data':
                                        phoneNoInput.countrySelected,
                                    'verificationId': value[
                                        'verificationId'], //verificationId can be null
                                    'resendToken': value['resendToken']
                                  })
                            });
                      } else {
                        Map<String, Object?> map = {};
                        map['email'] = _emailController.text.toString();
                        Navigator.pushNamed(context, '/namePassword',
                            arguments: map);
                      }
                      setState(() {
                        _btnLoading = false;
                      });
                    },
                    btnColor: blueColor,
                    btnActivated: _btnActivated,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey[900],
            width: double.infinity,
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    // Navigator.pushReplacementNamed(context, 'loginScreen');
                  },
                  child: Text(
                    "Log in.",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose');
    _emailController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
  }
}
