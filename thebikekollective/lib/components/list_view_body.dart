import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as GeoCode;
import 'home_screen_toggle.dart';
import 'styles.dart';
import 'formatted_text.dart';
import 'add_bike_fab.dart';
import '../utils/haversine_calculator.dart';
import '../utils/multi_select_alert_dialog.dart';

const GEOFENCE_DISTANCE = 0.1; // mi

class PostTile {
  String id;
  String name;
  String description;
  String condition;
  int combination;
  double latitude;
  double longitude;
  String street;
  String imageURL;
  bool checkedOut;
  List<dynamic> tags;
  double distanceToUser;
  double rating;
  PostTile(
      {required this.id,
      required this.name,
      required this.description,
      required this.condition,
      required this.combination,
      required this.latitude,
      required this.longitude,
      required this.street,
      required this.imageURL,
      required this.checkedOut,
      required this.tags,
      required this.distanceToUser,
      required this.rating});
}

class ListViewBody extends StatefulWidget {
  const ListViewBody({Key? key}) : super(key: key);

  @override
  _ListViewBodyState createState() => _ListViewBodyState();
}

class _ListViewBodyState extends State<ListViewBody> {
  String sortString = 'Sort by: Distance';
  List<String> sortItems = <String>[
    'Sort by: Distance',
    'Sort by: Condition',
    'Sort by: Rating'
  ];
  String filterString = 'No Filter';
  List<String> filterItems = <String>[
    'No Filter',
    'Filter by: Condition',
    'Filter by: Tags'
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
  String tagString = 'Mountain';
  List<String> tagItems = <String>[
    'Mountain',
    'Road',
    'Hybrid',
    'Electric',
    'Motorized',
    'Multiple Gear',
    'Tricycle',
    'Training Wheels',
    'Fixie',
    'Multiple Gear',
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
    'Multicolor'
  ];
  bool filterCondition = false;
  bool filterTag = false;
  double userLat = 0.0;
  double userLon = 0.0;
  String address = 'no address';
  String bikeId = 'no bike';
  bool filterTagsOn = false;
  Set<int>? tagSelectedValues;
  bool filterConditionOn = false;
  Set<int>? conditionSelectedValues;
  List<PostTile> postsListForStreets = [];
  List<String> streets = [];

  Future<LocationData> retrieveLocation() async {
    var locationService = Location();
    var locationUser = await locationService.getLocation();
    userLat = locationUser.latitude!;
    userLon = locationUser.longitude!;
    print('User Location: ${locationUser.latitude}, ${locationUser.longitude}');
    return locationUser;
  }

  Stream<QuerySnapshot<Object?>> ratingsQuery() {
    return FirebaseFirestore.instance.collection('rides').snapshots();
  }

  Stream<QuerySnapshot<Object?>> bikeQuery() {
    if ((filterTagsOn) && (tagSelectedValues!.isNotEmpty)) {
      return FirebaseFirestore.instance
          .collection('bikes')
          .where('Tags', arrayContains: tagItems[tagSelectedValues!.first - 1])
          .snapshots();
    } else {
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
          showBikeText(),
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
            icon:
                const Icon(Icons.arrow_drop_down, color: Color(s_raisinBlack)),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Color(s_raisinBlack)),
            underline: Container(
              height: 2,
              color: Color(s_raisinBlack),
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
      filterConditionButton(),
      SizedBox(width: 20),
      filterTagsButton(),
    ]);
  }

  Widget listViewBikes() {
    return FutureBuilder(
        future: retrieveLocation(),
        builder: (BuildContext context, snapshotLocation) {
          if (snapshotLocation.hasData) {
            return StreamBuilder(
                stream: ratingsQuery(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshotRatings) {
                  if (snapshotRatings.hasData) {
                    return StreamBuilder(
                        stream: bikeQuery(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshotBikes) {
                          if (snapshotBikes.hasData) {
                            // Converts to custom List<Map> that's easier to pass around
                            var snapMap =
                                postBuilder(snapshotBikes, snapshotRatings);
                            // Condition filtering
                            if ((filterConditionOn) &&
                                (conditionSelectedValues!.isNotEmpty)) {
                              snapMap = conditionBuilder(snapMap);
                            }
                            // Tag filtering
                            if ((filterTagsOn) &&
                                (tagSelectedValues!.isNotEmpty) &&
                                (tagSelectedValues!.length > 1)) {
                              snapMap = multiTagBuilder(snapMap);
                            }
                            postsListForStreets = snapMap;
                            return FutureBuilder(
                                future: getStreets(),
                                builder: (BuildContext context,
                                    snapshotPlacemarksUselessDontUse) {
                                  if (snapshotPlacemarksUselessDontUse
                                      .hasData) {
                                    // Sorting
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
                                                      color: Color(s_grayGreen),
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: ListTile(
                                                  isThreeLine: true,
                                                  title: entryName(
                                                      '${post.name} (${post.distanceToUser.toStringAsFixed(2)} mi)'),
                                                  subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        entryDescription(
                                                            post.description),
                                                        postSecondLineText(
                                                            'Condition: ${post.condition} | Rating: ${post.rating.toStringAsFixed(1)}'),
                                                        postThirdLineText(
                                                            '${post.street}'),
                                                      ]),
                                                  trailing: Image(
                                                      image: NetworkImage(
                                                          post.imageURL)),
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        // Take note of chosen bike for Ride screen
                                                        bikeId = post.id;
                                                        return AlertDialog(
                                                          title: alertTitle(
                                                              "Start Ride"),
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
                                    return bikesLoading(
                                        'Finding bike\'s locations...');
                                  }
                                });
                          } else {
                            return bikesLoading('Loading bike ratings...');
                          }
                        });
                  } else {
                    return bikesLoading('Loading bikes...');
                  }
                });
          } else {
            return bikesLoading('Getting user\'s location...');
          }
        });
  }

