import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:star_education_centre/models/student.dart';
import 'package:star_education_centre/models/return.dart';

class StudentRepository {
  final CollectionReference _studentFireStore =
  FirebaseFirestore.instance.collection("students");

  // Method to create (register) a student in Firestore
  Future<Return> registerStudent(Student student) async {
    Return response = Return(status: false);

    try {
      await _studentFireStore.doc(student.studentId).set(student.toMap());
      response.status = true;
      response.data = student.studentId;
    } catch (error) {
      print("Error registering student: $error");
      response.status = false;
      response.data = error;
    }

    return response;
  }

  // Method to read (get) students from Firestore
  Stream<List<Student>> readStudents() {
    return _studentFireStore.snapshots().asyncMap((snapshot) async {
      List<Future<Student>> futures = snapshot.docs.map((doc) async {
        return await Student.fromDocument(doc);
      }).toList();

      return await Future.wait(futures);
    });
  }


  // Method to read a student by Id
  Future<Student?> readStudentById(String studentId) async {
    try {
      QuerySnapshot snapshot =
      await _studentFireStore.where('sId', isEqualTo: studentId).get();

      if (snapshot.docs.isNotEmpty) {
        return Student.fromDocument(snapshot.docs.first);
      } else {
        return null;
      }
    } catch (error) {
      print("Error reading student by id: $error");
      return null;
    }
  }

  // Method to update a student in Firestore
  Future<bool> updateStudent(Student student) async {
    bool status = false;

    try {
      await _studentFireStore.doc(student.studentId).update(student.toMap());
      status = true;
    } catch (error) {
      print("Error updating student: $error");
      status = false;
    }

    return status;
  }

  // Method to delete a student from Firestore
  Future<bool> deleteStudent(String studentId) async {
    bool status = false;

    try {
      await _studentFireStore.doc(studentId).delete();
      status = true;
    } catch (error) {
      print("Error deleting student: $error");
      status = false;
    }

    return status;
  }

  // Method to get the total number of students
  Future<Return> getTotalStudentNumber() async {
    Return response = Return(status: false);

    try {
      AggregateQuery query = _studentFireStore.count();
      AggregateQuerySnapshot snapshot = await query.get();
      response.status = true;
      response.data = snapshot.count;
    } catch (error) {
      print('Error $error');
      response.error = true;
      response.data = error;
    }

    return response;
  }
}
