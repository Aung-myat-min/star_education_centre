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

    // Example popular courses (replace with real data later)
    final List<Map<String, String>> popularCourses = [
      {
        "courseName": "Introduction to Flutter",
        "price": "300,000 MMK"
      },
      {
        "courseName": "Advanced Java",
        "price": "350,000 MMK"
      },
      {
        "courseName": "Python for Data Science",
        "price": "400,000 MMK"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "⭐ Star Education Centre ⭐",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade200,
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
                  "At Star Education Centre, we provide professional courses aimed at enhancing skills in programming, networking, and website design. "
                      "With a focus on practical learning, our courses ensure students gain hands-on experience in real-world projects. ",
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

              // Popular Courses Section
              _buildPopularCoursesTable(popularCourses),
              const SizedBox(height: 30),

              // Footer or additional info
              const Center(
                child: Text(
                  "Explore courses, manage students, and stay on top of enrollments!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
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

  // Method to build the table of most popular courses
  Widget _buildPopularCoursesTable(List<Map<String, String>> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Most Popular Courses",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.black26),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
          },
          children: [
            // Table header
            TableRow(
              decoration: const BoxDecoration(color: Colors.blueGrey),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Course Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Price",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            // Table rows with popular courses data
            for (var course in courses)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      course["courseName"]!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      course["price"]!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
