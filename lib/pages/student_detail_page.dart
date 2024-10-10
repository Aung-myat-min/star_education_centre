import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/models/enrollment.dart';
import 'package:star_education_centre/models/return.dart';
import 'package:star_education_centre/models/student.dart'; // Assuming you have a Student model or service
import 'package:star_education_centre/utils/custom_text_field.dart';

import '../models/methods/student_methods.dart';

class StudentDetailPage extends StatefulWidget {
  const StudentDetailPage({super.key, required this.sId});

  final String sId;

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  late Student currentStudent;
  final TextEditingController _firstNameCon = TextEditingController();
  final TextEditingController _lastNameCon = TextEditingController();
  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _phoneCon = TextEditingController();
  final TextEditingController _addressCon = TextEditingController();
  String? _sectionValue;
  Timestamp? _startDate;

  //page transition associated
  bool readOnly = true;
  List<Course> _courseList = [];
  List<String> _selectedCourses = []; // List to hold selected course IDs
  Stream<List<Enrollment>>? _enrollments;
  int discount = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchStudentInfo(); // Fetch student info on page load
    _getCourses();
    _fetchEnrollments();
  }

  Future<void> _updateStudentInfo() async {
    try {
      Student s1 = Student(
          widget.sId,
          _firstNameCon.text,
          _lastNameCon.text,
          _emailCon.text,
          _phoneCon.text,
          _addressCon.text,
          _sectionValue!,
        _startDate!

      );
      bool status = await studentRepository.updateStudent(s1);

      SnackBar snackBar;
      if (status) {
        snackBar = const SnackBar(
          content: Text("Updated Student!"),
        );
      } else {
        snackBar = const SnackBar(
          content: Text("Update Failed!"),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _fetchStudentInfo() async {
    try {
      // Assuming you have a Student model or service
      Student? student = await studentRepository.readStudentById(widget.sId);

      // Populate the fields with student data
      if (student != null) {
        currentStudent = student;
        setState(() {
          _firstNameCon.text = student.firstName;
          _lastNameCon.text = student.lastName;
          _emailCon.text = student.email;
          _phoneCon.text = student.phone;
          _addressCon.text = student.address;
          _sectionValue = student.section;
          _startDate = student.startDate;
        });
      }
    } catch (e) {
      // Handle error (e.g., show an error message)
      print('Error fetching student data: $e');
    }
  }

  Future<void> _deleteStudent() async {
    bool status = await studentRepository.deleteStudent(currentStudent.studentId);

    if (status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student Deleted!"),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      // Redirect back to the previous page
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Student Deletion!"),
        ),
      );
    }
  }

  Future<void> _getCourses() async {
    try {
      courseRepository.getCourses().listen((courses) {
        setState(() {
          _courseList = courses;
        });
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $error"),
        ),
      );
      print('Error fetching courses: $error');
    }
  }

  Future<void> _enrollCourseDialog() async {
    // Fetch the student's current enrollments
    final List<Enrollment> enrollments = await enrollRepository.getEnrollmentByStudent(widget.sId).first;

    // Extract the course IDs of already enrolled courses
    List<String> enrolledCourseIds = enrollments.map((enrollment) => enrollment.courseId).toList();

    // Filter out already enrolled courses from the course list
    List<Course> availableCourses = _courseList.where((course) => !enrolledCourseIds.contains(course.courseId)).toList();

    double totalCourseFees = 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text('Add New Enrollment'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ListBody(
                      children: availableCourses.map(
                            (course) {
                          return CheckboxListTile(
                            title: Text(course.courseName),
                            value: _selectedCourses.contains(course.courseId),
                            onChanged: (bool? selected) {
                              setStateDialog(
                                    () {
                                  if (selected == true) {
                                    _selectedCourses.add(course.courseId);
                                    setState(() {
                                      totalCourseFees += course.fees;
                                    });
                                  } else {
                                    _selectedCourses.remove(course.courseId);
                                    setState(() {
                                      totalCourseFees -= course.fees;
                                    });
                                  }
                                },
                              );
                            },
                          );
                        },
                      ).toList(),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Total Fees: ${totalCourseFees - (totalCourseFees * (discount / 100))} MMK ($discount%)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _enrollCourse();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Enroll'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _enrollCourse() async {
    Map<String, double> selectedCoursesMap = {};

    // Populate the map with selected courses and their fees
    for (var courseId in _selectedCourses) {
      Course? selectedCourse = _courseList.firstWhere(
            (course) => course.courseId == courseId,
      );

      selectedCoursesMap[courseId] = selectedCourse.fees;
        }

    // Proceed only if there are selected courses
    if (selectedCoursesMap.isNotEmpty) {
      Return enrollmentResponse = await enrollCourses(widget.sId, selectedCoursesMap);

      if (enrollmentResponse.status) {
        _selectedCourses = [];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enrolled in courses successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Course enrollment failed!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No courses selected!")),
      );
    }
  }

  Future<void> _fetchEnrollments() async {
    _enrollments = enrollRepository.getEnrollmentByStudent(widget.sId);

    // Listen to the stream to fetch the number of courses
    _enrollments?.listen((enrollmentList) {
      final int numberOfCourses = enrollmentList.length;

      if (numberOfCourses >= 3) {
        discount = RoyalStudent.getDiscount();
      } else if (numberOfCourses == 1) {
        discount = RegisteredStudent.getDiscount();
      } else if (numberOfCourses == 2) {
        discount = OldStudent.getDiscount();
      } else {
        discount = Student.getDiscount();
      }

    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Student Info!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readonly: readOnly,
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
                          readonly: readOnly,
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
                          readonly: readOnly,
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
                          readonly: readOnly,
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
                      readonly: readOnly,
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
                          value: _sectionValue,
                          // Preselect value
                          items: ['A', 'B', 'C', 'D'].map((String section) {
                            return DropdownMenuItem<String>(
                              value: section,
                              child: Text(section),
                            );
                          }).toList(),
                          onChanged: readOnly
                              ? null // Disable if readonly
                              : (String? newValue) {
                                  setState(() {
                                    _sectionValue = newValue;
                                  });
                                },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                readOnly = !readOnly;
                                if (readOnly) {
                                  print("object");
                                  _updateStudentInfo();
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent,
                            ),
                            child: Text(
                              readOnly == true ? 'Edit' : 'Save',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _deleteStudent();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Enrolled Courses",
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  _enrolledCourses(studentId: widget.sId, enrollments: _enrollments!,)
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _enrollCourseDialog,
        backgroundColor: Colors.tealAccent,
        // Set the background color to teal accent
        shape: const CircleBorder(),
        // Rounded shape for the icon
        child: const Icon(
          Icons.add,
          color: Colors.black, // Set the icon color to make it stand out
        ),
      ),
    );
  }
}

class _enrolledCourses extends StatefulWidget {
  final String studentId;
  final Stream<List<Enrollment>> enrollments;
  const _enrolledCourses({required this.studentId, required this.enrollments});

  @override
  State<_enrolledCourses> createState() => _enrolledCoursesState();
}

class _enrolledCoursesState extends State<_enrolledCourses> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Enrollment>>(
      stream: widget.enrollments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No enrollments found.'));
        }

        final enrollments = snapshot.data!;

        return SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                // Table Header
                Table(
                  border: TableBorder.all(color: Colors.black, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(2),
                  },
                  children: const [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Course Name',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Cost',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Discount',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Enrolled Date',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Table Rows for enrollments
                Column(
                  children: enrollments.map((enrollment) {
                    return FutureBuilder<Course?>(
                      future: courseRepository.readCourseById(enrollment.courseId),
                      builder: (context, courseSnapshot) {
                        if (courseSnapshot.connectionState == ConnectionState.waiting) {
                          return const Text("Loading..."); // Custom widget to show loading row
                        } else if (courseSnapshot.hasError) {
                          return const Text("Error Loading", style: TextStyle(color: Colors.red)); // Custom widget to show error row
                        }

                        final course = courseSnapshot.data;
                        if (course == null) {
                          return const Text("Error Loading", style: TextStyle(color: Colors.red)); // Custom widget for unknown course
                        }

                        // Calculate total cost after discount
                        double discountedCost = course.fees - (course.fees * (enrollment.discount / 100));

                        return Table(
                          border: TableBorder.all(color: Colors.black, width: 1),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(course.courseName,
                                      style: const TextStyle(fontSize: 14)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    discountedCost.toStringAsFixed(0),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${enrollment.discount}%',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${enrollment.enrolledT.day}/${enrollment.enrolledT.month}/${enrollment.enrolledT.year}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
