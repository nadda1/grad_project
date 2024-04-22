import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  List<PlatformFile>? _pickedFiles;  // To store picked files

  Future<void> pickFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true, // Allows multiple files to be picked
    type: FileType.custom, // Allows picking of all file types
    allowedExtensions: ['jpg', 'pdf', 'png', 'doc', 'docx'], // Specify allowed extensions
  );

  if (result != null) {
    setState(() {
      _pickedFiles = result.files; 
    });
  } else {
    // User canceled the picker
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
    ..fields['description'] = _descriptionController.text
    ..fields['required_skills'] = jsonEncode(_skillsController.text.split(',').map((skill) => skill.trim()).toList())
    ..fields['expected_budget'] = _budgetController.text
    ..fields['expected_duration'] = _durationController.text;

  if (_pickedFiles != null) {
    for (var file in _pickedFiles!) {
      request.files.add(await http.MultipartFile.fromPath(
        'attachments[]',
        file.path!,
        contentType: MediaType('application', 'octet-stream'), // Ensure this is correct or use file.extension
      ));
    }
  }  var response = await request.send();
  var responseBody = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    showSuccessDialog('Job posted successfully.');
  } else {
    try {
      Map<String, dynamic> decodedResponseBody = jsonDecode(responseBody);
      String errorMessage = decodedResponseBody['message']?.toString() ?? 'Unknown error occurred.';
      showErrorDialog(errorMessage);
    } catch (e) {
      showErrorDialog('Failed to parse error message. Please try again.');
    }
  }
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
            onPressed: () => Navigator.of(context). pop(),
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
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Job Title', hintText: 'Enter job title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description', hintText: 'Enter job description'),
            ),
            TextField(
              controller: _skillsController,
              decoration: InputDecoration(labelText: 'Required Skills', hintText: 'Enter required skills, separated by commas'),
            ),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(labelText: 'Expected Budget', hintText: 'Enter expected budget'),
            ),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(labelText: 'Expected Duration (days)', hintText: 'Enter expected duration in days'),
            ),
            ElevatedButton(
              onPressed: pickFiles,
              child: Text('Pick Files'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: postJob,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF5C8EF2)),
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
    );
  }
}
