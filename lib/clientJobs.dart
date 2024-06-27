import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'specificjob.dart'; // تأكد من أن مسار الاستيراد هذا صحيح لكي تعمل التنقلات

class ClientJobsPage extends StatefulWidget {
  @override
  _ClientJobsPageState createState() => _ClientJobsPageState();
}

class _ClientJobsPageState extends State<ClientJobsPage> {
  List jobs = [];

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<bool> acceptRequest(BuildContext context, int requestId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url =
        'https://snapwork-133ce78bbd88.herokuapp.com/api/response-accept/$requestId';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.put(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error: ${response.body}');
      return false;
    }
  }

  Future<bool> declineRequest(BuildContext context, int requestId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url =
        'https://snapwork-133ce78bbd88.herokuapp.com/api/response-decline/$requestId';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.put(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error: ${response.body}');
      return false;
    }
  }

  Future<void> fetchJobs() async {
    final prefs = await SharedPreferences.getInstance();
    String? token =
    prefs.getString('token'); // نفترض أن الرمز المخزن بالمفتاح 'token'
    var url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/jobs';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'];
      setState(() {
        jobs.addAll(data);
      });
    } else {
      print('Failed to load jobs');
    }
  }

  Future<String> sendRating(
      int jobId, List<Map<String, dynamic>> rates, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    String? token =
    prefs.getString('token'); // نفترض أن الرمز المخزن بالمفتاح 'token'
    var url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/rate';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var body = json.encode({
      'job_id': jobId,
      'rated_by': 3, // افتراضياً
      'rates': rates,
      'comment': comment,
    });

    var response =
    await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return 'Rating sent successfully';
    } else {
      return 'Failed to send rating';
    }
  }

  void showRatingDialog(BuildContext context, int jobId) {
    final _formKey = GlobalKey<FormState>();
    List<Map<String, dynamic>> rates = [
      {'name': 'Skills', 'value': 0},
      {'name': 'Availability', 'value': 0},
      {'name': 'Communication', 'value': 0},
      {'name': 'Quality', 'value': 0},
      {'name': 'Deadlines', 'value': 0},
      {'name': 'Cooperation', 'value': 0},
    ];
    String comment = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Rate Job'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...rates.map((rate) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rate['name']),
                            Slider(
                              value: rate['value'].toDouble(),
                              min: 0,
                              max: 5,
                              divisions: 5,
                              label: rate['value'].toString(),
                              onChanged: (double newValue) {
                                setState(() {
                                  rate['value'] = newValue.toInt();
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Comment'),
                        onChanged: (value) {
                          comment = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String message = await sendRating(jobId, rates, comment);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  AlertDialog buildRequestDialog(BuildContext context, dynamic request) {
    return AlertDialog(
      title: Text('Request Details'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Type: ${request['type']}'),
            Text('New Bid: \$${request['new_bid'] ?? 'No change'}'),
            Text(
                'New Duration: ${request['new_duration'] ?? 'No change'} days'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close the dialog
            bool success = await acceptRequest(context, request['id']);
            String message = success
                ? 'Request accepted successfully.'
                : 'Failed to accept request.';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
          },
          child: const Text('Accept'),
          style: TextButton.styleFrom(backgroundColor: Colors.green),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close the dialog
            bool success = await declineRequest(context, request['id']);
            String message =
            success ? 'Request declined.' : 'Failed to decline request.';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
          },
          child: const Text('Decline'),
          style: TextButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contracts'),
        backgroundColor: Color.fromARGB(255, 242, 242, 242),
      ),
      body: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          List hiredApplications = job['applications']
              .where((app) => app['status'] == 'hired')
              .toList();

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpecificJobPage(
                    jobId: job['id'].toString(),
                    specializationId: job['specialization']['id'].toString(),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job Title: ${job['title']}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Client Name: ${job['client']['name']}'),
                    Text('Specialization: ${job['specialization']['name']}'),
                    Text('Description: ${job['description']}'),
                    Text('Expected Budget: \$${job['expected_budget']}'),
                    Text('Expected Duration: ${job['expected_duration']} days'),
                    Text('Location: ${job['address']}'),
                    SizedBox(height: 10),
                    Text('Required Skills:'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: job['required_skills'].map<Widget>((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: Colors.blueGrey[100],
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    Text('Attachments:'),
                    if (job['attachments'] != null &&
                        job['attachments'].isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: job['attachments'].map<Widget>((attachment) {
                          return Text(attachment);
                        }).toList(),
                      ),
                    SizedBox(height: 10),
                    Text('Hired Applications:'),
                    Column(
                      children: hiredApplications.map<Widget>((app) {
                        return ListTile(
                          title:
                          Text('Freelancer: ${app['freelancer']['name']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bid: \$${app['bid']}'),
                              Text('Duration: ${app['duration']} days'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    ...job['reqeusts'].map<Widget>((request) {
                      return GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) =>
                              buildRequestDialog(context, request),
                        ),
                        child: Text(
                          'There is a request to ${request['type']}',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      );
                    }).toList(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.rate_review),
                          onPressed: () {
                            showRatingDialog(context, job['id']);
                          },
                        ),
                      ],
                    ),
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