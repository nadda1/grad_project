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

  Future<void> showChangeRequestDialog(String jobSlug, String appSlug) async {
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
                if (bidController.text.isNotEmpty &&
                    durationController.text.isNotEmpty) {
                  requestChange(jobSlug, appSlug, bidController.text,
                      durationController.text);
                  print(appSlug);
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

  Future<void> requestCancel(String jobSlug, String appSlug) async {
    String url =
        'https://snapwork-133ce78bbd88.herokuapp.com/api/request-cancel/$appSlug/$jobSlug';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      },
      body: jsonEncode({'type': 'cancel', 'new_bid': '', 'new_duration': ''}),
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

  Future<void> requestChange(
      String jobSlug, String appSlug, String newBid, String newDuration) async {
    String url =
        'https://snapwork-133ce78bbd88.herokuapp.com/api/request-change/$appSlug/$jobSlug';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      },
      body: jsonEncode(
          {'type': 'change', 'new_bid': newBid, 'new_duration': newDuration}),
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
    String url =
        'https://snapwork-133ce78bbd88.herokuapp.com/api/request-submit/$appSlug/$jobSlug';
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

          return Card(
            elevation: 4,
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildInfoRow('Freelancer', job['freelancer']['name']),
                  _buildInfoRow('Bid', '\$${job['bid']}'),
                  _buildInfoRow('Duration', '${job['duration']} days'),
                  _buildCoverLetter(job['cover_letter']),
                  SizedBox(height: 12),
                  _buildAttachments(job['attachments']),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIconButton(
                        icon: Icons.cancel,
                        label: 'Cancel',
                        color: Colors.redAccent,
                        onPressed: () =>
                            requestCancel(job['slug'], job['job']['slug']),
                      ),
                      _buildIconButton(
                        icon: Icons.edit,
                        label: 'Change',
                        color: Colors.orange,
                        onPressed: () => showChangeRequestDialog(
                            job['slug'], job['job']['slug']),
                      ),
                      _buildIconButton(
                        icon: Icons.check_circle,
                        label: 'Submit',
                        color: Colors.green,
                        onPressed: () =>
                            requestSubmit(job['slug'], job['job']['slug']),
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

  Widget _buildInfoRow(String title, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverLetter(String? coverLetter) {
    if (coverLetter != null) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cover Letter:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Container(
              color: Colors.grey[100], // Light grey background color
              padding: EdgeInsets.all(8),
              child: Text(
                coverLetter,
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink(); // Empty container if no cover letter
    }
  }

  Widget _buildAttachments(List<String>? attachments) {
    if (attachments != null && attachments.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attachments:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: attachments.map((attachment) {
              return Text(
                '- $attachment',
                style: TextStyle(
                  color: Colors.black87,
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else {
      return SizedBox.shrink(); // Empty container if no attachments
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Flexible(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        ),
      ),
    );
  }
}
