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
  if (authToken == null) {
    await _loadAuthToken();
  }

  List<dynamic> allJobs = [];

  String url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/applications';
  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $authToken'},
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body)['data'];
    // Filter jobs to include only those where status is 'hired'
    allJobs.addAll(data.where((job) => job['status'] == 'hired'));
  } else {
    print('Failed to fetch jobs');
  }

  setState(() {
    jobList = allJobs;
  });
}
Future<void> showChangeRequestDialog(String jobSlug , String appSLug) async {
  TextEditingController bidController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button to close the dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Request Change'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: bidController,
                decoration: InputDecoration(
                  labelText: 'New Bid (new bid)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(
                  labelText: 'New Duration (days)',
                ),
                keyboardType: TextInputType.number,
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
            child: Text('Submit'),
            onPressed: () {
              if (bidController.text.isNotEmpty && durationController.text.isNotEmpty) {
                requestChange(jobSlug, appSLug, bidController.text, durationController.text);
                print(appSLug);
                print(jobSlug);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}


  Future<void> requestCancel(String jobSlug, String appSlug ) async {
    String url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/request-cancel/$appSlug/$jobSlug';
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
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("you have not hired yet in this job to request "),
        backgroundColor: Colors.red,
      ));
    }
  }
  Future<void> requestChange(String jobSlug, String appSlug, String newBid, String newDuration) async {
  String url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/request-change/$appSlug/$jobSlug';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken'
    },
    body: jsonEncode({
      'type': 'change',
      'new_bid': newBid,
      'new_duration': newDuration
    }),
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Request to change sent successfully'),
      backgroundColor: Colors.green,
    ));
  } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("you have not hired yet in this job to request "),
        backgroundColor: Colors.red,
      ));
  }
}

  Future<void> requestSubmit(String jobSlug, String appSlug) async {
    String url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/request-submit/$appSlug/$jobSlug';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      },
      body: jsonEncode({
        'type': 'submit',
       
      }),
    );
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Request to submit sent successfully'),
        backgroundColor: Colors.green,
      ));
    } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("you have not hired yet in this job to request "),
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

        // تحديث العرض ليشمل معلومات العرض ومدته والغطاء الخاص بالتقديم
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Freelancer: ${job['freelancer']['name']}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Bid: \$${job['bid']}'),
                Text('Duration: ${job['duration']} days'),
                if (job['cover_letter'] != null) Text('Cover Letter: ${job['cover_letter']}'),
                SizedBox(height: 10),
                Text('Attachments:'),
                if (job['attachments'] != null && job['attachments'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: job['attachments'].map<Widget>((attachment) {
                      return Text(attachment);
                    }).toList(),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => requestCancel(job['slug'],job['job']['slug']),
                      child: Text('Request to Cancel'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                    ElevatedButton(
                      onPressed: () => showChangeRequestDialog(job['slug'],job['job']['slug']),
                      child: Text('Request to Change'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                    ElevatedButton(
                      onPressed: () => requestSubmit(job['slug'],job['job']['slug']),
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