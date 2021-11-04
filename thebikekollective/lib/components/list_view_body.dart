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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listViewBikes(),
      floatingActionButton: HomeScreenToggle(map: true),
    );
  }

  Widget listViewBikes() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('bikes')
            // .orderBy(
            //     'epoch_seconds') // Should also order by distance, condition, etc.
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            //&& snapshot.data!.docs.length > 0
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var post = snapshot.data!.docs[index];
                return Container(
                    height: 100,
                    child: Card(
                        elevation: 2,
                        child: ListTile(
                            leading: Column(children: [
                              entryName(post['Name']),
                              entryDescription(post['Description'])
                            ]),
                            trailing:
                                Image(image: NetworkImage(post['imageURL'])),
                            contentPadding: EdgeInsets.all(20),
                            onTap: () {})));
              },
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: Color(s_jungleGreen),
            ));
          }
        });
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
    );
  }
}
