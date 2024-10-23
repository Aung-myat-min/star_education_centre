import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:star_education_centre/models/student.dart';

class StudentFactory {
  // Factory method to create instances based on number of enrollments
  static Student determineStudentClass({
    required String sId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required Timestamp startDate,
    required String section,
    required int numberOfCourses,
  }) {
    switch (numberOfCourses) {
      case 0:
        return Student(
          sId: sId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          address: address,
          section: section,
          startDate: startDate,
          numberOfCourses: numberOfCourses,
        );
      case 1:
        return RegisteredStudent(
          sId: sId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          address: address,
          section: section,
          startDate: startDate,
          numberOfCourses: numberOfCourses,
        );
      case 2:
        return OldStudent(
          sId: sId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          address: address,
          section: section,
          startDate: startDate,
          numberOfCourses: numberOfCourses,
        );
      default:
        return RoyalStudent(
          sId: sId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          address: address,
          section: section,
          startDate: startDate,
          numberOfCourses: numberOfCourses,
        );
    }
  }
}
