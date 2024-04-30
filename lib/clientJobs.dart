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
                    Text(job['title'], style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
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
