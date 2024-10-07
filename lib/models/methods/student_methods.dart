import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/models/enrollment.dart';
import 'package:star_education_centre/models/methods/enrollment_methods.dart';
import 'package:star_education_centre/models/return.dart';
import 'package:star_education_centre/models/student.dart';

//return status only
Future<Return> enrollCourse(
    String studentId, String courseId, double courseFee) async {
  Return response = new Return(status: false);

  try {
    final String enId = uuid.v1();
    final DateTime enrolledT = new DateTime.now();
    final int numberOfCourses = await getNumbersOfEnrollments(studentId)
        .then((response) => response.data);

    // Calculate the discount
    final int discount;
    if (numberOfCourses >= 3) {
      discount = RoyalStudent.getDiscount();
    } else if (numberOfCourses == 1) {
      discount = RegisteredStudent.getDiscount();
    } else if (numberOfCourses == 2) {
      discount = OldStudent.getDiscount();
    } else {
      discount = Student.getDiscount();
    }

    //calculating total amount
    double discountAmount = (courseFee * discount) / 100;
    double totalFee = courseFee - discountAmount;

    Enrollment newEnrollment = new Enrollment(
        enId, discount, enrolledT, totalFee, studentId, courseId);
    bool status = await newEnrollment.enrollStudent();
    if (status) {
      response.status = true;
    } else {
      response.status = false;
    }
  } catch (error) {
    print("Error Enrolling A Course: $error");
    response.status = false;
  }
  return response;
}
