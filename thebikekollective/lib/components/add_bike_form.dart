import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../screens/home_screen.dart';

class BikeFields {
  String? bikeName;
  String? bikeDescription;
  String? bikeCondition;
  int? bikeCombination;
  double? latitude;
  double? longitude;
  String? imageURL;
  List<String?>? bikeTags;
  bool checkedOut;
  BikeFields(
      {this.bikeName,
      this.bikeDescription,
      this.bikeCondition,
      this.bikeCombination,
      this.latitude,
      this.longitude,
      this.imageURL,
      this.bikeTags,
      this.checkedOut = false,
      });
}

// Weird bug fix: For some reason having this not be absolute global scope made
// it keep reverting (possibly a setState() infinite loop in here somewhere)
double? userLat = 0.0;
double? userLon = 0.0;

class AddBikeForm extends StatefulWidget {
  const AddBikeForm({Key? key}) : super(key: key);

  @override
  _AddBikeFormState createState() => _AddBikeFormState();
}

class _AddBikeFormState extends State<AddBikeForm> {
  final formKey = GlobalKey<FormState>();
  GlobalKey<FormFieldState> bikeNameKey = GlobalKey<FormFieldState>();
  var bikeFields = BikeFields();
  LocationData? locationData;
  bool bikeNameTaken = false;

  @override
  void initState() {
    super.initState();
    retrieveLocation();
  }

  void retrieveLocation() async {
    var locationService = Location();
    locationData = await locationService.getLocation();
    print(
        'User Location: ${locationData!.latitude}, ${locationData!.longitude}');
    userLat = locationData!.latitude;
    userLon = locationData!.longitude;
    setState(() {});
  }

  Widget build(BuildContext context) {
    final double buttonHeight = 60;
    final double buttonWidth = 260;
    //final url = ModalRoute.of(context)!.settings.arguments as String?;
    bikeFields.bikeTags = ['', '', ''];

    return Form(
        key: formKey,
        child: Column(children: [
          Container(width: 325, child: bikeNameEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: bikeConditionEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: bikeCombinationEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: bikeDescriptionEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: bikeTypeEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: bikeGearEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: bikeColorEntry()),
          SizedBox(height: 10),
          addBikeButton(buttonWidth, buttonHeight),
        ]));
  }

  Widget bikeNameEntry() {
    return TextFormField(
        autofocus: false,
        key: bikeNameKey,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Bike Name',
            labelStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            hintText: 'Please enter the name of the Bike',
            hintStyle: TextStyle(color: Color(s_jungleGreen)),
            errorStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
        onSaved: (value) {
          bikeFields.bikeName = value;
        },
        validator: (value) {

          if (value!.isEmpty) {
            return 'Please enter a name for the Bike';
          } else if (bikeNameTaken) {
              return 'Bike Name is already taken!';
          } else if (value.length > 20) {
            return 'The name of the Bike may not be greater than 20 characters';
          } else {
            return null;
          }
        });
  }

  Future<bool> uniqueCheck(String? value) async {
    bool alreadyTaken = false;
    var snapshot = await FirebaseFirestore.instance
        .collection('bikes')
        .where('name', isEqualTo: value)
        .get();
    snapshot.docs.forEach((result) {
      alreadyTaken = true;
    });
    return alreadyTaken;
  }

