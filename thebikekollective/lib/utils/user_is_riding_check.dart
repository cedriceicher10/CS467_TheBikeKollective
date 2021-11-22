import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<String> retrieveUsername() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var username = preferences.getString('username')!;
  return username;
}

Future<String> UserIsRiding() async{
  var username = await retrieveUsername();

  final q = await FirebaseFirestore.instance
      .collection('rides')
      .where('rider', isEqualTo: username)
      .get();
  if( q.docs.length > 0 ){
    for(var i=0; i<q.docs.length; i++){
      if(q.docs[i]['ended'] == false){
        return q.docs[i]['bike'];
      }
    }

  }
  return 'none';
}