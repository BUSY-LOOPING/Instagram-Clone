// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/button.dart';
import 'package:instagram_clone/screens/signup_screen.dart';
import 'package:instagram_clone/screens/text_field_input.dart';
import 'package:instagram_clone/utils/base_holder_screens.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/utils/validate.dart';


class LoginScreen extends StatefulWidget {
  static String routeName = '/loginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _isvalidPwd = true,
      _isvalidEmail = true,
      _btnActivated = false,
      _btnLoading = false;

  bool checkBtnActivated(bool _isvalidEmail, bool _isvalidPwd) {
    return validateEmailOrPhoneNumber(_emailController.text) &&
        validatePwd(_pwdController.text);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailController.addListener(() {
        setState(() {
          if (!_isvalidEmail && _emailController.text.isNotEmpty) {
            _isvalidEmail = validateEmailOrPhoneNumber(_emailController.text);
          } else {
            _isvalidEmail = true;
          }
          _btnActivated = checkBtnActivated(_isvalidEmail, _isvalidPwd);
        });
      });

      _pwdController.addListener(() {
        setState(() {
          if (!_isvalidPwd && _pwdController.text.isNotEmpty) {
            if (_pwdController.text.length < 6) {
              _isvalidPwd = false;
            } else {
              _isvalidPwd = true;
            }
          } else {
            _isvalidPwd = true;
          }
          _btnActivated = checkBtnActivated(_isvalidEmail, _isvalidPwd);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Container(),
                ),
                SvgPicture.asset(
                  'assets/svg/ic_instagram_logo.svg',
                  color: primaryColor,
                  height: min(50, double.infinity / 2),
                ),

                // Text(
                //   'Instagram',
                //   style: TextStyle(
                //     fontSize: 40,
                //     fontFamily: 'LogoFont',
                //     fontWeight: FontWeight.w100,
                //   ),
                // ),

                const SizedBox(
                  height: 32,
                ),
                //textfield input for email
                Focus(
                  onFocusChange: (_emailFocus) {
                    setState(() {
                      if (!_emailFocus && _emailController.text.isNotEmpty) {
                        _isvalidEmail =
                            validateEmailOrPhoneNumber(_emailController.text);
                      }
                    });
                  },
                  child: TextFieldInput(
                    isInvalidInput: !_isvalidEmail,
                    invalidInputString: 'Enter a valid email or phone number.',
                    textEditingController: _emailController,
                    hintText: 'Phone number, email',
                    textInputType: TextInputType.text,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                //textfield input for password
                Focus(
                  onFocusChange: (_pwdFocus) {
                    setState(() {
                      if (!_pwdFocus && _pwdController.text.isNotEmpty) {
                        if (_pwdController.text.length < 6) {
                          _isvalidPwd = false;
                        } else {
                          _isvalidPwd = true;
                        }
                      }
                    });
                  },
                  child: TextFieldInput(
                    isPass: true,
                    textEditingController: _pwdController,
                    hintText: 'Password',
                    textInputType: TextInputType.visiblePassword,
                    isInvalidInput: !_isvalidPwd,
                    invalidInputString:
                        'Passwords must be at least 6 characters.',
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                //button for login
                BaseButton(
                  text: 'Log in',
                  btnLoading: _btnLoading,
                  onTapAction: () async {
                    setState(() {
                      _btnLoading = true;
                    });
                    var email = _emailController.text.toString();
                    var pwd = _pwdController.text.toString();
                    if (validatePhNumber(email)) {
                      email += '@abc.com';
                    }
                    await AuthMethods()
                        .signInUser(email: email, password: pwd)
                        .then((value) => {
                              if (value == 'success')
                                {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/home', (route) => false)
                                }
                              else
                                {print(value)}
                            });
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Forgot your login details? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {},
                      child: Text(
                        'Get help loggin in.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                Flexible(
                  flex: 2,
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
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, SignUpScreen.routeName);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => SignUpScreen()));
                },
                child: Text(
                  "Sign up.",
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
    );
    return BaseScreen(child: column);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _pwdController.dispose();
  }
}
