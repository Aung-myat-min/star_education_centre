import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/models/methods/student_methods.dart';
import 'package:star_education_centre/models/return.dart';
import 'package:star_education_centre/models/student.dart';
import 'package:star_education_centre/utils/custom_text_field.dart';
import 'package:star_education_centre/utils/hoverable_container.dart';

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
        title: const Text("Manage Students"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.logout_rounded),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Colors.redAccent.withOpacity(0.2),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded border
                  ),
                ),
                side: WidgetStateProperty.all(
                  const BorderSide(
                    color: Colors.redAccent, // Border color redAccent
                    width: 1, // Border width
                  ),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.tealAccent,
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

  final _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void initState() {
    super.initState();
    _getCourses();
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
    String? currentStudentId;

    if (_formKey.currentState!.validate()) {
      var uniqueId = uuid.v1();
      final DateTime startDate = DateTime.now();

      // Create new student object
      Student s1 = Student(
          uniqueId,
          _firstNameCon.text,
          _lastNameCon.text,
          _emailCon.text,
          _phoneCon.text,
          _addressCon.text,
          _sectionValue!,
          Timestamp.fromDate(startDate));

      // Register the student
      Return response = await studentRepository.registerStudent(s1);
      SnackBar snackBar;

      if (response.status) {
        snackBar = const SnackBar(
          content: Text("Registered Student!"),
        );
        currentStudentId =
            response.data; // Get the student ID after successful registration
      } else {
        snackBar = const SnackBar(
          content: Text("Registration Failed!"),
        );
      }

      // Show the snackbar message
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

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
            print('Error finding course: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Selected course not found!")),
            );
          }
        }

        // Enroll the student in the selected courses
        if (selectedCoursesMap.isNotEmpty) {
          Return enrollmentResponse =
              await enrollCourses(currentStudentId!, selectedCoursesMap);

          if (enrollmentResponse.status) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Enrolled in courses successfully!")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Course enrollment failed!")),
            );
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
                          backgroundColor: Colors.tealAccent,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 20),
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
                      child: const Text('Select Courses'),
                    ),
                  ),
                  Text(
                    'Total: ${_totalCourseFees.toStringAsFixed(2)} MMK',
                    // Display the total fee
                    style: const TextStyle(
                      fontSize: 11,
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

  final List<String> _sections = ['A', 'B', 'C', 'D']; // Sections for dropdown

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
    return ConstrainedBox(
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
              stream: studentRepository.readStudents(), // Your stream of students
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
