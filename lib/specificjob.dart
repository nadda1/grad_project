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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('you applied in this job before')));
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
Widget buildSkillsCard(List<dynamic> skills) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    color: Colors.deepPurple, // You can customize the background color
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 6.0, // Horizontal space between chips
        runSpacing: 6.0, // Vertical space between chips
        children: skills.map((skill) => Chip(
          label: Text(skill, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurpleAccent,
        )).toList(),
      ),
    ),
  );
}
Widget buildCard(String details) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    color: Colors.deepPurple, 
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Wrap(
            spacing: 6.0, // Horizontal space between chips
            runSpacing: 6.0,
            children: [
              Chip(
                label: Text(
                  details,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.deepPurpleAccent,
              ),
            ],
          ),
        ],
      ),
    ),
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
          if (jobDetails.containsKey('title'))
          buildCard( jobDetails['title'] ?? 'N/A'),
          if (jobDetails.containsKey('address'))
          buildCard( jobDetails['address'] ?? 'Location not available'),
          if (jobDetails.containsKey('expected_budget'))
          buildCard( '\$${jobDetails['expected_budget']}'),
          if (jobDetails.containsKey('description'))
          buildCard( jobDetails['description'] ?? 'Description not available'),
          if (jobDetails.containsKey('required_skills'))
            buildSkillsCard(jobDetails['required_skills']),
          if (userRole == 'freelancer')
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
          if (userRole == 'client' && jobDetails.containsKey('applications'))
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text('The Applicants', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          if (userRole == 'client' && jobDetails.containsKey('applications'))
            ...jobDetails['applications'].map((application) => buildApplicationCard(
          application['freelancer'] ?? 'N/A',
          application['bid'].toString() ?? '0',
          application['duration'].toString() ?? '0',
          application['cover_letter'] ?? 'N/A',
        )).toList(),
          if (userRole == 'freelancer' && jobDetails.containsKey('applications'))
            ...jobDetails['applications'].map((application) => buildApplicationCardForFreelance(
          application['freelancer'] ?? 'N/A',
          application['cover_letter'] ?? 'N/A',
        )).toList(),
                ],
              ),
            ),
          );
}

Widget buildApplicationCard(String freelancer, String bid, String duration, String coverLetter) {
  return Card(
    color: Colors.lightBlueAccent,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      title: Text('Freelancer: $freelancer', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bid: \$$bid', style: TextStyle(color: Colors.black)),
          Text('Duration: $duration days', style: TextStyle(color: Colors.black)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Cover Letter: $coverLetter', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    ),
  );
}
Widget buildApplicationCardForFreelance(String freelancer, String coverLetter) {
  // Split the cover letter into words
  List<String> words = coverLetter.split(' ');
  // Take only the first 8 words or fewer if there aren't enough
  String displayText = words.take(8).join(' ');
  // Add ellipsis if there are more than 8 words
  if (words.length > 8) {
    displayText += '...';
  }

  return Card(
    color: Colors.lightBlueAccent,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      title: Text('Freelancer: $freelancer', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Cover Letter: $displayText', style: TextStyle(color: Colors.black)),
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
