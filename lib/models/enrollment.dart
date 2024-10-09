import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference _enrollmentFireStore =
    FirebaseFirestore.instance.collection('enrollments');

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

  static Stream<List<Enrollment>> getEnrollmentByCourseAndDate(
      String courseId, DateTime date) {
    // Create timestamps for the start and end of the day
    Timestamp startDate = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 0, 0, 0)); // Start of the day
    Timestamp endDate = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59)); // End of the day

    print('Course ID: $courseId, Date: $date');
    return _enrollmentFireStore
        .where('courseId', isEqualTo: courseId)
        .where('enrolledT', isGreaterThanOrEqualTo: startDate)
        .where('enrolledT', isLessThanOrEqualTo: endDate)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Enrollment.fromDocument(doc);
      }).toList();
    });
  }

  // Create (Register) an enrollment in Firestore
  Future<bool> enrollStudent() async {
    bool status = false;

    try {
      await _enrollmentFireStore.doc(_enId).set(toMap());
      status = true;
    } catch (error) {
      print("Error creating enrollment: $error");
      status = false;
    }

    return status;
  }

  // Read (Get) enrollments from Firestore
  static Future<List<Enrollment>> getEnrollments() async {
    List<Enrollment> list = [];

    try {
      QuerySnapshot snapshot = await _enrollmentFireStore.get();
      for (var doc in snapshot.docs) {
        Enrollment x = fromDocument(doc);
        list.add(x);
      }
    } catch (error) {
      print('Error reading enrollments: $error');
      list = [];
    }

    return list;
  }

  // Read enrollment by Id
  static Future<Enrollment?> readEnrollmentById(String enId) async {
    try {
      QuerySnapshot snapshot =
          await _enrollmentFireStore.where('enId', isEqualTo: enId).get();

      if (snapshot.docs.isNotEmpty) {
        return fromDocument(snapshot.docs.first);
      } else {
        return null;
      }
    } catch (error) {
      print("Error reading enrollment by id: $error");
      return null;
    }
  }

  static Stream<List<Enrollment>> getEnrollmentByStudent(String studentId) {
    return _enrollmentFireStore
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Enrollment.fromDocument(doc);
      }).toList();
    });
  }

  // Update a enrollment in Firestore
  Future<bool> updateEnrollment() async {
    bool status = false;

    try {
      await _enrollmentFireStore.doc(_enId).update(toMap());
      status = true;
    } catch (error) {
      print("Error updating enrollment: $error");
      status = false;
    }

    return status;
  }

  // Delete a enrollment from Firestore
  Future<bool> deleteEnrollment() async {
    bool status = false;

    try {
      await _enrollmentFireStore.doc(_enId).delete();
      status = true;
    } catch (error) {
      print("Error deleting enrollment: $error");
      status = false;
    }

    return status;
  }
}
