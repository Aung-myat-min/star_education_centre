import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/models/factory/student_factory.dart';
import 'package:star_education_centre/models/return.dart';
import 'package:star_education_centre/models/student.dart';
import 'package:star_education_centre/utils/custom_text_field.dart';
import 'package:star_education_centre/utils/hoverable_container.dart';
import 'package:star_education_centre/utils/logout_button.dart';
import 'package:star_education_centre/utils/status_snackbar.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => {},
          icon: const Icon(Icons.menu_rounded),
        ),
        centerTitle: true,
        title: const Text(
          "Manage Students",
          style: TextStyle(color: Colors.white),
        ),
        actions: const [LogoutButton()],
        backgroundColor: Colors.black87,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _StuRegisterForm(),
              Padding(
                padding: EdgeInsets.all(8),
                child: _StudentList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StuRegisterForm extends StatefulWidget {
  const _StuRegisterForm();

  @override
  State<_StuRegisterForm> createState() => _StuRegisterFormState();
}

class _StuRegisterFormState extends State<_StuRegisterForm> {
  final TextEditingController _firstNameCon = TextEditingController();
  final TextEditingController _lastNameCon = TextEditingController();
  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _phoneCon = TextEditingController();
  final TextEditingController _addressCon = TextEditingController();
  String? _sectionValue;
  List<Course> _courseList = []; // List to hold courses
  final List<String> _selectedCourses = []; // List to hold selected course IDs
  double _totalCourseFees = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getCourses();
  }

  Future<void> _getCourses() async {
    try {
      courseActions.getCourses().listen((courses) {
        setState(() {
          _courseList = courses;
        });
      });
    } catch (error) {
      statusSnackBar(context, SnackBarType.fail, "Error $error");
    }
  }

  Future<void> _showCourseSelectionDialog() async {
    // Show dialog with a list of courses
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text("Select Courses"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: _courseList.map((course) {
                    return CheckboxListTile(
                      title: Text(course.courseName),
                      value: _selectedCourses.contains(course.courseId),
                      onChanged: (bool? selected) {
                        setStateDialog(() {
                          if (selected == true) {
                            _selectedCourses.add(course.courseId);
                            setState(() {
                              _totalCourseFees += course.fees;
                            });
                          } else {
                            _selectedCourses.remove(course.courseId);
                            setState(() {
                              _totalCourseFees -= course.fees;
                            });
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> registerStudent() async {

    if (_formKey.currentState!.validate()) {
      var uniqueId = uuid.v1();
      final DateTime startDate = DateTime.now();

      // Create new student object
      Student s1 = StudentFactory.determineStudentClass(
          sId: uniqueId,
          firstName: _firstNameCon.text,
          lastName: _lastNameCon.text,
          email: _emailCon.text,
          phone: _phoneCon.text,
          address: _addressCon.text,
          startDate: Timestamp.fromDate(startDate),
          section: _sectionValue!,
          numberOfCourses: 0);

      // Register the student
      Return response = await studentActions.registerStudent(s1);

      if (response.status) {
        statusSnackBar(
            context, SnackBarType.success, "Successfully Registered");
      } else {
        statusSnackBar(context, SnackBarType.fail, "Failed Registration");
      }

      if (response.status) {
        // Prepare a Map for the selected courses and their corresponding fees
        Map<String, double> selectedCoursesMap = {};

        // Collect the selected courses and their fees into the map
        for (String courseId in _selectedCourses) {
          try {
            final currentCourse = _courseList.firstWhere(
              (course) => course.courseId == courseId,
              orElse: () => throw Exception('Course not found'),
            );

            selectedCoursesMap[currentCourse.courseId] = currentCourse.fees;
          } catch (e) {
            statusSnackBar(
                context, SnackBarType.fail, "Selected course not found!");
          }
        }

        // Enroll the student in the selected courses
        if (selectedCoursesMap.isNotEmpty) {
          Return enrollmentResponse =
              await studentActions.enrollCourses(s1, selectedCoursesMap);

          if (enrollmentResponse.status) {
            statusSnackBar(context, SnackBarType.success,
                "Enrolled in courses successfully!");
          } else {
            statusSnackBar(
                context, SnackBarType.fail, "Course enrollment failed!");
          }
        }
      }

      // Clear the form fields and selected courses after registration and enrollment
      setState(() {
        _firstNameCon.clear();
        _lastNameCon.clear();
        _emailCon.clear();
        _phoneCon.clear();
        _addressCon.clear();
        _sectionValue = null;
        _selectedCourses.clear();
      });
    }
  }

  @override
  void dispose() {
    _firstNameCon.dispose();
    _lastNameCon.dispose();
    _emailCon.dispose();
    _phoneCon.dispose();
    _addressCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Register Student Here!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameCon,
                      hintText: 'First Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameCon,
                      hintText: 'Last Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _emailCon,
                      hintText: 'Email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneCon,
                      hintText: 'Phone Number',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        } else if (value.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CustomTextField(
                  controller: _addressCon,
                  hintText: 'Address',
                  minLines: 2,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select Section'),
                      items: ['A', 'B', 'C', 'D'].map((String section) {
                        return DropdownMenuItem<String>(
                          value: section,
                          child: Text(section),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _sectionValue = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50, // Set your desired height
                      child: ElevatedButton(
                        onPressed: registerStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Optional:",
                    style: TextStyle(fontSize: 21),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showCourseSelectionDialog,
                      child: const Text(
                        'Select Courses',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Text(
                    'Total: ${_totalCourseFees.toStringAsFixed(0)} MMK',
                    // Display the total fee
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentList extends StatefulWidget {
  const _StudentList();

  @override
  State<_StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<_StudentList> {
  String _searchQuery = ''; // For name and ID search
  String? _selectedSection; // For section filter

  final List<String> _sections = ['A', 'B', 'C', 'D'];

  // Method to filter students by name, ID, and section
  List<Student> _filterStudents(List<Student> students) {
    return students.where((student) {
      final isSectionMatch =
          _selectedSection == null || student.section == _selectedSection;
      final isSearchQueryMatch = student.firstName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          student.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.studentId.toLowerCase().contains(_searchQuery.toLowerCase());

      return isSectionMatch && isSearchQueryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 200,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Name or ID Search Field
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search by Name or ID',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Section Filter Dropdown
                  DropdownButton<String>(
                    value: _selectedSection,
                    hint: const Text('Select Section'),
                    items: _sections.map((section) {
                      return DropdownMenuItem<String>(
                        value: section,
                        child: Text(section),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSection = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: StreamBuilder<List<Student>>(
                stream: studentActions.readStudents(),
                // Your stream of students
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No students found.'),
                    );
                  }

                  // Filter students based on search query and selected section
                  final filteredStudents = _filterStudents(snapshot.data!);

                  if (filteredStudents.isEmpty) {
                    return const Center(
                      child: Text('No students match the search criteria.'),
                    );
                  }

                  // Display filtered students
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: filteredStudents.length,
                    itemBuilder: (BuildContext context, int index) {
                      final student = filteredStudents[index];
                      return SelectionArea(
                        child: HoverableContainer(student: student),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
