import 'package:star_education_centre/models/Student.dart'; // Assuming this is the correct path
import 'package:star_education_centre/models/Course.dart';  // Assuming the Course class is in this file

class Enrollment {
  final String _enId;
  DateTime enrolledT;
  num discount;
  double totalFee;

  String studentId;       // ID of the student (relation)
  String courseId;        // ID of the course (relation)

  Enrollment(this._enId, this.discount, this.enrolledT, this.totalFee, this.studentId, this.courseId);

  // Getter for private enrollId
  String get enrollId => _enId;
}
