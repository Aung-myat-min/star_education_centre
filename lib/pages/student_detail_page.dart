import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/models/enrollment.dart';
import 'package:star_education_centre/models/return.dart';
import 'package:star_education_centre/models/student.dart';
import 'package:star_education_centre/utils/custom_text_field.dart';

class StudentDetailPage extends StatefulWidget {
  const StudentDetailPage({super.key, required this.student});

  final Student student;

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

  //page associated
  bool readOnly = true;
  List<Course> _courseList = [];
  final List<String> _selectedCourses = []; // List to hold selected course IDs
  Stream<List<Enrollment>>? _enrollments;
  int discount = 0;

  final _formKey = GlobalKey<FormState>();

  Future<void> _updateStudentInfo() async {
    try {
      Student s1 = Student(
          widget.student.studentId,
          _firstNameCon.text,
          _lastNameCon.text,
          _emailCon.text,
          _phoneCon.text,
          _addressCon.text,
          _sectionValue!,
          _startDate!,
          currentStudent.numberOfCourses);
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

  Future<void> _deleteStudent() async {
    bool status =
        await studentRepository.deleteStudent(currentStudent.studentId);

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
    }
  }

  Future<void> _enrollCourseDialog() async {
    // Fetch the student's current enrollments
    final List<Enrollment> enrollments = await enrollRepository
        .getEnrollmentByStudent(widget.student.studentId)
        .first;

    // Extract the course IDs of already enrolled courses
    List<String> enrolledCourseIds =
        enrollments.map((enrollment) => enrollment.courseId).toList();

    // Filter out already enrolled courses from the course list
    List<Course> availableCourses = _courseList
        .where((course) => !enrolledCourseIds.contains(course.courseId))
        .toList();

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

    if (selectedCoursesMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No courses selected!")),
      );
      return;
    }

    Return enrollmentResponse = await studentRepository.enrollCourses(
        currentStudent, selectedCoursesMap);

    if (enrollmentResponse.status) {
      _selectedCourses.clear();  // Clear selected courses

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enrolled in courses successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course enrollment failed!")),
      );
    }
    determineDiscount();
  }


  void determineDiscount() {
    if (currentStudent.numberOfCourses >= 3) {
      discount = 20;
    } else if (currentStudent.numberOfCourses == 2) {
      discount = 10;
    } else if (currentStudent.numberOfCourses == 1) {
      discount = 5;
    } else {
      discount = 0;
    }

    print('${currentStudent.numberOfCourses} ${discount}');
  }

  @override
  void initState() {
    super.initState();
    currentStudent = widget.student;
    _firstNameCon.text = currentStudent.firstName;
    _lastNameCon.text = currentStudent.lastName;
    _emailCon.text = currentStudent.email;
    _phoneCon.text = currentStudent.phone;
    _addressCon.text = currentStudent.address;
    _sectionValue = currentStudent.section;
    _startDate = currentStudent.startDate;

    determineDiscount();

    _enrollments =
        enrollRepository.getEnrollmentByStudent(widget.student.studentId);
    _getCourses();
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
    print(currentStudent);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _deleteStudent();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white70,
            ),
            icon: Icon(
              Icons.delete_forever_rounded,
              color: Colors.red.shade500,
            ),
          ),
        ],
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
                                  _updateStudentInfo();
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen,
                            ),
                            child: Text(
                              readOnly == true ? 'Edit' : 'Save',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
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
                  _EnrolledCourses(
                    studentId: widget.student.studentId,
                    enrollments: _enrollments!,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _enrollCourseDialog,
        backgroundColor: Colors.black54,
        // Set the background color to teal accent
        shape: const CircleBorder(),
        // Rounded shape for the icon
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _EnrolledCourses extends StatefulWidget {
  final String studentId;
  final Stream<List<Enrollment>> enrollments;

  const _EnrolledCourses({required this.studentId, required this.enrollments});

  @override
  State<_EnrolledCourses> createState() => _EnrolledCoursesState();
}

class _EnrolledCoursesState extends State<_EnrolledCourses> {
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
                          child: FittedBox(
                            child: Text(
                              'Discount',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
                      future:
                          courseRepository.readCourseById(enrollment.courseId),
                      builder: (context, courseSnapshot) {
                        if (courseSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                              "Loading..."); // Custom widget to show loading row
                        } else if (courseSnapshot.hasError) {
                          return const Text("Error Loading",
                              style: TextStyle(
                                  color: Colors
                                      .red)); // Custom widget to show error row
                        }

                        final course = courseSnapshot.data;
                        if (course == null) {
                          return const Text("Error Loading",
                              style: TextStyle(
                                  color: Colors
                                      .red)); // Custom widget for unknown course
                        }

                        // Calculate total cost after discount
                        double discountedCost = course.fees -
                            (course.fees * (enrollment.discount / 100));

                        return Table(
                          border:
                              TableBorder.all(color: Colors.black, width: 1),
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
