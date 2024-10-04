//Student Class
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

  // Method to calculate discount, overridden in subclasses
  num getDiscount() {
    return 0;
  }

  //Getter for StudentId
  String get studentId => _sId;

}

class RegisteredStudent extends Student {
  @override
  num getDiscount() => 5;

  RegisteredStudent(super.sId, super.firstName, super.lastName, super.email,
      super.phone, super.address, super.section);
}

class OldStudent extends Student {
  @override
  num getDiscount() => 10;

  OldStudent(super.sId, super.firstName, super.lastName, super.email, super.phone,
      super.address, super.section);
}

class RoyalStudent extends Student {
  @override
  num getDiscount() => 20;

  RoyalStudent(super.sId, super.firstName, super.lastName, super.email, super.phone,
      super.address, super.section);
}
