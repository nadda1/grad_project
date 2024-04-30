import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContractsPage extends StatefulWidget {
  @override
  _ContractsPageState createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> {
  List<dynamic> jobList = [];
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('token');
    if (authToken != null) {
      fetchJobs();
    }
  }

  Future<void> fetchJobs() async {
  int currentPage = 1;
  bool hasMore = true;
  List<dynamic> allJobs = [];

  if (authToken == null) {
    await _loadAuthToken();
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? loggedInUsername = prefs.getString('user_name');

  while (hasMore) {
    String url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/jobs/specialization?page=$currentPage';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'];
      if (data.isEmpty) {
        hasMore = false;
      } else {
        for (var job in data) {
          var applications = job['applications'] as List;
          applications = applications.where((app) => app['freelancer'] == loggedInUsername && app['status'] == 'hired').toList();
          if (applications.isNotEmpty) {
            job['applications'] = applications;
            allJobs.add(job);
          }
        }
        currentPage++;
      }
    } else {
      print('Failed to fetch jobs');
      hasMore = false;
    }
  }

  setState(() {
    jobList = allJobs;
  });
}



  Future<void> requestCancel(String jobSlug) async {
    String url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/request-cancel/$jobSlug';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      },
      body: jsonEncode({
        'type': 'cancel',
        'new_bid': '',
        'new_duration': ''
      }),
    );
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Request to Cancel sent successfully'),
        backgroundColor: Colors.green,
      ));
    } else {
      var responseBody = json.decode(response.body);
      var errorMessage = responseBody['message'] ?? 'Failed to process your request';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contracts'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView.builder(
        itemCount: jobList.length,
        itemBuilder: (context, index) {
          final job = jobList[index];
          final client = job['client'];
          final applications = job['applications'];

          return Card(
            elevation: 4,
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Job: ${job['title']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Client: ${client['username']}'),
                  SizedBox(height: 10),
                  Text('Applications:'),
                  Column(
                    children: applications.map<Widget>((app) {
                      return ListTile(
                        title: Text('Freelancer: ${app['freelancer']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bid: \$${app['bid']}'),
                            Text('Duration: ${app['duration']} days'),
                            Text('Status: ${app['status']}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => requestCancel(job['slug']),
                        child: Text('Request to Cancel'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      ),
                      ElevatedButton(
                        onPressed: () {}, 
                        child: Text('Request to Change'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                      ElevatedButton(
                        onPressed: () {}, 
                        child: Text('Request to Submit'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