  List<PostTile> postBuilder(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshotBikes,
      AsyncSnapshot<QuerySnapshot<Object?>> snapshotRatings) {
    List<PostTile> posts = [];
    for (var index = 0; index < snapshotBikes.data!.size; ++index) {
      // Convert to lightweight bike post object
      PostTile post = PostTile(
          id: snapshotBikes.data!.docs[index].id,
          name: snapshotBikes.data!.docs[index]['Name'],
          description: snapshotBikes.data!.docs[index]['Description'],
          condition: snapshotBikes.data!.docs[index]['Condition'],
          latitude: snapshotBikes.data!.docs[index]['Latitude'],
          longitude: snapshotBikes.data!.docs[index]['Longitude'],
          street: 'no street yet',
          imageURL: snapshotBikes.data!.docs[index]['imageURL'],
          combination: snapshotBikes.data!.docs[index]['Combination'],
          checkedOut: snapshotBikes.data!.docs[index]['checkedOut'],
          tags: snapshotBikes.data!.docs[index]['Tags'],
          distanceToUser: 0.0,
          rating: 0.0);
      // Add ratings (average from rides table)
      double sum = 0;
      double count = 0;
      for (var index = 0; index < snapshotRatings.data!.size; ++index) {
        if (post.id == snapshotRatings.data!.docs[index]['bike']) {
          sum += snapshotRatings.data!.docs[index]['rating'];
          count++;
        }
      }
      if (count > 0) {
        post.rating = sum / count;
      }
      // Add to returable List collection
      posts.add(post);
    }
    return posts;
  }

  List<PostTile> conditionBuilder(List<PostTile> posts) {
    // Generate condition list
    List<String> conditionFilters = [];
    for (var conditionIndex in conditionSelectedValues!) {
      conditionFilters.add(conditionItems[conditionIndex - 1]);
    }

    List<PostTile> conditionPosts = [];
    for (var index = 0; index < posts.length; ++index) {
      String postCondition = posts[index].condition;
      if (conditionFilters.contains(postCondition)) {
        conditionPosts.add(posts[index]);
      }
    }
    return conditionPosts;
  }

  List<PostTile> multiTagBuilder(List<PostTile> posts) {
    // Generate tag list
    List<String> tagFilters = [];
    for (var tagIndex in tagSelectedValues!) {
      tagFilters.add(tagItems[tagIndex - 1]);
    }

    // Compare to posts' tags
    List<PostTile> tagPosts = [];
    for (var index = 0; index < posts.length; ++index) {
      List<dynamic> postTags = posts[index].tags;
      if (postHasTagsInFilterList(tagFilters, postTags)) {
        tagPosts.add(posts[index]);
      }
    }
    return tagPosts;
  }

