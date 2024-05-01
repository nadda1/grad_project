import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'specificjob.dart';

class ClientJobsPage extends StatefulWidget {
  @override
  _ClientJobsPageState createState() => _ClientJobsPageState();
}

class _ClientJobsPageState extends State<ClientJobsPage> {
  List jobs = [];
  int? clientId;

  @override
  void initState() {
    super.initState();
    loadClientId();
  }

  Future<void> loadClientId() async {
    final prefs = await SharedPreferences.getInstance();
    clientId = prefs.getInt('user_id');
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    int currentPage = 1;
    bool hasMore = true;

    while (hasMore) {
      var url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/jobs/specialization?page=$currentPage';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];
        var newJobs = data.where((job) => job['client']['id'] == clientId).toList();

        setState(() {
          jobs.addAll(newJobs);
        });

        if (newJobs.isEmpty) {
          hasMore = false;
        } else {
          currentPage++;
        }
      } else {
        print('Failed to load jobs');
        hasMore = false; 
      }
    }
  }

  Future<void> updateJobDetails(String jobId, Map<String, dynamic> updatedData) async {
    var url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/jobs/$jobId';

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');  // Assuming the token is stored with key 'auth_token'

    var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',  // Include the token in the header
    };

    var response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
        print('Job updated successfully.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Job updated successfully.'))); // Success message
    } else {
        var responseBody = json.decode(response.body);
        var errorMessage = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));  // Show the error message from server
    }
}


  void showEditJobDialog(Map job) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
            TextEditingController titleController = TextEditingController(text: job['title']);
            TextEditingController descriptionController = TextEditingController(text: job['description']);
            TextEditingController skillsController = TextEditingController(text: job['required_skills'].join(', '));
            TextEditingController attachmentsController = TextEditingController(text: ".pdf");
            TextEditingController budgetController = TextEditingController(text: job['expected_budget'].toString());
            TextEditingController durationController = TextEditingController(text: job['expected_duration'].toString());

            return AlertDialog(
                title: Text('Edit Job'),
                content: SingleChildScrollView(
                    child: ListBody(
                        children: <Widget>[
                            TextField(
                                controller: titleController,
                                decoration: InputDecoration(hintText: "Title"),
                            ),
                            TextField(
                                controller: descriptionController,
                                decoration: InputDecoration(hintText: "Description"),
                            ),
                            TextField(
                                controller: skillsController,
                                decoration: InputDecoration(hintText: "Required Skills (comma separated)"),
                            ),
                            TextField(
                                controller: attachmentsController,
                                decoration: InputDecoration(hintText: "attachments"),
                            ),
                            TextField(
                                controller: budgetController,
                                decoration: InputDecoration(hintText: "Expected Budget"),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                            ),
                            TextField(
                                controller: durationController,
                                decoration: InputDecoration(hintText: "Expected Duration (days)"),
                                keyboardType: TextInputType.number,
                            ),
                        ],
                    ),
                ),
                actions: <Widget>[
                    TextButton(
                        child: Text('Update'),
                        onPressed: () {
                            Map<String, dynamic> updatedData = {
                                "title": titleController.text,
                                "description": descriptionController.text,
                                "required_skills": skillsController.text.split(',').map((skill) => skill.trim()).toList(),
                                "expected_budget": int.tryParse(budgetController.text),
                                "expected_duration": int.tryParse(durationController.text),
                                "attachments": attachmentsController.text.split(',').map((e) => e.trim()).toList(),
                            };
                            updateJobDetails(job['id'].toString(), updatedData);
                            Navigator.of(context).pop(); // Close the dialog
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
        title: Text('Client Jobs'),
      ),
      body: jobs.isEmpty ? Center(child: Text("No jobs found for this client.")) :
      ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          var job = jobs[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SpecificJobPage(
                  jobId: job['id'].toString(),
                  specializationId: job['specialization']['id'].toString(),
                )));
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(job['title'], style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => showEditJobDialog(job),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Text(job['description'], style: TextStyle(fontSize: 14.0)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
