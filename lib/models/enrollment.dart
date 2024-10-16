import 'package:cloud_firestore/cloud_firestore.dart';

class Enrollment {
  final String _enId;
  DateTime enrolledT;
  num discount;
  double totalFee;

  String studentId; // ID of the student (relation)
  String courseId; // ID of the course (relation)

  Enrollment({
    required String enId,
    required this.discount,
    required this.enrolledT,
    required this.totalFee,
    required this.studentId,
    required this.courseId,
  }) : _enId = enId;

  // Getter for private enrollId
  String get enrollId => _enId;

  // Convert object to a Map
  Map<String, dynamic> toMap() {
    return {
      'enId': _enId,
      'enrolledT': enrolledT,
      'discount': discount,
      'totalFee': totalFee,
      'studentId': studentId,
      'courseId': courseId,
    };
  }

  // Method to create Enrollment object from Firestore document
  static Enrollment fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp timestamp = data['enrolledT'] as Timestamp;
    final DateTime enrolledDateTime = timestamp.toDate();

    return Enrollment(
      enId: data['enId'],
      discount: data['discount'],
      enrolledT: enrolledDateTime,
      totalFee: data['totalFee'],
      studentId: data['studentId'],
      courseId: data['courseId'],
    );
  }
}
