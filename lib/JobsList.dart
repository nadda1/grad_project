import 'package:flutter/material.dart';
import 'data.dart';

class JobsList extends StatefulWidget {
  final List<Map<String, String>> jobData;

  JobsList({required this.jobData});
  @override
  _JobsListState createState() => _JobsListState();
}

class _JobsListState extends State<JobsList> {
  int _visibleItems = 3;
  List<Map<String, String>> wishlist = []; // List to store the wishlist items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _visibleItems + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == _visibleItems) {
            return Center(
              child: ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF5C8EF2))
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
            return Container(
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
                                if (!wishlist.contains(widget.jobData[index])) {
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
            );
          }
        },
      ),
    );
  }
}

