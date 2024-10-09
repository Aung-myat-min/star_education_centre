import 'package:flutter/material.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/utils/custom_text_field.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({super.key, required this.cId});

  final String cId;

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late Course currentCourse;
  final TextEditingController _courseName = TextEditingController();
  final TextEditingController _fees = TextEditingController();
  final TextEditingController _aboutCourse = TextEditingController();
  bool readonly = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> buutonClick() async {
    if (!readonly) {
      // Only update the course if the fields are editable
      if (_formKey.currentState!.validate()) {
        await updateCourse();
      }
    }
    setState(() {
      readonly = !readonly;  // Toggle readonly mode
    });
  }


  Future<void> _loadCourse() async {
    try {
      Course? course = await Course.readCourseById(widget.cId);

      // Check if course exists
      if (course != null) {
        setState(() {
          currentCourse = course;  // Set the current course
          _courseName.text = course.courseName;
          _aboutCourse.text = course.aboutCourse;
          _fees.text = course.fees.toString();
        });
      } else {
        // Handle the case where no course is found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course not found!'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching course data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load course data.'),
        ),
      );
    }
  }

  Future<void> updateCourse() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Ensure that all fields are properly filled and valid
        Course c1 = Course(
          widget.cId,
          _courseName.text,
          double.parse(_fees.text),
          _aboutCourse.text,
        );

        bool status = await c1.updateCourse();
        SnackBar snackBar;
        if (status) {
          snackBar = const SnackBar(
            content: Text("Updated the course!"),
          );
        } else {
          snackBar = const SnackBar(
            content: Text("Failed to update the course."),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } catch (e) {
        print('Error updating course: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update course. Invalid input!'),
          ),
        );
      }
    }
  }



  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              width: double.infinity,
              child: Form( // <-- Wrap with Form
                key: _formKey, // <-- Assign form key
                child: Column(
                  children: [
                    const Text(
                      "Edit Course Info!",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            readonly: readonly,
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
                            readonly: readonly,
                            controller: _fees,
                            hintText: 'Course Fee',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid fee';
                              }

                              final parsedValue = double.tryParse(value);
                              if (parsedValue == null || parsedValue <= 0) {
                                return 'Please enter a valid positive number';
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
                        readonly: readonly,
                        controller: _aboutCourse,
                        hintText: 'About Course',
                        minLines: 2,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a brief about the course';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: buutonClick,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.tealAccent,
                              ),
                              child: Text(
                                readonly ? 'Edit' : 'Update Course',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: buutonClick,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
