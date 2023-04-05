import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:instagram_clone/utils/color.dart';

class TextFieldInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final bool isPhoneNo;
  final bool isInvalidInput;
  final String invalidInputString;
  final String hintText;
  final TextInputType textInputType;
  final EdgeInsetsGeometry contentPadding;
  Country _countrySelected =
      countryList.firstWhere((Country c) => c.isoCode == 'IN');

  Country get countrySelected => _countrySelected;

  set countrySelected(Country countrySelected) {
    _countrySelected = countrySelected;
  }

  TextFieldInput(
      {required this.textEditingController,
      this.isPass = false,
      this.isPhoneNo = false,
      this.contentPadding = const EdgeInsets.all(15),
      required this.hintText,
      required this.textInputType,
      this.isInvalidInput = false,
      this.invalidInputString = 'Invalid',
      super.key});

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  late bool _pwdVisible;

  @override
  void initState() {
    super.initState();
    _pwdVisible = widget.isPass;
    widget.textEditingController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // OutlineInputBorder _inpBorder = OutlineInputBorder(
    //   borderRadius: BorderRadius.all(Radius.circular(5)),
    //   borderSide: Divider.createBorderSide(context),
    // );
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(209, 66, 66, 66),
            border: Border.all(
              width: 1,
              color: widget.isInvalidInput ? Colors.red : Colors.transparent,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            children: [
              widget.isPhoneNo
                  ? IntrinsicHeight(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      height: 100,
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          highlightColor:
                                              Colors.black.withOpacity(0.3),
                                          splashFactory: NoSplash.splashFactory,
                                          dialogBackgroundColor:
                                              textInputBgColor,
                                          colorScheme:
                                              ColorScheme.fromSwatch().copyWith(
                                            primary: Colors.transparent,
                                            secondary: Colors.transparent,
                                          ),
                                        ),
                                        child: CountryPickerDialog(
                                          itemBuilder:
                                              (Country countrySeleted) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Text(
                                                '${countrySeleted.name} (+${countrySeleted.phoneCode})',
                                              ),
                                            );
                                          },
                                          isDividerEnabled: true,
                                          popOnPick: true,
                                          contentPadding: EdgeInsets.all(0.0),
                                          titlePadding:
                                              EdgeInsets.only(bottom: 10),
                                          searchCursorColor: Colors.grey[300],
                                          searchInputDecoration:
                                              InputDecoration(
                                            icon: Icon(
                                              Icons.search,
                                              color: Colors.grey[300],
                                            ),
                                            hintText: 'Country name or code',
                                            border: InputBorder.none,
                                          ),
                                          isSearchable: true,
                                          title: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'SELECT YOUR COUNTRY',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          onValuePicked: (Country value) {
                                            setState(() {
                                              widget.countrySelected = value;
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 9.0),
                              child: Text(
                                '${widget.countrySelected.isoCode} +${widget.countrySelected.phoneCode}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black,
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              Expanded(
                child: TextField(
                  autofocus: true,
                  // cursorColor: Colors.grey,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),

                  controller: widget.textEditingController,
                  decoration: InputDecoration(
                    fillColor: Color.fromARGB(209, 66, 66, 66),
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    suffixIcon: !widget.isPass
                        ? (widget.textEditingController.text.isEmpty
                            ? null
                            : IconButton(
                                enableFeedback: false,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                color: Colors.grey,
                                onPressed: widget.textEditingController.clear,
                                icon: Icon(Icons.close),
                              ))
                        : (widget.textEditingController.text.isEmpty
                            ? null
                            : IconButton(
                                enableFeedback: false,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                color: Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _pwdVisible = !_pwdVisible;
                                  });
                                },
                                icon: Icon(Icons.remove_red_eye),
                              )),

                    // border: _inpBorder,
                    // focusedBorder: _inpBorder,
                    // enabledBorder: _inpBorder,
                    // filled: true,
                    contentPadding: widget.contentPadding,
                  ),
                  keyboardType: widget.textInputType,
                  obscureText: _pwdVisible,
                ),
              ),
            ],
          ),
        ),
        widget.isInvalidInput
            ? Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    widget.invalidInputString,
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }
}
