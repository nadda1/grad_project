import 'package:flutter/material.dart';
import 'package:grad_project/user.dart';

class UserProfile extends StatelessWidget {
  final String userId;

  const UserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find user details based on userId
    Map<String, dynamic>? userData = UserData.firstWhere(
          (user) => user['userId'] == userId,
      // Return null if user not found
    );

    if (userData != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${userData['firstName']} ${userData['lastName']}'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Color(0xFFB1CAF8),
              padding: EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userData['avatar'] ?? ''),
                    radius: 40.0,
                  ),
                  SizedBox(width: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 20.0),
                      Text(
                        ' ${userData['firstName']} ${userData['lastName']}',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),


                    ],
                  ),
                ],
              ),
            ),
             // Add some space between avatar and summary
            Container(
              height: 100,
              color: Color(0xFFD9D9D9),
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                ],
              ),
            ),
            SizedBox(height: 20.0), // Add some space between summary and history section
            Expanded(
              child: Container(
                color: Colors.white, // Change the color if needed
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary:',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${userData['summary']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'History',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.0),
                    // Add your history section widgets here
                    // For example:
                    // Text('History section content goes here'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('User Not Found'),
        ),
        body: Center(
          child: Text('User with ID: $userId not found.'),
        ),
      );
    }
  }
}
