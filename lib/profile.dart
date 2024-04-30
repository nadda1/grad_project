import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'navigation_service.dart';
import 'contracts_page.dart';
import 'clientJobs.dart';

final NavigationService navigationService = NavigationService();


class Certification {
  final String name;
  final String issuer;
  final String issueDate;
  final String url;
  final String description;

  Certification({
    required this.name,
    required this.issuer,
    required this.issueDate,
    required this.url,
    required this.description,
  });
    Map<String, dynamic> toJson() {
    return {
      'name': name,
      'issuer': issuer,
      'issueDate': issueDate,
      'url': url,
      'description': description,
    };
  }

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      name: json['name'],
      issuer: json['issuer'],
      issueDate: json['issueDate'],
      url: json['url'],
      description: json['description'],
    );
  }
}


class Experience {
  final String company;
  final String position;
  final String city;
  final String country;
  final String startDate;
  final String endDate;
  final String description;

  Experience({
    required this.company,
    required this.position,
    required this.city,
    required this.country,
    required this.startDate,
    required this.endDate,
    required this.description,
  });
   Map<String, dynamic> toJson() {
    return {
      'company': company,
      'position': position,
      'city': city,
      'country': country,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      company: json['company'],
      position: json['position'],
      city: json['city'],
      country: json['country'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      description: json['description'],
    );
  }
}


class Education {
  final String school;
  final String degree;
  final String startDate;
  final String endDate;
  final String major;
  final String description;

  Education({
    required this.school,
    required this.degree,
    required this.startDate,
    required this.endDate,
    required this.major,
    required this.description,
  });
    Map<String, dynamic> toJson() {
    return {
      'school': school,
      'degree': degree,
      'startDate': startDate,
      'endDate': endDate,
      'major': major,
      'description': description,
    };
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      school: json['school'],
      degree: json['degree'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      major: json['major'],
      description: json['description'],
    );
  }
}




class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Loading...';
  String _email = 'Loading...';
  List<Education> _educationList = []; // Maintain a list of education data
  List<Experience> _experienceList = [];
  List<Certification> _certificationList = [];
   String? role;

Future<void> _saveEducationList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    'educationList',
    _educationList.map((e) => jsonEncode(e.toJson())).toList(),
  );
}

Future<void> _saveExperienceList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    'experienceList',
    _experienceList.map((e) => jsonEncode(e.toJson())).toList(),
  );
}

Future<void> _saveCertificationList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    'certificationList',
    _certificationList.map((e) => jsonEncode(e.toJson())).toList(),
  );
}


 void _addEducation(Education education) {
    setState(() {
      _educationList.add(education);
    });
    _saveEducationList();
  }

   void _addExperience(Experience experience) {
    setState(() {
      _experienceList.add(experience);
    });
     _saveExperienceList();
  }

    void _addCertification(Certification certification) {
    setState(() {
      _certificationList.add(certification);
    });
    _saveCertificationList();
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserRole();
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
      });
    _loadEducationList();
    _loadExperienceList();
    _loadCertificationList();
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }
  Future<void> _loadEducationList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? educationData = prefs.getStringList('educationList');
  if (educationData != null) {
    setState(() {
      _educationList = educationData.map((e) => Education.fromJson(jsonDecode(e))).toList();
    });
  }
}

Future<void> _loadExperienceList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? experienceData = prefs.getStringList('experienceList');
  if (experienceData != null) {
    setState(() {
      _experienceList = experienceData.map((e) => Experience.fromJson(jsonDecode(e))).toList();
    });
  }
}

