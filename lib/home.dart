import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _locationController = TextEditingController();
    _searchController.addListener(_filterJobs);
    _loadUserRole();
    fetchJobs();
  }
void _calculateDistanceForAllJobs(String latStr, String longStr) {
  setState(() {
    filteredJobs = filteredJobs.map((job) {
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

  void _filterJobs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredJobs = jobList.where((job) {
        return job['title'].toLowerCase().contains(query);
      }).toList();
    });
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

Future<void> fetchJobs({String specializationId = ''}) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String url = 'https://snapwork-133ce78bbd88.herokuapp.com/api/jobs/specialization';
  if (specializationId.isNotEmpty) {
    url += '/$specializationId';
  }

  if (token != null) {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        jobList = json.decode(response.body)['data'];
        _filterJobs();
      });
    } else {
      print('Failed to fetch jobs');
    }
  }
}


  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role');
    });
  }

  void _showLocationPicker(BuildContext context) async {
  LatLng selectedLocation = LatLng(0, 0);  // Default location

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
          SizedBox(width: 10), // Spacer between search and location fields
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
                Jobs("coffee.png", "all jobs", "", (id) => fetchJobs(specializationId: id)),
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
  var job = filteredJobs[index];
  String formattedDate = job['created_at'] != null ? formatDate(job['created_at']) : 'Not available';
  List<String> userCoords = _locationController.text.split(',');
  String distance = 'Location not set';
  if (userCoords.length > 1 && userCoords[0].trim().isNotEmpty && userCoords[1].trim().isNotEmpty) {
    distance = calculateDistance(
      userCoords[0].trim(),  // User latitude
      userCoords[1].trim(),  // User longitude
      job['latitude'] as String?,  // Job latitude
      job['longitude'] as String?  // Job longitude
    );
     double distanceNumeric = double.tryParse(distance.split(' ')[0]) ?? double.infinity;
  if (distanceNumeric < 20.0) {
    distance = '$distance: Close to you, suit you';
  }
  else{
    distance = '$distance';
  }
    
  }
  return InkWell(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SpecificJobPage(jobId: job['id'].toString()),
      ));
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
        title: Text(
          job['title'],
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job['description'],
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            Text(
              'Created at: $formattedDate',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
             Text(
            'Distance: ${distance}',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            ),
          ],
        ),
        trailing: Text(
          'Budget: ${job['expected_budget']} \$',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          ),
        ),
      ),
    );
  },
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
                Navigator.pop(context);
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Post()));
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
