import 'package:attendaily/ReportPage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:attendaily/batchPage.dart';
import 'package:attendaily/ReportPage.dart';
import 'package:attendaily/markAttend.dart';
import 'package:flutter/material.dart';
import 'package:attendaily/addBatch.dart';
import 'package:attendaily/login/login_Page.dart';
import 'package:attendaily/main.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:attendaily/uiHelper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
class HomeData {
  final Map<String, int> todayAttendance;
  final Map<String, dynamic> attendanceComparison;
  final List<Map<String, dynamic>> weeklyAttendance;
  final Map<String, int> homeTotals;


  HomeData({
    required this.todayAttendance,
    required this.attendanceComparison,
    required this.weeklyAttendance,
    required this.homeTotals,
  });
}
class first extends StatefulWidget{
  const first({super.key});

  @override
  State<first> createState() => _firstState();
}
class _firstState extends State<first> {
  Color color=Colors.white;
  Color blur=Colors.grey;

  late Future<Map<String, int>> todayAttendanceFuture;
 late Future<Map<String, dynamic>> attendanceComparisonFuture;
  late Future<List<Map<String, dynamic>>> weeklyAttendanceFuture;
  late Future<Map<String, int>> homeTotalsFuture;
  late Future<HomeData> homeDataFuture;

  bool initialLoading = true;

  bool attendanceLoading = false;

  bool totalsLoading = false;

  Map<String, int> todayData = {};

  Map<String, dynamic> comparisonData = {};

  List<Map<String, dynamic>> weeklyData = [];

  Map<String, int> totalsData = {};


  @override
  void initState() {
    super.initState();
    //print("🔥 FIRST PAGE INITSTATE");
   // todayAttendanceFuture = getTodayAttendance();
    //attendanceComparisonFuture = getAttendanceComparison();
    //weeklyAttendanceFuture = getWeeklyAttendance();
    //homeTotalsFuture = getHomeTotals();
    //homeDataFuture = loadHomeData();

    loadInitialHome();
  }
  //present or absent
  Future<void> loadInitialHome() async {

    try {

      final results = await Future.wait([
        getTodayAttendance(),
        getAttendanceComparison(),
        getWeeklyAttendance(),
        getHomeTotals(),
      ]);

      if (!mounted) return;

      setState(() {

        todayData =
        results[0] as Map<String, int>;

        comparisonData =
        results[1] as Map<String, dynamic>;

        weeklyData =
        results[2]
        as List<Map<String, dynamic>>;

        totalsData =
        results[3] as Map<String, int>;

        initialLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        initialLoading = false;
      });

    }
  }
  Future<HomeData> loadHomeData() async {
    final results = await Future.wait([
      todayAttendanceFuture,
      attendanceComparisonFuture,
      weeklyAttendanceFuture,
      homeTotalsFuture,
    ]);

    return HomeData(
      todayAttendance:
      results[0] as Map<String, int>,

      attendanceComparison:
      results[1] as Map<String, dynamic>,

      weeklyAttendance:
      results[2] as List<Map<String, dynamic>>,

      homeTotals:
      results[3] as Map<String, int>,
    );
  }
  //weekly attendance
  Future<List<Map<String, dynamic>>> getWeeklyAttendance() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    final uid = user.uid;

    // ============================================================
    // GET ALL BATCHES
    // ============================================================

    final batchesSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("batches")
        .get();

    final batches = batchesSnapshot.docs;

    // ============================================================
    // LAST 7 DAYS
    // ============================================================

    final today = DateTime.now();

    final List<Map<String, dynamic>> results = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(
        Duration(days: i),
      );

      final dateKey =
          "${date.year}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')}";

      int present = 0;
      int absent = 0;

      // ==========================================================
      // GET ATTENDANCE OF ALL BATCHES FOR THIS DATE
      // ==========================================================

      final attendanceDocs = await Future.wait(
        batches.map(
              (batch) async {
            return FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("batches")
                .doc(batch.id)
                .collection("attendance")
                .doc(dateKey)
                .get();
          },
        ),
      );

      // ==========================================================
      // COUNT PRESENT / ABSENT
      // ==========================================================

      for (final doc in attendanceDocs) {
        if (!doc.exists) {
          continue;
        }

        final data = doc.data();

        if (data == null) {
          continue;
        }

        for (final entry in data.entries) {
          if (entry.value == "Present") {
            present++;
          } else if (entry.value == "Absent") {
            absent++;
          }
        }
      }

      // ==========================================================
      // CALCULATE PERCENTAGE
      // ==========================================================

      final total = present + absent;

      final percentage = total == 0
          ? 0
          : ((present / total) * 100).round();

