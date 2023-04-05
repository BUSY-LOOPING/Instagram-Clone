import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/button.dart';
import 'package:instagram_clone/screens/text_field_input.dart';
import 'package:instagram_clone/screens/top_snackbar.dart';
import 'package:instagram_clone/utils/base_holder_screens.dart';
import 'package:instagram_clone/utils/color.dart';

class PickUserNameScreen extends StatefulWidget {
  const PickUserNameScreen({super.key});

  @override
  State<PickUserNameScreen> createState() => _PickUserNameScreenState();
}

class _PickUserNameScreenState extends State<PickUserNameScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _btnActivated = false, _showErrorWidget = false;
  String _alertMsg = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.addListener(() {
        setState(() {
          _btnActivated = _controller.text.isNotEmpty;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object?> map =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;

    return BaseScreen(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: TopSnackBar(
              toast: BaseSnackbarWidget(
                content: _alertMsg,
              ),
              showSnackBar: _showErrorWidget,
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Expanded(child: SizedBox()),
                Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Text(
                      'CHANGE USERNAME',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Pick username for your account. You can always change it later',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFieldInput(
                        textEditingController: _controller,
                        hintText: 'Username',
                        textInputType: TextInputType.text),
                    const SizedBox(
                      height: 15,
                    ),
                    BaseButton(
                      text: 'Next',
                      onTapAction: () async {
                        showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext buildContext) {
                              return Dialog(
                                backgroundColor:
                                    Color.fromARGB(254, 26, 26, 26),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    // ignore: prefer_const_literals_to_create_immutables
                                    children: [
                                      Transform.scale(
                                        scale: 0.8,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        'Registering...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });

                        map['username'] = _controller.text.toString();
                        if (map['profilePic'] == null) {
                          print('profilePic null');
                        }
                        await AuthMethods()
                            .signUpUser(
                                name: map['full_name'].toString(),
                                email: map['email'].toString(),
                                password: map['password'].toString(),
                                username: map['username'].toString(),
                                file: map['profilePic'],
                                phoneNo: map['phone_no'].toString())
                            .then((String value) => {
                                  if (value == 'success')
                                    {
                                      setState(() {
                                        _showErrorWidget = false;
                                      }),
                                      Navigator.pop(context),
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              '/home', (route) => false)
                                    }
                                  else if (value == 'username-not-available')
                                    {
                                      Navigator.pop(context),
                                      setState(() {
                                        _alertMsg =
                                            "This username isn't available. Please try another.";
                                        _showErrorWidget = true;
                                      })
                                    }
                                  else
                                    {print('Error is === $value'),
                                    Navigator.pop(context),
                                    setState(() {
                                      _alertMsg =
                                            "Something went wrong. Please try again.";
                                        _showErrorWidget = true;
                                    })}
                                });
                      },
                      btnColor: blueColor,
                      btnActivated: _btnActivated,
                    )
                  ],
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
