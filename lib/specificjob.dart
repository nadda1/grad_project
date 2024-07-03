import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'messaging.dart';

class SpecificJobPage extends StatefulWidget {
  final String jobId;
  final String specializationId;

  SpecificJobPage(
      {Key? key, required this.jobId, required this.specializationId})
      : super(key: key);

  @override
  _SpecificJobPageState createState() => _SpecificJobPageState();
}

class _SpecificJobPageState extends State<SpecificJobPage> {
  Map<String, dynamic> jobDetails = {};
  Map<String, dynamic> freelancer = {};
  String? userIDjob;
  String? userRole;
  String? userid;
  String? jobstatus;
  int freelancer_id = 0;

  @override
  void initState() {
    super.initState();
    fetchJobDetails();
    _loadUserRole();
    _loadUserid();
  }

  Future<List<dynamic>> fetchFreelancers() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse(
            'https://snapwork-133ce78bbd88.herokuapp.com/api/freelancers/${widget.specializationId}'),
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

  Future<List<dynamic>> fetchRelativeFreelancers() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse(
            'https://snapwork-133ce78bbd88.herokuapp.com/api/prev-freelancers'),
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
        Uri.parse(
            'https://snapwork-133ce78bbd88.herokuapp.com/api/invitations'),
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invitation sent successfully!")));
      } else {
        var responseBody = json.decode(response.body);
        var errorMessage = responseBody['message'];
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  Future<void> hireFreelancer(String jobSlug, String applicationSlug) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Authentication error. Please log in again.")));
      return;
    }

    final response = await http.put(
      Uri.parse(
          'https://snapwork-133ce78bbd88.herokuapp.com/api/hire/$jobSlug/$applicationSlug'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      fetchJobDetails();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Freelancer hired successfully!")));
    } else {
      var responseBody = json.decode(response.body);
      var error = responseBody['message'];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void showFreelancersPopup(BuildContext context) async {
    List<dynamic> freelancers = await fetchFreelancers();

    // Sort freelancers by total_average_rating in descending order
    freelancers.sort((a, b) {
      double ratingA = (a['user']['total_average_rating'] ?? 0).toDouble();
      double ratingB = (b['user']['total_average_rating'] ?? 0).toDouble();
      return ratingB.compareTo(ratingA);
    });

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

                return buildFreelancerTile(freelancer);
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

  void showRelativeFreelancersPopup(BuildContext context) async {
    List<dynamic> freelancerss = await fetchRelativeFreelancers();

    // استخدام مجموعة Set لتتبع المعرفات التي تمت معالجتها
    Set<String> processedIds = Set();

    List<dynamic> uniqueFreelancers = [];

    // ترشيح المستقلين لإزالة المكررات
    for (var freelancer in freelancerss) {
      if (!processedIds.contains(freelancer['id'].toString())) {
        uniqueFreelancers.add(freelancer);
        processedIds.add(freelancer['id'].toString());
      }
    }

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
              itemCount: uniqueFreelancers.length,
              itemBuilder: (BuildContext context, int index) {
                var freelancer = uniqueFreelancers[index];

                return buildRelativeFreelancerTile(freelancer);
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

  Widget buildFreelancerTile(Map<String, dynamic> freelancer) {
    double totalAverageRating =
    (freelancer['user']['total_average_rating'] ?? 0).toDouble();

    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(
          'Name: ${freelancer['user']['name'] ?? 'No data'}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender: ${freelancer['user']['gender'] ?? 'No data'}\nEmail: ${freelancer['user']['email'] ?? 'No data'}',
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Rating:'),
                RatingBarIndicator(
                  rating: totalAverageRating,
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: Axis.horizontal,
                ),
                if (totalAverageRating > 2 && totalAverageRating <= 3)
                  Image.asset(
                    'assets/images/bronze-medal.png',
                    height: 50.0,
                  ),
                if (totalAverageRating > 3 && totalAverageRating <= 4)
                  Image.asset(
                    'assets/images/silver-medal.png',
                    height: 50.0,
                  ),
                if (totalAverageRating > 4 && totalAverageRating < 5)
                  Image.asset(
                    'assets/images/medal.png',
                    height: 50.0,
                  ),
                if (totalAverageRating == 5)
                  Image.asset(
                    'assets/images/trophy.png',
                    height: 50.0,
                  ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            sendInvitation(freelancer['user']['id'].toString());
          },
          child: Text(
            'Invite',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF69C26A), // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget buildRelativeFreelancerTile(Map<String, dynamic> freelancer) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(
          'Name: ${freelancer['name'] ?? 'No data'}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender: ${freelancer['gender'] ?? 'No data'}\nEmail: ${freelancer['email'] ?? 'No data'}',
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            sendInvitation(freelancer['id'].toString());
          },
          child: Text(
            'Invite',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF69C26A), // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }

  Future<void> submitApplication(String bid, String duration,
      String coverLetter, BuildContext context) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Freelancer hired successfully!")));
    } else {
      var responseBody = json.decode(response.body);
      var error = responseBody['message'];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
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
        Uri.parse(
            'https://snapwork-133ce78bbd88.herokuapp.com/api/jobs/${widget.jobId}'),
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
                  submitApplication(bidController.text, durationController.text,
                      coverLetterController.text, context);

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
      color: Color.fromARGB(255, 255, 255, 255), // White background color
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skills',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0), // Space between title and chips
            Wrap(
              spacing: 6.0, // Horizontal space between chips
              runSpacing: 6.0, // Vertical space between chips
              children: skills
                  .map((skill) => Chip(
                label:
                Text(skill, style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.white,
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(String attributeName, String? details) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white, // Background color set to white
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attributeName,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontFamily: 'CustomFont',
              ), // Attribute name in grey
            ),
            SizedBox(height: 4.0),
            Text(
              details ?? 'N/A',
              style: TextStyle(color: Color(0xFF333333)), // Value in black
              softWrap: true, // Allow text to wrap
              overflow: TextOverflow.visible, // Ensure text is visible
            ),
          ],
        ),
      ),
    );
  }

  Widget buildApplicationCard(
      String freelancer,
      int id,
      String bid,
      String duration,
      String coverLetter,
      String applicationSlug,
      Map<String, dynamic> freelancerDetails) {
    double averageRating =
        freelancerDetails['total_average_rating']?.toDouble() ?? 0.0;
    List<dynamic> comments = freelancerDetails['comments'] ?? [];

    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Details of $freelancer'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${freelancerDetails['name'] ?? 'no data'}'),
                    Text('Email: ${freelancerDetails['email'] ?? 'no data'}'),
                    Text(
                        'Skills: ${freelancerDetails['skills'].map((skill) => skill['name']).join(', ') ?? 'no data'}'),
                    SizedBox(height: 10),
                    Text('Rating:'),
                    RatingBarIndicator(
                      rating: averageRating,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                  ],
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
        title: Text('Freelancer: $freelancer',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bid: \$$bid', style: TextStyle(color: Colors.black)),
            Text('Duration: $duration days',
                style: TextStyle(color: Colors.black)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Cover Letter: $coverLetter',
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        trailing: userid == userIDjob && userRole == "client"
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () =>
                  hireFreelancer(jobDetails['slug'], applicationSlug),
              child:
              Text(' Hire ', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Color(0xFF69C26A), // New color for "Hire" button
              ),
            ),
            SizedBox(width: 8), // Add some spacing between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to message page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MessagePage(userid: id, username: freelancer),
                    // Replace MessagePage with your message page
                  ),
                );
              },
              child:
              Text('Contact', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Color(0xFF87AFCC), // New color for "Contact" button
              ),
            ),
          ],
        )
            : SizedBox.shrink(),
      ),
    );
  }

  Widget buildApplicationCardForFreelance(
      String freelancer, String coverLetter) {
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
        title: Text('Freelancer: $freelancer',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Cover Letter: $displayText',
                  style: TextStyle(color: Colors.black)),
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
        backgroundColor: Color.fromARGB(255, 242, 242, 242), // Original color
        title: Text(
          'Job Tracking',
          style: TextStyle(
            color: Color(0xFF343ABA), // Blue color for the title
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            if (jobDetails.containsKey('title'))
              buildCard('Title', jobDetails['title'] ?? 'N/A'),
            if (jobDetails.containsKey('address'))
              buildCard('Location',
                  jobDetails['address'] ?? 'Location not available'),
            if (jobDetails.containsKey('expected_budget'))
              buildCard(
                  'Expected Budget', '\$${jobDetails['expected_budget']}'),
            if (jobDetails.containsKey('description'))
              buildCard('Description',
                  jobDetails['description'] ?? 'Description not available'),
            if (jobDetails.containsKey('required_skills') &&
                jobDetails['required_skills'] is List)
              buildSkillsCard(jobDetails['required_skills'])
            else
              buildCard('Required Skills',
                  'Skills not specified or incorrect format'),
            if (userRole == 'client' &&
                userid == userIDjob &&
                jobstatus != "hired")
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => showFreelancersPopup(context),
                      color: Color(0xFF28A745), // Green color
                    ),
                    SizedBox(width: 8), // Add spacing between icon and text
                    Text(
                      'Find Collaborators', // Updated button name
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF28A745), // Green color
                      ),
                    ),
                  ],
                ),
              ),
            // Add new button here
            if (userRole == 'client' &&
                userid == userIDjob &&
                jobstatus != "hired")
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.person_search),
                      onPressed: () => showRelativeFreelancersPopup(context),
                      color: Color(0xFF28A745), // Green color
                    ),
                    SizedBox(width: 8), // Add spacing between icon and text
                    Text(
                      'Invite Past Collaborators',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF28A745), // Green color
                      ),
                    ),
                  ],
                ),
              ),
            if (userRole == 'freelancer' && jobstatus != "hired")
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE04F35), // Red color
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => showApplicationDialog(context),
                    child: Text(
                      'Apply for a Job',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            if (jobDetails.containsKey('applications'))
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'The Applicants',
                  style: TextStyle(
                    color: Color(0xFF343ABA),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (userRole == 'client' && jobDetails.containsKey('applications'))
              if (jobDetails['applications'].isEmpty)
                Card(
                  color: Colors.grey[200],
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No applicants yet',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...jobDetails['applications']
                    .map((application) => buildApplicationCard(
                  application['freelancer']['name'] ?? 'N/A',
                  application['freelancer']['id'] ?? 0,
                  application['bid'].toString() ?? '0',
                  application['duration'].toString() ?? '0',
                  application['cover_letter'] ?? 'N/A',
                  application['slug'] ?? 'N/A',
                  application['freelancer'] ??
                      'N/A', // Pass the entire freelancer object
                ))
                    .toList(),
            if (userRole == 'freelancer' &&
                jobDetails.containsKey('applications'))
              ...jobDetails['applications']
                  .map((application) => buildApplicationCardForFreelance(
                application['freelancer']['name'] ?? 'N/A',
                application['cover_letter'] ?? 'N/A',
              ))
                  .toList(),
          ],
        ),
      ),
    );
  }
}
