
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference _courseFireStore =
FirebaseFirestore.instance.collection("courses");


//Class Course
class Course{
  final String _cId;
  String courseName;
  double fees;
  String aboutCourse;

  Course(this._cId, this.courseName, this.fees, this.aboutCourse);

  // Getter for _cId to allow reading, but not modifying
  String get courseId => _cId;

  // Method to convert a Student object to a Map (for Firestore)
  Map<String, dynamic> toMap(){
    return {
      'cId': _cId,
      'courseName': courseName,
      'fees': fees,
      'aboutCourse': aboutCourse
    };
  }

  // Static method to create a Course object from Firestore data
  static Course fromDocument(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      data['cId'],
      data['courseName'],
      data['fees'],
      data['aboutCourse']
    );
  }

  // Create (Register) a course in Firestore
  Future<bool> createCourse() async {
    bool status = false;

    try {
      await _courseFireStore.doc(_cId).set(toMap());
      status = true;
    } catch (error) {
      print("Error registering course: $error");
      status = false;
    }

    return status;
  }

  // Read (Get) courses from Firestore
  static Stream<List<Course>> getCourses() {
    return _courseFireStore.snapshots().map((snapshot){
      return snapshot.docs.map((doc) => fromDocument(doc)).toList();
    });
  }

  // Read student by Id
  static Future<Course?> readCourseById(String cId) async {
    try {
      QuerySnapshot snapshot =
      await _courseFireStore.where('cId', isEqualTo: cId).get();

      if (snapshot.docs.isNotEmpty) {
        return fromDocument(snapshot.docs.first);
      } else {
        return null;
      }
    } catch (error) {
      print("Error reading course by id: $error");
      return null;
    }
  }

  // Update a student in Firestore
  Future<bool> updateCourse() async {
    bool status = false;

    try {
      await _courseFireStore.doc(_cId).update(toMap());
      status = true;
    } catch (error) {
      print("Error updating course: $error");
      status = false;
    }

    return status;
  }

  // Delete a student from Firestore
  Future<bool> deleteCourse() async {
    bool status = false;

    try {
      await _courseFireStore.doc(_cId).delete();
      status = true;
    } catch (error) {
      print("Error deleting student: $error");
      status = false;
    }

    return status;
  }
}
