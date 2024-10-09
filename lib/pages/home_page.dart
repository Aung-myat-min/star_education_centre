import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data
    const int totalStudents = 150;
    const int totalCourses = 12;
    const int totalEnrollments = 320;
    const String mostEnrolledCourse = "Introduction to Flutter";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "⭐ Star Education Centre ⭐",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.tealAccent.shade100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              const Center(
                child: Text(
                  "Student and Course\nManagement Software",
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Efficient, user-friendly platform for managing student and course records.",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              // Overview Statistics Section
              _buildStatisticsSection(totalStudents, totalCourses, totalEnrollments, mostEnrolledCourse),
              const SizedBox(height: 30),

              // Footer or additional info
              const Center(
                child: Text(
                  "Explore courses, manage students, and stay on top of enrollments!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the statistics section
  Widget _buildStatisticsSection(int totalStudents, int totalCourses, int totalEnrollments, String mostEnrolledCourse) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoCard(
              icon: Icons.people,
              label: "Total Students",
              value: totalStudents.toString(),
              color: Colors.blue.shade100,
            ),
            _buildInfoCard(
              icon: Icons.book,
              label: "Total Courses",
              value: totalCourses.toString(),
              color: Colors.pink.shade100,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoCard(
              icon: Icons.how_to_reg,
              label: "Total Enrollments",
              value: totalEnrollments.toString(),
              color: Colors.green.shade100,
            ),
            _buildInfoCard(
              icon: Icons.star,
              label: "Most Enrolled Course",
              value: mostEnrolledCourse,
              color: Colors.orange.shade100,
            ),
          ],
        ),
      ],
    );
  }

  // Method to build individual info cards
  // Method to build individual info cards
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: 180, // Set a fixed width
        height: 180, // Set the height to match the width
        child: Padding(
          padding: const EdgeInsets.all(16), // Add padding for better layout
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.black87),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
