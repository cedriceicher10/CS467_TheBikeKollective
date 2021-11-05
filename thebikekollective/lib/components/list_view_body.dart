import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen_toggle.dart';
import 'styles.dart';
import 'formatted_text.dart';

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
    return StreamBuilder(
        stream: bikeQuery(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return Flexible(
                child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                //
                snapshot = sortSnapshot(snapshot);
                // TO DO: Only show bikes that are within x distance
                // TO DO: Sort by condition
                // TO DO: Sort by distance
                // TO DO: Filter by tags
                //
                var post = snapshot.data!.docs[index];
                return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Color(s_jungleGreen), width: 1),
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                        isThreeLine: true,
                        title: entryName(post['Name']),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              entryDescription(post['Description']),
                              conditionDescription(
                                  'Distance: XX mi | Condition: ' + // TO DO: Add in actual distance per bike
                                      post['Condition']),
                            ]),
                        trailing: Image(image: NetworkImage(post['imageURL'])),
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
  }

  AsyncSnapshot<QuerySnapshot<Object?>> sortSnapshot(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    // Sort first
    if (sortString == sortItems[0]) {
      // Sort by distance
    } else if (sortString == sortItems[1]) {
      // Sort by condition
      // snapshot.data!.docs
      //     .sort((a, b) => a['Name'].length.compareTo(b['Name'].length));
    }
    return snapshot;
  }

  Stream<QuerySnapshot<Object?>> bikeQuery() {
    if (filterString == filterItems[1]) {
      return FirebaseFirestore.instance
          .collection('bikes')
          .where('Condition', isEqualTo: conditionString)
          .snapshots();
    } else {
      return FirebaseFirestore.instance.collection('bikes').snapshots();
    }
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
