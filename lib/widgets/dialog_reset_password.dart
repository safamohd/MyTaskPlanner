import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/button_standard.dart';
import 'package:my_task_planner/widgets/input_standard.dart';
import 'package:provider/provider.dart';
import 'package:my_task_planner/services/auth_service.dart';

class ResetpasswordDialog extends StatefulWidget {
  final String email;

  ResetpasswordDialog({Key key, this.email = ""}) : super(key: key);

  @override
  _ResetpasswordDialogState createState() => _ResetpasswordDialogState();
}

class _ResetpasswordDialogState extends State<ResetpasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  AuthService _authService;
  var _loading = false;
  var _emailAddress = "";
  var _resetEmailSent = false;

  @override
  void didChangeDependencies() {
    _authService = context.watch<AuthService>();
    _loading = _authService.isLoading;
    _emailAddress = widget.email;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(marginStandard),
      decoration: BoxDecoration(
        color: colorPrimary,
        borderRadius: BorderRadius.circular(radiusStandard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(marginSmall),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.close_rounded),
            ),
          ),
          Column(
            children: [
              _resetEmailSent
                  ? Padding(
                      // show success message when the reset email sent successfully
                      padding: const EdgeInsets.all(marginStandard),
                      child: Center(
                        child: Text(TransUtil.trans('success_reset_email_sent')),
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: StandardInput(
                        color: colorPrimaryLight,
                        initialValue: widget.email,
                        hintText: TransUtil.trans("hint_email"),
                        isRequiredInput: true,
                        emailFormat: true,
                        onChanged: (value) => _emailAddress = value,
                      ),
                    ),
              SizedBox(
                height: marginStandard,
              ),
              StandardButton(
                width: double.infinity,
                isLoading: _loading,
                text: _resetEmailSent ? TransUtil.trans("btn_ok") : TransUtil.trans("btn_reset_password"),
                onButtonPressed: _loading
                    ? null
                    : _resetEmailSent
                        ? () => Navigator.of(context).pop()
                        : () async {
                            if (_formKey.currentState.validate()) {
                              await _authService
                                  .resetPassword(_emailAddress)
                                  .then((value) => {
                                        setState(() {
                                          _resetEmailSent = true;
                                        })
                                      })
                                  .catchError(
                                (error) {
                                  print(error);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error.toString()),
                                    ),
                                  );
                                },
                              );
                            }
                          },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
