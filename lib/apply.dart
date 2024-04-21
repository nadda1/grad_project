import 'package:flutter/material.dart';

class ApplyPage extends StatefulWidget {
  @override
  _ApplyPageState createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  DateTime? _selectedDate;
  String? _selectedEducation;
  String? _selectedGender;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for Job'),

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Personal Information:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10.0),
            _buildInputField('Full Name'),
            _buildInputField('Email Address'),
            _buildInputField('Phone Number'),
            _buildInputField('Address'),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Color(0xFF5C8EF2)),
                    suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF5C8EF2)),
                  ),
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : '',
                  ),
                  style: TextStyle(color: Color(0xFF5C8EF2)),
                ),
              ),
            ),
            _buildInputField('Gender', choices: ['Male', 'Female', 'Other']),
            SizedBox(height: 20.0),
            Text(
              'Education:',
              style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField(
              value: _selectedEducation,
              items: [
                DropdownMenuItem(child: Text('High School'), value: 'High School'),
                DropdownMenuItem(child: Text('Bachelor\'s Degree'), value: 'Bachelor\'s Degree'),
                DropdownMenuItem(child: Text('Master\'s Degree'), value: 'Master\'s Degree'),
                DropdownMenuItem(child: Text('Ph.D.'), value: 'Ph.D.'),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedEducation = value as String?;
                });
              },
              decoration: InputDecoration(
                labelText: 'Highest Level of Education',
                labelStyle: TextStyle(color: Color(0xFF5C8EF2)),
              ),
              style: TextStyle(color: Color(0xFF5C8EF2)),
            ),
            SizedBox(height: 20.0),
            Text(
              'List of Previous Employers:',
              style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            _buildInputField('Employer Name'),
            _buildInputField('Job Title'),
            SizedBox(height: 20.0),
            Text(
              'Skills and Qualifications:',
              style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            _buildInputField('Technical Skills'),
            _buildInputField('Soft Skills'),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(

                    textStyle: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, {List<String>? choices}) {
    if (choices != null) {
      return DropdownButtonFormField(
        items: choices.map((choice) => DropdownMenuItem(child: Text(choice), value: choice)).toList(),
        onChanged: (value) {},
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF5C8EF2)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        style: TextStyle(color: Color(0xFF5C8EF2)),
      );
    } else {
      return TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF5C8EF2)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        style: TextStyle(color: Color(0xFF5C8EF2)),
      );
    }
  }
}