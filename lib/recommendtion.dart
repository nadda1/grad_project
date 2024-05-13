import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RecommendedJobsWidget extends StatefulWidget {
  @override
  _RecommendedJobsWidgetState createState() => _RecommendedJobsWidgetState();
}

class _RecommendedJobsWidgetState extends State<RecommendedJobsWidget> {
  List<Widget> jobCards = [];

  Future<void> fetchData() async {
    final String apiUrl = 'https://1nadda.pythonanywhere.com/recommend';

    // Fetch skills from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> skills = prefs.getStringList('user_skills') ?? ["default skill"]; // Default skills if none found

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'skills': skills}),
      );

      if (response.statusCode == 200) {
        // Replace "NaN" with null in the response body
        String responseBody = response.body.replaceAll('"NaN"', 'null');

        List<dynamic> jobData = jsonDecode(responseBody)["recommended_jobs"];

        setState(() {
          jobCards = jobData.map<Widget>((job) {
            return Card(
              child: ListTile(
                title: Text(job["title"]), // Job title
                subtitle: Text(job["description"]), // Job description
              ),
            );
          }).toList();
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: jobCards,
    );
  }
}
