import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'home_screen_toggle.dart';
import 'styles.dart';
import 'formatted_text.dart';
import 'add_bike_fab.dart';
import '../utils/haversine_calculator.dart';

const GEOFENCE_DISTANCE = 10.0; // mi

class PostTile {
  String id;
  String name;
  String description;
  String condition;
  int combination;
  double latitude;
  double longitude;
  String imageURL;
  bool checkedOut; // TO DO: Use when checkedOut field is active
  List<dynamic> tags; // TO DO: Use when tags are active
  double distanceToUser;
  PostTile(
      {required this.id,
      required this.name,
      required this.description,
      required this.condition,
      required this.combination,
      required this.latitude,
      required this.longitude,
      required this.imageURL,
      required this.checkedOut, // TO DO: Use when checkedOut field is active
      required this.tags, // TO DO: Use when tags are active
      required this.distanceToUser});
}

class ListViewBody extends StatefulWidget {
  const ListViewBody({Key? key}) : super(key: key);

  @override
  _ListViewBodyState createState() => _ListViewBodyState();
}

class _ListViewBodyState extends State<ListViewBody> {
  String sortString = 'Sort by: Distance';
  List<String> sortItems = <String>['Sort by: Distance', 'Sort by: Condition'];
  String filterString = 'No Filter';
  List<String> filterItems = <String>[
    'No Filter',
    'Filter by: Condition',
    'Filter by: Tag'
  ];
  String conditionString = 'Excellent';
  List<String> conditionItems = <String>[
    'Excellent',
    'Great',
    'Good',
    'Fair',
    'Poor',
    'Totaled'
  ];
  String tagString = 'Mountain'; // TO DO: Use when tags are active
  List<String> tagItems = <String>[
    'Mountain',
    'Road',
    'Hybrid',
    'Electric',
    'Motorized',
    'Multiple Gear',
    'Tricycle',
    'Training Wheels'
  ];
  bool filterCondition = false;
  bool filterTag = false;
  double userLat = 0.0;
  double userLon = 0.0;
  String bikeId = 'no bike';

  Future<LocationData> retrieveLocation() async {
    var locationService = Location();
    var locationUser = await locationService.getLocation();
    userLat = locationUser.latitude!;
    userLon = locationUser.longitude!;
    print('User Location: ${locationUser.latitude}, ${locationUser.longitude}');
    return locationUser;
  }