  bool postHasTagsInFilterList(
      List<String> tagsDesired, List<dynamic> postInQuestion) {
    // Post has less tags than desired
    if (postInQuestion.length < tagsDesired.length) {
      return false;
    }

    int foundNum = 0;
    for (var tagIndex = 0; tagIndex < tagsDesired.length; ++tagIndex) {
      for (var postIndex = 0; postIndex < postInQuestion.length; ++postIndex) {
        if (tagsDesired[tagIndex] == postInQuestion[postIndex]) {
          foundNum++;
          if (foundNum == tagsDesired.length) {
            return true;
          }
        }
      }
    }
    return false;
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
        geoFencedPosts.add(bike);
      }
    });
    // Add streets to bikes
    int index = 0;
    postList.forEach((bike) {
      bike.street = streets[index];
      index++;
    });
    // Sort
    if (sortString == 'Sort by: Distance') {
      geoFencedPosts
          .sort((a, b) => a.distanceToUser.compareTo(b.distanceToUser));
    } else if (sortString == 'Sort by: Condition') {
      geoFencedPosts.sort((a, b) => compareCondition(a.condition, b.condition));
    } else if (sortString == 'Sort by: Rating') {
      geoFencedPosts.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return geoFencedPosts;
  }

  Future<dynamic> getStreets() async {
    var placemarks;
    // Add street address for each bike
    for (var index = 0; index < postsListForStreets.length; ++index) {
      placemarks = await GeoCode.placemarkFromCoordinates(
          postsListForStreets[index].latitude,
          postsListForStreets[index].longitude);
      streets.add(placemarks[0].street!);
    }
    return placemarks;
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

  Widget filterConditionButton() {
    return ElevatedButton(
        child: filterAlertText('Filter by Condition', filterConditionOn),
        onPressed: (() async {
          _showConditionsDialog();
        }),
        style: ElevatedButton.styleFrom(
          primary: filterConditionColor(),
          side: BorderSide(width: 1.0, color: Color(s_raisinBlack)),
        ));
  }

  Color filterConditionColor() {
    if (filterConditionOn) {
      return Color(s_grayGreen);
    } else {
      return Colors.white;
    }
  }

  void _showConditionsDialog() async {
    List<MultiSelectDialogItem> conditionAlertItems = [];
    for (var index = 0; index < conditionItems.length; ++index) {
      MultiSelectDialogItem conditionAlertItem = MultiSelectDialogItem(
          value: index + 1, filter: conditionItems[index]);
      conditionAlertItems.add(conditionAlertItem);
    }
    conditionSelectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectAlertDialog(
          items: conditionAlertItems,
          initiallyChecked: conditionSelectedValues,
        );
      },
    );

    // Protects tapping outside of filter dialog
    if (conditionSelectedValues == null) {
      conditionSelectedValues = {};
    }

    if (conditionSelectedValues!.isNotEmpty) {
      filterConditionOn = true;
    } else {
      filterConditionOn = false;
    }
    setState(() {});
  }

  Widget filterTagsButton() {
    return ElevatedButton(
        child: filterAlertText('Filter by Tags', filterTagsOn),
        onPressed: (() async {
          _showTagsDialog();
        }),
        style: ElevatedButton.styleFrom(
          primary: filterTagsColor(),
          side: BorderSide(width: 1.0, color: Color(s_raisinBlack)),
        ));
  }

  Color filterTagsColor() {
    if (filterTagsOn) {
      return Color(s_grayGreen);
    } else {
      return Colors.white;
    }
  }

  void _showTagsDialog() async {
    List<MultiSelectDialogItem> tagAlertItems = [];
    for (var index = 0; index < tagItems.length; ++index) {
      MultiSelectDialogItem tagAlertItem =
          MultiSelectDialogItem(value: index + 1, filter: tagItems[index]);
      tagAlertItems.add(tagAlertItem);
    }
    tagSelectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectAlertDialog(
          items: tagAlertItems,
          initiallyChecked: tagSelectedValues,
        );
      },
    );

    // Protects tapping outside of filter dialog
    if (tagSelectedValues == null) {
      tagSelectedValues = {};
    }

    if (tagSelectedValues!.isNotEmpty) {
      filterTagsOn = true;
    } else {
      filterTagsOn = false;
    }
    setState(() {});
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

  Widget filterAlertText(String text, bool filterOn) {
    Color textColor = Color(s_raisinBlack);
    if (filterOn) {
      textColor = Colors.white;
    }
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: textColor,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
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
        // Remove alert
        Navigator.of(context, rootNavigator: true).pop('dialog');
        // Navigate to the Ride screen
        Navigator.of(context).pushNamedAndRemoveUntil(
            'rideScreen', (_) => false,
            arguments: bikeId);
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

  Widget bikesLoading(String text) {
    return Center(
        child: Column(children: [
      CircularProgressIndicator(
        color: Color(s_jungleGreen),
      ),
      FormattedText(
        text: text,
        size: s_fontSizeMedium,
        color: Color(s_jungleGreen),
        font: s_font_AmaticSC,
        weight: FontWeight.bold,
      )
    ]));
  }

  Widget showBikeText() {
    return Center(
        child: FormattedText(
            text: 'Showing eligible bikes within $GEOFENCE_DISTANCE mi',
            size: s_fontSizeSmall,
            color: Color(s_grayGreen),
            font: s_font_BonaNova,
            weight: FontWeight.bold,
            align: TextAlign.center));
  }

  Widget noBikesFound() {
    return Center(
        child: FormattedText(
            text: 'No Bikes Found In Your Area!',
            size: s_fontSizeLarge,
            color: Color(s_declineRed),
            font: s_font_AmaticSC,
            weight: FontWeight.bold,
            align: TextAlign.center));
  }

  Widget dropDownText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Color(s_raisinBlack),
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
        color: Color(s_raisinBlack),
        font: s_font_BonaNova,
        style: FontStyle.italic,
        weight: FontWeight.bold);
  }

  Widget postSecondLineText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeExtraSmall,
      color: Color(s_raisinBlack),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget postThirdLineText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeExtraSmall,
      color: Color(s_raisinBlack),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }
}