      results.add({
        "date": date,
        "present": present,
        "absent": absent,
        "percentage": percentage,
      });
    }

    return results;
  }

  Widget weeklyAttendanceChart(
      List<Map<String, dynamic>> data,
      ) {

    // =========================================================
    // NO DATA
    // =========================================================

    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),

        child: const Center(
          child: Text(
            "No attendance data available.",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // =========================================================
    // CHART CARD
    // =========================================================

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // ===================================================
          // HEADER
          // ===================================================

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    "Weekly Attendance",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff263b84),
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "Last 7 days",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // =================================================
              // PERCENTAGE ICON
              // =================================================

              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: const Color(0xff263b84)
                      .withOpacity(0.08),

                  borderRadius:
                  BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Color(0xff263b84),
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ===================================================
          // CHART
          // ===================================================

          SizedBox(
            height: 220,

            child: LineChart(
              LineChartData(

                // =================================================
                // Y AXIS
                // =================================================

                minY: 0,
                maxY: 100,

                // =================================================
                // GRID
                // =================================================

                gridData: FlGridData(
                  show: true,

                  horizontalInterval: 20,

                  verticalInterval: 1,

                  drawVerticalLine: false,

                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color:
                      Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    );
                  },
                ),

                // =================================================
                // BORDER
                // =================================================

                borderData: FlBorderData(
                  show: false,
                ),

                // =================================================
                // TITLES
                // =================================================

                titlesData: FlTitlesData(

                  // -------------------------------------------------
                  // TOP
                  // -------------------------------------------------

                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  // -------------------------------------------------
                  // RIGHT
                  // -------------------------------------------------

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  // -------------------------------------------------
                  // LEFT
                  // -------------------------------------------------

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      reservedSize: 42,

                      interval: 20,

                      getTitlesWidget:
                          (value, meta) {

                        return Text(
                          "${value.toInt()}%",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  // -------------------------------------------------
                  // BOTTOM
                  // -------------------------------------------------

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      interval: 1,

                      reservedSize: 30,

                      getTitlesWidget:
                          (value, meta) {

                        final index =
                        value.toInt();

                        if (index < 0 ||
                            index >= data.length) {
                          return const SizedBox();
                        }

                        final date =
                        data[index]["date"]
                        as DateTime;

                        const days = [
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat",
                          "Sun",
                        ];

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            top: 8,
                          ),

                          child: Text(
                            days[date.weekday - 1],

                            style:
                            const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // =================================================
                // LINE
                // =================================================

                lineBarsData: [

                  LineChartBarData(

                    spots: [
                      for (int i = 0;
                      i < data.length;
                      i++)

                        FlSpot(
                          i.toDouble(),

                          (data[i]["percentage"]
                          as int)
                              .toDouble(),
                        ),
                    ],

                    isCurved: true,

                    curveSmoothness: 0.25,

                    barWidth: 3,

                    color:
                    const Color(0xff263b84),

                    // =================================================
                    // DOTS
                    // =================================================

                    dotData: FlDotData(
                      show: true,

                      getDotPainter:
                          (spot,
                          percent,
                          barData,
                          index) {

                        return FlDotCirclePainter(
                          radius: 4,

                          color:
                          const Color(
                            0xff263b84,
                          ),

                          strokeWidth: 2,

                          strokeColor:
                          Colors.white,
                        );
                      },
                    ),

                    // =================================================
                    // AREA BELOW LINE
                    // =================================================

                    belowBarData:
                    BarAreaData(
                      show: true,

                      color:
                      const Color(
                        0xff263b84,
                      ).withOpacity(0.08),
                    ),
                  ),
                ],

                // =================================================
                // TOUCH
                // =================================================

                lineTouchData:
                LineTouchData(
                  enabled: true,

                  touchTooltipData:
                  LineTouchTooltipData(

                    getTooltipItems:
                        (touchedSpots) {

                      return touchedSpots
                          .map((spot) {

                        return LineTooltipItem(
                          "${spot.y.toInt()}%",

                          const TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<Map<String, int>> getHomeTotals() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {
        "totalEmployees": 0,
        "totalBatches": 0,
      };
    }

    final uid = user.uid;

    // =============================================================
    // GET ALL BATCHES
    // =============================================================

    final batchesSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("batches")
        .get();

    final totalBatches = batchesSnapshot.docs.length;

    // =============================================================
    // GET ALL EMPLOYEES FROM ALL BATCHES
    // =============================================================

    int totalEmployees = 0;

    for (final batchDoc in batchesSnapshot.docs) {

      final employeesSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("batches")
          .doc(batchDoc.id)
          .collection("employees")
          .get();

      totalEmployees += employeesSnapshot.docs.length;
    }

    // =============================================================
    // RETURN TOTALS
    // =============================================================

    return {
      "totalEmployees": totalEmployees,
      "totalBatches": totalBatches,
    };
  }
  Future<Map<String,int>>getTodayAttendance()async{
    final user=FirebaseAuth.instance.currentUser;

    if (user==null){
      return  {
        "present":0,
        "absent":0,
        "total":0,
        "percentage":0,
        "markedBatches":0,
        "totalBatches":0,
      };
    }
    final uid=user.uid;
    final today=DateTime.now();
    final dateKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    int present=0;
    int absent=0;
    //take all batches
    final batchesSnapshot=  await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("batches")
        .get();
    int totalBatches = batchesSnapshot.docs.length;
    int markedBatches = 0;
    //har batch
    final attendanceResults = await Future.wait(
      batchesSnapshot.docs.map((batchDoc) async {
        return FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("batches")
            .doc(batchDoc.id)
            .collection("attendance")
            .doc(dateKey)
            .get();
      }),
    );



    for (final attendanceDoc in attendanceResults) {
      if (!attendanceDoc.exists) {
        continue;
      }

      final data = attendanceDoc.data();

      if (data == null) {
        continue;
      }

      markedBatches++;

      for (final entry in data.entries) {
        if (entry.value == "Present") {
          present++;
        }

        if (entry.value == "Absent") {
          absent++;
        }
      }
    }
    final total= present+absent;
    final percentage = total == 0
        ? 0
        : ((present / total) * 100).round();
    return {
      "present": present,
      "absent": absent,
      "total":total,
      "percentage":percentage,
      "totalBatches": totalBatches,
      "markedBatches": markedBatches,

    };
  }
  Future<Map<String, dynamic>> getAttendanceComparison() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {
        "difference": 0,
        "label": "vs previous day",
      };
    }

    final uid = user.uid;

    DateTime today = DateTime.now();

    // Aaj se peeche search karega
    for (int i = 1; i <= 30; i++) {
      final date = today.subtract(Duration(days: i));

      final dateKey =
          "${date.year}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')}";

      final batchesSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("batches")
          .get();

      int present = 0;
      int absent = 0;
      bool foundAttendance = false;

      for (final batch in batchesSnapshot.docs) {
        final attendanceDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("batches")
            .doc(batch.id)
            .collection("attendance")
            .doc(dateKey)
            .get();

        if (!attendanceDoc.exists) {
          continue;
        }

        final data = attendanceDoc.data();

        if (data == null || data.isEmpty) {
          continue;
        }

        foundAttendance = true;

        for (final entry in data.entries) {
          if (entry.value == "Present") {
            present++;
          } else if (entry.value == "Absent") {
            absent++;
          }
        }
      }

      // Is din attendance mili
      if (foundAttendance) {
        final total = present + absent;

        if (total == 0) {
          continue;
        }

        final previousPercentage =
        ((present / total) * 100).round();

        return {
          "percentage": previousPercentage,
          "date": date,
          "daysAgo": i,
        };
      }
    }

    // Pichlay 30 din mein koi attendance nahi mili
    return {
      "percentage": null,
      "date": null,
      "daysAgo": null,
    };
  }
 // void refreshHomeData() {
    //print(" REFRESH HOME DATA CALLED");

   // setState(() {
     // homeDataFuture = loadHomeData();
      //todayAttendanceFuture = getTodayAttendance();
      //attendanceComparisonFuture = getAttendanceComparison();
      //weeklyAttendanceFuture = getWeeklyAttendance();
      //homeTotalsFuture = getHomeTotals();
    //});
  //}
  Widget _attendanceComparison(int percentage) {
    final previousPercentage =
    comparisonData["percentage"];

    final daysAgo =
    comparisonData["daysAgo"];

    if (previousPercentage == null ||
        daysAgo == null) {
      return const SizedBox.shrink();
    }

    final difference =
        percentage - (previousPercentage as int);

    String label;

    if (daysAgo == 1) {
      label = "vs yesterday";
    } else if (daysAgo == 2) {
      label = "vs 2 days ago";
    } else {
      label = "vs $daysAgo days ago";
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            difference >= 0
                ? Icons.trending_up_sharp
                : Icons.trending_down_sharp,
            color: difference >= 0
                ? Colors.green
                : Colors.red,
            size: 15,
          ),
          const SizedBox(width: 2),
          Text(
            "${difference >= 0 ? '+' : ''}$difference%",
            style: TextStyle(
              color: difference >= 0
                  ? Colors.green
                  : Colors.red,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> refreshAttendance() async {
    setState(() {
      attendanceLoading = true;
    });

    try {
      final results = await Future.wait([
        getTodayAttendance(),
        getAttendanceComparison(),
        getWeeklyAttendance(),
      ]);

      if (!mounted) return;

      setState(() {
        todayData = results[0] as Map<String, int>;
        comparisonData = results[1] as Map<String, dynamic>;
        weeklyData =
        results[2] as List<Map<String, dynamic>>;

        attendanceLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        attendanceLoading = false;
      });
    }
  }

  Future<void> refreshTotals() async {
    setState(() {
      totalsLoading = true;
    });

    try {
      final data = await getHomeTotals();

      if (!mounted) return;

      setState(() {
        totalsData = data;
        totalsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        totalsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: initialLoading
            ? const Skeleton()
            : LayoutBuilder(
                builder: (context, constraints) {
            
                  // ============================================================
                  // DESKTOP
                  // ============================================================

                  if (constraints.maxWidth >= 900) {
                    return Container(
                      color: const Color(0xfff5f6fa),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          // ======================================================
                          // LEFT SIDE
                          // ======================================================

                          Expanded(
                            flex: 7,

                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(25),

                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  // ==================================================
                                  // WELCOME HEADER
                                  // ==================================================

                                  Container(
                                    width: double.infinity,
                                    height: 150,

                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 20,
                                    ),

                                    decoration: BoxDecoration(
                                      color:
                                      const Color(0xff263b84),

                                      borderRadius:
                                      BorderRadius.circular(18),
                                    ),

                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,

                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                      children: [

                                        Text(
                                          "Welcome",

                                          style: TextStyle(
                                            color:
                                            Colors.grey.shade400,

                                            fontSize: 20,

                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),

                                        const SizedBox(height: 3),

                                        StreamBuilder(
                                          stream:
                                          FirebaseFirestore
                                              .instance
                                              .collection("users")
                                              .doc(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          )
                                              .snapshots(),

                                          builder:
                                              (context, snapshot) {

                                            final data =
                                            snapshot.data?.data()
                                            as Map<String, dynamic>?;

                                            return Text(
                                              data?["name"] ?? "",

                                              style:
                                              const TextStyle(
                                                color: Colors.white,

                                                fontSize: 30,

                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 25),

                                  // ==================================================
                                  // ATTENDANCE LOADING
                                  // ==================================================

                                  if (attendanceLoading)
                                    const skeleton2()

                                  // ==================================================
                                  // ATTENDANCE AVAILABLE
                                  // ==================================================

                                  else if (
                                  (todayData["markedBatches"] ?? 0) > 0
                                  )
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                      children: [

                                        // ============================================
                                        // TITLE
                                        // ============================================

                                        const Text(
                                          "Today's Attendance",

                                          style: TextStyle(
                                            fontSize: 23,

                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 15),

                                        // ============================================
                                        // DATA
                                        // ============================================

                                        Builder(
                                          builder: (context) {

                                            final present =
                                                todayData["present"] ?? 0;

                                            final absent =
                                                todayData["absent"] ?? 0;

                                            final total =
                                                todayData["total"] ?? 0;

                                            final percentage =
                                                todayData["percentage"] ?? 0;

                                            final totalBatches =
                                                todayData["totalBatches"] ?? 0;

                                            final markedBatches =
                                                todayData["markedBatches"] ?? 0;

                                            final pendingBatches =
                                                totalBatches -
                                                    markedBatches;

                                            return Column(
                                              children: [

                                                // ==================================
                                                // PENDING BATCHES
                                                // ==================================

                                                if (pendingBatches > 0)
                                                  Container(
                                                    width:
                                                    double.infinity,

                                                    margin:
                                                    const EdgeInsets
                                                        .only(
                                                      bottom: 15,
                                                    ),

                                                    padding:
                                                    const EdgeInsets
                                                        .all(13),

                                                    decoration:
                                                    BoxDecoration(
                                                      color:
                                                      Colors.orange
                                                          .shade50,

                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                        12,
                                                      ),
                                                    ),

                                                    child: Row(
                                                      children: [

                                                        Icon(
                                                          Icons
                                                              .pending_actions,

                                                          color:
                                                          Colors.orange
                                                              .shade700,
                                                        ),

                                                        const SizedBox(
                                                          width: 10,
                                                        ),

                                                        Expanded(
                                                          child: Text(
                                                            "$pendingBatches "
                                                                "${pendingBatches == 1 ? 'batch' : 'batches'} "
                                                                "attendance is pending. "
                                                                "$markedBatches out of "
                                                                "$totalBatches batches marked.",

                                                            style:
                                                            TextStyle(
                                                              color:
                                                              Colors.orange
                                                                  .shade800,

                                                              fontSize: 13,

                                                              fontWeight:
                                                              FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                // ==================================
                                                // PRESENT / ABSENT
                                                // ==================================

                                                Row(
                                                  children: [

                                                    Expanded(
                                                      child:
                                                      _desktopAttendanceCard(
                                                        icon:
                                                        Icons
                                                            .check_circle,

                                                        number:
                                                        present,

                                                        title:
                                                        "Present",

                                                        color:
                                                        Colors.green,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                      width: 15,
                                                    ),

                                                    Expanded(
                                                      child:
                                                      _desktopAttendanceCard(
                                                        icon:
                                                        Icons.cancel,

                                                        number:
                                                        absent,

                                                        title:
                                                        "Absent",

                                                        color:
                                                        Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(
                                                  height: 15,
                                                ),



                                                Container(
                                                  width:
                                                  double.infinity,

                                                  padding:
                                                  const EdgeInsets
                                                      .all(18),

                                                  decoration:
                                                  BoxDecoration(
                                                    color:
                                                    Colors.white,

                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                      18,
                                                    ),
                                                  ),

                                                  child: Row(
                                                    children: [

                                                      // ==========================
                                                      // CIRCLE
                                                      // ==========================

                                                      TweenAnimationBuilder<
                                                          double>(
                                                        tween:
                                                        Tween<double>(
                                                          begin: 0,

                                                          end:
                                                          percentage
                                                              .toDouble(),
                                                        ),

                                                        duration:
                                                        const Duration(
                                                          seconds: 2,
                                                        ),

                                                        builder:
                                                            (
                                                            context,
                                                            value,
                                                            child,
                                                            ) {

                                                          return SizedBox(
                                                            height: 130,
                                                            width: 130,

                                                            child: Stack(
                                                              alignment:
                                                              Alignment
                                                                  .center,

                                                              children: [

                                                                SizedBox(
                                                                  height: 95,
                                                                  width: 95,

                                                                  child:
                                                                  CircularProgressIndicator(
                                                                    value:
                                                                    value /
                                                                        100,

                                                                    strokeWidth:
                                                                    13,

                                                                    backgroundColor:
                                                                    Colors
                                                                        .grey
                                                                        .shade200,

                                                                    color:
                                                                    const Color(
                                                                      0xff263b84,
                                                                    ),
                                                                  ),
                                                                ),

                                                                Text(
                                                                  "${value.round()}%",

                                                                  style:
                                                                  const TextStyle(
                                                                    fontSize: 21,

                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),

                                                      const SizedBox(
                                                        width: 20,
                                                      ),

                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,

                                                          children: [

                                                            const Text(
                                                              "Overall Attendance",

                                                              style:
                                                              TextStyle(
                                                                fontSize: 21,

                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                              ),
                                                            ),

                                                            const SizedBox(
                                                              height: 6,
                                                            ),

                                                            Text(
                                                              "$present out of "
                                                                  "$total present today",

                                                              style:
                                                              TextStyle(
                                                                color:
                                                                Colors
                                                                    .grey
                                                                    .shade600,

                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(
                                                  height: 20,
                                                ),



                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 10,
                                                  ),

                                                  child:
                                                  weeklyAttendanceChart(
                                                    weeklyData,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),

                                  // ==================================================
                                  // NO ATTENDANCE
                                  // ==================================================

                                  // Yahan kuch show nahi hoga agar
                                  // markedBatches == 0

                                ],
                              ),
                            ),
                          ),

                          // ======================================================
                          // RIGHT SIDE
                          // ======================================================

                          Expanded(
                            flex: 4,

                            child: Container(
                              height: double.infinity,

                              padding:
                              const EdgeInsets.all(25),

                              color: Colors.white,

                              child: SingleChildScrollView(

                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,

                                  children: [

                                    const SizedBox(height: 5),

                                    const Text(
                                      "Quick Actions",

                                      style: TextStyle(
                                        fontSize: 23,

                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    // ==================================================
                                    // ADD BATCH
                                    // ==================================================

                                    _desktopAction(
                                      title: "Add Batch",

                                      subtitle:
                                      "New registration",

                                      icon:
                                      Icons
                                          .person_add_alt_rounded,

                                      background:
                                      const Color(0xff162A55),

                                      iconColor:
                                      Colors.blue,

                                      textColor:
                                      Colors.white,

                                      onTap: () async {

                                        await Navigator.push(
                                          context,

                                          MaterialPageRoute(
                                            builder: (context) =>
                                                addBatch(),
                                          ),
                                        );

                                        // ONLY TOTALS REFRESH

                                        refreshTotals();
                                      },
                                    ),

                                    const SizedBox(height: 13),

                                    // ==================================================
                                    // ATTENDANCE
                                    // ==================================================

                                    _desktopAction(
                                      title: "Attendance",

                                      subtitle:
                                      "Mark manually",

                                      icon:
                                      Icons
                                          .assignment_turned_in_rounded,

                                      background:
                                      Colors.blue,

                                      iconColor:
                                      Colors.white,

                                      textColor:
                                      Colors.white,

                                      onTap: () async {

                                        await Navigator.push(
                                          context,

                                          MaterialPageRoute(
                                            builder: (context) =>
                                                markAttend(),
                                          ),
                                        );

                                        // ONLY ATTENDANCE REFRESH

                                        refreshAttendance();
                                      },
                                    ),

                                    const SizedBox(height: 13),

                                    // ==================================================
                                    // BATCHES
                                    // ==================================================

                                    _desktopAction(
                                      title:
                                      "Batches List",

                                      subtitle:
                                      "Check list",

                                      icon:
                                      Icons
                                          .people_alt_rounded,

                                      background:
                                      Colors.white,

                                      iconColor:
                                      Colors.blue,

                                      textColor:
                                      Colors.black,

                                      onTap: () {

                                        Navigator.push(
                                          context,

                                          MaterialPageRoute(
                                            builder: (context) =>
                                                batchPage(),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 13),

                                    // ==================================================
                                    // REPORTS
                                    // ==================================================

                                    _desktopAction(
                                      title:
                                      "Reports",

                                      subtitle:
                                      "Check reports",

                                      icon:
                                      Icons
                                          .assignment_turned_in_rounded,

                                      background:
                                      Colors.white,

                                      iconColor:
                                      Colors.black,

                                      textColor:
                                      Colors.black,

                                      onTap: () {

                                        Navigator.push(
                                          context,

                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReportPage(),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 25),

                                    // ==================================================
                                    // SMALL INFO CARD
                                    // ==================================================

                                    Container(
                                      width: double.infinity,

                                      padding:
                                      const EdgeInsets.all(18),

                                      decoration:
                                      BoxDecoration(
                                        color:
                                        const Color(
                                          0xffeef2ff,
                                        ),

                                        borderRadius:
                                        BorderRadius.circular(
                                          16,
                                        ),
                                      ),

                                      child: Row(
                                        children: [

                                          Container(
                                            padding:
                                            const EdgeInsets.all(
                                              10,
                                            ),

                                            decoration:
                                            BoxDecoration(
                                              color:
                                              const Color(
                                                0xff263b84,
                                              ).withOpacity(.1),

                                              shape:
                                              BoxShape.circle,
                                            ),

                                            child: const Icon(
                                              Icons
                                                  .dashboard_rounded,

                                              color:
                                              Color(0xff263b84),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          const Expanded(
                                            child: Text(
                                              "Manage your batches, "
                                                  "attendance and reports "
                                                  "from here.",

                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
            
            
                  // MOBILE / TABLET

            
                  return
                    // CustomScrollView(
                  //                       slivers: [
                  //                         SliverAppBar(
                  //                           backgroundColor: Color(0xff263b84),                   //color
                  //                           collapsedHeight: 90,
                  //                           expandedHeight: 140,
                  //                           stretch: true,
                  //
                  //
                  //                           shape: RoundedRectangleBorder(
                  //                               borderRadius: BorderRadius.circular(15)
                  //                           ),
                  //                           flexibleSpace:  FlexibleSpaceBar(
                  //
                  //                             background: Padding(
                  //                               padding: const EdgeInsets.only(left: 30,bottom: 10,right: 15),
                  //                               child: Column(
                  //                                 mainAxisAlignment: MainAxisAlignment.end,
                  //                                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                                 children: [
                  //                                   Row(
                  //
                  //                                     children: [
                  //                                       Column(
                  //                                         children: [
                  //                                           Text("Welcome",style: TextStyle(color: Colors.grey.shade400,fontWeight: FontWeight.w500,fontSize:20),),
                  //
                  //
                  //
                  //                                           StreamBuilder(
                  //                                             stream: FirebaseFirestore.instance
                  //                                                 .collection("users")
                  //                                                 .doc(FirebaseAuth.instance.currentUser!.uid)
                  //                                                 .snapshots(),
                  //                                             builder: (context, snapshot) {
                  //                                               final data = snapshot.data?.data() as Map<String, dynamic>?;
                  //
                  //                                               return Text(
                  //                                                 data?["name"] ?? "",
                  //                                                 style: TextStyle(
                  //                                                   fontSize: 28,
                  //                                                   fontWeight: FontWeight.w500,
                  //                                                   color: Colors.white,
                  //                                                 ),
                  //                                               );
                  //                                             },
                  //                                           ),
                  //
                  //
                  //
                  //
                  //                                         ],
                  //                                       ),
                  //                                     ],
                  //                                   ),
                  //                                 ],
                  //                               ),
                  //                             ),
                  //
                  //                           ),
                  //
                  //                         ),
                  //             //SliverToBoxAdapter(
                  //             //             child:Padding(
                  //             //               padding: const EdgeInsets.only(left: 16,top: 25,bottom: 15),
                  //             //               child: Text("Today's Summary",style: TextStyle(fontWeight:FontWeight.w600,fontSize: 22),),
                  //             //             ),
                  //             //           ),
                  //                         SliverToBoxAdapter(
                  //                           child: FutureBuilder<Map<String, int>>(
                  //                             future: todayAttendanceFuture,
                  //                             builder: (context, snapshot) {
                  //
                  //             // LOADING
                  //
                  //                               if (snapshot.connectionState == ConnectionState.waiting) {
                  //                                 return const skeleton();
                  //                               }
                  //
                  //
                  //             // ERROR
                  //
                  //                               if (snapshot.hasError) {
                  //                                 return Padding(
                  //                                   padding: const EdgeInsets.all(20),
                  //                                   child: Center(
                  //                                     child: Text(
                  //                                       "Error: ${snapshot.error}",
                  //                                     ),
                  //                                   ),
                  //                                 );
                  //                               }
                  //
                  //
                  //             // DATA
                  //
                  //                               final present =
                  //                                   snapshot.data?["present"] ?? 0;
                  //
                  //                               final absent =
                  //                                   snapshot.data?["absent"] ?? 0;
                  //
                  //                               final total =
                  //                                   snapshot.data?["total"] ?? 0;
                  //
                  //                               final percentage =
                  //                                   snapshot.data?["percentage"] ?? 0;
                  //
                  //                               final totalBatches =
                  //                                   snapshot.data?["totalBatches"] ?? 0;
                  //
                  //                               final markedBatches =
                  //                                   snapshot.data?["markedBatches"] ?? 0;
                  //
                  //                               final pendingBatches =
                  //                                   totalBatches - markedBatches;
                  //
                  //
                  //                               if (markedBatches == 0) {
                  //                                 return const SizedBox.shrink();
                  //                               }
                  //
                  //
                  //
                  //                               return Column(
                  //                                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                                 children: [
                  //
                  //
                  //
                  //                                   const Padding(
                  //                                     padding: EdgeInsets.only(
                  //                                       left: 16,
                  //                                       top: 25,
                  //                                       bottom: 15,
                  //                                     ),
                  //                                     child: Text(
                  //                                       "Today's Summary",
                  //                                       style: TextStyle(
                  //                                         fontWeight: FontWeight.w600,
                  //                                         fontSize: 22,
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //
                  //
                  //
                  //                                   if (pendingBatches > 0)
                  //                                     Container(
                  //                                       margin: const EdgeInsets.only(
                  //                                         left: 15,
                  //                                         right: 15,
                  //                                         bottom: 10,
                  //                                       ),
                  //                                       padding: const EdgeInsets.all(12),
                  //                                       decoration: BoxDecoration(
                  //                                         color: Colors.orange.shade50,
                  //                                         borderRadius: BorderRadius.circular(12),
                  //                                       ),
                  //                                       child: Row(
                  //                                         children: [
                  //
                  //                                           Icon(
                  //                                             Icons.pending_actions,
                  //                                             color: Colors.orange.shade700,
                  //                                           ),
                  //
                  //                                           const SizedBox(width: 8),
                  //
                  //                                           Expanded(
                  //                                             child: Text(
                  //                                               "$pendingBatches "
                  //                                                   "${pendingBatches == 1 ? 'batch' : 'batches'} "
                  //                                                   "attendance been pending. "
                  //                                                   "$markedBatches out of $totalBatches "
                  //                                                   "batches marked.",
                  //                                               style: TextStyle(
                  //                                                 color: Colors.orange.shade800,
                  //                                                 fontSize: 13,
                  //                                                 fontWeight: FontWeight.w500,
                  //                                               ),
                  //                                             ),
                  //                                           ),
                  //                                         ],
                  //                                       ),
                  //                                     ),
                  //
                  //
                  //             // PRESENT / ABSENT CARDS
                  //
                  //
                  //                                   Padding(
                  //                                     padding: const EdgeInsets.only(
                  //                                       left: 15,
                  //                                       right: 15,
                  //                                     ),
                  //                                     child: Container(
                  //                                       padding: const EdgeInsets.only(
                  //                                         top: 10,
                  //                                         bottom: 10,
                  //                                         left: 40,
                  //                                         right: 40,
                  //                                       ),
                  //                                       child: Row(
                  //                                         mainAxisAlignment:
                  //                                         MainAxisAlignment.spaceBetween,
                  //                                         children: [
                  //
                  //
                  //             // PRESENT
                  //
                  //
                  //                                           Expanded(
                  //                                             child: Container(
                  //                                               padding: const EdgeInsets.all(8),
                  //                                               decoration: BoxDecoration(
                  //
                  //                                                 color: Colors.white,
                  //                                                 borderRadius:
                  //                                                 BorderRadius.circular(12),
                  //                                               ),
                  //                                               height: 120,
                  //                                               child: Column(
                  //                                                 spacing: 3,
                  //                                                 children: [
                  //
                  //                                                   const Icon(
                  //                                                     Icons.check_circle,
                  //                                                     color: Colors.green,
                  //                                                   ),
                  //
                  //                                                   Text(
                  //                                                     "$present",
                  //                                                     style: TextStyle(
                  //                                                       fontSize: 26,
                  //                                                       fontWeight: FontWeight.w800,
                  //                                                       color:
                  //                                                       Colors.green.shade400,
                  //                                                     ),
                  //                                                   ),
                  //
                  //                                                   const Text(
                  //                                                     "Present",
                  //                                                     style: TextStyle(
                  //                                                       fontSize: 20,
                  //                                                     ),
                  //                                                   ),
                  //                                                 ],
                  //                                               ),
                  //                                             ),
                  //                                           ),
                  //
                  //                                           const SizedBox(width: 45),
                  //
                  //
                  //             // ABSENT
                  //
                  //
                  //                                           Expanded(
                  //                                             child: Container(
                  //                                               padding: const EdgeInsets.all(8),
                  //                                               decoration: BoxDecoration(
                  //
                  //                                                 color: Colors.white,
                  //                                                 borderRadius:
                  //                                                 BorderRadius.circular(12),
                  //                                               ),
                  //                                               height: 120,
                  //                                               child: Column(
                  //                                                 spacing: 3,
                  //                                                 children: [
                  //
                  //                                                   const Icon(
                  //                                                     Icons.cancel,
                  //                                                     color: Colors.red,
                  //                                                   ),
                  //
                  //                                                   Text(
                  //                                                     "$absent",
                  //                                                     style: TextStyle(
                  //                                                       fontSize: 26,
                  //                                                       fontWeight: FontWeight.w800,
                  //                                                       color:
                  //                                                       Colors.red.shade400,
                  //                                                     ),
                  //                                                   ),
                  //
                  //                                                   const Text(
                  //                                                     "Absent",
                  //                                                     style: TextStyle(
                  //                                                       fontSize: 20,
                  //                                                     ),
                  //                                                   ),
                  //                                                 ],
                  //                                               ),
                  //                                             ),
                  //                                           ),
                  //                                         ],
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //
                  //             // ==================================================
                  //             // OVERALL ATTENDANCE
                  //             // ==================================================
                  //
                  //                                   Padding(
                  //                                     padding: const EdgeInsets.symmetric(
                  //                                       horizontal: 16,
                  //                                       vertical: 10,
                  //                                     ),
                  //                                     child: Container(
                  //                                       decoration: BoxDecoration(
                  //                                         color: Colors.white,
                  //                                         borderRadius:
                  //                                         BorderRadius.circular(12),
                  //                                       ),
                  //                                       child: Row(
                  //                                         spacing: 12,
                  //                                         children: [
                  //
                  //             // ==========================================
                  //             // CIRCULAR PERCENTAGE
                  //             // ==========================================
                  //
                  //                                           TweenAnimationBuilder<double>(
                  //                                             tween: Tween<double>(
                  //                                               begin: 0,
                  //                                               end: percentage.toDouble(),
                  //                                             ),
                  //                                             duration:
                  //                                             const Duration(seconds: 2),
                  //                                             builder:
                  //                                                 (context, value, child) {
                  //
                  //                                               return SizedBox(
                  //                                                 height: 130,
                  //                                                 width: 130,
                  //                                                 child: Stack(
                  //                                                   alignment: Alignment.center,
                  //                                                   children: [
                  //
                  //                                                     SizedBox(
                  //                                                       height: 90,
                  //                                                       width: 90,
                  //                                                       child:
                  //                                                       CircularProgressIndicator(
                  //                                                         value: value / 100,
                  //                                                         strokeWidth: 13,
                  //                                                         backgroundColor:
                  //                                                         Colors.grey.shade200,
                  //                                                         color:
                  //                                                         const Color(0xff263b84),
                  //                                                       ),
                  //                                                     ),
                  //
                  //                                                     Text(
                  //                                                       "${value.round()}%",
                  //                                                       style: const TextStyle(
                  //                                                         color: Colors.black,
                  //                                                         fontWeight:
                  //                                                         FontWeight.bold,
                  //                                                         fontSize: 20,
                  //                                                       ),
                  //                                                     ),
                  //                                                   ],
                  //                                                 ),
                  //                                               );
                  //                                             },
                  //                                           ),
                  //
                  //             // ==========================================
                  //             // ATTENDANCE DETAILS
                  //             // ==========================================
                  //
                  //                                           Expanded(
                  //                                             child: Column(
                  //                                               crossAxisAlignment:
                  //                                               CrossAxisAlignment.start,
                  //                                               spacing: 4,
                  //                                               children: [
                  //
                  //                                                 const Text(
                  //                                                   "Overall Attendance",
                  //                                                   style: TextStyle(
                  //                                                     color: Colors.black,
                  //                                                     fontWeight:
                  //                                                     FontWeight.bold,
                  //                                                     fontSize: 20,
                  //                                                   ),
                  //                                                 ),
                  //
                  //                                                 Text(
                  //                                                   "$present out of $total "
                  //                                                       "present today",
                  //                                                   style: TextStyle(
                  //                                                     color:
                  //                                                     Colors.grey.shade600,
                  //                                                     fontSize: 14,
                  //                                                   ),
                  //                                                 ),
                  //
                  //                                                 const SizedBox(height: 2),
                  //
                  //             // ====================================
                  //             // COMPARISON
                  //             // ====================================
                  //
                  //                                                 FutureBuilder<
                  //                                                     Map<String, dynamic>>(
                  //                                                   future:
                  //                                                   attendanceComparisonFuture,
                  //                                                   builder:
                  //                                                       (context, comparisonSnapshot) {
                  //
                  //                                                     if (comparisonSnapshot
                  //                                                         .connectionState ==
                  //                                                         ConnectionState.waiting) {
                  //                                                       return const SizedBox.shrink();
                  //                                                     }
                  //
                  //                                                     if (comparisonSnapshot
                  //                                                         .hasError) {
                  //                                                       return const SizedBox.shrink();
                  //                                                     }
                  //
                  //                                                     final previousPercentage =
                  //                                                     comparisonSnapshot
                  //                                                         .data?["percentage"];
                  //
                  //                                                     final daysAgo =
                  //                                                     comparisonSnapshot
                  //                                                         .data?["daysAgo"];
                  //
                  //             // Previous attendance nahi mili
                  //                                                     if (previousPercentage ==
                  //                                                         null ||
                  //                                                         daysAgo == null) {
                  //                                                       return const SizedBox.shrink();
                  //                                                     }
                  //
                  //                                                     final difference =
                  //                                                         percentage -
                  //                                                             previousPercentage;
                  //
                  //                                                     String label;
                  //
                  //                                                     if (daysAgo == 1) {
                  //                                                       label = "vs yesterday";
                  //                                                     } else if (daysAgo == 2) {
                  //                                                       label = "vs 2 days ago";
                  //                                                     } else {
                  //                                                       label =
                  //                                                       "vs $daysAgo days ago";
                  //                                                     }
                  //
                  //                                                     return Container(
                  //                                                       padding:
                  //                                                       const EdgeInsets
                  //                                                           .symmetric(
                  //                                                         horizontal: 6,
                  //                                                         vertical: 2,
                  //                                                       ),
                  //                                                       decoration:
                  //                                                       BoxDecoration(
                  //                                                         color:
                  //                                                         Colors.grey.shade200,
                  //                                                         borderRadius:
                  //                                                         BorderRadius
                  //                                                             .circular(12),
                  //                                                       ),
                  //                                                       child: Row(
                  //                                                         mainAxisSize:
                  //                                                         MainAxisSize.min,
                  //                                                         children: [
                  //
                  //                                                           Icon(
                  //                                                             difference >= 0
                  //                                                                 ? Icons
                  //                                                                 .trending_up_sharp
                  //                                                                 : Icons
                  //                                                                 .trending_down_sharp,
                  //                                                             color:
                  //                                                             difference >= 0
                  //                                                                 ? Colors.green
                  //                                                                 : Colors.red,
                  //                                                             size: 15,
                  //                                                           ),
                  //
                  //                                                           const SizedBox(width: 2),
                  //
                  //                                                           Text(
                  //                                                             "${difference >= 0 ? '+' : ''}"
                  //                                                                 "$difference%",
                  //                                                             style: TextStyle(
                  //                                                               color:
                  //                                                               difference >= 0
                  //                                                                   ? Colors.green
                  //                                                                   : Colors.red,
                  //                                                               fontSize: 12,
                  //                                                             ),
                  //                                                           ),
                  //
                  //                                                           const SizedBox(width: 2),
                  //
                  //                                                           Text(
                  //                                                             label,
                  //                                                             style: TextStyle(
                  //                                                               fontSize: 12,
                  //                                                               color:
                  //                                                               Colors.grey
                  //                                                                   .shade500,
                  //                                                             ),
                  //                                                           ),
                  //                                                         ],
                  //                                                       ),
                  //                                                     );
                  //                                                   },
                  //                                                 ),
                  //                                               ],
                  //                                             ),
                  //                                           ),
                  //                                         ],
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //                                 ],
                  //                               );
                  //                             },
                  //                           ),
                  //                         ),
                  //
                  //                         SliverToBoxAdapter(
                  //                           child:Padding(
                  //                             padding: const EdgeInsets.only(left: 16,top: 25,bottom: 15),
                  //                             child: Text("Quick Actions",style: TextStyle(fontWeight:FontWeight.w600,fontSize: 22),),
                  //                           ),
                  //                         ),
                  //                         SliverToBoxAdapter(
                  //                           child: Container(
                  //                             padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                  //                             child: Row(
                  //                               children: [
                  //                                 Expanded(
                  //                                   child: InkWell(
                  //                                     onTap: ()async{
                  //                                       await Navigator.push(context, MaterialPageRoute(builder: (context)=>addBatch()));
                  //
                  //                                     },
                  //                                     child: Container(
                  //                                       width: double.infinity,
                  //                                       padding: EdgeInsets.all(13),
                  //                                       decoration: BoxDecoration(
                  //                                           color: Color(0xFF162A55)   ,             // Color(0xff263b84),
                  //                                           borderRadius: BorderRadius.circular(15)
                  //                                       ),
                  //                                       child: Column(
                  //                                         crossAxisAlignment: CrossAxisAlignment.start,
                  //                                         children: [
                  //                                           Container(
                  //                                             padding: EdgeInsets.all(6),
                  //                                             decoration: BoxDecoration(
                  //                                                 borderRadius: BorderRadius.circular(14),
                  //                                                 color: Colors.black26.withOpacity(0.3)
                  //                                             ),
                  //                                             child: Icon(Icons.person_add_alt_rounded,color: Colors.blue,),
                  //                                           ),
                  //                                           Text("Add Batch",style: TextStyle(color: Colors.white,fontSize: 18),),
                  //                                           Text("New registration",style: TextStyle(color: Colors.grey.shade500,fontSize: 12),)
                  //                                         ],
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //                                 ),
                  //                                 SizedBox(width: 13,),
                  //                                 Expanded(
                  //                                   child: InkWell(
                  //                                     onTap: ()async{
                  //                                       await Navigator.push(context, MaterialPageRoute(builder: ((context) => markAttend())));
                  //                                       refreshAttendance();
                  //                                     },
                  //                                     child: Container(
                  //                                       width: double.infinity,
                  //                                       padding: EdgeInsets.all(13),
                  //                                       decoration: BoxDecoration(
                  //                                           color: Colors.blue,           // Color(0xff263b84),
                  //                                           borderRadius: BorderRadius.circular(15)
                  //                                       ),
                  //                                       child: Column(
                  //                                         crossAxisAlignment: CrossAxisAlignment.start,
                  //                                         children: [
                  //                                           Container(
                  //                                             padding: EdgeInsets.all(6),
                  //                                             decoration: BoxDecoration(
                  //                                                 borderRadius: BorderRadius.circular(14),
                  //                                                 color: Colors.white30
                  //                                             ),
                  //                                             child: Icon(Icons.assignment_turned_in_rounded,color: Colors.white,),
                  //                                           ),
                  //                                           Text("Attendance",style: TextStyle(color: Colors.white,fontSize: 18),),
                  //                                           Text(" Mark manually",style: TextStyle(color: Colors.grey.shade200,fontSize: 12),)
                  //                                         ],
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //                                 )
                  //                               ],
                  //                             ),
                  //                           ),
                  //                         ),
                  //                         SliverToBoxAdapter(
                  //                           child: Container(
                  //                             padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                  //                             child: Row(
                  //                               children: [
                  //                                 Expanded(
                  //                                   child: InkWell(
                  //                                     onTap: (){
                  //                                       Navigator.push(context, MaterialPageRoute(builder: (context)=>batchPage()));
                  //
                  //                                     },
                  //                                     child: Container(
                  //                                       width: double.infinity,
                  //                                       padding: EdgeInsets.all(13),
                  //                                       decoration: BoxDecoration(
                  //                                           color: Colors.white  ,             // Color(0xff263b84),
                  //                                           borderRadius: BorderRadius.circular(15)
                  //                                       ),
                  //                                       child: Column(
                  //                                         crossAxisAlignment: CrossAxisAlignment.start,
                  //                                         children: [
                  //                                           Container(
                  //                                             padding: EdgeInsets.all(6),
                  //                                             decoration: BoxDecoration(
                  //                                                 borderRadius: BorderRadius.circular(14),
                  //                                                 color: Colors.grey.shade200
                  //                                             ),
                  //                                             child: Icon(Icons.person_add_alt_rounded,color: Colors.blue,),
                  //                                           ),
                  //                                           Text("Batches List",style: TextStyle(color: Colors.black,fontSize: 18),),
                  //                                           Text("Check list",style: TextStyle(color: Colors.grey.shade500,fontSize: 12),)
                  //                                         ],
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //                                 ),
                  //                                 SizedBox(width: 13,),
                  //                                 Expanded(
                  //                                   child: InkWell(
                  //                                     onTap: (){
                  //                                       Navigator.push(context, MaterialPageRoute(builder: (context)=>ReportPage()));
                  //
                  //                                     },
                  //                                     child: Container(
                  //                                       width: double.infinity,
                  //                                       padding: EdgeInsets.all(13),
                  //                                       decoration: BoxDecoration(
                  //                                           color: Colors.white,          // Color(0xff263b84),
                  //                                           borderRadius: BorderRadius.circular(15)
                  //                                       ),
                  //                                       child: Column(
                  //                                         crossAxisAlignment: CrossAxisAlignment.start,
                  //                                         children: [
                  //                                           Container(
                  //                                             padding: EdgeInsets.all(6),
                  //                                             decoration: BoxDecoration(
                  //                                                 borderRadius: BorderRadius.circular(14),
                  //                                                 color: Colors.grey.shade200
                  //                                             ),
                  //                                             child: Icon(Icons.assignment_turned_in_rounded,color: Colors.black,),
                  //                                           ),
                  //                                           Text("Reports",style: TextStyle(color: Colors.black, fontSize: 18),),
                  //                                           Text("Check reports",style: TextStyle(color: Colors.grey.shade400,fontSize: 12),)
                  //                                         ],
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //                                 )
                  //                               ],
                  //                             ),
                  //                           ),
                  //                         ),
                  //                         SliverToBoxAdapter(
                  //                           child:Padding(
                  //                             padding: const EdgeInsets.only(left: 16,top: 25,bottom: 15),
                  //                             child: Text("Overview",style: TextStyle(fontWeight:FontWeight.w600,fontSize: 22),),
                  //                           ),
                  //                         ),
                  //                         SliverToBoxAdapter(
                  //                           child: FutureBuilder(
                  //                             future: homeTotalsFuture,
                  //                             builder: (context, snapshot) {
                  //                               if(snapshot.connectionState==ConnectionState.waiting){
                  //                                 return Center(child: CircularProgressIndicator(),);
                  //                               }
                  //                               if(snapshot.hasError){
                  //                                 return  Row(
                  //                                   children: [
                  //                                     _statCard(icon: Icons.people_alt_rounded, title: "total employees", value: "0"),
                  //                                   SizedBox(width: 20,),
                  //                                     _statCard(icon: Icons.groups_rounded, title: "total batches", value: "0"),
                  //                                   ],
                  //                                 );
                  //
                  //                               }
                  //                               final data = snapshot.data ??
                  //                                   {
                  //                                     "totalEmployees": 0,
                  //                                     "totalBatches": 0,
                  //                                   };
                  //
                  //                               final totalEmployees =
                  //                                   data["totalEmployees"] ?? 0;
                  //
                  //                               final totalBatches =
                  //                                   data["totalBatches"] ?? 0;
                  //                               return Padding(
                  //                                 padding: const EdgeInsets.symmetric(horizontal: 14),
                  //                                 child: Container(
                  //                                   child: Row(
                  //                                     children: [
                  //
                  //                                       Expanded(
                  //                                         child: _statCard(
                  //                                           icon: Icons.people,
                  //                                           title: "Total Employees",
                  //                                           value: totalEmployees.toString(),
                  //                                         ),
                  //                                       ),
                  //
                  //                                       const SizedBox(width: 16),
                  //
                  //                                       Expanded(
                  //                                         child: _statCard(
                  //                                           icon: Icons.groups,
                  //                                           title: "Total Batches",
                  //                                           value: totalBatches.toString(),
                  //                                         ),
                  //                                       ),
                  //
                  //                                     ],
                  //                                   ),
                  //                                 ),
                  //                               );
                  //                             }
                  //                           ),
                  //                         ),
                  //                         SliverToBoxAdapter(
                  //                           child: Padding(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20,
                  //                           ),
                  //                             child: weeklyAttendanceChart(
                  //                               weeklyData,
                  //                             ),
                  //                           ),
                  //                         )
                  //
                  //
                  //
                  //                       ],
                  //                     );
                    CustomScrollView(
                      slivers: [

                        // ============================================================
                        // APP BAR
                        // ============================================================

                        SliverAppBar(
                          backgroundColor: const Color(0xff263b84),
                          collapsedHeight: 90,
                          expandedHeight: 140,
                          stretch: true,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomLeft  : Radius.circular(25),bottomRight: Radius.circular(25)),
                          ),

                          flexibleSpace: FlexibleSpaceBar(
                            background: Padding(
                              padding: const EdgeInsets.only(
                                left: 35,
                                bottom: 15,
                                right: 15,

                              ),


                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                
                                  children: [
                                
                                    Row(
                                      children: [
                                
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                
                                          children: [
                                
                                            Text(
                                              "Welcome!",
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontWeight:
                                                FontWeight.w500,
                                                fontSize: 20,
                                              ),
                                            ),
                                
                                            StreamBuilder(
                                              stream:
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid,
                                              )
                                                  .snapshots(),
                                
                                              builder:
                                                  (context, snapshot) {
                                
                                                final data =
                                                snapshot.data?.data()
                                                as Map<String, dynamic>?;
                                
                                                return Text(
                                                  data?["name"] ?? "",
                                
                                                  style: const TextStyle(
                                                    fontSize: 26,
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                            ),
                          ),
                        ),

                        // ============================================================
                        // TODAY'S ATTENDANCE
                        // ============================================================

                        SliverToBoxAdapter(
                          child: Builder(
                            builder: (context) {

                              // ATTENDANCE REFRESH LOADING

                              if (attendanceLoading) {
                                return const skeleton2();
                              }

                              final present =
                                  todayData["present"] ?? 0;

                              final absent =
                                  todayData["absent"] ?? 0;

                              final total =
                                  todayData["total"] ?? 0;

                              final percentage =
                                  todayData["percentage"] ?? 0;

                              final totalBatches =
                                  todayData["totalBatches"] ?? 0;

                              final markedBatches =
                                  todayData["markedBatches"] ?? 0;

                              final pendingBatches =
                                  totalBatches - markedBatches;

                              // NO ATTENDANCE TODAY

                              if (markedBatches == 0) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  // ==================================================
                                  // TITLE
                                  // ==================================================

                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      top: 25,
                                      bottom: 15,
                                    ),

                                    child: Text(
                                      "Today's Summary",

                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight.w600,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),

                                  // ==================================================
                                  // PENDING BATCHES
                                  // ==================================================

                                  if (pendingBatches > 0)
                                    Container(
                                      margin: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        bottom: 10,
                                      ),

                                      padding:
                                      const EdgeInsets.all(12),

                                      decoration: BoxDecoration(
                                        color:
                                        Colors.orange.shade50,

                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),

                                      child: Row(
                                        children: [

                                          Icon(
                                            Icons.pending_actions,
                                            color:
                                            Colors.orange.shade700,
                                          ),

                                          const SizedBox(width: 8),

                                          Expanded(
                                            child: Text(
                                              "$pendingBatches "
                                                  "${pendingBatches == 1 ? 'batch' : 'batches'} "
                                                  "attendance been pending. "
                                                  "$markedBatches out of "
                                                  "$totalBatches batches marked.",

                                              style: TextStyle(
                                                color:
                                                Colors.orange.shade800,
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // ==================================================
                                  // PRESENT / ABSENT
                                  // ==================================================

                                  Padding(
                                    padding:
                                    const EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                    ),

                                    child: Container(
                                      padding:
                                      const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 40,
                                        right: 40,
                                      ),

                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,

                                        children: [

                                          // PRESENT

                                          Expanded(
                                            child: Container(
                                              padding:
                                              const EdgeInsets.all(8),

                                              decoration:
                                              BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                              ),

                                              height: 120,

                                              child: Column(
                                                spacing: 3,

                                                children: [

                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                  ),

                                                  Text(
                                                    "$present",

                                                    style: TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                      FontWeight.w800,
                                                      color:
                                                      Colors.green
                                                          .shade400,
                                                    ),
                                                  ),

                                                  const Text(
                                                    "Present",

                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 45),

                                          // ABSENT

                                          Expanded(
                                            child: Container(
                                              padding:
                                              const EdgeInsets.all(8),

                                              decoration:
                                              BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                              ),

                                              height: 120,

                                              child: Column(
                                                spacing: 3,

                                                children: [

                                                  const Icon(
                                                    Icons.cancel,
                                                    color: Colors.red,
                                                  ),

                                                  Text(
                                                    "$absent",

                                                    style: TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                      FontWeight.w800,
                                                      color:
                                                      Colors.red
                                                          .shade400,
                                                    ),
                                                  ),

                                                  const Text(
                                                    "Absent",

                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // ==================================================
                                  // OVERALL ATTENDANCE
                                  // ==================================================

                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),

                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),

                                      child: Row(
                                        spacing: 12,

                                        children: [

                                          // ==================================================
                                          // CIRCULAR PERCENTAGE
                                          // ==================================================

                                          TweenAnimationBuilder<double>(
                                            tween: Tween<double>(
                                              begin: 0,
                                              end: percentage.toDouble(),
                                            ),

                                            duration:
                                            const Duration(
                                              seconds: 2,
                                            ),

                                            builder:
                                                (context, value, child) {

                                              return SizedBox(
                                                height: 130,
                                                width: 130,

                                                child: Stack(
                                                  alignment:
                                                  Alignment.center,

                                                  children: [

                                                    SizedBox(
                                                      height: 90,
                                                      width: 90,

                                                      child:
                                                      CircularProgressIndicator(
                                                        value:
                                                        value / 100,

                                                        strokeWidth: 13,

                                                        backgroundColor:
                                                        Colors.grey
                                                            .shade200,

                                                        color:
                                                        const Color(
                                                          0xff263b84,
                                                        ),
                                                      ),
                                                    ),

                                                    Text(
                                                      "${value.round()}%",

                                                      style:
                                                      const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),

                                          // ==================================================
                                          // ATTENDANCE DETAILS
                                          // ==================================================

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                              spacing: 4,

                                              children: [

                                                const Text(
                                                  "Overall Attendance",

                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),

                                                Text(
                                                  "$present out of $total "
                                                      "present today",

                                                  style: TextStyle(
                                                    color:
                                                    Colors.grey.shade600,
                                                    fontSize: 14,
                                                  ),
                                                ),

                                                const SizedBox(height: 2),

                                                // NEW COMPARISON
                                                _attendanceComparison(
                                                  percentage,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // ============================================================
                        // QUICK ACTIONS TITLE
                        // ============================================================

                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              top: 25,
                              bottom: 15,
                            ),

                            child: const Text(
                              "Quick Actions",

                              style: TextStyle(
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),

                        // ============================================================
                        // QUICK ACTIONS - ROW 1
                        // ============================================================

                        SliverToBoxAdapter(
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),

                            child: Row(
                              children: [

                                // ==================================================
                                // ADD BATCH
                                // ==================================================

                                Expanded(
                                  child: InkWell(

                                    onTap: () async {

                                      await Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                              addBatch(),
                                        ),
                                      );

                                      // ONLY TOTALS REFRESH

                                      refreshTotals();
                                    },

                                    child: Container(
                                      width: double.infinity,

                                      padding:
                                      const EdgeInsets.all(13),

                                      decoration: BoxDecoration(
                                        color:
                                        const Color(0xFF162A55),

                                        borderRadius:
                                        BorderRadius.circular(15),
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                        children: [

                                          Container(
                                            padding:
                                            const EdgeInsets.all(6),

                                            decoration:
                                            BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(14),

                                              color: Colors.black26
                                                  .withOpacity(0.3),
                                            ),

                                            child: const Icon(
                                              Icons
                                                  .person_add_alt_rounded,
                                              color: Colors.blue,
                                            ),
                                          ),

                                          const Text(
                                            "Add Batch",

                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),

                                          Text(
                                            "New registration",

                                            style: TextStyle(
                                              color:
                                              Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 13),

                                // ==================================================
                                // ATTENDANCE
                                // ==================================================

                                Expanded(
                                  child: InkWell(

                                    onTap: () async {

                                      await Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder: (context) =>
                                              markAttend(),
                                        ),
                                      );

                                      // ONLY ATTENDANCE REFRESH

                                      refreshAttendance();
                                    },

                                    child: Container(
                                      width: double.infinity,

                                      padding:
                                      const EdgeInsets.all(13),

                                      decoration: BoxDecoration(
                                        color: Colors.blue,

                                        borderRadius:
                                        BorderRadius.circular(15),
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                        children: [

                                          Container(
                                            padding:
                                            const EdgeInsets.all(6),

                                            decoration:
                                            BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(14),

                                              color: Colors.white30,
                                            ),

                                            child: const Icon(
                                              Icons
                                                  .assignment_turned_in_rounded,
                                              color: Colors.white,
                                            ),
                                          ),

                                          const Text(
                                            "Attendance",

                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),

                                          Text(
                                            " Mark manually",

                                            style: TextStyle(
                                              color:
                                              Colors.grey.shade200,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ============================================================
                        // QUICK ACTIONS - ROW 2
                        // ============================================================

                        SliverToBoxAdapter(
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),

                            child: Row(
                              children: [

                                // ==================================================
                                // BATCHES LIST
                                // ==================================================

                                Expanded(
                                  child: InkWell(

                                    onTap: () {

                                      Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder: (context) =>
                                              batchPage(),
                                        ),
                                      );
                                    },

                                    child: Container(
                                      width: double.infinity,

                                      padding:
                                      const EdgeInsets.all(13),

                                      decoration: BoxDecoration(
                                        color: Colors.white,

                                        borderRadius:
                                        BorderRadius.circular(15),
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                        children: [

                                          Container(
                                            padding:
                                            const EdgeInsets.all(6),

                                            decoration:
                                            BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(14),

                                              color:
                                              Colors.grey.shade200,
                                            ),

                                            child: const Icon(
                                              Icons
                                                  .person_add_alt_rounded,
                                              color: Colors.blue,
                                            ),
                                          ),

                                          const Text(
                                            "Batches List",

                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                          ),

                                          Text(
                                            "Check list",

                                            style: TextStyle(
                                              color:
                                              Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 13),

                                // ==================================================
                                // REPORTS
                                // ==================================================

                                Expanded(
                                  child: InkWell(

                                    onTap: () {

                                      Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ReportPage(),
                                        ),
                                      );
                                    },

                                    child: Container(
                                      width: double.infinity,

                                      padding:
                                      const EdgeInsets.all(13),

                                      decoration: BoxDecoration(
                                        color: Colors.white,

                                        borderRadius:
                                        BorderRadius.circular(15),
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                        children: [

                                          Container(
                                            padding:
                                            const EdgeInsets.all(6),

                                            decoration:
                                            BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(14),

                                              color:
                                              Colors.grey.shade200,
                                            ),

                                            child: const Icon(
                                              Icons
                                                  .assignment_turned_in_rounded,
                                              color: Colors.black,
                                            ),
                                          ),

                                          const Text(
                                            "Reports",

                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                          ),

                                          Text(
                                            "Check reports",

                                            style: TextStyle(
                                              color:
                                              Colors.grey.shade400,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ============================================================
                        // OVERVIEW TITLE
                        // ============================================================

                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              top: 25,
                              bottom: 15,
                            ),

                            child: const Text(
                              "Overview",

                              style: TextStyle(
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),

                        // ============================================================
                        // OVERVIEW
                        // ============================================================

                        SliverToBoxAdapter(
                          child: Builder(
                            builder: (context) {

                              // ONLY OVERVIEW LOADING

                              if (totalsLoading) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),

                                  child: Center(
                                    child:
                                    CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final totalEmployees =
                                  totalsData["totalEmployees"] ?? 0;

                              final totalBatches =
                                  totalsData["totalBatches"] ?? 0;

                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),

                                child: Row(
                                  children: [

                                    Expanded(
                                      child: _statCard(
                                        icon:
                                        Icons.people,
                                        title:
                                        "Total Employees",
                                        value:
                                        totalEmployees.toString(),
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: _statCard(
                                        icon:
                                        Icons.groups,
                                        title:
                                        "Total Batches",
                                        value:
                                        totalBatches.toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // ============================================================
                        // WEEKLY ATTENDANCE CHART
                        // ============================================================

                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 20,
                            ),

                            child: attendanceLoading
                                ? const skeleton2()
                                : weeklyAttendanceChart(
                              weeklyData,
                            ),
                          ),
                        ),
                      ],
                    );

                }),
          );}



// =================================================================
// DESKTOP ATTENDANCE CARD
// =================================================================

  Widget _desktopAttendanceCard({
    required IconData icon,
    required int number,
    required String title,
    required Color color,
  }) {
    return Container(
      height: 125,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: color,
            size: 28,
          ),

          const SizedBox(height: 5),

          Text(
            "$number",
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }


// =================================================================
// DESKTOP QUICK ACTION
// =================================================================

  Widget _desktopAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color background,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),

      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(17),

        decoration: BoxDecoration(
          color: background,
          borderRadius:
          BorderRadius.circular(16),

          boxShadow: background == Colors.white
              ? [
            BoxShadow(
              color:
              Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset:
              const Offset(0, 3),
            ),
          ]
              : null,
        ),

        child: Row(
          children: [

            Container(
              padding:
              const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: background == Colors.white
                    ? Colors.grey.shade100
                    : Colors.black.withOpacity(.15),

                borderRadius:
                BorderRadius.circular(12),
              ),

              child: Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: background == Colors.white
                          ? Colors.grey.shade500
                          : Colors.white70,

                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,

              color: background == Colors.white
                  ? Colors.grey.shade400
                  : Colors.white60,
            ),
          ],
        ),
      ),
    );
  }}

class skeleton extends StatelessWidget{
  const skeleton({super.key});
  Widget skeletonBox({
    double? height,
    double?width,
    double radius=10,
}){
    return Shimmer.fromColors(

        baseColor: Colors.grey.shade200,
        highlightColor:Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
       borderRadius: BorderRadius.circular(radius),
      ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 17),
            child: skeletonBox(
              height:130,
              width: double.infinity,
              radius: 12,
            )
            ),
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 17),
    child: skeletonBox(
    height:100,
    width: double.infinity,
    radius: 12,
    )
    ),

        ],
      ),
    );

  }
}

Widget _statCard({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.all(10),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          size: 30,
          color: const Color(0xff263b84),
        ),

        const SizedBox(height: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
class Skeleton extends StatelessWidget{
  const Skeleton({super.key});
  Widget skeletonBox({
    double? height,
    double?width,
    double radius=10,
  }){
    return Shimmer.fromColors(

      baseColor: Colors.grey.shade200,
      highlightColor:Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
     child:  ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 700,
        ),
       child: Container(
         padding: EdgeInsets.only(top: 60),
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 17),
                    child: skeletonBox(
                      height:130,
                      width: double.infinity,
                      radius: 12,
                    )
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 17),
                    child: skeletonBox(
                      height:90,
                      width: double.infinity,
                      radius: 12,
                    )
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 17),
                    child: skeletonBox(
                      height:130,
                      width: double.infinity,
                      radius: 12,
                    )
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36,vertical: 17),
                    child: skeletonBox(
                      height:140,
                      width: double.infinity,
                      radius: 12,
                    )
                ),
              ],
            ),
          ),
     ),
      );


  }
}
class skeleton2 extends StatelessWidget{
  const skeleton2({super.key});
  Widget skeletonBox({
    double? height,
    double?width,
    double radius=10,
  }){
    return Shimmer.fromColors(

      baseColor: Colors.grey.shade200,
      highlightColor:Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 17),
              child: skeletonBox(
                height:130,
                width: double.infinity,
                radius: 12,
              )
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 17),
              child: skeletonBox(
                height:100,
                width: double.infinity,
                radius: 12,
              )
          ),

        ],
      ),
    );

  }
}