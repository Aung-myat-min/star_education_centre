//Class Course
class Course{
  final String _cId;
  String courseName;
  double fees;

  Course(this._cId, this.courseName, this.fees);

  // Getter for _cId to allow reading, but not modifying
  String get courseId => _cId;
}
