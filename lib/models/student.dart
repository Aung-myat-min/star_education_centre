import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:star_education_centre/models/methods/enrollment_methods.dart';

abstract class StudentSkeleton {
  String get studentId;
  String get firstName;
  String get lastName;
  String get email;
  String get phone;
  String get address;
  String get section;
  Timestamp get startDate;

  int getDiscount(); // Abstract method for discount
}

//default student class
class Student implements StudentSkeleton {
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
  @override
  String section;
  @override
  Timestamp startDate;

  Student(this._sId, this.firstName, this.lastName, this.email, this.phone,
      this.address, this.section, this.startDate);

  @override
  String get studentId => _sId;

  // Implementing the getDiscount method
  @override
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
    };
  }

  // Factory method to create instances based on number of enrollments
  static Student determineStudentClass(
      String sId, String firstName, String lastName,
      String email, String phone, String address,
      Timestamp startDate, String section, int numberOfEnrollments) {
    if (numberOfEnrollments >= 3) {
      return RoyalStudent(sId, firstName, lastName, email, phone, address,section, startDate);
    } else if (numberOfEnrollments == 2) {
      return OldStudent(sId, firstName, lastName, email, phone, address, section, startDate);
    } else if (numberOfEnrollments == 1) {
      return RegisteredStudent(sId, firstName, lastName, email, phone, address,section, startDate);
    } else {
      return Student(sId, firstName, lastName, email, phone, address,section, startDate);
    }
  }

  // Create a Student object from Firestore data
  static Future<Student> fromDocument(DocumentSnapshot doc)async {
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
    final int numberOfCourses = await getNumbersOfEnrollments(sId)
        .then((response) => response.data);

    return determineStudentClass(
      sId,
      firstName,
      lastName,
      email,
      phone,
      address,
      startDate,
      section,
      numberOfCourses
    );
  }
}

// Subclasses for Registered, Old, and Royal Students
class RegisteredStudent extends Student {
  RegisteredStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section, super.startDate);

  @override
  int getDiscount() => 5; // Override to provide specific discount
}

class OldStudent extends Student {
  OldStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section, super.startDate);

  @override
  int getDiscount() => 10; // Override to provide specific discount
}

class RoyalStudent extends Student {
  RoyalStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section, super.startDate);

  @override
  int getDiscount() => 20; // Override to provide specific discount
}
