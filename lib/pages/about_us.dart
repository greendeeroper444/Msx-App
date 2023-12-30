import 'package:flutter/material.dart';

// Define a simple data structure for team members
class TeamMember {
  final String name;
  final String role;

  TeamMember(this.name, this.role);
}

class AboutUsPage extends StatelessWidget {
  AboutUsPage({super.key});

  //list of team members
  final List<TeamMember> teamMembers = [
    TeamMember('Rhea Vitualla', 'Team Leader/Project Manager'),
    TeamMember('Greendee Roper Panogalon', 'Backend Developer'),
    TeamMember('Kyla Jardinico', 'UI/UX Designer'),
    TeamMember('Rodel Jacobe', 'UI Developer'),
    TeamMember('Jarryl Jovenir', 'Tester and Database manager'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to MSX App!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'MSX App is a music application that provides a seamless and enjoyable music listening experience. Our mission is to bring music lovers together and make music accessible to everyone.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Key Features:',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                '- Discover and enjoy a vast library of music.',
              ),
              const Text(
                  '- Create and share your own albums.',
              ),
              const Text(
                  '- Personalized recommendations based on your preferences.',
              ),

              const SizedBox(height: 16),

              const Text(
                'Meet the Team:',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              for (var member in teamMembers)
                ListTile(
                  title: Text(member.name),
                  subtitle: Text(member.role),
                ),

              const SizedBox(height: 16),

              const Text(
                'Contact Us:',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                ),
              ),

             const SizedBox(height: 8),

              const Text(
                'Email: support@msxapp.com',
              ),
              const Text(
                'Phone: 09501049657',
              ),
            ],
          ),
        ),
      ),
    );
  }
}


