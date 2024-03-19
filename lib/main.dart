import 'package:flutter/material.dart';
import 'Authentication.dart';
import 'home.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF1F5FC),
      ),
      home: WelcomePage(),
    );
  }
}
Color buttonColor = Color(0xFF1B3D55);
class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/images/welcome.jpg',
              width: 400,
              height: 500,
              fit: BoxFit.contain,
            ),
            Text(
              'Welcome to Our App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to login page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },

              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>( Color(0xFF0064B1)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0), // Adjust radius as needed
                  ),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(200, 40), // Adjust width and height as needed
                ),
              ),

              child: Text('Login'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to sign up page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(
                    0xFFFFFFFF)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0), // Adjust radius as needed
                  ),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(200, 40), // Adjust width and height as needed
                ),
              ),
              child: Text('Sign Up',
                style: TextStyle(
                  color: Color(0xFF0064B1),),
              ),
            ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to sign up page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(title: '',)),
                );

              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(
                    0xFFFFFFFF)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0), // Adjust radius as needed
                  ),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(200, 40), // Adjust width and height as needed
                ),
              ),
              child: Text('Home',
                style: TextStyle(
                  color: Color(0xFF0064B1),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(), // Display the login form
    );
  }
}

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SignUpForm(), // Display the sign up form
    );
  }
}
