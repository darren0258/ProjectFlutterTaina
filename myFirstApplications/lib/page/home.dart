import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:myfirstapplications/page/record_page.dart';
import 'package:myfirstapplications/page/userpage.dart';

import '../model/datamodel.dart';
import 'homepage.dart';

class MyHomePage extends StatefulWidget {
  //final bool progress;
  //final List<LatLng> origin;
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController pageController = PageController();
  int selectIndex = 0;

  void onPageChanged(int index) {
    setState(() {
      selectIndex = index;
    });
  }

  void onItemTap(int selectItem) {
    pageController.jumpToPage(selectItem);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const HomePageCoOp(),
      const UserPage(),
      const RecordPage()
    ];

    return Consumer<DataModel>(
      builder: (context, dataModel, child) => Scaffold(
        body: PageView(
          controller: pageController,
          children: pages,
          onPageChanged: onPageChanged,
        ),

        bottomNavigationBar: BottomNavigationBar(
          onTap: onItemTap,
          items: [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.home,
                  color: selectIndex == 0 ? Colors.blue : Colors.blue),
              backgroundColor: Colors.blue,
            ),
            const BottomNavigationBarItem(
                label: "user",
                icon: Icon(Icons.person),
                backgroundColor: Colors.blue),
            const BottomNavigationBarItem(
                label: "ประวัติ",
                icon: Icon(Icons.access_time),
                backgroundColor: Colors.blue),
          ],
        ),
        //debugShowCheckedModeBanner: false,
      ),
    );
  }
}
