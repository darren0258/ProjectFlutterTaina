import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myfirstapplications/widget/homewidget.dart';
import 'package:myfirstapplications/widget/location.dart';
import 'package:provider/provider.dart';

import '../model/datamodel.dart';

class HomePageCoOp extends StatefulWidget {
  const HomePageCoOp({Key? key}) : super(key: key);

  @override
  _HomePageCoOpState createState() => _HomePageCoOpState();
}

class _HomePageCoOpState extends State<HomePageCoOp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
      builder: (context, dataModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("ยินดีตอนรับสู่แอพฟลิเคชันรับจ้างไถนา"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            children: const [
              HomeWidget(),
              Padding(padding: EdgeInsets.all(10)),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: const [
              //     Padding(padding: EdgeInsets.all(10)),
              //     Text(
              //       "กำลังดำเนินการ",
              //       style: TextStyle(fontSize: 20),
              //     ),
              //   ],
              // ),
              // Padding(padding: EdgeInsets.all(5)),
              //Progress(),
            ],
          ),
        ),
      ),
    );
  }
}
