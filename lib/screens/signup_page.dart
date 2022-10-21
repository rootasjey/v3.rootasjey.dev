// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootasjey/actions/users.dart';
import 'package:rootasjey/components/fade_in_x.dart';
import 'package:rootasjey/components/fade_in_y.dart';
import 'package:rootasjey/components/loading_animation.dart';
import 'package:rootasjey/globals/app_state.dart';
import 'package:rootasjey/globals/constants.dart';
import 'package:rootasjey/router/locations/home_location.dart';
import 'package:rootasjey/router/locations/signin_location.dart';
import 'package:rootasjey/utils/snack.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class SignupPage extends ConsumerStatefulWidget {
  final void Function(bool isAuthenticated)? onSignupResult;

  const SignupPage({Key? key, this.onSignupResult}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool _isCheckingEmail = false;
  bool _isCheckingName = false;
  bool _isSigningUp = false;

  final _confirmPasswordNode = FocusNode();
  final _passwordNode = FocusNode();
  final _usernameNode = FocusNode();

  String _confirmPassword = '';
  String _email = '';
  String _emailErrorMessage = '';
  String _nameErrorMessage = '';
  String _password = '';
  String _username = '';

  Timer? _emailTimer;
  Timer? _nameTimer;

  @override
  void dispose() {
    super.dispose();
    _usernameNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 100.0,
              bottom: 300.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: 300.0,
                      child: body(),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (_isSigningUp) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: LoadingAnimation(
          message: "signup_dot".tr(),
        ),
      );
    }

    return idleContainer();
  }

  Widget emailInput() {
    return FadeInY(
      delay: 0.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: TextFormField(
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            icon: const Icon(Icons.email),
            labelText: "email".tr(),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) async {
            _email = value;

            setState(() {
              _isCheckingEmail = true;
            });

            final isWellFormatted = UsersActions.checkEmailFormat(_email);

            if (!isWellFormatted) {
              setState(() {
                _isCheckingEmail = false;
                _emailErrorMessage = "email_not_valid".tr();
              });

              return;
            }

            if (_emailTimer != null) {
              _emailTimer!.cancel();
              _emailTimer = null;
            }

            _emailTimer = Timer(1.seconds, () async {
              final isAvailable =
                  await (UsersActions.checkEmailAvailability(_email)
                      as FutureOr<bool>);
              if (!isAvailable) {
                setState(() {
                  _isCheckingEmail = false;
                  _emailErrorMessage = "email_not_available".tr();
                });

                return;
              }

              setState(() {
                _isCheckingEmail = false;
                _emailErrorMessage = '';
              });
            });
          },
          onFieldSubmitted: (_) => _usernameNode.requestFocus(),
          validator: (value) {
            if (value!.isEmpty) {
              return "email_empty_forbidden".tr();
            }

            return null;
          },
        ),
      ),
    );
  }

  Widget emailInputError() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 40.0,
      ),
      child: Text(
        _emailErrorMessage,
        style: TextStyle(
          color: Colors.red.shade300,
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (Beamer.of(context).beamingHistory.isNotEmpty)
          FadeInX(
            beginX: 10.0,
            delay: 100.milliseconds,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
              ),
              child: IconButton(
                onPressed: Beamer.of(context).beamBack,
                icon: const Icon(UniconsLine.arrow_left),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FadeInY(
                beginY: 50.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    "signup".tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              FadeInY(
                delay: 200.milliseconds,
                beginY: 50.0,
                child: Opacity(
                  opacity: 0.6,
                  child: Text("account_create_new".tr()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        header(),
        emailInput(),
        if (_isCheckingEmail) emailProgress(),
        if (_emailErrorMessage.isNotEmpty) emailInputError(),
        nameInput(),
        if (_isCheckingName) nameProgress(),
        if (_nameErrorMessage.isNotEmpty) nameInputError(),
        passwordInput(),
        confirmPasswordInput(),
        validationButton(),
        alreadyHaveAccountButton(),
      ],
    );
  }

  Widget emailProgress() {
    return Container(
      padding: const EdgeInsets.only(
        left: 40.0,
      ),
      child: const LinearProgressIndicator(),
    );
  }

  Widget nameInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: _usernameNode,
              decoration: InputDecoration(
                icon: const Icon(
                  Icons.person_outline,
                ),
                labelText: "username".tr(),
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) async {
                setState(() {
                  _username = value;
                  _isCheckingName = true;
                });

                final isWellFormatted =
                    UsersActions.checkUsernameFormat(_username);

                if (!isWellFormatted) {
                  setState(() {
                    _isCheckingName = false;
                    _nameErrorMessage = _username.length < 3
                        ? "input_minimum_char".tr()
                        : "input_valid_format".tr();
                  });

                  return;
                }

                if (_nameTimer != null) {
                  _nameTimer!.cancel();
                  _nameTimer = null;
                }

                _nameTimer = Timer(1.seconds, () async {
                  final isAvailable =
                      await UsersActions.checkUsernameAvailability(_username);

                  if (!isAvailable) {
                    setState(() {
                      _isCheckingName = false;
                      _nameErrorMessage = "name_unavailable".tr();
                    });

                    return;
                  }

                  setState(() {
                    _isCheckingName = false;
                    _nameErrorMessage = '';
                  });
                });
              },
              onFieldSubmitted: (_) => _passwordNode.requestFocus(),
              validator: (value) {
                if (value != null && value.isEmpty) {
                  return "name_empty_forbidden".tr();
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget nameInputError() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 40.0,
      ),
      child: Text(
        _nameErrorMessage,
        style: TextStyle(
          color: Colors.red.shade300,
        ),
      ),
    );
  }

  Widget nameProgress() {
    return Container(
      padding: const EdgeInsets.only(
        left: 40.0,
      ),
      child: const LinearProgressIndicator(),
    );
  }

  Widget passwordInput() {
    return FadeInY(
      delay: 200.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: _passwordNode,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock_outline),
                labelText: "password".tr(),
              ),
              obscureText: true,
              onChanged: (value) {
                if (value.isEmpty) {
                  return;
                }
                _password = value;
              },
              onFieldSubmitted: (_) => _confirmPasswordNode.requestFocus(),
              validator: (value) {
                if (value!.isEmpty) {
                  return "password_empty_forbidden".tr();
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget confirmPasswordInput() {
    return FadeInY(
      delay: 400.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: _confirmPasswordNode,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock_outline),
                labelText: "password_confirm".tr(),
              ),
              obscureText: true,
              onChanged: (value) {
                if (value.isEmpty) {
                  return;
                }
                _confirmPassword = value;
              },
              onFieldSubmitted: (value) => trySignUp(),
              validator: (value) {
                if (value!.isEmpty) {
                  return "password_confirm_empty_forbidden".tr();
                }

                if (_confirmPassword != _password) {
                  return "passwords_dont_match".tr();
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 500.milliseconds,
      beginY: 50.0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: ElevatedButton(
            onPressed: () => trySignUp(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.colors.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(7.0),
                ),
              ),
            ),
            child: Container(
              width: 250.0,
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "signup".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget alreadyHaveAccountButton() {
    return FadeInY(
      delay: 700.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ElevatedButton(
          onPressed: () => Beamer.of(context).beamToNamed(SigninLocation.route),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              "account_already_own".tr(),
              style: const TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> checkInputs() async {
    if (!checkInputsFormat()) {
      return false;
    }

    if (!await checkInputsAvailability()) {
      return false;
    }

    return true;
  }

  void trySignUp() async {
    setState(() => _isSigningUp = true);

    if (!await checkInputs()) {
      setState(() => _isSigningUp = false);
      return;
    }

    try {
      final userNotifier = ref.read(AppState.userProvider.notifier);
      final createAccountResponse = await userNotifier.signUp(
        email: _email,
        username: _username,
        password: _password,
      );

      setState(() => _isSigningUp = false);

      if (createAccountResponse.success) {
        if (!mounted) return;
        Beamer.of(context).beamToNamed(HomeLocation.route);
        return;
      }

      String message = "account_create_error".tr();
      final error = createAccountResponse.error;

      if (error != null && error.code != null && error.message != null) {
        message = "[code: ${error.code}] - ${error.message}";
      }

      if (!mounted) return;
      Snack.error(context, title: "", message: message);

      setState(() => _isSigningUp = false);
      Snack.error(context, title: "", message: "account_create_error".tr());
    } catch (error) {
      setState(() => _isSigningUp = false);
      Snack.error(context,
          title: "account".tr(), message: "account_create_error".tr());
    }
  }

  Future<bool> checkInputsAvailability() async {
    final checkResults = await Future.wait([
      UsersActions.checkEmailAvailability(_email),
      UsersActions.checkUsernameAvailability(_username),
    ]);

    final bool? foldedResult = checkResults.firstWhere(
      (result) => result == false,
      orElse: () => true,
    );

    return foldedResult ?? false;
  }

  bool checkInputsFormat() {
    // ?NOTE: Triming because of TAB key on Desktop insert blank spaces.
    _email = _email.trim();
    _password = _password.trim();

    if (_password.isEmpty || _confirmPassword.isEmpty) {
      Snack.error(
        context,
        title: "password".tr(),
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    if (_confirmPassword != _password) {
      Snack.error(
        context,
        title: "password".tr(),
        message: "passwords_dont_match".tr(),
      );

      return false;
    }

    if (_username.isEmpty) {
      Snack.error(
        context,
        title: "username".tr(),
        message: "name_empty_forbidden".tr(),
      );

      return false;
    }

    if (!UsersActions.checkEmailFormat(_email)) {
      Snack.error(
        context,
        title: "email".tr(),
        message: "email_not_valid".tr(),
      );

      return false;
    }

    if (!UsersActions.checkUsernameFormat(_username)) {
      Snack.error(
        context,
        title: "username".tr(),
        message: _username.length < 3
            ? "input_minimum_char".tr()
            : "input_valid_format".tr(),
      );

      return false;
    }

    return true;
  }
}
