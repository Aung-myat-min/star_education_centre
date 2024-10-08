import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:star_education_centre/models/return.dart';

final CollectionReference _attendanceFireStore =
FirebaseFirestore.instance.collection("attendances");

class Attendance {
  final String _aId;
  DateTime attendanceDate;
  List<String> listOfStudentId;  // Present students
  String courseId;
  List<String> absentsStudents;  // Absent students

  Attendance(this._aId, this.attendanceDate, this.listOfStudentId, this.courseId, this.absentsStudents);

  String get attendanceId => _aId;

  Map<String, dynamic> toMap() {
    return {
      'aId': _aId,
      'attendanceDate': Timestamp.fromDate(attendanceDate),
      'listOfStudentId': listOfStudentId,
      'courseId': courseId,
      'absentsStudents': absentsStudents,
    };
  }

  static Attendance fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Attendance(
      data['aId'],
      (data['attendanceDate'] as Timestamp).toDate(),
      List<String>.from(data['listOfStudentId']),
      data['courseId'],
      List<String>.from(data['absentsStudents']),
    );
  }

// Register attendance with path organized by date and courseId
  Future<Return> makeAttendance() async {
    Return response = Return(status: false);

    try {
      // Format the attendance date to use as the document path
      String formattedDate = DateFormat('MM-dd-yyyy').format(attendanceDate);

      // Set the document path based on date and courseId
      await _attendanceFireStore
          .doc(formattedDate)
          .collection(courseId)
          .doc(_aId)
          .set(toMap());

      response.status = true;
      response.data = _aId;
    } catch (error) {
      print("Error registering attendance: $error");
      response.status = false;
      response.data = error.toString();
    }

    return response;
  }


  static Future<Return<Stream<List<Attendance>>>> getAttendanceByDate(DateTime date) async {
    Return<Stream<List<Attendance>>> response = Return(status: false);

    try {
      // Format the date to match the Firestore document structure (e.g., "MM-dd-yyyy")
      String formattedDate = DateFormat('MM-dd-yyyy').format(date);

      // Fetch attendance data from Firestore by the formatted date
      Stream<List<Attendance>> attendanceStream = _attendanceFireStore
          .doc(formattedDate)
          .collection('courses')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Attendance.fromDocument(doc)).toList();
      });

      // Set the success response with the data stream
      response.status = true;
      response.data = attendanceStream;

    } catch (error) {
      print("Error getting attendance by date: $error");
      response.error = true;
      response.data = error.toString() as Stream<List<Attendance>>;
    }

    return response;
  }

  // Method to remove present students and add them to absent list
  Future<Return> removeStudents(List<String> studentsToRemove) async {
    Return response = Return(status: false);
    try {
      // Format the attendance date to use as the document path
      String formattedDate = DateFormat('MM-dd-yyyy').format(attendanceDate);

      // Update both present and absent lists
      await _attendanceFireStore
          .doc(formattedDate)
          .collection(courseId)
          .doc(_aId)
          .update({
        'listOfStudentId': FieldValue.arrayRemove(studentsToRemove),
        'absentsStudents': FieldValue.arrayUnion(studentsToRemove),
      });

      response.status = true;
      response.data = 'Removed students from present list and added to absent list';
    } catch (error) {
      print("Error removing students: $error");
      response.error = true;
      response.data = error.toString();
    }
    return response;
  }

  // Method to add present students and remove them from absent list
  Future<Return> addStudents(List<String> studentsToAdd) async {
    Return response = Return(status: false);
    try {
      // Format the attendance date to use as the document path
      String formattedDate = DateFormat('MM-dd-yyyy').format(attendanceDate);

      // Update both present and absent lists
      await _attendanceFireStore
          .doc(formattedDate)
          .collection(courseId)
          .doc(_aId)
          .update({
        'listOfStudentId': FieldValue.arrayUnion(studentsToAdd),
        'absentsStudents': FieldValue.arrayRemove(studentsToAdd),
      });

      response.status = true;
      response.data = 'Added students to present list and removed from absent list';
    } catch (error) {
      print("Error adding students: $error");
      response.error = true;
      response.data = error.toString();
    }
    return response;
  }

}
