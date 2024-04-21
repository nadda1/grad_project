import 'package:flutter/material.dart';
import 'package:grad_project/profile.dart';
import 'JobsList.dart';
import 'data.dart';
import 'post.dart';
import 'package:shared_preferences/shared_preferences.dart';

Container Jobs(String imagePath, String title) {
  return Container(
    width: 150.0,
    child: Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/" + imagePath,
              fit: BoxFit.fill,
              height: 50.0,
              width: 40,
            ),
            SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _searchController;
  String? userRole;  // Variable to store user role

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadUserRole();
  }

  void _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to the Scaffold
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10.0, top: 19.0, bottom: 19.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  height: 90,
                  width: 90,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.more_horiz, color: Color(0xFF343ABA), size: 36.0),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17),
            child: Text(
              'Find Your Job ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF343ABA),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(17),
            padding: EdgeInsets.fromLTRB(40, 15, 40, 15),
            decoration: BoxDecoration(
              color: Color(0xFF5C8EF2),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Jobs("coffee.png", "Baresta"),
                  Jobs("delivery-man.png", "Delivery"),
                  Jobs("baby.png", "Babysitting"),
                  Jobs("cooking.png", "cook"),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17),
                  child: Text(
                    'For you',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF343ABA),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: JobsList(jobData: _filterJobs(JobData)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF5C8EF2),
              ),
              child: Text('settings'),
            ),
            ListTile(
              title: Text('Wishlist'),
              onTap: () {
                Navigator.pop(context);
                _showWishlist();
              },
            ),
            ListTile(
              title: Text('log out '),
              onTap: () {
                Navigator.pop(context);
                
              },
            ),
            ListTile(
              title: Text('change password'),
              onTap: () {
                Navigator.pop(context);
                // Add functionality for changing password if needed
              },
            ),
          ],
        ),
      ),
            bottomNavigationBar: BottomAppBar(
        color: Color(0xFFF1F5FC),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Color(0xFF343ABA)),
              onPressed: () {},
            ),
            if (userRole == 'client')  // Conditional rendering based on the user role
              IconButton(
                icon: Icon(Icons.add, color: Color(0xFF343ABA)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Post()));
                },
              ),
            IconButton(
              icon: Icon(Icons.account_circle_outlined, color: Color(0xFF343ABA)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _filterJobs(List<Map<String, String>> jobs) {
    final query = _searchController.text.toLowerCase();
    return jobs.where((job) {
      final name = job['name']!.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  void _showWishlist() {}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}