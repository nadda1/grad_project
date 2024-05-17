import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:grad_project/recommendtion.dart';
import 'package:grad_project/wishlist.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Messaging.dart';
import 'Search.dart';
import 'specificjob.dart';
import 'profile.dart';
import 'post.dart';
Container Jobs(String imagePath, String title, String id, Function(String) onTap) {
  return Container(
    width: 150.0,
    child: GestureDetector(
      onTap: () => onTap(id),
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
  late TextEditingController _locationController;
  String? userRole;
  List<dynamic> jobList = [];
  List<dynamic> filteredJobs = [];
  int currentPage = 1;
  List<Widget> jobCards = [];
  String lastAction = 'all';


  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _locationController = TextEditingController();
    _searchController.addListener(_filterJobs);
    _loadUserRole();
    fetchJobs();
  }
  void refreshJobList() {
    fetchJobs(); // Assuming fetchJobs is the method that fetches all jobs
  }

  Future<void> fetchJobs({String specializationId = '', int page = 1, bool fetchAll = false}) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/jobs/specialization/$specializationId?page=$page';

  if (specializationId.isEmpty) {
    url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/jobs/specialization?page=$page';
  }

  if (token != null) {
    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var currentPageData = json.decode(response.body)['data'];
      if (fetchAll || page == 1) {
        jobList.clear();  // Clear the job list before adding new data
      }
      jobList.addAll(currentPageData); // Append new jobs to the list
      currentPage = page; // Update the current page

      setState(() {
        lastAction = 'all'; // Update last action to 'all'
        filteredJobs = List.from(jobList); // Update filtered jobs based on the complete list
      });
    } else {
      print('Failed to fetch jobs');
    }
  }
}

 Future<void> fetchData(String specializationId, {int page = 1}) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> skills = prefs.getStringList('user_skills') ?? ["html","css","js"]; // Provide a default skill if none found

  final String apiUrl = 'https://1nadda.pythonanywhere.com/recommend';

  try {
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'skills': skills, 'page': page}),  // Use dynamic skills
    );

    if (response.statusCode == 200) {
      String responseBody = response.body;
      List<dynamic> recommendedJobs = jsonDecode(responseBody)["recommended_jobs"];
      print(skills);

      setState(() {
        lastAction = 'recommended'; // Update last action to 'recommended'
        jobList = recommendedJobs;  // Update the main job list
        filteredJobs = List.from(jobList);  // Filtered jobs are now the same as job list
        buildJobCardsFromRecommendedJobs(recommendedJobs);  // Optionally build job cards
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

  void buildJobCardsFromRecommendedJobs(List<dynamic> recommendedJobs) {
    setState(() {
      jobCards = recommendedJobs.map<Widget>((job) {
        return Card(
          child: ListTile(
            title: Text(job[1]), // Job title
            subtitle: Text(job[3]), // Job description
          ),
        );
      }).toList();
    });
  }




  void _filterJobs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredJobs = jobList.where((job) {
        return job['title'].toLowerCase().contains(query);
      }).toList();
    });
  }

  String calculateDistance(String? userLatStr, String? userLongStr, String? jobLatStr, String? jobLongStr) {
    if (userLatStr == null || userLongStr == null || userLatStr.isEmpty || userLongStr.isEmpty ||
        jobLatStr == null || jobLongStr == null) {
      return 'Location not set';
    } else {
      final double userLat = double.tryParse(userLatStr) ?? 0.0;
      final double userLong = double.tryParse(userLongStr) ?? 0.0;
      final double jobLat = double.tryParse(jobLatStr) ?? 0.0;
      final double jobLong = double.tryParse(jobLongStr) ?? 0.0;

      double distanceInMeters = Geolocator.distanceBetween(userLat, userLong, jobLat, jobLong);
      return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
    }
  }

  void _calculateDistanceForAllJobs(String latStr, String longStr) {
    if (jobList.isEmpty) {
      fetchJobs(fetchAll: true).then((_) {
        applyDistanceFilter(latStr, longStr);
      });
    } else {
      applyDistanceFilter(latStr, longStr);
    }
  }
  void applyDistanceFilter(String latStr, String longStr) {
    setState(() {
      filteredJobs = jobList.map((job) {
        job['distance'] = calculateDistance(latStr, longStr, job['latitude'] as String?, job['longitude'] as String?);
        return job;
      }).toList();

      filteredJobs.sort((a, b) {
        String distanceA = a['distance'];
        String distanceB = b['distance'];

        double distanceANumeric = distanceA == 'Location not set' ? double.infinity : double.parse(distanceA.split(' ')[0]);
        double distanceBNumeric = distanceB == 'Location not set' ? double.infinity : double.parse(distanceB.split(' ')[0]);

        return distanceANumeric.compareTo(distanceBNumeric);
      });
    });
  }





  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }




  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role');
    });
  }

  void _showLocationPicker(BuildContext context) async {
    LatLng selectedLocation = LatLng(0, 0);

    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Location"),
          content: Container(
            height: 300,
            width: 300,
            child: FlutterMap(
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
              ],
              options: MapOptions(
                center: LatLng(currentPosition.latitude, currentPosition.longitude),
                zoom: 13.0,
                onTap: (_, position) {
                  selectedLocation = position;
                  _locationController.text = "${selectedLocation.latitude}, ${selectedLocation.longitude}";
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                _calculateDistanceForAllJobs(selectedLocation.latitude.toString(), selectedLocation.longitude.toString());
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Container locationInputField() {
    return Container(
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
            child: TextField(
              //controller: _searchController,
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
              onSubmitted: (String value) {
                print("submit");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(searchQuery: value),
                  ),
                );
              },
            ),
          ),

          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'nearest jobs for you',
                prefixIcon: Icon(Icons.place),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              _showLocationPicker(context);
            },
            color: Colors.white,
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                icon: Icon(Icons.message, color: Color(0xFF343ABA), size: 26.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(),
                    ),
                  );
                },
              ),
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
              'Find Your Job',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF343ABA),
              ),
            ),
          ),
          locationInputField(),
          SizedBox(height: 15.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Jobs("all-inclusive.png", "all jobs", "", (id) => fetchJobs(specializationId: id)),
                  Jobs("social-media.png", "Recommended", "", (id) => fetchData(id)),
                  Jobs("coffee.png", "web", "1", (id) => fetchJobs(specializationId: id)),
                  Jobs("delivery-man.png", "mobile", "2", (id) => fetchJobs(specializationId: id)),
                  Jobs("baby.png", "graphic", "3", (id) => fetchJobs(specializationId: id)),
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
  child: ListView.builder(
    itemCount: filteredJobs.length,
    itemBuilder: (context, index) {
      if (index >= filteredJobs.length) {
        return Container(); // Safeguard against out of range errors
      }
      var job = filteredJobs[index];
      String formattedDate = job['created_at'] != null ? formatDate(job['created_at']) : 'Not available';
      List<String> userCoords = _locationController.text.split(',');
      String distance = 'Location not set';
      String message = job['status'] == "hired" ? 'this job is expired' : '';

      if (userCoords.length > 1 && userCoords[0].trim().isNotEmpty && userCoords[1].trim().isNotEmpty) {
        distance = calculateDistance(
          userCoords[0].trim(),  // User latitude
          userCoords[1].trim(),  // User longitude
          job['latitude'] as String?,  // Job latitude
          job['longitude'] as String?  // Job longitude
        );
        double distanceNumeric = double.tryParse(distance.split(' ')[0]) ?? double.infinity;
        distance = distanceNumeric < 20.0 ? '$distance: Close to you, suit you' : distance;
      }

      return InkWell(
        onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpecificJobPage(
              jobId: job['id'].toString(),
              specializationId: job['specialization']?['id']?.toString() ?? '1',
            ),
          ),
        );
      },

        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
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
                SizedBox(width: 30),  // Spacer
                FavIconButton(
                  job: job,
                  isBookmarked: true,  // Assume this state is dynamic and can change
                  updateUI: () => setState(() {}),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['description'],
                  style: TextStyle(color: Colors.black87),
                ),
                Text(
                  'Created at: $formattedDate',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'Distance: $distance',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: Text(
              'Budget: ${job['expected_budget']} \$',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ),
      );
    },
  ),
),

               Center(
                child: TextButton(
                    onPressed: () {
                        if (lastAction == 'all') {
                            fetchJobs(page: currentPage + 1);
                        } else if (lastAction == 'recommended') {
                            fetchData('', page: currentPage ); // Assume fetchData can handle empty ID and page
                        }
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    child: Text('Load More', style: TextStyle(fontSize: 18)),
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
              child: Text('Settings'),
            ),
            ListTile(
              title: Text('Wishlist'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WishlistPage()));

              },
            ),
            ListTile(
              title: Text('Log out'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Change password'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Recommendation'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RecommendedJobsWidget()));
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
            if (userRole == 'client')
              IconButton(
                icon: Icon(Icons.add, color: Color(0xFF343ABA)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Post(
                        onJobPosted: refreshJobList, // Pass the callback here
                      ),
                    ),
                  );
                },
              ),
            IconButton(
              icon: Icon(Icons.account_circle_outlined, color: Color(0xFF343ABA)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
            ),

          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }


}
class FavIconButton extends StatefulWidget {
  final Map<String, dynamic> job;
  final bool isBookmarked; // New property to indicate if the job is bookmarked
  final Function() updateUI;

