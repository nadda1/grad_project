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

  Future<String> sendRating(int jobId, List<Map<String, dynamic>> rates,
      String comment) async {
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
                  builder: (context) =>
                      SpecificJobPage(
                        jobId: job['id'].toString(),
                        specializationId: job['specialization']['id']
                            .toString(),
                      ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: EdgeInsets.all(10),
              // color: Color.fromARGB(255, 224, 228, 234),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Job Title: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SerifFont',
                                  color: Colors
                                      .blueGrey, // Changed to blue grey
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  job['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'SerifFont',
                                    color: Colors.black, // Changed to black
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: Icon(Icons.notifications),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NotificationPage(
                                      requests: job['reqeusts'],
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Client Name: ',
                          style: TextStyle(
                            fontFamily: 'SerifFont',
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,// Changed to blue grey
                          ),
                        ),
                        Expanded(
                          child: Text(
                            job['client']['name'],
                            style: TextStyle(
                              fontFamily: 'SerifFont',
                              color: Colors.black, // Changed to black
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Specialization: ',
                          style: TextStyle(
                            fontFamily: 'SerifFont',
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,// Changed to blue grey
                          ),
                        ),
                        Expanded(
                          child: Text(
                            job['specialization']['name'],
                            style: TextStyle(
                              fontFamily: 'SerifFont',
                              color: Colors.black, // Changed to black
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Description: ',
                          style: TextStyle(
                            fontFamily: 'SerifFont',
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,// Changed to blue grey
                          ),
                        ),
                        Expanded(
                          child: Text(
                            job['description'],
                            style: TextStyle(
                              fontFamily: 'SerifFont',
                              color: Colors.black,

                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Expected Budget: ',
                          style: TextStyle(
                            fontFamily: 'SerifFont',
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,// Changed to blue grey
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${job['expected_budget']}',
                            style: TextStyle(
                              fontFamily: 'SerifFont',
                              color: Colors.green, // Changed to black
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Expected Duration: ',
                          style: TextStyle(
                            fontFamily: 'SerifFont',
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,// Changed to blue grey
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${job['expected_duration']} days',
                            style: TextStyle(
                              fontFamily: 'SerifFont',
                              color: Colors.green, // Changed to black
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Location: ',
                          style: TextStyle(
                            fontFamily: 'SerifFont',
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            job['address'],
                            style: TextStyle(
                              fontFamily: 'SerifFont',
                              color: Colors.black, // Changed to black
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Text(
                    //   'Required Skills:',
                    //   style: TextStyle(
                    //     fontFamily: 'SerifFont',
                    //     color: Colors.blueGrey, // Changed to blue grey
                    //   ),
                    // ),
                    // Wrap(
                    //   spacing: 8.0,
                    //   runSpacing: 4.0,
                    //   children: job['required_skills'].map<Widget>((skill) {
                    //     return Chip(
                    //       label: Text(
                    //         skill,
                    //         style: TextStyle(fontFamily: 'SerifFont'),
                    //       ),
                    //       backgroundColor: Colors.blueGrey[100],
                    //     );
                    //   }).toList(),
                    // ),
                    // SizedBox(height: 10),
                    if (job['attachments'] != null &&
                        job['attachments'].isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attachments:',
                            style: TextStyle(
                              fontFamily: 'SerifFont',
                              color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...job['attachments'].map<Widget>((attachment) {
                            return Text(
                              attachment,
                              style: TextStyle(
                                fontFamily: 'SerifFont',
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold// Changed to black
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    SizedBox(height: 10),
                    if (hiredApplications != null &&
                        hiredApplications.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hired Applications:',style: TextStyle(
                            fontFamily: 'SerifFont',
                            color: Colors.blueGrey, // Changed to blue grey
                          ),),
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
                        ],
                      ),
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



class NotificationPage extends StatefulWidget {
  final List requests;

  NotificationPage({required this.requests});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = List<bool>.filled(widget.requests.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',

        ),
        backgroundColor: Color.fromARGB(255, 242, 242, 242),
      ),
      body: ListView.builder(
        itemCount: widget.requests.length,
        itemBuilder: (context, index) {
          final request = widget.requests[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  title: GestureDetector(
                    onTap: () {
                      setState(() {
                        _expanded[index] = !_expanded[index];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'There is a request to ${request['type']}',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_expanded[index])
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${request['type']}'),
                        Text('New Bid: \$${request['new_bid'] ?? 'No change'}'),
                        Text('New Duration: ${request['new_duration'] ?? 'No change'} days'),
                        ButtonBar(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                bool success = await acceptRequest(context, request['id']);
                                String message = success
                                    ? 'Request accepted successfully.'
                                    : 'Failed to accept request.';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              },
                              child: Text('Accept',style: TextStyle(
                                color: Colors.white,
                              ),),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                bool success = await declineRequest(context, request['id']);
                                String message = success
                                    ? 'Request declined.'
                                    : 'Failed to decline request.';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              },
                              child: Text('Decline',style: TextStyle(
                                color: Colors.white,
                              ),),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
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
}