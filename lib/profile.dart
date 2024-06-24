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
  List<dynamic>? _languages;
  double _averageRating = 0.0;
  List<dynamic> _reviews = [];
  String? role = '';
  List<Map<String, dynamic>> _projects = [];


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
        _languages= userProfile['languages'];
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



  Future<void> _deleteLanguage(int index) async {
    final languageId = _languages![index]['id'];

    final response = await http.delete(
      Uri.parse('https://yourapi.com/languages/$languageId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _languages!.removeAt(index);
      });
    } else {
      // Handle error case
      print('Failed to delete language entry');
    }
  }



Future<void> _showAddLanguageDialog() async {
  TextEditingController _languageController = TextEditingController();
  TextEditingController _levelController = TextEditingController();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Language'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _languageController,
                decoration: InputDecoration(labelText: 'Language'),
              ),
              TextFormField(
                controller: _levelController,
                decoration: InputDecoration(labelText: 'Level'),
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

              final response = await http.post(
                Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/languages'),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode(
                  {
                    "name": _languageController.text,
                    "level": _levelController.text,
                  }
                ),
              );

              if (response.statusCode == 200) {
                Navigator.of(context).pop(); // Close the dialog
                _loadUserProfile();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Language added successfully."),
                ));
              } else {
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Failed to add language. Error: ${response.body}"),
                ));
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}




  Future<void> _deleteEmployment(int index) async {
    final employmentId = _employments![index]['id'];

    final response = await http.delete(
      Uri.parse('https://yourapi.com/employments/$employmentId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _employments!.removeAt(index);
      });
    } else {
      // Handle error case
      print('Failed to delete employment entry');
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

                final response = await http.post(
                  Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/employments'),
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(
                
                      {
                        "company": _companyController.text,
                        "position": _positionController.text,
                        "city": _cityController.text,
                        "country": _countryController.text,
                        "start_date": _startDateController.text,
                        "end_date": _endDateController.text,
                        "description": _descriptionController.text,
                      }

                  ),
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
 


Future<void> _deleteProject(int index) async {
    final projectId = _projects[index]['id'];

    final response = await http.delete(
      Uri.parse('https://yourapi.com/projects/$projectId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _projects.removeAt(index);
      });
    } else {
      // Handle error case
      print('Failed to delete project entry');
    }
  }






void _showAddProjectDialog() {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _urlController = TextEditingController();
  TextEditingController _technologiesController = TextEditingController();
  TextEditingController _completionDateController = TextEditingController();
  TextEditingController _attachmentTitleController = TextEditingController();
  TextEditingController _attachmentUrlController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(labelText: 'URL'),
              ),
              TextFormField(
                controller: _technologiesController,
                decoration: InputDecoration(labelText: 'Technologies'),
              ),
              TextFormField(
                controller: _completionDateController,
                decoration: InputDecoration(labelText: 'Completion Date'),
              ),
              TextFormField(
                controller: _attachmentTitleController,
                decoration: InputDecoration(labelText: 'Attachment Title'),
              ),
              TextFormField(
                controller: _attachmentUrlController,
                decoration: InputDecoration(labelText: 'Attachment URL'),
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
                Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/update-projects'),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode(
                  {
                    "title": _titleController.text,
                    "description": _descriptionController.text,
                    "url": _urlController.text,
                    "technologies": _technologiesController.text.split(','),
                    "completion_date": _completionDateController.text,
                    "attachments": [
                      {
                        "title": _attachmentTitleController.text,
                        "url": _attachmentUrlController.text,
                      }
                    ]
                  },
                ),
              );

              if (response.statusCode == 200) {
                Navigator.of(context).pop(); // Close the dialog
                _loadUserProfile();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Project added successfully."),
                ));
              } else {
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Failed to add project. Error: ${response.body}"),
                ));
              }
            },
            child: Text('Save'),
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

 Future<void> _deleteCertification(int index) async {
    final certificationId = _certifications![index]['id'];

    final response = await http.delete(
      Uri.parse('https://yourapi.com/certifications/$certificationId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _certifications!.removeAt(index);
      });
    } else {
      // Handle error case
      print('Failed to delete certification entry');
    }
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

                final response = await http.post(
                  Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/certifications'),
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(

                      {
                        "name": _nameController.text,
                        "issuer": _issuerController.text,
                        "issue_date": _issueDateController.text,
                        "url": _urlController.text,
                        "description": _descriptionController.text,
                      }

                  ),
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

                final response = await http.post(
                  Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/educations'),
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(

                      {
                        "school": _schoolController.text,
                        "degree": _degreeController.text,
                        "start_date": _startDateController.text,
                        "end_date": _endDateController.text,
                        "major": _majorController.text,
                        "description": _descriptionController.text,
                      }

                  ),
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
 
 Future<void> _deleteEducation(int index) async {
    final educationId = _educations![index]['id'];

    final response = await http.delete(
      Uri.parse('https://yourapi.com/educations/$educationId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _educations!.removeAt(index);
      });
    } else {
      // Handle error case
      print('Failed to delete education entry');
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
        for (var i = 0; i < _educations!.length; i++)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'School: ${_educations![i]['school']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Degree: ${_educations![i]['degree']}'),
                      Text('Major: ${_educations![i]['major']}'),
                      Text('Start Date: ${_educations![i]['start_date']}'),
                      Text('End Date: ${_educations![i]['end_date']}'),
                      Text('Description: ${_educations![i]['description']}'),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _deleteEducation(i),
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              const SeparatorLine(),
              const SizedBox(height: 20.0),
            ],
          ),
      ],
    ],
  ),
),
              const SizedBox(height: 20.0),
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
            for (var i = 0; i < _certifications!.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${_certifications![i]['name']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Issuer: ${_certifications![i]['issuer']}'),
                          Text('Issue Date: ${_certifications![i]['issue_date']}'),
                          Text('URL: ${_certifications![i]['url']}'),
                          Text('Description: ${_certifications![i]['description']}'),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _deleteCertification(i),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const SeparatorLine(),
                  const SizedBox(height: 20.0),
                ],
              ),
          ],
        ],
      ),
    ),
              const SizedBox(height: 20.0),
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
                'Languages:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _showAddLanguageDialog,
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          if (_languages != null) ...[
            for (var i = 0; i < _languages!.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Language: ${_languages![i]['name']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Level: ${_languages![i]['level']}'),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _deleteLanguage(i),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const SeparatorLine(),
                  const SizedBox(height: 20.0),
                ],
              ),
          ],
        ],
      ),
    ),
 const SizedBox(height: 20.0),
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
            for (var i = 0; i < _employments!.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company: ${_employments![i]['company']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Position: ${_employments![i]['position']}'),
                          Text('City: ${_employments![i]['city']}'),
                          Text('Country: ${_employments![i]['country']}'),
                          Text('Start Date: ${_employments![i]['start_date']}'),
                          Text('End Date: ${_employments![i]['end_date']}'),
                          Text('Description: ${_employments![i]['description']}'),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _deleteEmployment(i),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const SeparatorLine(),
                  const SizedBox(height: 20.0),
                ],
              ),
          ],
        ],
      ),
    ),
              const SizedBox(height: 20.0),
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
                'Projects:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _showAddProjectDialog,
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          if (_projects.isNotEmpty) ...[
            for (var i = 0; i < _projects.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title: ${_projects[i]['title']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Description: ${_projects[i]['description']}'),
                  if (_projects[i]['url'] != null) Text('URL: ${_projects[i]['url']}'),
                  if (_projects[i]['completion_date'] != null)
                    Text('Completion Date: ${_projects[i]['completion_date']}'),
                  if (_projects[i]['attachments'] != null) ...[
                    for (var attachment in _projects[i]['attachments'])
                      Text('${attachment['title']}: ${attachment['url']}'),
                  ],
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () => _deleteProject(i),
                    child: Text('Delete Project'),
                  ),
                  const SizedBox(height: 10.0),
                  const Divider(),
                  const SizedBox(height: 10.0),
                ],
              ),
          ],
        ],
      ),
    
),

              const SizedBox(height: 20.0),
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
      color: Color.fromARGB(255, 0, 0, 0),
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
    );
  }
}
