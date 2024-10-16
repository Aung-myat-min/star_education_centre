import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/pages/course_detail_page.dart';
import 'package:star_education_centre/utils/custom_text_field.dart';
import 'package:star_education_centre/utils/logout_button.dart';
import 'package:star_education_centre/utils/status_snackbar.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Manage Courses",
          style: TextStyle(color: Colors.white),
        ),
        actions: const [LogoutButton()],
        backgroundColor: Colors.black87,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _CourseRegisterForm(),
              Padding(
                padding: EdgeInsets.all(8),
                child: _CourseList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseRegisterForm extends StatefulWidget {
  const _CourseRegisterForm();

  @override
  State<_CourseRegisterForm> createState() => _CourseRegisterFormState();
}

class _CourseRegisterFormState extends State<_CourseRegisterForm> {
  final TextEditingController _courseName = TextEditingController();
  final TextEditingController _fees = TextEditingController();
  final TextEditingController _aboutCourse = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> createCourse() async {
    if (_formKey.currentState!.validate()) {
      var uniqueId = uuid.v1();
      Course c1 = Course(
          cId: uniqueId,
          courseName: _courseName.text,
          fees: double.parse(_fees.text),
          aboutCourse: _aboutCourse.text);

      bool status = await courseActions.createCourse(c1);
      if (status) {
        statusSnackBar(context, SnackBarType.success, "Course Created!");
      } else {
        statusSnackBar(context, SnackBarType.fail, "Failed Course Creation!");
      }
      setState(() {
        _courseName.text = '';
        _fees.text = '';
        _aboutCourse.text = '';
      });
    }
  }

  @override
  void dispose() {
    _courseName.dispose();
    _fees.dispose();
    _aboutCourse.dispose();
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
                'Create Course Here!',
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
                      controller: _courseName,
                      hintText: 'Course Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the course name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _fees,
                      hintText: 'Course Fee',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid fee';
                        }

                        // Check if the value is a valid number
                        final parsedValue = double.tryParse(value);
                        if (parsedValue == null || parsedValue <= 0) {
                          return 'Please enter a valid positive number';
                        }

                        return null; // Return null if validation is successful
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CustomTextField(
                  controller: _aboutCourse,
                  hintText: 'About Course',
                  minLines: 2,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter breif about course';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: createCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                  ),
                  child: const Text(
                    'Create Course',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ), // Button label
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseList extends StatefulWidget {
  const _CourseList();

  @override
  State<_CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<_CourseList> {
  String _searchQuery = '';

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
              ],
            ),
          ),
          StreamBuilder<List<Course>>(
            stream: courseActions.getCourses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No courses found.'),
                );
              }

              final courses = snapshot.data!.where((course) {
                final matchesSearch = course.courseName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
                return matchesSearch;
              }).toList();

              if (courses.isEmpty) {
                return const Center(
                    child: Text('No courses match your search.'));
              }

              return SizedBox(
                height: courses.length * 90,
                child: ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (BuildContext context, int index) {
                    final course = courses[index];
                    return _CourseHoverableContainer(course: course);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CourseHoverableContainer extends StatelessWidget {
  final Course course;

  const _CourseHoverableContainer({required this.course});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                CourseDetailPage(cId: course.courseId),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: ListTile(
          title: Text(
            course.courseName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            course.aboutCourse,
            style: const TextStyle(fontSize: 14),
          ),
          trailing: Text(
            '${course.fees.toStringAsFixed(2)} MMK',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
