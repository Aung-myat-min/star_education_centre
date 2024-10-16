import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:star_education_centre/models/course.dart';
import 'package:star_education_centre/models/return.dart';

class CourseActions {
  final CollectionReference _courseFireStore =
      FirebaseFirestore.instance.collection("courses");

  Future<Return> getTotalCourseNumber() async {
    Return response = Return(status: false);

    try {
      AggregateQuery query = _courseFireStore.count();

      // Execute the count query
      AggregateQuerySnapshot snapshot = await query.get();

      // Assign the count result to the response
      response.status = true;

      // The number of documents (students)
      response.data = snapshot.count;
    } catch (error) {
      print('Error $error');
      response.error = true;

      // Assign the error to the response
      response.data = error;
      rethrow;
    }

    return response;
  }

  // Create (Register) a course in Firestore
  Future<bool> createCourse(Course course) async {
    bool status = false;

    try {
      await _courseFireStore.doc(course.courseId).set((course.toMap()));
      status = true;
    } catch (error) {
      print("Error registering course: $error");
      status = false;
    }

    return status;
  }

  // Read (Get) courses from Firestore
  Stream<List<Course>> getCourses() {
    return _courseFireStore.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Course.fromDocument(doc)).toList();
    });
  }

  // Read student by Id
  Future<Course?> readCourseById(String cId) async {
    try {
      QuerySnapshot snapshot =
          await _courseFireStore.where('cId', isEqualTo: cId).get();

      if (snapshot.docs.isNotEmpty) {
        return Course.fromDocument(snapshot.docs.first);
      } else {
        return null;
      }
    } catch (error) {
      print("Error reading course by id: $error");
      return null;
    }
  }

  // Update a student in Firestore
  Future<bool> updateCourse(Course course) async {
    bool status = false;

    try {
      await _courseFireStore.doc(course.courseId).update(course.toMap());
      status = true;
    } catch (error) {
      print("Error updating course: $error");
      status = false;
    }

    return status;
  }

  // Delete a student from Firestore
  Future<bool> deleteCourse(Course course) async {
    bool status = false;

    try {
      await _courseFireStore.doc(course.courseId).delete();
      status = true;
    } catch (error) {
      print("Error deleting student: $error");
      status = false;
    }

    return status;
  }
}
