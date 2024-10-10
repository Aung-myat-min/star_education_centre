import 'package:star_education_centre/models/repositories/course_repository.dart';
import 'package:star_education_centre/models/repositories/enroll_repository.dart';
import 'package:star_education_centre/models/repositories/student_repository.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
StudentRepository studentRepository = StudentRepository();
CourseRepository courseRepository = CourseRepository();
EnrollRepository enrollRepository = EnrollRepository();
