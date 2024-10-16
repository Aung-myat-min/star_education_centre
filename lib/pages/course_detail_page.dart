import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/utils/custom_text_field.dart';
import 'package:star_education_centre/utils/status_snackbar.dart';

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

  Future<void> buttonClick() async {
    if (!readonly) {
      // Only update the course if the fields are editable
      if (_formKey.currentState!.validate()) {
        await updateCourse();
      }
    }
    setState(() {
      readonly = !readonly; // Toggle readonly mode
    });
  }

  Future<void> _loadCourse() async {
    try {
      Course? course = await courseActions.readCourseById(widget.cId);

      // Check if course exists
      if (course != null) {
        setState(() {
          currentCourse = course; // Set the current course
          _courseName.text = course.courseName;
          _aboutCourse.text = course.aboutCourse;
          _fees.text = course.fees.toString();
        });
      } else {
        statusSnackBar(context, SnackBarType.alert, "Course not found!");
      }
    } catch (e) {
      statusSnackBar(
          context, SnackBarType.fail, "Failed to load course data...");
    }
  }

  Future<void> updateCourse() async {
    if (_formKey.currentState!.validate()) {
      try {
        Course c1 = Course(
          cId: widget.cId,
          courseName: _courseName.text,
          fees: double.parse(_fees.text),
          aboutCourse: _aboutCourse.text,
        );

        bool status = await courseActions.updateCourse(c1);
        if (status) {
          statusSnackBar(context, SnackBarType.success, "Updated Course!");
        } else {
          statusSnackBar(
              context, SnackBarType.fail, "Failed to update the course.");
        }
      } catch (e) {
        statusSnackBar(context, SnackBarType.fail,
            "Failed to update course. Invalid input!");
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
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              width: double.infinity,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Edit Course Info",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                              onPressed: buttonClick,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                              ),
                              child: Text(
                                readonly ? 'Edit' : 'Update Course',
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: buttonClick,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade300,
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
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
