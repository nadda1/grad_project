import 'package:flutter/material.dart';
import 'data.dart'; // Assuming you have the JobData here
import 'user.dart'; // Assuming you have the UserData here
import 'apply.dart';
import 'userprofile.dart';
class JobsList extends StatefulWidget {
  final List<Map<String, dynamic>> jobData; // Updated to dynamic

  JobsList({required this.jobData});
  @override
  _JobsListState createState() => _JobsListState();
}

class _JobsListState extends State<JobsList> {
  int _visibleItems = 3;
  List<Map<String, dynamic>> wishlist = []; // Updated to dynamic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _visibleItems + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == _visibleItems) {
            return Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xFF5C8EF2)),
                ),
                onPressed: () {
                  setState(() {
                    _visibleItems += 3;
                  });
                },
                child: Text('Show More'),
              ),
            );
          } else {
            return GestureDetector(
              onTap: () {
                _showJobDetailsDialog(widget.jobData[index]);
              },
              child: Container(
                padding: EdgeInsets.all(7.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.jobData[index]['name']!,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF343ABA),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                wishlist.contains(widget.jobData[index])
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (!wishlist.contains(
                                      widget.jobData[index])) {
                                    wishlist.add(widget.jobData[index]);
                                  } else {
                                    wishlist.remove(widget.jobData[index]);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Price: ${widget.jobData[index]['price']} LE/Hour',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5C8EF2),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Time: ${widget.jobData[index]['time']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5C8EF2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showJobDetailsDialog(Map<String, dynamic> job) {
    String userId = job['userId'] ?? ''; // Get userId from job data

    // Find user details based on userId
    Map<String, dynamic>? userData = UserData.firstWhere(
          (user) => user['userId'] == userId,
    );

    if (userData != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(job['name']!),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      // Navigate to user profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfile(userId: userId),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(userData['avatar'] ??
                              ''),
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          '${userData['firstName']} ${userData['lastName']}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Description: ${job['description']}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Price: ${job['price']} LE/Hour',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF343ABA),
                    ),
                  ),
                  Text(
                    'Time: ${job['time']}',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF343ABA),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Add your apply for job logic here
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ApplyPage()),
                  );
                },
                child: Text('Apply'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }
}