  FavIconButton({required this.job, required this.isBookmarked, required this.updateUI});

  @override
  _FavIconButtonState createState() => _FavIconButtonState();
}

class _FavIconButtonState extends State<FavIconButton> {
  bool isFavorited = false;
  List<dynamic> wishlistJobs = [];
  bool _isDisposed = false; // Track whether the widget is disposed

  @override
  void initState() {
    super.initState();
    _fetchWishlistJobs();

    isFavorited = checkfav();
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
        print('Failed to fetch wishlist jobs. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  bool checkfav() {
    var bookmark = wishlistJobs.firstWhere((bookmark) => bookmark['job']['id'] == widget.job['id'], orElse: () => null);
    if (bookmark != null) {
      isFavorited = true;
    }
    return isFavorited;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorited ? Icons.favorite : Icons.favorite_border,
        color: isFavorited ? Colors.red : Colors.black, // Set color based on favorited state
      ),
      onPressed: () async {
        // Check if the job is already in the wishlist
        checkfav();

        // If the job is already in the wishlist, do nothing
        if (isFavorited) {
          _showMessageDialog(context, 'Already in bookmarks');
        }

        final prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        if (token == null) {
          print('No token found');
          return;
        }

        int jobId = widget.job['id'] as int;
        String url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/bookmarks';

        Map<String, String> headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        };

        final postResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(<String, int>{'job_id': jobId}),
        );

        if (postResponse.statusCode == 201) {
          print('Job added to bookmarks');
          _showMessageDialog(context, 'Job added to bookmarks');
          setState(() {
            isFavorited = true; // Update favorited state
          });
        } else if (postResponse.statusCode == 422) {
          print('Job already in bookmarks');
          _showMessageDialog(context, 'Already in bookmarks');
          setState(() {
            isFavorited = true;
          });
        } else {
          isFavorited = false;
          print('Failed to add job to bookmarks. Response: ${postResponse.body}');
        }
      },
    );
  }

  void _showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bookmark Status"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true; // Set disposed flag
    super.dispose();
  }
} 