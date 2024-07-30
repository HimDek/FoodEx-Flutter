import 'package:flutter/material.dart';
import '../common/components.dart';
import 'api.dart';
import 'forms.dart';

class UpdatePhone extends StatefulWidget {
  final void Function() onSubmit;

  const UpdatePhone({super.key, required this.onSubmit});

  @override
  UpdatePhoneState createState() => UpdatePhoneState();
}

class UpdatePhoneState extends State<UpdatePhone> {
  late bool _isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    phoneController.text = homeKey.currentState!.userData['username'];
    phoneOtpController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Phone'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              phoneForm(context),
              phoneOtpForm(context),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Theme.of(context)
                              .colorScheme
                              .secondaryContainer;
                        }
                        return Theme.of(context).colorScheme.primaryContainer;
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withAlpha(128);
                        }
                        return Theme.of(context).colorScheme.onPrimaryContainer;
                      },
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                    textStyle:
                        const WidgetStatePropertyAll(TextStyle(fontSize: 24)),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          if (phoneKey.currentState!.validate() &&
                              phoneOtpKey.currentState!.validate()) {
                            Map profileData = {};
                            profileData['phone'] = phoneController.text;
                            profileData['phoneotp'] = phoneOtpController.text;
                            if ((await updateProfile(() => {}, profileData)) ==
                                0) {
                              widget.onSubmit();
                            }
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        },
                  child: Text(_isLoading ? 'Saving...' : 'Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateEmail extends StatefulWidget {
  final void Function() onSubmit;

  const UpdateEmail({super.key, required this.onSubmit});

  @override
  UpdateEmailState createState() => UpdateEmailState();
}

class UpdateEmailState extends State<UpdateEmail> {
  late bool _isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    emailController.text = homeKey.currentState!.userData['email'] ?? '';
    emailOtpController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              emailForm(context),
              emailOtpForm(context),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Theme.of(context)
                              .colorScheme
                              .secondaryContainer;
                        }
                        return Theme.of(context).colorScheme.primaryContainer;
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withAlpha(128);
                        }
                        return Theme.of(context).colorScheme.onPrimaryContainer;
                      },
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                    textStyle:
                        const WidgetStatePropertyAll(TextStyle(fontSize: 24)),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          if (emailKey.currentState!.validate() &&
                              emailOtpKey.currentState!.validate()) {
                            Map profileData = {};
                            profileData['email'] = emailController.text;
                            profileData['emailotp'] = emailOtpController.text;
                            if ((await updateProfile(() => {}, profileData)) ==
                                0) {
                              widget.onSubmit();
                            }
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        },
                  child: Text(_isLoading ? 'Saving...' : 'Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
