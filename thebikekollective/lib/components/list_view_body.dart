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
  String filterString = 'No Filter';

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
              setState(() {
                sortString = newValue!;
              });
            },
            items: <String>['Sort by: Distance', 'Sort by: Condition']
                .map<DropdownMenuItem<String>>((String value) {
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
              setState(() {
                filterString = newValue!;
              });
            },
            items: <String>[
              'No Filter',
              'Filter by: Condition',
              'Filter by: Mountain Bike',
              'Filter by: Road Bike'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: dropDownText(value),
              );
            }).toList(),
          ))
    ]);
  }

  Widget listViewBikes() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('bikes')
            // .orderBy(
            //     'epoch_seconds') // Should also order by distance, condition, etc.
            .snapshots(),
        //
        // TO DO: Only show bikes that are within x distance
        // TO DO: Sort by condition
        // TO DO: Sort by distance
        // TO DO: Filter by tags
        //
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            //&& snapshot.data!.docs.length > 0
            return Flexible(
                child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
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
                                  'Condition: ' + post['Condition']),
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
