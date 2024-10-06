import 'package:flutter/material.dart';
import 'package:star_education_centre/pages/attendance_page.dart';
import 'package:star_education_centre/pages/courses_page.dart';
import 'package:star_education_centre/pages/home_page.dart';
import 'package:star_education_centre/pages/student_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    AttendancePage(),
    StudentPage(),
    CoursesPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.teal,
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade300,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
        ],
      ),
    );
  }
}
