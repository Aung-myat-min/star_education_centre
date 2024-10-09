import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/models/return.dart';

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

  // Method to get the 3 most popular courses
  static Future<List<Map<String, dynamic>>> getMostPopularCourses() async {
    try {
      QuerySnapshot snapshot = await _enrollmentFireStore.get();
      Map<String, int> courseEnrollmentCount = {};

      // Count enrollments for each course
      for (var doc in snapshot.docs) {
        Enrollment enrollment = fromDocument(doc);
        courseEnrollmentCount[enrollment.courseId] =
            (courseEnrollmentCount[enrollment.courseId] ?? 0) + 1;
      }

      // Sort courses by the number of enrollments in descending order
      var sortedCourses = courseEnrollmentCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Take the top 3 courses
      List<Map<String, dynamic>> topCourses = [];

      for (var entry in sortedCourses.take(3)) {
        String courseId = entry.key;
        Course? course = await Course.readCourseById(courseId);
        if (course != null) {
          topCourses.add({
            'courseName': course.courseName,
            'price': course.fees.toString(),
            'enrollments': entry.value, // Number of enrollments
          });
        }
      }

      return topCourses;
    } catch (error) {
      print('Error finding most popular courses: $error');
      return [];
    }
  }

  static Future<Return> getTotalEnrollmentsNumber() async {
    Return response = Return(status: false);

    try {
      AggregateQuery query = _enrollmentFireStore.count();

      // Execute the count query
      AggregateQuerySnapshot snapshot = await query.get();

      // Assign the count result to the response
      response.status = true;
      response.data = snapshot.count; // The number of documents (students)
    } catch (error) {
      print('Error $error');
      response.error = true;
      response.data = error; // Assign the error to the response
      rethrow;
    }

    return response;
  }

  static Stream<List<Enrollment>> getEnrollmentByCourseAndDate(
      String courseId, DateTime date) {
    // Create timestamps for the start and end of the day
    Timestamp startDate = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 0, 0, 0)); // Start of the day
    Timestamp endDate = Timestamp.fromDate(DateTime(
        date.year, date.month, date.day, 23, 59, 59)); // End of the day

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
