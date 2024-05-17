import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Messaging.dart';

class SpecificJobPage extends StatefulWidget {
  final String jobId;
  final String specializationId;


  SpecificJobPage({Key? key, required this.jobId, required this.specializationId}) : super(key: key); // Update this line

  @override
  _SpecificJobPageState createState() => _SpecificJobPageState();
}

class _SpecificJobPageState extends State<SpecificJobPage> {
  Map<String, dynamic> jobDetails = {};
  Map<String, dynamic> freelancer={};
  String? userIDjob;
  String? userRole;
  String? userid;
  String? jobstatus;
  int freelancer_id=0;


  @override
  void initState() {
    super.initState();
    fetchJobDetails();
    _loadUserRole();
    _loadUserid();
  }

  Future<List<dynamic>> fetchFreelancers( ) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/freelancers/${widget.specializationId}'),
        headers: {'Authorization': 'Bearer $token'},
      );



      if (response.statusCode == 200) {
        List<dynamic> freelancers = json.decode(response.body)['data'];
        return freelancers;
      } else {
        throw Exception('Failed to load freelancers');
      }
    } else {
      throw Exception('Token not found');
    }
  }

  Future<void> sendInvitation(String freelancerId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      final response = await http.post(
        Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/invitations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'job_id': widget.jobId,
          'freelancer_id': freelancerId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invitation sent successfully!")));
      } else {
        var responseBody = json.decode(response.body);
        var errorMessage = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }
  Future<void> hireFreelancer(String jobSlug, String applicationSlug) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Authentication error. Please log in again.")));
      return;
    }

    final response = await http.put(
      Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/hire/$jobSlug/$applicationSlug'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      fetchJobDetails();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Freelancer hired successfully!")));
    } else {
      var responseBody = json.decode(response.body);
      var error = responseBody['message'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void showFreelancersPopup(BuildContext context) async {
    List<dynamic> freelancers = await fetchFreelancers();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Freelancers'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: freelancers.length,
              itemBuilder: (BuildContext context, int index) {
                var freelancer = freelancers[index];

                return Card(
                  color: Colors.deepPurple,
                  child: ListTile(
                    title: Text('Name: ${freelancer['username'] ?? 'No data'}'),
                    subtitle: Text('Gender: ${freelancer['gender'] ?? 'No data'}\nEmail: ${freelancer['email'] ?? 'No data'}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        sendInvitation(freelancer['id'].toString());
                      },
                      child: Text('Invite'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
        'job_id': widget.jobId,
      }),
    );

    if (response.statusCode == 201) {
      fetchJobDetails();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Freelancer hired successfully!")));
    } else {
      var responseBody = json.decode(response.body);
      var error = responseBody['message'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role');
    });
  }
  Future<void> _loadUserid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getInt('user_id')?.toString();
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
          var jobResponse = json.decode(response.body);

          jobDetails = jobResponse['data'];
          jobstatus = jobResponse['data']['status'];

          userIDjob = jobResponse['data']['client']['id'].toString();
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
      color: Color.fromARGB(255, 255, 255, 255),  // You can customize the background color
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 6.0, // Horizontal space between chips
          runSpacing: 6.0, // Vertical space between chips
          children: skills.map((skill) => Chip(
            label: Text(skill, style: TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          )).toList(),
        ),
      ),
    );
  }
  Widget buildCard(String details) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Color.fromARGB(255, 255, 255, 255),
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
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildApplicationCard(String freelancer, int id, String bid, String duration, String coverLetter, String applicationSlug, Map<String, dynamic> freelancerDetails) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: () {
          // عرض النافذة المنبثقة عند النقر على البطاقة
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Details of $freelancer'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Name: ${freelancerDetails['name']}'),
                      Text('Email: ${freelancerDetails['email']}'),
                      Text('Bio: ${freelancerDetails['bio'] ?? "Not available"}'),
                      Text('Phone: ${freelancerDetails['phone'] ?? "Not available"}'),
                      Text('Skills: ${freelancerDetails['skills'].map((s) => s['name']).join(", ")}'),
                      Text('Education: ${freelancerDetails['educations'].map((e) => "${e['school']} - ${e['degree']}").join(", ")}'),
                      Text('Certifications: ${freelancerDetails['certifications'].map((c) => c['name']).join(", ")}'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
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
        trailing: userid == userIDjob && userRole=="client" ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => hireFreelancer(jobDetails['slug'], applicationSlug),
              child: Text('Hire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
              ),
            ),
            SizedBox(width: 8), // Add some spacing between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to message page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessagePage(userid: id, username:freelancer),
                    // Replace MessagePage with your message page
                  ),
                );
              },
              child: Text('Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Change button color as needed
              ),
            ),
          ],
        ): SizedBox.shrink(),
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
      color: const Color.fromARGB(255, 255, 255, 255),
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


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 242, 242),
        title: Text('Job Details', style: TextStyle(color: Color(0xFF343ABA),)), // Blue color for the title
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Color.fromARGB(255, 242, 242, 242),
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
            // if (jobDetails.containsKey('required_skills'))
            //   buildSkillsCard(jobDetails['required_skills']),


            if (userRole == 'client' && userid==userIDjob && jobstatus!="hired")
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => showFreelancersPopup(context),
                    child: Text('Suggestion Invite', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            if (userRole == 'freelancer' && jobstatus!="hired")
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 224, 79, 53),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => showApplicationDialog( context),
                    child: Text('apply for a job', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),

            if (  jobDetails.containsKey('applications'))
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('The Applicants', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 18, fontWeight: FontWeight.bold)),
              ),

            if (userRole == 'client' && jobDetails.containsKey('applications'))
              ...jobDetails['applications'].map((application) => buildApplicationCard(
                  application['freelancer']['name'] ?? 'N/A',
                  application['freelancer']['id'] ?? 0,
                  application['bid'].toString() ?? '0',
                  application['duration'].toString() ?? '0',
                  application['cover_letter'] ?? 'N/A',
                  application['slug'],
                  application['freelancer']  // تمرير كائن الفريلانسر كاملًا
              )).toList(),
            if (userRole == 'freelancer' && jobDetails.containsKey('applications'))
              ...jobDetails['applications'].map((application) => buildApplicationCardForFreelance(
                application['freelancer']['name'] ?? 'N/A',
                application['cover_letter'] ?? 'N/A',
              )).toList(),

          ],
        ),
      ),
    );
  }




}