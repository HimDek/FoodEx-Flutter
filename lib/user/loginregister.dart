import 'package:flutter/material.dart';
import 'api.dart';
import 'forms.dart';

class LoginRegister extends StatefulWidget {
  final void Function() onLog;

  const LoginRegister({super.key, required this.onLog});

  @override
  LoginRegisterState createState() => LoginRegisterState();
}

class LoginRegisterState extends State<LoginRegister> {
  late int _index = 0;
  late bool _isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List<Widget> _loginChildren() {
    return [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  return Theme.of(context).colorScheme.secondaryContainer;
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
            textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 24)),
          ),
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  if (phoneKey.currentState!.validate() &&
                      otpKey.currentState!.validate()) {
                    if ((await login(phoneController.text,
                            int.parse(otpController.text)) ==
                        0)) {
                      widget.onLog();
                    }
                  }
                  setState(() {
                    _isLoading = false;
                  });
                },
          child: Text(_isLoading ? 'Loging in...' : 'Login'),
        ),
      ),
      SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Don\'t have an account? '),
            GestureDetector(
              onTap: () => {
                setState(() {
                  _index = 1;
                }),
              },
              child:
                  const Text('Register', style: TextStyle(color: Colors.blue)),
            )
          ],
        ),
      ),
    ];
  }

  List<Widget> _registerChildren() {
    return [
      firstnameForm(context),
      const SizedBox(
        height: 10,
      ),
      lastnameForm(context),
      const SizedBox(
        height: 10,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  return Theme.of(context).colorScheme.secondaryContainer;
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
            textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 24)),
          ),
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  if (phoneKey.currentState!.validate() &&
                      otpKey.currentState!.validate() &&
                      firstnameKey.currentState!.validate()) {
                    if ((await register(
                            phoneController.text,
                            int.parse(otpController.text),
                            firstnameController.text,
                            lastnameController.text)) ==
                        0) {
                      widget.onLog();
                    }
                  }
                  setState(() {
                    _isLoading = false;
                  });
                },
          child: Text(_isLoading ? 'Registering...' : 'Register'),
        ),
      ),
      SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Already have an account? '),
            GestureDetector(
              onTap: () => {
                setState(() {
                  _index = 0;
                }),
              },
              child: const Text('Login', style: TextStyle(color: Colors.blue)),
            )
          ],
        ),
      ),
    ];
  }

  Widget _buildRegisterLogin(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Center(
              child: Text('FoodEx', style: TextStyle(fontSize: 50)),
            ),
            const Center(
              child: Text('Register or login to access all features',
                  style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(
              height: 20,
            ),
            phoneForm(context),
            otpForm(context),
            Column(
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  Widget _page() {
    switch (_index) {
      case 1:
        return _buildRegisterLogin(_registerChildren());
    }
    return _buildRegisterLogin(_loginChildren());
  }

  @override
  Widget build(BuildContext context) {
    return _page();
  }
}
