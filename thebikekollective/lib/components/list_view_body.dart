import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'home_screen_toggle.dart';
import 'styles.dart';
import 'formatted_text.dart';
import '../utils/haversine_calculator.dart';

const GEOFENCE_DISTANCE = 10.0; // mi

class PostTile {
  String name;
  String description;
  String condition;
  int combination;
  double latitude;
  double longitude;
  String imageURL;
  double distanceToUser;
  PostTile(
      {required this.name,
      required this.description,
      required this.condition,
      required this.combination,
      required this.latitude,
      required this.longitude,
      required this.imageURL,
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
    'Filter by: Tag #1', // TO DO: Dynamically create this list from available tags
    'Filter by: Tag #2'
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
  bool filterCondition = false;
  double userLat = 0.0;
  double userLon = 0.0;

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
    } else {
      return FirebaseFirestore.instance.collection('bikes').snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        filterSortButtons(),
        listViewBikes(),
      ]),
      floatingActionButton: HomeScreenToggle(map: true),
    );
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
              if (filterString == filterItems[1]) {
                filterCondition = true;
              } else {
                filterCondition = false;
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
          : Container() // Hides condition drop-down when filter isn't on Filter: Condition
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
                    var snapList = snapshotBikes.data!.docs.toList();
                    var snapMap = postBuilder(
                        snapList); // Converts to custom List<Map> that's easier to pass around
                    var posts = sortSnapshot(snapMap);
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
                                onTap: () {}));
                      },
                    ));
                  } else {
                    return Center(
                        child: CircularProgressIndicator(
                      color: Color(s_jungleGreen),
                    ));
                  }
                });
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: Color(s_jungleGreen),
            ));
          }
        });
  }

  List<PostTile> postBuilder(List<QueryDocumentSnapshot<Object?>> snapList) {
    List<PostTile> posts = [];
    snapList.forEach((snapPost) {
      PostTile post = PostTile(
          name: snapPost['Name'],
          description: snapPost['Description'],
          condition: snapPost['Condition'],
          latitude: snapPost['Latitude'],
          longitude: snapPost['Longitude'],
          imageURL: snapPost['imageURL'],
          combination: snapPost['Combination'],
          distanceToUser: 0.0);
      posts.add(post);
    });
    return posts;
  }

  List<PostTile> sortSnapshot(List<PostTile> postList) {
    List<PostTile> geoFencedPosts = [];
    // Add distance to user for each bike
    postList.forEach((bike) {
      bike.distanceToUser =
          haversineCalculator(userLat, userLon, bike.latitude, bike.longitude);
      // Cut off bikes that are more than GEOFENCE_DISTANCE
      if (bike.distanceToUser < GEOFENCE_DISTANCE) {
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
