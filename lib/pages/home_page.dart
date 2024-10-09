import 'package:flutter/material.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/models/enrollment.dart';
import 'package:star_education_centre/models/return.dart';
import 'package:star_education_centre/models/student.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalStudents = -1;
  int totalCourses = -1;
  int totalEnrollments = -1;
  String? mostEnrolledCourse;
  List<Map<String, dynamic>> popularCourses = [];

  bool _isLoading = true; // To track the loading state

  @override
  void initState() {
    super.initState();
    _getInfos();
  }

  Future<void> _getInfos() async {
    try {
      // Set loading to true when starting to fetch data
      setState(() {
        _isLoading = true;
      });

      // Fetch all required data
      Return studentInfo = await Student.getTotalStudentNumber();
      Return courseInfo = await Course.getTotalCourseNumber();
      Return enrollmentInfo = await Enrollment.getTotalEnrollmentsNumber();
      List<Map<String, dynamic>> courseList =
          await Enrollment.getMostPopularCourses();

      // Check for errors in the data fetching
      if (studentInfo.error || studentInfo.status == false) {
        throw Exception('Error fetching student info');
      }
      if (courseInfo.error || courseInfo.status == false) {
        throw Exception('Error fetching course info');
      }
      if (enrollmentInfo.error || enrollmentInfo.status == false) {
        throw Exception('Error fetching enrollment info');
      }

      // Update the state with the fetched data
      setState(() {
        totalStudents = studentInfo.data;
        totalCourses = courseInfo.data;
        totalEnrollments = enrollmentInfo.data;
        mostEnrolledCourse =
            courseList.isNotEmpty ? courseList[0]["courseName"] : "N/A";
        popularCourses = courseList;
        _isLoading = false; // Set loading to false after fetching the data
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // Stop loading if there is an error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $error"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while fetching data
          : SingleChildScrollView(
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
                    _buildStatisticsSection(totalStudents, totalCourses,
                        totalEnrollments, mostEnrolledCourse ?? ''),
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Method to build the statistics section
  Widget _buildStatisticsSection(int totalStudents, int totalCourses,
      int totalEnrollments, String mostEnrolledCourse) {
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
        width: 180,
        height: 180,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
  Widget _buildPopularCoursesTable(List<Map<String, dynamic>> courses) {
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
            2: FlexColumnWidth(1),
          },
          children: [
            // Table header
            const TableRow(
              decoration: BoxDecoration(color: Colors.blueGrey),
              children: [
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Enrollment",
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      course["enrollments"]!.toString(),
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
