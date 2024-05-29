import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'navigation_service.dart';
import 'clientJobs.dart';
import 'contracts_page.dart';

final NavigationService navigationService = NavigationService();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Loading...';
  String _email = 'Loading...';
  List<dynamic>? _educations;
  List<dynamic>? _certifications;
  List<dynamic>? _employments;
  List<dynamic>? _skills;
  double _averageRating = 0.0;
  List<dynamic> _reviews = [];
  String? role = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserRole();
    _loadUserRatings();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      Map<String, dynamic> userProfile = await _getUserProfile();
      setState(() {
        _name = userProfile['name'];
        _email = userProfile['email'];
        _educations = userProfile['educations'];
        _certifications = userProfile['certifications'];
        _employments = userProfile['Employment'];
        _skills = userProfile['skills'];
      });
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _loadUserRatings() async {
    try {
      Map<String, dynamic> userRatings = await _getUserRatings();
      List<dynamic> ratingsData = userRatings['data'];
      double totalRating = 0.0;

      for (var rating in ratingsData) {
        totalRating += rating['value'];
      }

      setState(() {
        _averageRating = ratingsData.isNotEmpty ? totalRating / ratingsData.length : 0.0;
        _reviews = ratingsData;
      });

      // Print the average rating
      print('Average Rating: $_averageRating');
    } catch (e) {
      print('Error loading user ratings: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserRatings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token not found in shared preferences');
    }

    final response = await http.get(
      Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/rate'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user ratings');
    }
  }

  void _showReviewsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Freelancer Reviews'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _reviews.map((review) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['comment'],
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Rating: ${review['value']}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
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

  Future<void> showAddEmploymentsDialog() async {
    TextEditingController _companyController = TextEditingController();
    TextEditingController _positionController = TextEditingController();
    TextEditingController _cityController = TextEditingController();
    TextEditingController _countryController = TextEditingController();
    TextEditingController _startDateController = TextEditingController();
    TextEditingController _endDateController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(labelText: 'Company'),
                ),
                TextFormField(
                  controller: _positionController,
                  decoration: InputDecoration(labelText: 'Position'),
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(labelText: 'Country'),
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
                  controller: _descriptionController,
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
                  Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/update-employments'),
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    "employments": [
                      {
                        "company": _companyController.text,
                        "position": _positionController.text,
                        "city": _cityController.text,
                        "country": _countryController.text,
                        "start_date": _startDateController.text,
                        "end_date": _endDateController.text,
                        "description": _descriptionController.text,
                      }
                    ]
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop(); // Close the dialog
                  _loadUserProfile();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(" updated successfully."),
                  ));
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Failed to update . Error: ${response.body}"),
                  ));
                }
              },
              child: Text('save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAddSkillsDialog() async {
    TextEditingController _skillController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Skill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _skillController,
                  decoration: InputDecoration(labelText: 'Skill'),
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
                  Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/update-skills'),
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    "skills": [
                      _skillController.text,
                    ]
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop(); // Close the dialog
                  _loadUserProfile();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(" updated successfully."),
                  ));
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Failed to update . Error: ${response.body}"),
                  ));
                }
              },
              child: Text('save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAddCertificateDialog() async {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _issuerController = TextEditingController();
    TextEditingController _issueDateController = TextEditingController();
    TextEditingController _urlController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Certificate'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _issuerController,
                  decoration: InputDecoration(labelText: 'Issuer'),
                ),
                TextFormField(
                  controller: _issueDateController,
                  decoration: InputDecoration(labelText: 'Issue Date'),
                ),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: 'URL'),
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
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
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
                  Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/update-certifications'),
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    "certifications": [
                      {
                        "name": _nameController.text,
                        "issuer": _issuerController.text,
                        "issue_date": _issueDateController.text,
                        "url": _urlController.text,
                        "description": _descriptionController.text,
                      }
                    ]
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  _loadUserProfile(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(" updated successfully."),
                  ));
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Failed to update . Error: ${response.body}"),
                  ));
                }
              },
              child: Text('save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddEducationDialog() async {
    TextEditingController _schoolController = TextEditingController();
    TextEditingController _degreeController = TextEditingController();
    TextEditingController _startDateController = TextEditingController();
    TextEditingController _endDateController = TextEditingController();
    TextEditingController _majorController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
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
                  Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/update-educations'),
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    "educations": [
                      {
                        "school": _schoolController.text,
                        "degree": _degreeController.text,
                        "start_date": _startDateController.text,
                        "end_date": _endDateController.text,
                        "major": _majorController.text,
                        "description": _descriptionController.text,
                      }
                    ]
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  _loadUserProfile(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(" updated successfully."),
                  ));
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Failed to update . Error: ${response.body}"),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
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
                  Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/update-profile'),
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
              const SizedBox(height: 10.0),
              if (_averageRating > 2 && _averageRating<=3)
                Image.asset(
                  'assets/images/bronze-medal.png',
                  height: 50.0,
                ),
              if (_averageRating > 3 && _averageRating<=4 )
                Image.asset(
                  'assets/images/silver-medal.png',
                  height: 50.0,
                ),
              if (_averageRating > 4 && _averageRating<5)
                Image.asset(
                  'assets/images/medal.png',
                  height: 50.0,
                ),
              if (_averageRating==5)
                Image.asset(
                  'assets/images/trophy.png',
                  height: 50.0,
                ),
              ElevatedButton(
                onPressed: () => _showReviewsDialog(context),
                child: Text('Show Reviews'),
              ),
              const SizedBox(height: 20.0),
              RatingBarIndicator(
                rating: _averageRating,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 40.0,
                direction: Axis.horizontal,
              ),
              
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
              role == "freelancer"
                  ? Padding(
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
                    )
                  : Padding(
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
              Container(
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
                          onPressed: _showAddEducationDialog,
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    if (_educations != null) ...[
                      for (var education in _educations!)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'School: ${education['school']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Degree: ${education['degree']}'),
                            Text('Major: ${education['major']}'),
                            Text('Start Date: ${education['start_date']}'),
                            Text('End Date: ${education['end_date']}'),
                            Text('Description: ${education['description']}'),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              const SeparatorLine(),
              Container(
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
                          'Certification:',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: showAddCertificateDialog,
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    if (_certifications != null) ...[
                      for (var certification in _certifications!)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${certification['name']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Issuer: ${certification['issuer']}'),
                            Text('Issue Date: ${certification['issue_date']}'),
                            Text('URL: ${certification['url']}'),
                            Text('Description: ${certification['description']}'),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              const SeparatorLine(),
              Container(
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
                          'Employments:',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: showAddEmploymentsDialog,
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    if (_employments != null) ...[
                      for (var employment in _employments!)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Company: ${employment['company']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Position: ${employment['position']}'),
                            Text('City: ${employment['city']}'),
                            Text('Country: ${employment['country']}'),
                            Text('Start Date: ${employment['start_date']}'),
                            Text('End Date: ${employment['end_date']}'),
                            Text('Description: ${employment['description']}'),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              const SeparatorLine(),
              Container(
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
                          'Skills:',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: showAddSkillsDialog,
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    if (_skills != null) ...[
                      for (var skill in _skills!)
                        Text(skill['name']),
                    ],
                  ],
                ),
              ),
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
