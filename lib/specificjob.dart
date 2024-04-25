import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpecificJobPage extends StatefulWidget {
  final String jobId;

  SpecificJobPage({Key? key, required this.jobId}) : super(key: key);

  @override
  _SpecificJobPageState createState() => _SpecificJobPageState();
}

class _SpecificJobPageState extends State<SpecificJobPage> {
  Map<String, dynamic> jobDetails = {};
    String? userRole;


  @override
  void initState() {
    super.initState();
    fetchJobDetails();
    _loadUserRole();
  }
  Future<void> submitApplication(String bid, String duration, String coverLetter, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  var response = await http.post(
    Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/applications'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'bid': int.parse(bid),
      'duration': int.parse(duration),
      'cover_letter': coverLetter,
      'job_id': widget.jobId, // Assuming jobId is accessible from this context
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Application submitted successfully!')));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit application')));
  }
}
  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role');
    });
  }

  Future<void> fetchJobDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/jobs/${widget.jobId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          jobDetails = json.decode(response.body)['data'];
        });
      } else {
        print('Failed to fetch job details');
      }
    }
  }
  void showApplicationDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  TextEditingController bidController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController coverLetterController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Apply for a Job"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: bidController,
                  decoration: InputDecoration(labelText: 'Bid (\$)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your bid';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: durationController,
                  decoration: InputDecoration(labelText: 'Duration (days)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the duration';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: coverLetterController,
                  decoration: InputDecoration(labelText: 'Cover Letter'),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a cover letter';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                submitApplication(
                  bidController.text,
                  durationController.text,
                  coverLetterController.text,
                  context
                );
                Navigator.of(context).pop();
              }
            },
            child: Text('Submit'),
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
      backgroundColor: Color.fromARGB(255, 0, 13, 24),
      title: Text('Job Details', style: TextStyle(color: Colors.white)),
      centerTitle: true,
      elevation: 0,
    ),
    backgroundColor: const Color.fromARGB(255, 0, 46, 83),
    body: Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        children: <Widget>[
          buildDetailCard('Job Title', jobDetails['title'] ?? 'N/A', Colors.blue),
          buildDetailCard('Location', jobDetails['address'] ?? 'Location not available', Colors.deepPurple),
          buildDetailCard('Budget', '\$${jobDetails['expected_budget']}', Colors.green),
          buildDetailCard('Description', jobDetails['description'] ?? 'Description not available', Colors.indigo),
          buildDetailCard('Requirements', jobDetails['required_skills']?.join(", ") ?? 'Requirements not available', Colors.orange),
          if (userRole == 'freelancer') // شرط لعرض الزر إذا كان دور المستخدم freelancer
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => showApplicationDialog(context),
                  child: Text('Apply for a job', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}


Widget buildDetailCard(String title, String content, Color color) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      tileColor: color.withAlpha(50),
      title: Text(title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(content, style: TextStyle(color: Colors.black87, fontSize: 14)),
    ),
  );
}
}
