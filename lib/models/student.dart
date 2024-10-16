import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:star_education_centre/models/person.dart';

// Default student class
class Student implements Person {
  final String _sId;
  @override
  String firstName;
  @override
  String lastName;
  @override
  String email;
  @override
  String phone;
  @override
  String address;
  String section;
  Timestamp startDate;
  int numberOfCourses;

  Student({
    required String sId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.section,
    required this.startDate,
    required this.numberOfCourses,
  }) : _sId = sId;

  String get studentId => _sId;

  int getDiscount() => 0;

  // Convert a Student object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'sId': _sId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'section': section,
      'startDate': startDate,
      'numberOfCourses': numberOfCourses
    };
  }

  // Create a Student object from Firestore data
  static Student fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Ensure the values are extracted correctly
    final String sId = data['sId'] as String;
    final String firstName = data['firstName'] as String;
    final String lastName = data['lastName'] as String;
    final String email = data['email'] as String;
    final String phone = data['phone'] as String;
    final String address = data['address'] as String;
    final String section = data['section'] as String;
    final Timestamp startDate = data['startDate'] as Timestamp;
    final int numberOfCourses = data['numberOfCourses'];

    return determineStudentClass(
      sId: sId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      startDate: startDate,
      section: section,
      numberOfCourses: numberOfCourses,
    );
  }

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

// Subclasses for Registered, Old, and Royal Students
class RegisteredStudent extends Student {
  RegisteredStudent({
    required super.sId,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.address,
    required super.section,
    required super.startDate,
    required super.numberOfCourses,
  });

  @override
  int getDiscount() => 5; // Override to provide specific discount
}

class OldStudent extends Student {
  OldStudent({
    required super.sId,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.address,
    required super.section,
    required super.startDate,
    required super.numberOfCourses,
  });

  @override
  int getDiscount() => 10; // Override to provide specific discount
}

class RoyalStudent extends Student {
  RoyalStudent({
    required super.sId,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.address,
    required super.section,
    required super.startDate,
    required super.numberOfCourses,
  });

  @override
  int getDiscount() => 20; // Override to provide specific discount
}
