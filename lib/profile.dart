import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView( // Allow scrolling if content overflows
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // User Information Section
              const Column(
                children: [
                  // Replace with user's profile picture URL or widget
                  CircleAvatar(
                    backgroundImage: NetworkImage('https://placeholdit.img/200x200'),
                    radius: 50.0, // Adjust radius as needed
                  ),
                  SizedBox(width: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Replace with user's name
                      Text(
                        'Anna Lee',
                        style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                      // Replace with user's email (optional)
                      Text('annalee9986@gmail.com'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // Additional Information Section (Optional)
              const Text('Bio:'), // Add bio text field or widget here (optional)
              const SizedBox(height: 10.0),
              const Text('Location: Cairo, Egypt'), // Replace with user's location (optional)
              const SizedBox(height: 10.0),
              // Add social media links here (optional)

              // Action Buttons (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () { /* Edit profile button action */ },
                    child: const Text('Edit Profile'),
                  ),
                  ElevatedButton(
                    onPressed: () { /* Change password button action */ },
                    child: const Text('Change Password'),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // Education Section
              const EducationSection(educationList: [
                'Bachelor of Science in Computer Science (2020)',
                'Master of Science in Artificial Intelligence (expected 2024)',
              ]),
              const SeparatorLine(),
              const SizedBox(height: 20.0),

              // Certificate Section
              const CertificateSection(certificateList: [
                'Machine Learning Specialization (Coursera)',
                'Flutter Development Bootcamp (Udacity)',
              ]),
              const SeparatorLine(),
              const SizedBox(height: 20.0),

              // Experience Section
              const ExperienceSection(experienceList: [
                'Software Engineer Intern (Company A, 2023)',
                'Web Developer (Company B, 2022)',
              ]),
            ],


          ),
        ),
      ),
    );
  }
}

class EducationSection extends StatelessWidget {
  final List<String> educationList; // Replace with your education data

  const EducationSection({Key? key, required this.educationList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Adjust background color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Education:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10.0),
          for (String education in educationList)
            Text(education), // Display each education entry
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class CertificateSection extends StatelessWidget {
  final List<String> certificateList; // Replace with your certificate data

  const CertificateSection({Key? key, required this.certificateList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Adjust background color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Certificate:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10.0),
          for (String certificate in certificateList)
            Text(certificate), // Display each education entry
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  final List<String> experienceList; // Replace with your experience data

  const ExperienceSection({Key? key, required this.experienceList}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Adjust background color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Experience:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10.0),
          for (String experience in experienceList)
            Text(experience), // Display each education entry
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class SeparatorLine extends StatelessWidget {
  const SeparatorLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0,
      color: Colors.grey[300], // Adjust color for the line
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
    );
  }
}
