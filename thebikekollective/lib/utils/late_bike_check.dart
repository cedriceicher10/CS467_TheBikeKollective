import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<String> retrieveUsername() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var username = preferences.getString('username')!;
  return username;
}

Future<void> addToStolenBikes(bike) async{
  final q = await FirebaseFirestore.instance
      .collection('bikes')
      .doc(bike)
      .update({'Condition': 'Stolen'});
  return q;
}

Future<String> LateBikeCheck() async{
  var username = await retrieveUsername();
  var isLate = false;
  String lateType = 'none';
  var isToBeLockedOut = false;

  final eightHours = 60 * 60 * 8;
  final twentyFourHours = 60 * 60 * 24;
  final time = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

  final rideDoc = await FirebaseFirestore.instance
      .collection('rides')
      .where('rider', isEqualTo: username)
      .get();
  for(var i=0; i<rideDoc.docs.length; i++){
    var ride = rideDoc.docs[i];
    if(ride['ended'] == false){
      if((time - ride['startTime'].seconds) > eightHours){
        isLate = true;
        lateType = 'warning';
        if((time - ride['startTime'].seconds) > twentyFourHours){
          isToBeLockedOut = true;
          lateType = 'banned';
          addToStolenBikes(ride['bike']);
        }
      }
    }


  }
  if(isToBeLockedOut == true){
    final q1 = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    final userId = q1.docs[0].id;
    final q2 = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'lockedOut': true});
  }
  return lateType;
}