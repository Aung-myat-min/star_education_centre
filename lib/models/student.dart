import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference _studentFireStore =
FirebaseFirestore.instance.collection("students");

// Student Class
class Student {
  final String _sId;
  String firstName;
  String lastName;
  String email;
  String phone;
  String address;
  String section;

  Student(this._sId, this.firstName, this.lastName, this.email, this.phone,
      this.address, this.section);

  // Method to convert a Student object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'sId': _sId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'section': section,
    };
  }

  // Static method to create a Student object from Firestore data
  static Student fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      data['sId'],
      data['firstName'],
      data['lastName'],
      data['email'],
      data['phone'],
      data['address'],
      data['section'],
    );
  }

  // Create (Register) a student in Firestore
  Future<bool> registerStudent() async {
    bool status = false;

    try {
      await _studentFireStore.doc(_sId).set(toMap());
      status = true;
    } catch (error) {
      print("Error registering student: $error");
      status = false;
    }

    return status;
  }

  // Read (Get) students from Firestore
  static Future<List<Student>> readStudents() async {
    List<Student> list = [];

    try {
      QuerySnapshot snapshot = await _studentFireStore.get();
      snapshot.docs.forEach((doc) {
        Student x = fromDocument(doc);
        list.add(x);
      });
    } catch (error) {
      print('Error reading students: $error');
      list = [];
    }

    return list;
  }

  // Read student by Id
  static Future<Student?> readStudentById(String sId) async {
    try {
      QuerySnapshot snapshot =
      await _studentFireStore.where('sId', isEqualTo: sId).get();

      if (snapshot.docs.isNotEmpty) {
        return fromDocument(snapshot.docs.first);
      } else {
        return null; // No student found with the given ID
      }
    } catch (error) {
      print("Error reading student by id: $error");
      return null;
    }
  }

  // Update a student in Firestore
  Future<bool> updateStudent() async {
    bool status = false;

    try {
      await _studentFireStore.doc(_sId).update(toMap());
      status = true;
    } catch (error) {
      print("Error updating student: $error");
      status = false;
    }

    return status;
  }

  // Delete a student from Firestore
  Future<bool> deleteStudent() async {
    bool status = false;

    try {
      await _studentFireStore.doc(_sId).delete();
      status = true;
    } catch (error) {
      print("Error deleting student: $error");
      status = false;
    }

    return status;
  }
}

// Subclasses for Registered, Old, and Royal Students remain unchanged.
class RegisteredStudent extends Student {
  @override
  num getDiscount() => 5;

  RegisteredStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section);
}

class OldStudent extends Student {
  @override
  num getDiscount() => 10;

  OldStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section);
}

class RoyalStudent extends Student {
  @override
  num getDiscount() => 20;

  RoyalStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section);
}
