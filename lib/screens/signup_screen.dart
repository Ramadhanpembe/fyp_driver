import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fyp_driver/data/resources.dart';
import 'package:fyp_driver/models/driver_info.dart';
import 'package:fyp_driver/models/driver_location.dart';
import 'package:fyp_driver/models/driver_login.dart';
import 'package:geolocator/geolocator.dart';

import '../models/driver_route.dart';
import '../utils/constants.dart';
import '../widgets/form_text_field.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedRouteIndex = -1;
  List<DriverRoute> _routes = [];

  List<DropdownMenuItem<String>>? _buildDropdownMenuItems() {
    List<DropdownMenuItem<String>>? list = [];
    for (int i = 0; i < _routes.length; i++) {
      if (i == 0) {
        list.add(DropdownMenuItem<String>(
          value: i.toString(),
          child: const Text(
            '--Select route--',
            style: kHintTextStyle,
          ),
        ));
      }
      list.add(
        DropdownMenuItem<String>(
          value: (i + 1).toString(),
          child: Text(
              '${_routes[i].fromTerminal.toUpperCase()} - ${_routes[i].toTerminal.toUpperCase()}'),
        ),
      );
    }
    return list;
  }

  Future<bool> _createAccount() async {
    Position? position = await locationManager.getDriverCurrentLocation();
    if (position == null) return false;
    DriverInfo driverInfo = DriverInfo(
      username: _usernameController.text,
      login: DriverLogin(
        phone: _phoneController.text,
        password: _passwordController.text,
      ),
      route: DriverRoute(
        fromTerminal: _routes[_selectedRouteIndex].fromTerminal,
        toTerminal: _routes[_selectedRouteIndex].toTerminal,
      ),
      location: DriverLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        accuracy: position.accuracy,
      ),
    );

    String createdID = await firestoreManager.storeDriverInfo(position, driverInfo);
    log('Here we gooooo!');
    log('CreatedID: $createdID');
    log('---------------------${driverInfo.username}----------');
    return true;
  }

  void _driverRoutes() async {
    _routes = await firestoreManager.getRouteNames();
  }

  @override
  void initState() {
    _driverRoutes();
    super.initState();
  }

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
                                child: Text('Create a PMS Driver Account'),
                              ),
                              FormTextField(
                                hintText: 'Username',
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter some text';
                                  } else if (value.trim().length < 4) {
                                    return 'Username must at least have four characters';
                                  }
                                  return null;
                                },
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
                              DropdownButtonFormField<String>(
                                hint: const Text('--Select route--'),
                                value: '0',
                                elevation: 0,
                                dropdownColor: Colors.grey.shade200,
                                items: _buildDropdownMenuItems(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedRouteIndex = int.parse(value!) - 1;
                                  });
                                  log('---value: $value');
                                  log('---selectedRouteIndex: $_selectedRouteIndex');
                                },
                                validator: (value) {
                                  if (value == '0') return 'Please select a route';
                                  return null;
                                },
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
                              FormTextField(
                                hintText: 'Repeat password',
                                obscureText: true,
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Please retype your password';
                                  } else if (value != _passwordController.text) {
                                    return 'Password mismatch';
                                  }
                                  return null;
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 2.0),
                                    child: Text('Already have account?'),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                                      foregroundColor: MaterialStateProperty.all(Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const LoginScreen()));
                                    },
                                    child: const Text('Login'),
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
                                        bool success = await _createAccount();
                                        if (success) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('Your account is created successfully'),
                                              ),
                                            );
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const LoginScreen()));
                                          }
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'There was an error in creating your account'),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: const Text('Create account'),
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
