
import 'package:attendaily/first.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


import 'package:attendaily/bars/searchpage.dart';
import 'package:attendaily/bars/historypage.dart';
import 'package:attendaily/bars/settingspage.dart';

class navigation extends StatefulWidget {

  @override
  State<navigation> createState() => _navigationState();
}

class _navigationState extends State<navigation> {

  int currentIndex = 0;


  @override
  final List<Widget> pages = [
    first(),
    SearchPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Desktop
    final bool isDesktop = width >= 900;

    return Scaffold(

body: Row(
children: [

// ======================================================
// DESKTOP SIDE NAVIGATION
// ======================================================

if (isDesktop)

Container(
width: 220,

color: Colors.white,

child: Column(
children: [

const SizedBox(height: 35),

// ==================================================
// APP NAME
// ==================================================

const Text(
"Attendaily",

style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: Color(0xff263b84),
),
),

const SizedBox(height: 45),

// ==================================================
// HOME
// ==================================================

_desktopNavigationItem(
icon: Icons.home_outlined,
selectedIcon: Icons.home,
title: "Home",
index: 0,
),

// ==================================================
// SEARCH
// ==================================================

_desktopNavigationItem(
icon: Icons.search_outlined,
selectedIcon: Icons.search,
title: "Search",
index: 1,
),

// ==================================================
// HISTORY
// ==================================================

_desktopNavigationItem(
icon: Icons.history_outlined,
selectedIcon: Icons.history,
title: "History",
index: 2,
),

// ==================================================
// SETTINGS
// ==================================================

_desktopNavigationItem(
icon: Icons.settings_outlined,
selectedIcon: Icons.settings,
title: "Settings",
index: 3,
),
],
),
),

// ======================================================
// PAGE AREA
// ======================================================

Expanded(
child: IndexedStack(
index: currentIndex,
children: pages,
),
),
],
),

// ==========================================================
// MOBILE / TABLET BOTTOM NAVIGATION
// ==========================================================

bottomNavigationBar: isDesktop
? null
: Container(
color: Colors.white,

child: Padding(
padding: const EdgeInsets.symmetric(
horizontal: 20,
vertical: 8,
),

child: GNav(

selectedIndex: currentIndex,

onTabChange: (index) {
setState(() {
currentIndex = index;
});
},

gap: 1,

padding:
const EdgeInsets.all(10),

backgroundColor:
Colors.white,

color: Colors.white,

activeColor:
Colors.white,

tabBackgroundColor:
Color(0xff182654),

tabs: const [

GButton(
icon: Icons.home,iconColor: Color(0xff182654),
text: "Home",
),

GButton(
icon: Icons.search,iconColor: Color(0xff182654),
text: "Search",
),

GButton(
icon: Icons.history,iconColor: Color(0xff182654),
text: "History",
),

GButton(
icon: Icons.settings,iconColor: Color(0xff182654),
text: "Settings",
),

],
),
),
),
);
}



// body: IndexedStack(
//         index: currentIndex,
//         children: pages,
//       ),
//
//       bottomNavigationBar:
//
//          Container(
//            color: Colors.lightBlue,
//
//            child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 15,
//               vertical: 19,
//             ),
//
//             child: GNav(
//               selectedIndex: currentIndex,
//
//               onTabChange: (index) {
//
//
//                 setState(() {
//                   currentIndex = index;
//
//                 });
//               },
//
//               gap: 10,
//               padding: const EdgeInsets.all(16),
//               backgroundColor: Colors.lightBlue,
//               color: Colors.white,
//               activeColor: Colors.white,
//               tabBackgroundColor: Colors.blue.shade700,
//
//               tabs: const [
//                 GButton(
//                   icon: Icons.home,
//                   text: "Home",
//                 ),
//                 GButton(
//                   icon: Icons.search,
//                   text: "Search",
//                 ),
//                 GButton(
//                   icon: Icons.history,
//                   text: "History",
//                 ),
//                 GButton(
//                   icon: Icons.settings,
//                   text: "Settings",
//                 ),
//               ],
//             ),
//                    ),
//          ),


  Widget _desktopNavigationItem({
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required int index,
  }) {

    final bool selected =
        currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),

      child: InkWell(

        borderRadius:
        BorderRadius.circular(12),

        onTap: () {

          setState(() {
            currentIndex = index;
          });

        },

        child: Container(

          width: double.infinity,

          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),

          decoration: BoxDecoration(

            color: selected
                ? const Color(0xff263b84)
                .withOpacity(0.10)
                : Colors.transparent,

            borderRadius:
            BorderRadius.circular(12),
          ),

          child: Row(
            children: [

              Icon(
                selected
                    ? selectedIcon
                    : icon,

                color: selected
                    ? const Color(0xff263b84)
                    : Colors.grey,

                size: 23,
              ),

              const SizedBox(width: 14),

              Text(
                title,

                style: TextStyle(

                  fontSize: 14,

                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.normal,

                  color: selected
                      ? const Color(0xff263b84)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}