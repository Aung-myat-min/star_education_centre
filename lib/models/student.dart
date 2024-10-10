import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:star_education_centre/models/return.dart';

final CollectionReference _studentFireStore =
    FirebaseFirestore.instance.collection("students");

class Student {
  final String _sId;
  String firstName;
  String lastName;
  String email;
  String phone;
  String address;
  String section;
  Timestamp startDate;

  Student(this._sId, this.firstName, this.lastName, this.email, this.phone,
      this.address, this.section, this.startDate);

  String get studentId => _sId;

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

  // Create a Student object from Firestore data
  static Student fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp startDate = data['startDate'] as Timestamp;

    return Student(
      data['sId'],
      data['firstName'],
      data['lastName'],
      data['email'],
      data['phone'],
      data['address'],
      data['section'],
      startDate,
    );
  }

  static int getDiscount() => 0;
}

// Subclasses for Registered, Old, and Royal Students remain unchanged.
class RegisteredStudent extends Student {
  static int getDiscount() => 5;

  RegisteredStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section, super.startDate);
}

class OldStudent extends Student {
  static int getDiscount() => 10;

  OldStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section, super.startDate);
}

class RoyalStudent extends Student {
  static int getDiscount() => 20;

  RoyalStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section, super.startDate);
}
