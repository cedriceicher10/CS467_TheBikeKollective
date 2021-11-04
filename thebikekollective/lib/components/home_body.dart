import 'package:flutter/material.dart';
import 'list_view_body.dart';
import 'create_map_body.dart';

class HomeBody extends StatefulWidget {
  final bool map;

  const HomeBody({Key? key, required this.map}) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    if (widget.map) {
      return CreateMapBody();
    } else {
      return ListViewBody();
    }
  }
}
