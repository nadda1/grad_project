import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';


class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Loading...';
  String _email = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      Map<String, dynamic> userProfile = await _getUserProfile();
      setState(() {
        _name = userProfile['name'];
        _email = userProfile['email'];
      });
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You're not logged in."),
      ));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/logout'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Logged out successfully."),
          
        ));
        Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomePage()),
        (Route<dynamic> route) => false,
      );
        // Add navigation or state update if needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to log out."),
        ));
      }
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred while logging out."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage('https://placeholdit.img/200x200'),
                radius: 50.0,
              ),
              SizedBox(height: 20.0),
              Text(
                _name,
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              Text(_email),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Edit profile button action
                },
                child: const Text('Edit Profile'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Change password button action
                },
                child: const Text('Change Password'),
              ),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Logout'),
              ),
              SizedBox(height: 20.0),
              const EducationSection(educationList: [
                'Bachelor of Science in Computer Science (2020)',
                'Master of Science in Artificial Intelligence (expected 2024)',
              ]),
              const SeparatorLine(),
              SizedBox(height: 20.0),
              const CertificateSection(certificateList: [
                'Machine Learning Specialization (Coursera)',
                'Flutter Development Bootcamp (Udacity)',
              ]),
              const SeparatorLine(),
              SizedBox(height: 20.0),
              const ExperienceSection(experienceList: [
                'Software Engineer Intern (Company A, 2023)',
                'Web Developer (Company B, 2022)',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token not found in shared preferences');
    }

    final response = await http.get(
      Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/user-profile'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}
class EducationSection extends StatelessWidget {
  final List<String> educationList; // Replace with your education data

  const EducationSection({Key? key, required this.educationList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Adjust background color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Education:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10.0),
          for (String education in educationList)
            Text(education), // Display each education entry
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class CertificateSection extends StatelessWidget {
  final List<String> certificateList; // Replace with your certificate data

  const CertificateSection({Key? key, required this.certificateList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Adjust background color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Certificate:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10.0),
          for (String certificate in certificateList)
            Text(certificate), // Display each education entry
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  final List<String> experienceList; // Replace with your experience data

  const ExperienceSection({Key? key, required this.experienceList}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Adjust background color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Experience:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10.0),
          for (String experience in experienceList)
            Text(experience), // Display each education entry
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class SeparatorLine extends StatelessWidget {
  const SeparatorLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0,
      color: Colors.grey[300], // Adjust color for the line
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
    );
  }
}