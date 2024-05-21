import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> wishlistJobs = [];
  int id = 0;

  @override
  void initState() {
    super.initState();
    _fetchWishlistJobs();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchWishlistJobs() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        print('No token found');
        return;
      }

      final response = await http.get(
        Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/bookmarks'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          wishlistJobs = jsonDecode(response.body)['data'];
        });
      } else {
        print(
            'Failed to fetch wishlist jobs. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: ListView.builder(
        itemCount: wishlistJobs.length,
        itemBuilder: (context, index) {
          final bookid = wishlistJobs[index]['id'];
          final job = wishlistJobs[index]['job'];
          final requiredSkills = job['required_skills'];
          final requiredSkillsText = requiredSkills != null
              ? 'Skills: ${requiredSkills.join(', ')}'
              : 'Skills: None';
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      job['title'],
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF343ABA),
                      ),
                    ),
                  ),
                  // Add your IconButton here
                  SizedBox(
                    width: 30, // Adjust the width as needed
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      String? token = prefs.getString('token');

                      if (token == null) {
                        print('No token found');
                        return;
                      }

                      try {
                        final deleteResponse = await http.delete(
                          Uri.parse(
                              'https://snapwork-133ce78bbd88.herokuapp.com/api/bookmarks/$bookid'),
                          headers: {
                            'Authorization': 'Bearer $token',
                          },
                        );

                        if (deleteResponse.statusCode == 200) {
                          // Remove the job from the wishlist locally
                          setState(() {
                            wishlistJobs.removeAt(index); // Remove from UI list
                          });

                          // Remove the job from the original list fetched from the server
                          setState(() {
                            wishlistJobs = List.from(wishlistJobs)
                              ..removeWhere(
                                      (element) => element['id'] == bookid);
                          });

                          print('Job removed from wishlist');
                        } else {
                          print(
                              'Failed to remove job from wishlist: ${deleteResponse.body}');
                        }
                      } catch (e) {
                        print('Error: $e');
                      }
                    },
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['description'],
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    requiredSkillsText,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Budget: \$${job['expected_budget']}'),
                  Text('Duration: ${job['expected_duration']} days'),
                ],
              ),
              onTap: () {
                // Handle tapping on the job card if needed
              },
            ),
          );
        },
      ),
    );
  }
}