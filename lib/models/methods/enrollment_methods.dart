import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:star_education_centre/models/return.dart';

final CollectionReference _enrollmentFireStore =
FirebaseFirestore.instance.collection('enrollments');

Future<Return> getNumbersOfEnrollments(String studentId) async{
  Return response = new Return(status: false, data: null);

  try{
    AggregateQuery courseNumbers = await _enrollmentFireStore.where('studentId', isEqualTo: studentId).count();
    int? count = (await courseNumbers.get()).count;
    response.data = count;
  }catch(error){
    response.error = true;
  }
  return response;
}