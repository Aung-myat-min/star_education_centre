import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_education_centre/models/factory/student_factory.dart';
import 'package:star_education_centre/models/student.dart';

void main() {
  group('StudentFactory Tests', () {
    test('Should return RegisteredStudent for 1-2 courses', () {
      // Arrange
      final student = StudentFactory.determineStudentClass(
        sId: 'S1',
        firstName: 'Aung',
        lastName: 'Min',
        email: 'aung.min@example.com',
        phone: '09123456789',
        address: 'Yangon, Myanmar',
        startDate: Timestamp.now(),
        section: 'A',
        numberOfCourses: 1, // Registering with 1 course
      );

      // Assert
      expect(student, isA<RegisteredStudent>());
      expect(student.getDiscount(), 5);
    });

    test('Should return OldStudent for 2 courses', () {
      // Arrange
      final student = StudentFactory.determineStudentClass(
        sId: 'S2',
        firstName: 'Thida',
        lastName: 'Oo',
        email: 'thida.oo@example.com',
        phone: '0987654321',
        address: 'Mandalay, Myanmar',
        startDate: Timestamp.now(),
        section: 'B',
        numberOfCourses: 2, // Registering with 2 courses
      );

      // Assert
      expect(student, isA<OldStudent>());
      expect(student.getDiscount(), 10);
    });

    test('Should return RoyalStudent for 5 or more courses', () {
      // Arrange
      final student = StudentFactory.determineStudentClass(
        sId: 'S3',
        firstName: 'Kyaw',
        lastName: 'Zaw',
        email: 'kyaw.zaw@example.com',
        phone: '09777777777',
        address: 'Naypyidaw, Myanmar',
        startDate: Timestamp.now(),
        section: 'C',
        numberOfCourses: 5, // Registering with 5 courses
      );

      // Assert
      expect(student, isA<RoyalStudent>());
      expect(student.getDiscount(), 20);
    });
  });
}