  Widget bikeConditionEntry() {
    String? value;
    List<String> colorList = [
      'Totaled',
      'Poor',
      'Fair',
      'Good',
      'Great',
      'Excellent'
    ];
    return DropdownButtonFormField(
      value: value,
      //decoration: InputDecoration(autofocus: true,
      //style: TextStyle(color: Color(s_jungleGreen)),
      decoration: InputDecoration(
          labelText: 'Bike\'s Condition',
          labelStyle: TextStyle(
              color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
          hintText: 'Please select the condition of the Bike',
          hintStyle: TextStyle(color: Color(s_jungleGreen)),
          errorStyle: TextStyle(
              color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
      onChanged: (value) {
        setState(() {
          bikeFields.bikeCondition = value as String?;
        });
      },
      onSaved: (value) {
        bikeFields.bikeCondition = value as String?;
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a Condition for the Bike';
        }
      },
      items: colorList.map((String value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget bikeCombinationEntry() {
    return TextFormField(
        keyboardType: TextInputType.number,
        autofocus: false,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Bike Lock Combination',
            labelStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            hintText: 'Please enter the lock\'s combination',
            hintStyle: TextStyle(color: Color(s_jungleGreen)),
            errorStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
        onSaved: (value) {
          bikeFields.bikeCombination = int.parse(value!);
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a combination.';
          } else if (value.length > 20) {
            return 'The combination may not be greater than 10 numbers.';
          } else if (value[0] == '0') {
            return 'The combination cannot start with 0.';
          }
          else {
            return null;
          }
        });
  }

  Widget bikeDescriptionEntry() {
    return TextFormField(
        autofocus: false,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Bike Description',
            labelStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            hintText: 'Please describe the Bike',
            hintStyle: TextStyle(color: Color(s_jungleGreen)),
            errorStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
        onSaved: (value) {
          bikeFields.bikeDescription = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a description';
          } else if (value.length > 50) {
            return 'The description may not be greater than 50 characters';
          } else {
            return null;
          }
        });
  }

  Widget bikeTypeEntry() {
    String? value;
    List<String> typeList = [
      'Mountain',
      'Road',
      'Hybrid',
      'Tricycle',
      'Training Wheels',
      'Electric',
      'Motorized',
    ];
    return DropdownButtonFormField(
      value: value,
      //decoration: InputDecoration(autofocus: true,
      style: TextStyle(color: Color(s_jungleGreen)),
      decoration: InputDecoration(
          labelText: 'Type of Bike',
          labelStyle: TextStyle(
              color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
          hintText: 'Please select the type of the Bike',
          hintStyle: TextStyle(color: Color(s_jungleGreen)),
          errorStyle: TextStyle(
              color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
      onChanged: (value) {
        setState(() {
          bikeFields.bikeTags![0] = value as String?;
        });
      },
      onSaved: (value) {
        bikeFields.bikeTags![0] = value as String?;
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a Type for the Bike';
        }
      },
      items: typeList.map((String value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget bikeGearEntry() {
    String? value;
    List<String> gearList = [
      'Fixie',
      'Multiple Gear',
    ];
    return DropdownButtonFormField(
      value: value,
      //decoration: InputDecoration(autofocus: true,
      style: TextStyle(color: Color(s_jungleGreen)),
      decoration: InputDecoration(
          labelText: 'Bike\'s Gears',
          labelStyle: TextStyle(
              color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
          hintText: 'Please select the type of gears for the Bike',
          hintStyle: TextStyle(color: Color(s_jungleGreen)),
          errorStyle: TextStyle(
              color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
      onChanged: (value) {
        setState(() {
          bikeFields.bikeTags![1] = value as String?;
        });
      },
      onSaved: (value) {
        bikeFields.bikeTags![1] = value as String?;
      },
      validator: (value) {
        if (value == null) {
          return 'Please select the gears for the Bike';
        }
      },
      items: gearList.map((String value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget bikeColorEntry() {
    String? value;
    List<String> colorList = [
      'Red',
      'Blue',
      'Yellow',
      'Green',
      'Pink',
      'Purple',
      'Orange',
      'Black',
      'Brown',
      'White',
      'Grey',
      'Multicolor',
    ];
    return DropdownButtonFormField(
      value: value,
      //decoration: InputDecoration(autofocus: true,
      style: TextStyle(color: Color(s_jungleGreen)),
      decoration: InputDecoration(
          labelText: 'Bike\'s Color',
          labelStyle: TextStyle(
              color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
          hintText: 'Please select the color of the Bike',
          hintStyle: TextStyle(color: Color(s_jungleGreen)),
          errorStyle: TextStyle(
              color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
      onChanged: (value) {
        setState(() {
          bikeFields.bikeTags![2] = value as String?;
        });
      },
      onSaved: (value) {
        bikeFields.bikeTags![2] = value as String?;
      },
      validator: (value) {
        if (value == null) {
          return 'Please select the color of the Bike';
        }
      },
      items: colorList.map((String value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget addBikeButton(double buttonWidth, double buttonHeight) {
    final url = ModalRoute.of(context)!.settings.arguments as String;
    bikeFields.imageURL = url;

    return ElevatedButton(
        onPressed: () async {
          bikeNameTaken = await uniqueCheck(bikeNameKey.currentState!.value);
          setState(() {});
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();

            bikeFields.latitude = userLat;
            bikeFields.longitude = userLon;
            bikeFields.imageURL = url;

            print(Text(bikeFields.toString()));
            await FirebaseFirestore.instance.collection('bikes').add({
              'Name': bikeFields.bikeName,
              'Description': bikeFields.bikeDescription,
              'Condition': bikeFields.bikeCondition,
              'Combination': bikeFields.bikeCombination,
              'Latitude': bikeFields.latitude,
              'Longitude': bikeFields.longitude,
              'imageURL': bikeFields.imageURL,
              'Tags' : bikeFields.bikeTags,
              'checkedOut': bikeFields.checkedOut,
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(map: true)),
            );
          }
        },
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: FormattedText(
          text: 'Add Bike',
          size: s_fontSizeLarge,
          color: Colors.white,
          font: s_font_AmaticSC,
          weight: FontWeight.bold,
        ));
  }
}