Future<void> _loadCertificationList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? certificationData = prefs.getStringList('certificationList');
  if (certificationData != null) {
    setState(() {
      _certificationList = certificationData.map((e) => Certification.fromJson(jsonDecode(e))).toList();
    });
  }
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
               EducationSection(
                educationList: _educationList,
                onAddEducation: _addEducation, // Callback to add education
              ),
              const SeparatorLine(),
              const SizedBox(height: 20.0),
               CertificateSection(
                certificationList: _certificationList,
                onAddCertification: _addCertification, // Callback to add education
              ),
              const SeparatorLine(),
              const SizedBox(height: 20.0),
               ExperienceSection(experienceList: _experienceList ,onAddExperience:_addExperience ),
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
   final void Function(Education) onAddEducation;

  const AddEducationForm({Key? key, required this.onAddEducation}) : super(key: key);


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
    // If inputs are valid, create an Education object
    Education education = Education(
      school: school,
      degree: degree,
      startDate: startDate,
      endDate: endDate,
      major: major,
      description: description,
    );

    // Call the callback to add education in the parent widget
    widget.onAddEducation(education);

    // Close the dialog
    Navigator.of(context).pop();
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

  final response = await http.put(
    Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/auth/update-educations'), // Use your actual API URL
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({"educations":[{
      "school": school,
      "degree": degree,
      "start_date": startDate,
      "end_date": endDate,
      "major": major,
      "description": description,
    }]}),
  );

  if (response.statusCode != 200) {
    // Handle case where request fails
    throw Exception("Failed to add education entry. Status code: ${response.statusCode}");
  }
}

}
class AddCertificateForm extends StatelessWidget {
  final void Function(Certification) onAddCertification;
  final BuildContext context;
  const AddCertificateForm({Key? key, required this.onAddCertification,required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _issuerController = TextEditingController();
    TextEditingController _issueDateController = TextEditingController();
    TextEditingController _urlController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

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
          onPressed: () {
            _submitForm(
              _nameController.text,
              _issuerController.text,
              _issueDateController.text,
              _urlController.text,
              _descriptionController.text,
            );
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  void _submitForm(
    String name,
    String issuer,
    String issueDate,
    String url,
    String description,
  ) {
    Certification certification = Certification(
      name: name,
      issuer: issuer,
      issueDate: issueDate,
      url: url,
      description: description,
    );

    onAddCertification(certification);

    Navigator.of(context).pop();
  }
}




class AddExperienceForm extends StatelessWidget {
 final void Function(Experience) onAddExperience;
final BuildContext context;

const AddExperienceForm({Key? key, required this.onAddExperience, required this.context}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    TextEditingController _companyController = TextEditingController();
    TextEditingController _positionController = TextEditingController();
    TextEditingController _cityController = TextEditingController();
    TextEditingController _countryController = TextEditingController();
    TextEditingController _startDateController = TextEditingController();
    TextEditingController _endDateController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    return AlertDialog(
      title: Text('Add Experience'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: <Widget>[
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
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _submitForm(
              _companyController.text,
              _positionController.text,
              _cityController.text,
              _countryController.text,
              _startDateController.text,
              _endDateController.text,
              _descriptionController.text,
            );
          },
          child: Text('save'),
        ),
      ],
    );
  }

  void _submitForm(
    String company,
    String position,
    String city,
    String country,
    String startDate,
    String endDate,
    String description,
  ) {
    // Create an Experience object
    Experience experience = Experience(
      company: company,
      position: position,
      city: city,
      country: country,
      startDate: startDate,
      endDate: endDate,
      description: description,
    );

    // Call the callback to add experience in the parent widget
    onAddExperience(experience);

    // Close the dialog
    Navigator.of(context).pop();
  }
}



class EducationSection extends StatelessWidget {
  final List<Education> educationList;
  final void Function(Education) onAddEducation;

  const EducationSection({
    Key? key,
    required this.educationList,
    required this.onAddEducation,
  }) : super(key: key);

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
                      return AddEducationForm(
                        onAddEducation: onAddEducation,
                      );
                    },
                  );
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Display education entries
          Column(
            children: educationList.map((education) {
              return ListTile(
                title: Text(
                  '${education.school} (${education.startDate} - ${education.endDate})',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${education.degree}, ${education.major}',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Description: ${education.description}',
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}


class ExperienceSection extends StatelessWidget {
  final List<Experience> experienceList;
  final void Function(Experience) onAddExperience;

  const ExperienceSection({Key? key, required this.experienceList, required this.onAddExperience}) : super(key: key);


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
                      return AddExperienceForm(
                        onAddExperience: onAddExperience,
                        context: context
                      );
                    },
                  );
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Display experience entries
          Column(
            children: experienceList.map((experience) {
              return ListTile(
                title: Text(
                  '${experience.position}, ${experience.company} (${experience.startDate} - ${experience.endDate})',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${experience.city}, ${experience.country}',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Description: ${experience.description}',
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
class CertificateSection extends StatelessWidget {
  final List<Certification> certificationList;
 final void Function(Certification) onAddCertification;
  const CertificateSection({Key? key, required this.certificationList,required this.onAddCertification}) : super(key: key);

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
                      return AddCertificateForm(
                        onAddCertification: onAddCertification,
                        context: context,
                      );
                    },
                  );
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Display certificate entries
          Column(
            children: certificationList.map((certification) {
              return ListTile(
                title: Text(
                  '${certification.name} (${certification.issueDate})',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issuer: ${certification.issuer}',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'URL: ${certification.url}',
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Description: ${certification.description}',
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
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