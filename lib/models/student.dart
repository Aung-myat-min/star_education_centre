import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Person {
  String get firstName;

  String get lastName;

  String get email;

  String get phone;

  String get address;
}

//default student class
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

  Student(this._sId, this.firstName, this.lastName, this.email, this.phone,
      this.address, this.section, this.startDate, this.numberOfCourses);

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

    return determineStudentClass(sId, firstName, lastName, email, phone,
        address, startDate, section, numberOfCourses);
  }

  // Factory method to create instances based on number of enrollments
  static Student determineStudentClass(
      String sId,
      String firstName,
      String lastName,
      String email,
      String phone,
      String address,
      Timestamp startDate,
      String section,
      int numberOfCourses) {
    switch (numberOfCourses) {
      case 0:
        return Student(sId, firstName, lastName, email, phone, address, section,
            startDate, numberOfCourses);
      case 1:
        return RegisteredStudent(sId, firstName, lastName, email, phone,
            address, section, startDate, numberOfCourses);
      case 2:
        return OldStudent(sId, firstName, lastName, email, phone, address,
            section, startDate, numberOfCourses);
      default:
        return RoyalStudent(sId, firstName, lastName, email, phone, address,
            section, startDate, numberOfCourses);
    }
  }
}

// Subclasses for Registered, Old, and Royal Students
class RegisteredStudent extends Student {
  RegisteredStudent(
      super.sId,
      super.firstName,
      super.lastName,
      super.email,
      super.phone,
      super.address,
      super.section,
      super.startDate,
      super.numberOfCourses);

  @override
  int getDiscount() => 5; // Override to provide specific discount
}

class OldStudent extends Student {
  OldStudent(
      super.sId,
      super.firstName,
      super.lastName,
      super.email,
      super.phone,
      super.address,
      super.section,
      super.startDate,
      super.numberOfCourses);

  @override
  int getDiscount() => 10; // Override to provide specific discount
}

class RoyalStudent extends Student {
  RoyalStudent(
      super.sId,
      super.firstName,
      super.lastName,
      super.email,
      super.phone,
      super.address,
      super.section,
      super.startDate,
      super.numberOfCourses);

  @override
  int getDiscount() => 20; // Override to provide specific discount
}
