import 'package:flutter/material.dart';
import 'Authentication.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async main
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final String initialRoute = token != null ? '/home' : '/';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Ap Title',
      initialRoute: initialRoute, // Dynamic initial route based on token
      routes: {
        '/': (context) => WelcomePage(),
        '/home': (context) => MyHomePage(title: 'Home Page'),
        // Define other routes as needed
      },
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

              child: Text('Login',style: TextStyle(
                color: Colors.white,
              ),),
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
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigate to sign up page
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) =>  MyHomePage(title: 'home',)),
            //     );
            //   },
            //   style: ButtonStyle(
            //     backgroundColor: MaterialStateProperty.all<Color>(Color(
            //         0xFFFFFFFF)),
            //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //       RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(40.0), // Adjust radius as needed
            //       ),
            //     ),
            //     minimumSize: MaterialStateProperty.all<Size>(
            //       Size(200, 40), // Adjust width and height as needed
            //     ),
            //   ),
            //   child: Text('home',
            //     style: TextStyle(
            //       color: Color(0xFF0064B1),),
            //   ),
            // ),

            // ElevatedButton(
            //   onPressed: () {
            //     // Navigate to sign up page
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) =>  MyHomePage(title: 'home',)),
            //     );
            //   },
            //   style: ButtonStyle(
            //     backgroundColor: MaterialStateProperty.all<Color>(Color(
            //         0xFFFFFFFF)),
            //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //       RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(40.0), // Adjust radius as needed
            //       ),
            //     ),
            //     minimumSize: MaterialStateProperty.all<Size>(
            //       Size(200, 40), // Adjust width and height as needed
            //     ),
            //   ),
            //   child: Text('home',
            //     style: TextStyle(
            //       color: Color(0xFF0064B1),),
            //   ),
            // ),
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