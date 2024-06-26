import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class Post extends StatefulWidget {
  final Function onJobPosted;
  Post({Key? key, required this.onJobPosted}) : super(key: key);
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<PlatformFile>? _pickedFiles;
  String _selectedLocationType = 'remote';
  String _selectedJobType = 'open';
  String? _selectedSpecialization;
  List<Map<String, dynamic>> _specializations = [];

  @override
  void initState() {
    super.initState();
    fetchSpecializations();
  }

  Future<void> fetchSpecializations() async {
    final response = await http.get(Uri.parse(
        'https://snapwork-133ce78bbd88.herokuapp.com/api/specializations'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _specializations = List<Map<String, dynamic>>.from(data['data']);
        _selectedSpecialization = _specializations.isNotEmpty
            ? _specializations[0]['id'].toString()
            : null;
      });
    } else {
      print('Failed to load specializations');
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _pickedFiles = result.files;
      });
    } else {
      print('No files selected');
    }
  }

  Future<void> postJob() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return;
    }

    var uri = Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/jobs');
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({'Authorization': 'Bearer $token'})
      ..fields['title'] = _titleController.text
      ..fields['specialization_id'] = _selectedSpecialization!
      ..fields['description'] = _descriptionController.text
      ..fields['expected_budget'] = _budgetController.text
      ..fields['expected_duration'] = _durationController.text
      ..fields['type'] = _selectedJobType
      ..fields['location_type'] = _selectedLocationType
      ..fields['longitude'] = _longitudeController.text
      ..fields['latitude'] = _latitudeController.text
      ..fields['address'] = _addressController.text;

    List<String> skills =
        _skillsController.text.split(',').map((skill) => skill.trim()).toList();
    for (int i = 0; i < skills.length; i++) {
      request.fields['required_skills[$i]'] = skills[i];
    }

    if (_pickedFiles != null) {
      for (var file in _pickedFiles!) {
        request.files.add(await http.MultipartFile.fromPath(
          'attachments[]',
          file.path!,
          contentType: MediaType('application', 'octet-stream'),
        ));
      }
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      showSuccessDialog('Job posted successfully.');
      widget.onJobPosted();
    } else {
      try {
        Map<String, dynamic> decodedResponseBody = jsonDecode(responseBody);
        String errorMessage = decodedResponseBody['message']?.toString() ??
            'Unknown error occurred.';
        showErrorDialog(errorMessage);
      } catch (e) {
        showErrorDialog('Failed to parse error message. Please try again.');
      }
    }
  }

  void _showLocationPicker() async {
    LatLng selectedLocation = LatLng(0, 0); // Default location
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

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
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
              ],
              options: MapOptions(
                center:
                    LatLng(currentPosition.latitude, currentPosition.longitude),
                zoom: 18.0,
                onTap: (_, position) {
                  selectedLocation = position; // Update location on tap
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                setState(() {
                  _longitudeController.text =
                      selectedLocation.longitude.toString();
                  _latitudeController.text =
                      selectedLocation.latitude.toString();
                });
                Navigator.of(context).pop();
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

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: 'Job Title', hintText: 'Enter job title'),
              ),
              if (_specializations.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedSpecialization,
                  decoration: InputDecoration(
                    labelText: 'Specialization',
                    hintText: 'Select specialization',
                  ),
                  items: _specializations.map((specialization) {
                    return DropdownMenuItem<String>(
                      value: specialization['id'].toString(),
                      child: Text(specialization['name']),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSpecialization = newValue!;
                    });
                  },
                ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter job description'),
              ),
              TextField(
                controller: _skillsController,
                decoration: InputDecoration(
                    labelText: 'Required Skills',
                    hintText: 'Enter required skills, separated by commas'),
              ),
              TextField(
                controller: _budgetController,
                decoration: InputDecoration(
                    labelText: 'Expected Budget',
                    hintText: 'Enter expected budget'),
              ),
              TextField(
                controller: _durationController,
                decoration: InputDecoration(
                    labelText: 'Expected Duration (days)',
                    hintText: 'Enter expected duration in days'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedLocationType,
                decoration: InputDecoration(
                  labelText: 'Location Type',
                  hintText: 'Select location type',
                ),
                items: ['remote', 'on-site'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedLocationType = newValue!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedJobType,
                decoration: InputDecoration(
                  labelText: 'Job Type',
                  hintText: 'Select job type',
                ),
                items: ['open', 'closed'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedJobType = newValue!;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _longitudeController,
                      decoration: InputDecoration(
                          labelText: 'longitude: filled automatic by map',
                          hintText: 'Longitude'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.map),
                    onPressed: _showLocationPicker,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latitudeController,
                      decoration: InputDecoration(
                          labelText: 'Latitude: filled automatic by map',
                          hintText: 'Latitude'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                    labelText: 'Address', hintText: 'Enter address'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickFiles,
                child: Text('Pick Files'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: postJob,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF5C8EF2)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                ),
                child: Text('Post Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
