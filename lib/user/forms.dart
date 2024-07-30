import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import '../common/components.dart';
import 'api.dart';

TextEditingController restaurantnameController = TextEditingController();
TextEditingController firstnameController = TextEditingController();
TextEditingController lastnameController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController phoneOtpController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController emailOtpController = TextEditingController();
TextEditingController upiIDController = TextEditingController();

final GlobalKey<FormState> restaurantnameKey = GlobalKey<FormState>();
final GlobalKey<FormState> firstnameKey = GlobalKey<FormState>();
final GlobalKey<FormState> lastnameKey = GlobalKey<FormState>();
final GlobalKey<FormState> phoneKey = GlobalKey<FormState>();
final GlobalKey<FormState> phoneOtpKey = GlobalKey<FormState>();
final GlobalKey<FormState> emailKey = GlobalKey<FormState>();
final GlobalKey<FormState> emailOtpKey = GlobalKey<FormState>();
final GlobalKey<FormState> upiIDKey = GlobalKey<FormState>();

Form restaurantnameForm(BuildContext context) => Form(
      key: restaurantnameKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        validator: (value) {
          return value != null
              ? value.length < 3
                  ? 'Restaurant\'s Name must be atleast 3 characters'
                  : null
              : null;
        },
        controller: restaurantnameController,
        decoration: const InputDecoration(
          label: Text('Restaurant Name'),
          hintText: 'The name of your Restaurant',
        ),
      ),
    );
Form firstnameForm(BuildContext context) => Form(
      key: firstnameKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        validator: (value) {
          return value != null
              ? value.length < 3
                  ? 'First Name must be atleast 3 characters'
                  : null
              : null;
        },
        controller: firstnameController,
        decoration: const InputDecoration(
          label: Text('First Name'),
          hintText: 'First Name',
        ),
      ),
    );
Form lastnameForm(BuildContext context) => Form(
      key: lastnameKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        controller: lastnameController,
        decoration: const InputDecoration(
          label: Text('Last Name'),
          hintText: 'Last Name',
        ),
      ),
    );
Form phoneForm(BuildContext context) => Form(
      key: phoneKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        controller: phoneController,
        decoration: InputDecoration(
          label: const Text('Phone number'),
          hintText: 'Phone number',
          suffixIcon: IconButton(
            onPressed: () async {
              if (phoneKey.currentState!.validate()) {
                var otp = await getPhoneOtp(phoneController.text);
                final ScaffoldMessengerState scaffold =
                    scaffoldKey.currentState!;
                final snackBar = SnackBar(
                  showCloseIcon: true,
                  content: Text(otp != 0
                      ? "Error: Unable to send OTP!"
                      : "An OTP was sent."),
                );
                scaffold.showSnackBar(snackBar);
              }
            },
            icon: Text(
              'Get OTP',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        maxLength: 10,
        validator: (value) {
          return value == null || value.isEmpty
              ? 'This field is required'
              : value.length < 10
                  ? 'Phone number must be 10 digits'
                  : null;
        },
        keyboardType: TextInputType.phone,
      ),
    );
Form phoneOtpForm(BuildContext context) => Form(
      key: phoneOtpKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        controller: phoneOtpController,
        maxLength: 6,
        validator: (value) {
          return value == null || value.isEmpty
              ? 'This field is required'
              : value.length < 6
                  ? 'OTP must be 6 digits'
                  : null;
        },
        decoration: const InputDecoration(
          label: Text('Phone OTP'),
          hintText: 'OTP sent to your mobile number',
        ),
        keyboardType: const TextInputType.numberWithOptions(
            signed: false, decimal: false),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
      ),
    );
Form emailForm(BuildContext context) => Form(
      key: emailKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        controller: emailController,
        decoration: InputDecoration(
          label: const Text('Email address'),
          hintText: 'Email Address',
          suffixIcon: IconButton(
            onPressed: () async {
              if (emailKey.currentState!.validate()) {
                var otp = await getEmailOtp(emailController.text);
                final ScaffoldMessengerState scaffold =
                    scaffoldKey.currentState!;
                final snackBar = SnackBar(
                  showCloseIcon: true,
                  content: Text(otp != 0
                      ? "Error: Unable to send OTP!"
                      : "An OTP was sent."),
                );
                scaffold.showSnackBar(snackBar);
              }
            },
            icon: Text(
              'Get OTP',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        validator: (value) {
          return value == null || value.isEmpty
              ? 'This field is required'
              : !EmailValidator.validate(value)
                  ? 'Enter a valid Email'
                  : null;
        },
        keyboardType: TextInputType.emailAddress,
      ),
    );
Form emailOtpForm(BuildContext context) => Form(
      key: emailOtpKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        controller: emailOtpController,
        maxLength: 6,
        validator: (value) {
          return value == null || value.isEmpty
              ? 'This field is required'
              : value.length < 6
                  ? 'OTP must be 6 digits'
                  : null;
        },
        decoration: const InputDecoration(
          label: Text('Email OTP'),
          hintText: 'OTP sent to your email',
        ),
        keyboardType: const TextInputType.numberWithOptions(
            signed: false, decimal: false),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
      ),
    );
Form upiIDForm(BuildContext context) => Form(
      key: upiIDKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        validator: (value) {
          return value != null
              ? !value.contains(RegExp('^[a-zA-Z0-9._-]+@[a-zA-Z]+\$'))
                  ? 'Enter a valid UPI ID'
                  : null
              : null;
        },
        keyboardType: TextInputType.text,
        controller: upiIDController,
        decoration: InputDecoration(
          label: const Text('UPI ID'),
          hintText: 'UPI ID',
          suffixIcon: IconButton(
            onPressed: () {
              if (upiIDKey.currentState!.validate()) {
                href(
                  context,
                  url:
                      'upi://pay?pa=${upiIDController.text}&pn=Check if UPI apps recognise this UPI ID',
                );
              }
            },
            icon: Text(
              'Test',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
