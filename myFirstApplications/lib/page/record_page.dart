import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myfirstapplications/widget/makerecord.dart';

import '../widget/homewidget.dart';
import '../widget/makerecord.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ประวัติ"),
        automaticallyImplyLeading: false,
      ),
      body: const Progress(),
    );
  }
}
