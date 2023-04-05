// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:ui';

import 'package:country_pickers/country.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/button.dart';
import 'package:instagram_clone/screens/text_field_input.dart';
import 'package:instagram_clone/utils/base_holder_screens.dart';
import 'package:instagram_clone/utils/color.dart';

class ConfirmOtpScreen extends StatefulWidget {
  static String routeName = '/confirmOtp';
  const ConfirmOtpScreen({super.key});

  @override
  State<ConfirmOtpScreen> createState() => _ConfirmOtpScreenState();
}

class _ConfirmOtpScreenState extends State<ConfirmOtpScreen> {
  final TextEditingController _loginCodeController = TextEditingController();
  String? _verificationID;
  String? _token;
  bool _btnActivated = false, _btnLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {});

    _loginCodeController.addListener(() {
      setState(() {
        if (_loginCodeController.text.length > 4) {
          _btnActivated = true;
        } else {
          _btnActivated = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object?> rcvdData =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;
    Country country = rcvdData['country_data'] as Country;
    _verificationID = rcvdData['verificationId'].toString();
    _token = rcvdData['resendToken'].toString();

    return BaseScreen(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Text(
                'ENTER CONFIRMATION CODE',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.grey[300]),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey[300],
                          ),
                          children: [
                            TextSpan(
                                text:
                                    'Enter the confirmation code we sent to +${country.phoneCode} ${rcvdData['phone_no']}.'),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => {print('resend code')},
                              text: ' Resend the code.',
                              style: TextStyle(
                                color: blueColor,
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              TextFieldInput(
                  textEditingController: _loginCodeController,
                  hintText: 'Login code',
                  textInputType: TextInputType.number),
              const SizedBox(
                height: 20,
              ),
              BaseButton(
                borderRadius: 8.0,
                text: 'Next',
                btnLoading: _btnLoading,
                onTapAction: () async {
                  setState(() {
                    _btnLoading = true;
                  });
                  await AuthMethods().verifyOTP(
                      otp: _loginCodeController.text,
                      veritificationID: _verificationID,
                      successCallback: (UserCredential value) {
                        setState(() {
                          _btnLoading = false;
                        });
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/namePassword',
                          (route) => false,
                          arguments: rcvdData,
                        );
                      });
                },
                btnColor: blueColor,
                btnActivated: _btnActivated,
              ),
              Expanded(
                flex: 20,
                child: SizedBox(),
              ),
            ],
          ),
        ))
      ],
    ));
  }
}
