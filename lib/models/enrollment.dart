import 'package:cloud_firestore/cloud_firestore.dart';

class Enrollment {
  final String _enId;
  DateTime enrolledT;
  num discount;
  double totalFee;

  String studentId; // ID of the student (relation)
  String courseId; // ID of the course (relation)

  Enrollment(this._enId, this.discount, this.enrolledT, this.totalFee,
      this.studentId, this.courseId);

  // Getter for private enrollId
  String get enrollId => _enId;

  //convert object to a Map
  Map<String, dynamic> toMap() {
    return {
      'enId': _enId,
      'enrolledT': enrolledT,
      'discount': discount,
      'totalFee': totalFee,
      'studentId': studentId,
      'courseId': courseId
    };
  }

  //method to create enrollment object from doc
  static Enrollment fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp timestamp = data['enrolledT'] as Timestamp;
    final DateTime enrolledDateTime = timestamp.toDate();

    return Enrollment(
      data['enId'],
      data['discount'],
      enrolledDateTime,
      data['totalFee'],
      data['studentId'],
      data['courseId'],
    );
  }
}
