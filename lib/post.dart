import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adjusted padding
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align labels to the left
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Job Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align labels vertically
                        children: [
                          Text(
                            'Description:',
                            style: TextStyle(fontSize: 14.0,color: Color(0xFF343ABA),),
                          ),],
                      ),

                      SizedBox(width: 50),
                          Row(
                            children :[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFD0DCF2),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: TextField(
                                maxLines: 5, // Adjust this as needed
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'Enter job description...',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Job Title:',
                            style: TextStyle(fontSize: 14.0,color: Color(0xFF343ABA),),

                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFD0DCF2),
                                hintText: 'Enter job title...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,

                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height:20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time:',
                            style: TextStyle(fontSize: 14.0,color: Color(0xFF343ABA),),

                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFD0DCF2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,

                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Salary per Hour:',
                            style: TextStyle(fontSize: 14.0,color: Color(0xFF343ABA),),

                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFD0DCF2),
                                hintText: 'Enter wage (optional)',
                                border: OutlineInputBorder(

                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,

                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xFF343ABA),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement post functionality
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF5C8EF2)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
              ),
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}