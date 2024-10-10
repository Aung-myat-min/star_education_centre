import 'package:cloud_firestore/cloud_firestore.dart';

//Class Course
class Course {
  final String _cId;
  String courseName;
  double fees;
  String aboutCourse;

  Course(this._cId, this.courseName, this.fees, this.aboutCourse);

  // Getter for _cId to allow reading, but not modifying
  String get courseId => _cId;

  // Method to convert a Student object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'cId': _cId,
      'courseName': courseName,
      'fees': fees,
      'aboutCourse': aboutCourse
    };
  }

  // Static method to create a Course object from Firestore data
  static Course fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
        data['cId'], data['courseName'], data['fees'], data['aboutCourse']);
  }
}
