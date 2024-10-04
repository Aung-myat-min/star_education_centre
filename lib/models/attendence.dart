class Attendence{
  final String _aId;
  DateTime attendenceDate;
  List<String> listOfStudentId;
  String courseId;

  Attendence(this._aId, this.attendenceDate, this.listOfStudentId, this.courseId);

  String get attendenceId => _aId;
}