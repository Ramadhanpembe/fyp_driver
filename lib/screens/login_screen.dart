import 'package:flutter/material.dart';
import 'package:fyp_driver/data/resources.dart';
import 'package:fyp_driver/models/driver_login.dart';
import 'package:fyp_driver/screens/home_screen.dart';
import 'package:fyp_driver/screens/signup_screen.dart';

import '../widgets/form_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              return SizedBox(
                width: width,
                height: height,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.15),
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 30.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  radius: 30.0,
                                  child: Text(
                                    'PMS',
                                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: Text('Login to PMS Driver Account'),
                              ),
                              FormTextField(
                                hintText: 'Phone number',
                                controller: _phoneController,
                                validator: (value) {
                                  if (!value!.startsWith(RegExp(r'^(\+255|0)[67]\d{8}$'))) {
                                    return 'Incorrect phone number';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.phone,
                              ),
                              FormTextField(
                                hintText: 'Password',
                                obscureText: true,
                                controller: _passwordController,
                                validator: (value) {
                                  if (value!.startsWith(' ') || value.contains(' ')) {
                                    return 'Password can not have white space';
                                  } else if (value.trim().length < 4) {
                                    return 'Password should at least have 4 characters';
                                  }
                                  return null;
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6.0),
                                    child: Text('Don\'t have account?'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: SizedBox(
                                      height: 30.0,
                                      child: TextButton(
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                                          foregroundColor: MaterialStateProperty.all(Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => const SignupScreen()));
                                        },
                                        child: const Text('Sign up'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        bool doesExist = await firestoreManager.authenticateDriver(
                                            _phoneController.text, _passwordController.text);
                                        if (doesExist) {
                                          if (mounted) {
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => HomeScreen(
                                                          login: DriverLogin(
                                                            phone: _phoneController.text,
                                                            password: _passwordController.text,
                                                          ),
                                                        )));
                                          }
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Incorrect logins info'),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: const Text('Login'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
