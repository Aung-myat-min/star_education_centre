import 'package:flutter/material.dart';
import 'package:star_education_centre/constants.dart';
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
                padding:  EdgeInsets.all(8),
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

  final _formKey = GlobalKey<FormState>(); // Key for form validation

  Future<void> registerStudent() async {
    if (_formKey.currentState!.validate()) {
      var uniqueId = uuid.v1();
      Student s1 = Student(
        uniqueId,
        _firstNameCon.text,
        _lastNameCon.text,
        _emailCon.text,
        _phoneCon.text,
        _addressCon.text,
        _sectionValue!,
      );

      bool status = await s1.registerStudent();
      SnackBar snackBar;
      if (status) {
        snackBar = const SnackBar(
          content:  Text("Registered Student!"),
        );
      } else {
        snackBar = const SnackBar(
          content:  Text("Registered Failed!"),
        );
      }
      setState(() {
        _firstNameCon.text = '';
        _lastNameCon.text = '';
        _emailCon.text = '';
        _phoneCon.text = '';
        _addressCon.text = '';
        _sectionValue = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          // Wrap the form elements in a Form widget
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
                          backgroundColor: Colors
                              .tealAccent, // Set the background color to tea accent
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 20),
                        ), // Button label
                      ),
                    ),
                  ),
                ],
              ),
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
  String _searchQuery = '';
  String? _selectedSection;

  final List<String> _sections = ['A', 'B', 'C', 'D'];

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
                // Name Search Field
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by Name',
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
              stream: Student.readStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No students found.'));
                }

                final students = snapshot.data!
                    .where((student) {
                  final matchesSearch = '${student.firstName} ${student.lastName}'
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                  final matchesSection = _selectedSection == null ||
                      student.section == _selectedSection;
                  return matchesSearch && matchesSection;
                })
                    .toList();

                if (students.isEmpty) {
                  return const Center(child: Text('No students match your criteria.'));
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: students.length,
                  itemBuilder: (BuildContext context, int index) {
                    final student = students[index];
                    return SelectionArea(
                      child: HoverableContainer(student: student)
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
