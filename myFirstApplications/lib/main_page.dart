import 'package:flutter/material.dart';
import 'package:myfirstapplications/page/homepage.dart';
import 'package:myfirstapplications/page/record_page.dart';
import 'package:myfirstapplications/page/userpage.dart';

class MyHomePage extends StatefulWidget {
  final bool progress;
  const MyHomePage({Key? key, required this.progress}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final bool newprogress = widget.progress;
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
    List<Widget> pages = [const UserPage(), const RecordPage()];

    return Scaffold(
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
    );
  }
}
