import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_service.dart';

final NavigationService navigationService = NavigationService();
Future<void> persistRoute(String routeName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_route', routeName);
}


class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isPasswordVisible = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
@override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              width: 400,
              height: 200,
              fit: BoxFit.contain,
            ),
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Please Log In ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF343ABA),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300.0,
              height: 50.0,
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
  width: 300.0,
  height: 50.0,
  child: TextField(
    controller: _passwordController,
    obscureText: !_isPasswordVisible, // Updated based on state variable
    decoration: InputDecoration(
      labelText: 'Password',
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      prefixIcon: Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(
          // Change the icon based on the state
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          // Update the state to toggle password visibility
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
    ),
  ),
),
            SizedBox(height: 20),
            ElevatedButton(
  onPressed: () async {
    String email = _emailController.text;
    String password = _passwordController.text;

    final String apiUrl = 'https://snapwork-133ce78bbd88.herokuapp.com/api/auth/login';

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Save token and user data to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', jsonData['data']['access_token']);
      await prefs.setString('user', json.encode(jsonData['data']['user']));
      await persistRoute('/home');
      navigationService.navigateTo('/home');
Navigator.pushAndRemoveUntil(
  context,
  
  MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
  (Route<dynamic> route) => false, // Remove all routes below
);
    } else {
      // Login failed, display an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('An error occurred during login. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  },
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0064B1)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
    ),
    minimumSize: MaterialStateProperty.all<Size>(
      Size(150, 40),
    ),
  ),
  child: Text('Login'),
),
       ],
        ),
      ),
    );
  }

  
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _isPasswordVisible = false;
bool _isConfirmPasswordVisible = false;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmationController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Please Log In ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF343ABA),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 300.0,
              height: 50.0,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300.0,
              height: 50.0,
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
             SizedBox(height: 15),
            SizedBox(
              width: 300.0,
              height: 50.0,
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ),
            
            SizedBox(height: 15),
           SizedBox(
  width: 300.0,
  height: 50.0,
  child: TextField(
    controller: _passwordController,
    obscureText: !_isPasswordVisible, // Updated based on state variable
    decoration: InputDecoration(
      labelText: 'Password',
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      prefixIcon: Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(
          // Change the icon based on the state
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          // Update the state to toggle password visibility
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
    ),
  ),
),
            SizedBox(height: 15),
            SizedBox(
  width: 300.0,
  height: 50.0,
  child: TextField(
    controller: _passwordConfirmationController,
    obscureText: !_isConfirmPasswordVisible, // Use the state variable here
    decoration: InputDecoration(
      fillColor: Colors.white,
      filled: true,
      labelText: 'Password confirmation',
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      // Your InputDecoration
      suffixIcon: IconButton(
        icon: Icon(
          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        },
      ),
    ),
  ),
),
           
           
            SizedBox(height: 20),
            ElevatedButton(
  onPressed: () async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String passwordConfirmation = _passwordConfirmationController.text;
    String email = _emailController.text;
    String name = _nameController.text;

    Map<String, String> userData = {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    String requestBody = json.encode(userData);

    final response = await http.post(
      Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    // Check the response status
    if (response.statusCode == 201) {
      // Registration successful, navigate to home.dart
       showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration success'),
            content: Text('congratulations you have an account'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Registration failed, display an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Failed'),
            content: Text('An error occurred during registration. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  },
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0064B1)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
    ),
    minimumSize: MaterialStateProperty.all<Size>(
      Size(150, 40),
    ),
  ),
  child: Text('Sign Up'),
),
          ],
        ),
      ),
    );
  }
}