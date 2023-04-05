import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:instagram_clone/screens/button.dart';
import 'package:instagram_clone/screens/text_field_input.dart';
import 'package:instagram_clone/utils/base_holder_screens.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/utils/validate.dart';

class NamePasswordScreen extends StatefulWidget {
  const NamePasswordScreen({super.key});

  @override
  State<NamePasswordScreen> createState() => _NamePasswordScreenState();
}

class _NamePasswordScreenState extends State<NamePasswordScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _validPwd = true, _rememberPwd = true, _btnActivated = false;

  void checkValidInp() {
    setState(() {
      if (_nameController.text.isNotEmpty && validatePwd(_pwdController.text)) {
        _btnActivated = true;
      } else {
        _btnActivated = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.addListener(() {
        checkValidInp();
      });
      _pwdController.addListener(() {
        if (!_validPwd) {
          setState(() {
            if (_pwdController.text.length < 6) {
              _validPwd = false;
            } else {
              _validPwd = true;
            }
          });
        }
        checkValidInp();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object?> map =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;

    return BaseScreen(
      child: Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(
                  'NAME AND PASSWORD',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFieldInput(
                    textEditingController: _nameController,
                    hintText: 'Full Name',
                    textInputType: TextInputType.name),
                const SizedBox(
                  height: 20,
                ),
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      if (!hasFocus) {
                        if (_pwdController.text.length < 6) {
                          _validPwd = false;
                        } else {
                          _validPwd = true;
                        }
                      }
                    });
                  },
                  child: TextFieldInput(
                    isPass: true,
                    textEditingController: _pwdController,
                    hintText: 'Password',
                    textInputType: TextInputType.visiblePassword,
                    isInvalidInput: !_validPwd,
                    invalidInputString:
                        'Passwords must be at least 6 characters.',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.05,
                      child: Theme(
                        data: ThemeData(
                          primarySwatch: Colors.blue,
                          unselectedWidgetColor: Colors.grey, // Your color
                        ),
                        child: Checkbox(
                          checkColor: Colors.black,
                          activeColor: blueColor,
                          value: _rememberPwd,
                          onChanged: ((bool? value) {
                            setState(() {
                              _rememberPwd = !_rememberPwd;
                            });
                          }),
                        ),
                      ),
                    ),
                    Text(
                      'Remember password',
                      style: TextStyle(
                          color: Color.fromARGB(255, 159, 159, 159),
                          fontSize: 15),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                BaseButton(
                  text: 'Continue',
                  onTapAction: () {
                    if (map['email'] == null || map['email'].toString() == '') {
                      print('email was null');
                      map['email'] = '${map['phone_no']}@abc.com';
                    }
                    map['full_name'] = _nameController.text.toString();
                    map['password'] = _pwdController.text.toString();
                    map['remember_password'] = _rememberPwd.toString();

                    Navigator.pushNamed(
                      context,
                      '/pickProfilePic',
                      arguments: map,
                    );
                  },
                  btnColor: blueColor,
                  btnActivated: _btnActivated,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _pwdController.dispose();
  }
}
