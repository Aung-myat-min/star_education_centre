import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/models/enrollment.dart';
import 'package:star_education_centre/models/student.dart'; // Assuming you have a Student model or service
import 'package:star_education_centre/utils/custom_text_field.dart';

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
  bool readOnly = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchStudentInfo(); // Fetch student info on page load
  }

  Future<void> _updateStudentInfo() async {
    try {
      Student s1 = new Student(
          widget.sId,
          _firstNameCon.text,
          _lastNameCon.text,
          _emailCon.text,
          _phoneCon.text,
          _addressCon.text,
          _sectionValue!);
      bool status = await s1.updateStudent();

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
        new SnackBar(
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
      Student? student = await Student.readStudentById(widget.sId);

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
        });
      }
    } catch (e) {
      // Handle error (e.g., show an error message)
      print('Error fetching student data: $e');
    }
  }

  Future<void> _deleteStudent() async {
    bool status = await currentStudent.deleteStudent();

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
      body: SizedBox(
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
                          style: const TextStyle(fontSize: 20),
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
                _enrolledCourses(studentId: widget.sId)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _enrolledCourses extends StatefulWidget {
  final String studentId;

  const _enrolledCourses({super.key, required this.studentId});

  @override
  State<_enrolledCourses> createState() => _enrolledCoursesState();
}

class _enrolledCoursesState extends State<_enrolledCourses> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Enrollment>>(
      stream: Enrollment.getEnrollmentByStudent(widget.studentId),
      // Get enrollments by student ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No enrollments found.'));
        }

        final enrollments = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: enrollments.length,
          itemBuilder: (context, index) {
            final enrollment = enrollments[index];

            return FutureBuilder<Course?>(
              future: Course.readCourseById(enrollment.courseId),
              builder: (context, courseSnapshot) {
                if (courseSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading course...'),
                  );
                } else if (courseSnapshot.hasError) {
                  return ListTile(
                    title: Text('Error: ${courseSnapshot.error}'),
                  );
                }

                final course = courseSnapshot.data;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Text(
                    course?.courseName ?? 'Unknown Course',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Enrolled on: ${DateFormat.yMMMMd().add_jm().format(enrollment.enrolledT)}', // Formatting enrolled time
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Text(
                    '\$${enrollment.totalFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
