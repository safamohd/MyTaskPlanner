import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/landing_screen.dart';
import 'package:my_task_planner/screens/login_screen.dart';
import 'package:my_task_planner/services/auth_service.dart';
import 'package:my_task_planner/utils/dialog_util.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/button_standard.dart';
import 'package:my_task_planner/widgets/input_standard.dart';
import 'package:my_task_planner/widgets/lang_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  var _name = "";
  var _email = "";
  var _password = "";
  var _rPassword = "";
  var _gender = "";
  var _loading = false;

  set loading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  void _handlSignUp() async {
    if (!_formKey.currentState.validate()) {
      // form will handle showing error
      return;
    }
    if (_password != _rPassword) {
      DialogUtil.showToast(TransUtil.trans("error_passwords_not_equals"));
      return;
    }
    if (_gender.isEmpty) {
      DialogUtil.showToast(TransUtil.trans("error_selecet_gender"));
      return;
    }
    loading = true;

    final user = await _authService.signUpWithEmailAndPassword(_name, _email, _gender, _password).catchError((error) {
      DialogUtil.showToast(error.toString());
      return null;
    });
    if (mounted)
      loading = false;
    else
      return;
    if (user == null) {
      // something wnet wrong couldn't validate user
      DialogUtil.showToast(TransUtil.trans("error_sign_up_failed"));
      return;
    }
    if (Navigator.of(context).canPop())
      Navigator.of(context).pop();
    else
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (builder) => LandingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(marginLarge),
          child: Column(
            children: [
              Image.asset(
                IMG_LOGO_FILLED,
                width: size.width * 0.4,
                fit: BoxFit.contain,
              ),
              SizedBox(
                height: marginLarge,
              ),
              Text(
                TransUtil.trans("app_name"),
                style: TextStyle(
                  color: colorPrimaryDark,
                  fontFamily: "Segoepr",
                  fontSize: fontSizeMedium,
                ),
              ),
              SizedBox(
                height: marginLarge,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    StandardInput(
                      hintText: TransUtil.trans("hint_name"),
                      isRequiredInput: true,
                      onChanged: (val) => _name = val,
                    ),
                    StandardInput(
                      hintText: TransUtil.trans("hint_email"),
                      isRequiredInput: true,
                      onChanged: (val) => _email = val,
                    ),
                    StandardInput(
                      hintText: TransUtil.trans("hint_password"),
                      isRequiredInput: true,
                      isObscureText: true,
                      minLength: 8,
                      onChanged: (val) => _password = val,
                    ),
                    StandardInput(
                      hintText: TransUtil.trans("hint_rpassword"),
                      isRequiredInput: true,
                      isObscureText: true,
                      onChanged: (val) => _rPassword = val,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: marginStandard,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TransUtil.trans("label_gender"),
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: RadioListTile(
                              value: "male",
                              groupValue: _gender,
                              selected: _gender == "male",
                              activeColor: colorPrimaryDark,
                              title: Text(TransUtil.trans("label_male")),
                              onChanged: (val) {
                                setState(() {
                                  _gender = val;
                                });
                              }),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: RadioListTile(
                              value: "female",
                              groupValue: _gender,
                              selected: _gender == "female",
                              activeColor: colorPrimaryDark,
                              title: Text(TransUtil.trans("label_female")),
                              onChanged: (val) {
                                setState(() {
                                  _gender = val;
                                });
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: marginStandard,
              ),
              StandardButton(
                text: TransUtil.trans("btn_sign_up"),
                isLoading: _loading,
                textStyle: TextStyle(
                  color: Colors.black87,
                ),
                onButtonPressed: _handlSignUp,
              ),
              SizedBox(
                height: marginSmall,
              ),
              RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: TransUtil.trans("hint_have_account"),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: fontSizeSmall,
                      ),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('clicked');
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (builder) => LoginScreen()));
                        },
                      text: TransUtil.trans('btn_login'),
                      style: TextStyle(
                          color: Colors.black87, decoration: TextDecoration.underline, fontSize: fontSizeSmall),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(marginLarge),
                child: LangPicker(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