  Stream<QuerySnapshot<Object?>> bikeQuery() {
    if (filterString == 'Filter by: Condition') {
      return FirebaseFirestore.instance
          .collection('bikes')
          .where('Condition', isEqualTo: conditionString)
          .snapshots();
    } else if (filterString == 'Filter by: Tag') {
      // TO DO: Use when tags are active
      return FirebaseFirestore.instance
          .collection('bikes')
          .where('Tags', arrayContains: tagString)
          .snapshots();
    } else {
      print('here');
      return FirebaseFirestore.instance
          .collection('bikes')
          .where('checkedOut', isEqualTo: false)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
          filterSortButtons(),
          tapBikeText(),
          listViewBikes(),
        ]),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AddBikeFAB(),
              SizedBox(height: 10),
              HomeScreenToggle(map: true)
            ]));
  }

  Widget filterSortButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          height: 40,
          child: DropdownButton<String>(
            value: sortString,
            icon: const Icon(Icons.arrow_drop_down,
                color: Color(s_cadmiumOrange)),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Color(s_cadmiumOrange)),
            underline: Container(
              height: 2,
              color: Color(s_cadmiumOrange),
            ),
            onChanged: (String? newValue) {
              sortString = newValue!;
              setState(() {});
            },
            items: sortItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: dropDownText(value),
              );
            }).toList(),
          )),
      SizedBox(width: 20),
      Container(
          height: 40,
          child: DropdownButton<String>(
            value: filterString,
            icon: const Icon(Icons.arrow_drop_down,
                color: Color(s_cadmiumOrange)),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Color(s_cadmiumOrange)),
            underline: Container(
              height: 2,
              color: Color(s_cadmiumOrange),
            ),
            onChanged: (String? newValue) {
              filterString = newValue!;
              if (filterString == 'Filter by: Condition') {
                filterCondition = true;
              } else {
                filterCondition = false;
              }
              if (filterString == 'Filter by: Tag') {
                filterTag = true;
              } else {
                filterTag = false;
              }
              setState(() {});
            },
            items: filterItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: dropDownText(value),
              );
            }).toList(),
          )),
      SizedBox(width: 20),
      filterCondition
          ? Container(
              height: 40,
              child: DropdownButton<String>(
                value: conditionString,
                icon: const Icon(Icons.arrow_drop_down,
                    color: Color(s_cadmiumOrange)),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Color(s_cadmiumOrange)),
                underline: Container(
                  height: 2,
                  color: Color(s_cadmiumOrange),
                ),
                onChanged: (String? newValue) {
                  conditionString = newValue!;
                  setState(() {});
                },
                items: conditionItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: dropDownText(value),
                  );
                }).toList(),
              ))
          : Container(), // Hides condition drop-down when filter isn't on Filter: Condition
      filterTag // TO DO: Use when tags are active
          ? Container(
              height: 40,
              child: DropdownButton<String>(
                value: tagString,
                icon: const Icon(Icons.arrow_drop_down,
                    color: Color(s_cadmiumOrange)),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Color(s_cadmiumOrange)),
                underline: Container(
                  height: 2,
                  color: Color(s_cadmiumOrange),
                ),
                onChanged: (String? newValue) {
                  tagString = newValue!;
                  setState(() {});
                },
                items: tagItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: dropDownText(value),
                  );
                }).toList(),
              ))
          : Container() // Hides filter drop-down when filter isn't on Filter: Tags
    ]);
  }

  Widget listViewBikes() {
    return FutureBuilder(
        future: retrieveLocation(),
        builder: (BuildContext context, snapshotLocation) {
          if (snapshotLocation.hasData) {
            return StreamBuilder(
                stream: bikeQuery(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshotBikes) {
                  if (snapshotBikes.hasData) {
                    var snapMap = postBuilder(
                        snapshotBikes); // Converts to custom List<Map> that's easier to pass around
                    var posts = sortSnapshot(snapMap);
                    if (posts.length == 0) {
                      return noBikesFound();
                    } else {
                      return Flexible(
                          child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          var post = posts[index];
                          return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Color(s_jungleGreen), width: 1),
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                  isThreeLine: true,
                                  title: entryName(post.name),
                                  subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        entryDescription(post.description),
                                        conditionDescription(
                                            'Distance: ${post.distanceToUser.toStringAsFixed(2)} mi | Condition: ${post.condition}'),
                                      ]),
                                  trailing:
                                      Image(image: NetworkImage(post.imageURL)),
                                  contentPadding: EdgeInsets.all(10),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        // Take note of chosen bike for Ride screen
                                        bikeId = post.id;
                                        print('Chose: $bikeId');
                                        return AlertDialog(
                                          title: alertTitle("Start Ride"),
                                          content: alertText(
                                              "Would you like to start a ride with this bike?"),
                                          actions: [
                                            reportStolenButton(),
                                            startRideButton(),
                                          ],
                                        );
                                      },
                                    );
                                  }));
                        },
                      ));
                    }
                  } else {
                    return bikesLoading();
                  }
                });
          } else {
            return bikesLoading();
          }
        });
  }

  List<PostTile> postBuilder(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshotBikes) {
    List<PostTile> posts = [];
    for (var index = 0; index < snapshotBikes.data!.size; ++index) {
      PostTile post = PostTile(
          id: snapshotBikes.data!.docs[index].id,
          name: snapshotBikes.data!.docs[index]['Name'],
          description: snapshotBikes.data!.docs[index]['Description'],
          condition: snapshotBikes.data!.docs[index]['Condition'],
          latitude: snapshotBikes.data!.docs[index]['Latitude'],
          longitude: snapshotBikes.data!.docs[index]['Longitude'],
          imageURL: snapshotBikes.data!.docs[index]['imageURL'],
          combination: snapshotBikes.data!.docs[index]['Combination'],
          checkedOut: snapshotBikes.data!.docs[index]
              ['checkedOut'], // TO DO: Use when checkedOut field is active
          tags: snapshotBikes.data!.docs[index]
              ['Tags'], // TO DO: Use when tags are active
          distanceToUser: 0.0);
      posts.add(post);
    }
    return posts;
  }

  List<PostTile> sortSnapshot(List<PostTile> postList) {
    List<PostTile> geoFencedPosts = [];
    // Add distance to user for each bike
    postList.forEach((bike) {
      bike.distanceToUser =
          haversineCalculator(userLat, userLon, bike.latitude, bike.longitude);
      // Cut off bikes that are more than GEOFENCE_DISTANCE or Checked-Out (in a current ride)
      if ((bike.distanceToUser < GEOFENCE_DISTANCE) &&
          (bike.condition != 'Stolen')) {
        // TO DO: Use when Stolen field is active
        geoFencedPosts.add(bike);
      }
    });
    // Sort
    if (sortString == 'Sort by: Distance') {
      geoFencedPosts
          .sort((a, b) => a.distanceToUser.compareTo(b.distanceToUser));
    } else if (sortString == 'Sort by: Condition') {
      geoFencedPosts.sort((a, b) => compareCondition(a.condition, b.condition));
    }
    return geoFencedPosts;
  }

  int compareCondition(String? a, String? b) {
    // Order: Excellent, Great, Good, Fair, Poor, Totaled
    if (a == b) return 0;
    switch (a) {
      case "Excellent":
        return -1;
      case "Great":
        if (b == 'Excellent') return 1;
        return -1;
      case "Good":
        if ((b == 'Excellent') || (b == 'Great')) return 1;
        return -1;
      case "Fair":
        if ((b == 'Excellent') || (b == 'Great') || (b == 'Great')) return 1;
        return -1;
      case "Poor":
        if ((b == 'Excellent') ||
            (b == 'Great') ||
            (b == 'Great') ||
            (b == 'Fair')) return 1;
        return -1;
      case "Totaled":
        if ((b == 'Excellent') ||
            (b == 'Great') ||
            (b == 'Great') ||
            (b == 'Fair') ||
            (b == 'Poor')) return 1;
        return -1;
    }
    return -1;
  }

  Widget reportStolenButton() {
    return ElevatedButton(
      child: FormattedText(
        text: 'Report Stolen',
        size: s_fontSizeSmall,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold,
      ),
      style: ElevatedButton.styleFrom(primary: Color(s_declineRed)),
      onPressed: () async {
        await FirebaseFirestore.instance
            .collection('bikes')
            .doc(bikeId)
            .update({'Condition': 'Stolen'});
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
  }

  Widget startRideButton() {
    return ElevatedButton(
      child: FormattedText(
        text: 'Start Ride',
        size: s_fontSizeSmall,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold,
      ),
      style: ElevatedButton.styleFrom(primary: Color(s_jungleGreen)),
      onPressed: () async {
        await FirebaseFirestore.instance
            .collection('bikes')
            .doc(bikeId)
            .update({'checkedOut': true});
        Navigator.of(context, rootNavigator: true).pop('dialog');
        // TO DO: Navigate to 'Ride' screen
      },
    );
  }

  Widget alertTitle(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeMedium,
      color: Color(s_jungleGreen),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget alertText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Color(s_jungleGreen),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget bikesLoading() {
    return Center(
        child: Column(children: [
      CircularProgressIndicator(
        color: Color(s_jungleGreen),
      ),
      FormattedText(
        text: 'Loading Bikes...',
        size: s_fontSizeMedium,
        color: Color(s_jungleGreen),
        font: s_font_AmaticSC,
        weight: FontWeight.bold,
      )
    ]));
  }

  Widget tapBikeText() {
    return Center(
        child: FormattedText(
      text: 'Tap a bike to start your ride!',
      size: s_fontSizeSmall,
      color: Color(s_periwinkleBlue),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    ));
  }

  Widget noBikesFound() {
    return Center(
        child: FormattedText(
      text: 'No Bikes Found In Your Area!',
      size: s_fontSizeLarge,
      color: Color(s_declineRed),
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    ));
  }

  Widget dropDownText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Color(s_cadmiumOrange),
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }

  Widget entryName(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeMedium,
      color: Color(s_jungleGreen),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget entryDescription(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeExtraSmall,
        color: Color(s_jungleGreen),
        font: s_font_BonaNova,
        style: FontStyle.italic);
  }

  Widget conditionDescription(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeExtraSmall,
      color: Color(s_jungleGreen),
      font: s_font_BonaNova,
    );
  }
}
