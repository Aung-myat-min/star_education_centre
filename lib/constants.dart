import 'package:star_education_centre/models/actions/course_actions.dart';
import 'package:star_education_centre/models/actions/enroll_actions.dart';
import 'package:star_education_centre/models/actions/student_actions.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
StudentActions studentActions = StudentActions();
CourseActions courseActions = CourseActions();
EnrollActions enrollActions = EnrollActions();

const String loginEmail = "stareducation@centre.com";
const String loginPassword =
    '12345678'; // my prefer password -> "\$starEducati0n"
