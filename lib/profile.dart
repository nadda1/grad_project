import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'navigation_service.dart';
import 'contracts_page.dart';
import 'clientJobs.dart';


final NavigationService navigationService = NavigationService();


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Loading...';
  String _email = 'Loading...';
  String? role;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserRole();
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
  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
  }

Future<void> _logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  if (token == null) {
    // Directly replace with the WelcomePage route to ensure no back navigation
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
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
      // Use pushNamedAndRemoveUntil to manage the route stack and URL state
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to log out."),
      ));
    }
  } catch (e) {
    print('Error logging out: $e');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("An error occurred while logging out."),
    ));
  }
}

 Future<void> _showEditProfileDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        String editedName = _name;
        String editedEmail = _email;
        String editedPassword = '';
        String editedConfirmPassword = '';

        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _name,
                  onChanged: (value) {
                    editedName = value;
                  },
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  initialValue: _email,
                  onChanged: (value) {
                    editedEmail = value;
                  },
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  onChanged: (value) {
                    editedPassword = value;
                  },
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextFormField(
                  onChanged: (value) {
                    editedConfirmPassword = value;
                  },
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
  child: Text('Save'),
  onPressed: () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You're not logged in."),
      ));
      return;
    }

    final response = await http.put(
      Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/update-profile'), // Use your actual API URL
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': editedName,
        'email': editedEmail,
        if (editedPassword.isNotEmpty) 'password': editedPassword,
        if (editedConfirmPassword.isNotEmpty) 'password_confirmation': editedConfirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(); // Close the dialog
      _loadUserProfile(); // Reload the user profile to reflect changes
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Profile updated successfully."),
      ));
    } else {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update profile. Error: ${response.body}"),
      ));
    }
  },
),
          ],
        );
      },
    );
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
              const CircleAvatar(
                backgroundImage: NetworkImage('https://placeholdit.img/200x200'),
                radius: 50.0,
              ),
              const SizedBox(height: 20.0),
              Text(
                _name,
                style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              Text(_email),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: _showEditProfileDialog,
                  child: const Text('Edit Profile'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Change password button action
                  },
                  child: const Text('Change Password'),
                ),
              ),
              role=="freelancer"? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContractsPage()),
                    );
                  },
                  child: const Text('My Contracts'),
                ),
              ):Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClientJobsPage()),
                    );
                  },
                  child: const Text('my posted jobs'),
                ),
              ),
               Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
              ),
              const SizedBox(height: 20.0),
              const EducationSection(),
              const SeparatorLine(),
              const SizedBox(height: 20.0),
              const CertificateSection(),
              const SeparatorLine(),
              const SizedBox(height: 20.0),
              const ExperienceSection(),
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



class AddEducationForm extends StatefulWidget {
  const AddEducationForm({Key? key}) : super(key: key);

  @override
  _AddEducationFormState createState() => _AddEducationFormState();
}

class _AddEducationFormState extends State<AddEducationForm> {
  TextEditingController _schoolController = TextEditingController();
  TextEditingController _degreeController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _majorController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Education'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _schoolController,
              decoration: InputDecoration(labelText: 'School'),
            ),
            TextFormField(
              controller: _degreeController,
              decoration: InputDecoration(labelText: 'Degree'),
            ),
            TextFormField(
              controller: _startDateController,
              decoration: InputDecoration(labelText: 'Start Date'),
            ),
            TextFormField(
              controller: _endDateController,
              decoration: InputDecoration(labelText: 'End Date'),
            ),
            TextFormField(
              controller: _majorController,
              decoration: InputDecoration(labelText: 'Major'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
  child: Text('Save'),
  onPressed: () async {
    _submitForm();
    
  },
),
      ],
    );
  }

void _submitForm() async {
  // Retrieve values from controllers
  String school = _schoolController.text;
  String degree = _degreeController.text;
  String startDate = _startDateController.text;
  String endDate = _endDateController.text;
  String major = _majorController.text;
  String description = _descriptionController.text;

  // Validate inputs
  if (_validateInputs(school, degree, startDate, endDate, major, description)) {
    // If inputs are valid, send request to add new education entry
    try {
      await _addEducationEntry(school, degree, startDate, endDate, major, description);
      Navigator.of(context).pop(); // Close the dialog after successful submission
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Education entry added successfully."),
      ));
    } catch (error) {
      // Handle error if request fails
      print('Error adding education entry: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to add education entry. Please try again."),
      ));
    }
  }
}

bool _validateInputs(String school, String degree, String startDate, String endDate, String major, String description) {
  // Perform validation here
  if (school.isEmpty || degree.isEmpty || startDate.isEmpty || endDate.isEmpty || major.isEmpty || description.isEmpty) {
    // Display error message if any field is empty
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("All fields are required."),
    ));
    return false; // Inputs are not valid
  }
  
  // Additional validation logic can be added here if needed
  
  return true; // Inputs are valid
}

Future<void> _addEducationEntry(String school, String degree, String startDate, String endDate, String major, String description) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  if (token == null) {
    // Handle case where user is not logged in
    throw Exception("User is not logged in");
  }

  final response = await http.post(
    Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/update-educations'), 
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "school": school,
      "degree": degree,
      "start_date": startDate,
      "end_date": endDate,
      "major": major,
      "description": description,
    }),
  );

  if (response.statusCode != 200) {
    // Handle case where request fails
    throw Exception("Failed to add education entry. Status code: ${response.statusCode}");
  }
}

}

class AddCertificateForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Certificate'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Issuer'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Issue Date'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'URL'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Add certificate logic
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}


class AddExperienceForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Experience'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Company'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Position'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'City'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Country'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Start Date'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'End Date'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Add experience logic
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}


class EducationSection extends StatelessWidget {
  const EducationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Education:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddEducationForm(); // Show AddEducationForm in a dialog
                    },
                  );
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Display education entries
        ],
      ),
    );
  }
}

class CertificateSection extends StatelessWidget {
  const CertificateSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Certificate:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
               onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddCertificateForm(); // Show AddCertificateForm in a dialog
                    },
                  );
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Display certificate entries
        ],
      ),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Experience:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
                 onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddExperienceForm(); // Show AddExperienceForm in a dialog
                    },
                  );
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Display experience entries
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
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
    );
  }
}