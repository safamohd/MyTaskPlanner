import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_task_planner/landing_screen.dart';
import 'package:my_task_planner/widgets/lang_picker.dart';
import 'package:provider/provider.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/screens/sign_up_screen.dart';
import 'package:my_task_planner/services/auth_service.dart';
import 'package:my_task_planner/utils/dialog_util.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/button_standard.dart';
import 'package:my_task_planner/widgets/input_standard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthService _authService;

  var _email = "";
  var _password = "";

  var _loading = false;

  set loading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  void _handlLogin() async {
    if (!_formKey.currentState.validate()) {
      // form will handle showing error
      return;
    }

    loading = true;

    final user = await _authService.signInWithEmailAndPassword(_email, _password).catchError((error) {
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
    // if the sign in flow has no error close this screen
    // and the main wrapper will handle directing to home screen
    // if navigator can't pop push replace this screen with home screen
    if (Navigator.of(context).canPop())
      Navigator.of(context).pop();
    else
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (builder) => LandingScreen()));
  }

  @override
  void didChangeDependencies() {
    _authService = context.read<AuthService>();
    super.didChangeDependencies();
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
                      hintText: TransUtil.trans("hint_email"),
                      isRequiredInput: true,
                      onChanged: (val) => _email = val,
                    ),
                    StandardInput(
                      hintText: TransUtil.trans("hint_password"),
                      isRequiredInput: true,
                      isObscureText: true,
                      bottomMargin: 4,
                      onChanged: (val) => _password = val,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => DialogUtil.showResetPasswordDialog(context, _email),
                        text: TransUtil.trans('btn_forgot_password'),
                        style: TextStyle(
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                          fontSize: fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: marginStandard,
              ),
              StandardButton(
                isLoading: _loading,
                text: TransUtil.trans("btn_login"),
                textStyle: TextStyle(
                  color: Colors.black87,
                ),
                onButtonPressed: _loading ? null : _handlLogin,
              ),
              SizedBox(
                height: marginSmall,
              ),
              RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: TransUtil.trans(
                        "hint_no_account",
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: fontSizeSmall,
                      ),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('clicked');
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(builder: (builder) => SignUpScreen()));
                        },
                      text: TransUtil.trans('btn_create_account'),
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
