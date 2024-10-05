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

    return Enrollment(
      data['enId'],
      data['enrolledT'],
      data['discount'],
      data['totalFee'],
      data['studentId'],
      data['courseId'],
    );
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
      snapshot.docs.forEach((doc) {
        Enrollment x = fromDocument(doc);
        list.add(x);
      });
    } catch (error) {
      print('Error reading enrollments: $error');
      list = [];
    }

    return list;
  }

  // Read enrollment by Id
  static Future<Enrollment?> readStudentById(String enId) async {
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

  // Update a enrollment in Firestore
  Future<bool> updateStudent() async {
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
  Future<bool> deleteStudent() async {
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
