import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/models/enrollment.dart';
import 'package:star_education_centre/models/methods/enrollment_methods.dart';
import 'package:star_education_centre/models/return.dart';
import 'package:star_education_centre/models/student.dart';

//return status only
Future<Return> enrollCourses(
    String studentId, Map<String, double> courseFeesMap) async {
  Return response = Return(status: false);
  bool allEnrollmentsSuccessful = true;

  try {
    final DateTime enrolledT = DateTime.now();
    final int numberOfCourses = await getNumbersOfEnrollments(studentId)
        .then((response) => response.data);

    // Calculate the discount based on the number of enrollments
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

    // Loop through each course and enroll the student
    for (String courseId in courseFeesMap.keys) {
      double courseFee = courseFeesMap[courseId]!;

      // Calculate the discounted total amount
      double discountAmount = (courseFee * discount) / 100;
      double totalFee = courseFee - discountAmount;

      // Generate enrollment ID
      final String enId = uuid.v1();

      Enrollment newEnrollment = Enrollment(
        enId,
        discount,
        enrolledT,
        totalFee,
        studentId,
        courseId,
      );

      // Attempt to enroll the student in the course
      bool status = await enrollRepository.enrollStudent(newEnrollment);
      if (!status) {
        allEnrollmentsSuccessful = false;
      }
    }

    // Set the response based on whether all enrollments were successful
    response.status = allEnrollmentsSuccessful;

  } catch (error) {
    print("Error Enrolling Courses: $error");
    response.status = false;
  }
  return response;
}
