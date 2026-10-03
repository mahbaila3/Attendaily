import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {

// ===============================================================
// DATE
// ===============================================================

  DateTime selectedDate = DateTime.now();

// ===============================================================
// FIREBASE DATA
// ===============================================================

  Future<Map<String, dynamic>> getReportData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {
        "totalPresent": 0,
        "totalAbsent": 0,
        "batches": [],
      };
    }

    final dateKey =
        "${selectedDate.year.toString().padLeft(4, "0")}-"
        "${selectedDate.month.toString().padLeft(2, "0")}-"
        "${selectedDate.day.toString().padLeft(2, "0")}";

    final batchSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("batches")
        .get();

    int totalPresent = 0;
    int totalAbsent = 0;

    List<Map<String, dynamic>> batchHistory = [];

    for (final batchDoc in batchSnapshot.docs) {
      final batchData = batchDoc.data();

// ===========================================================
// EMPLOYEES
// ===========================================================

      final employeesSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("batches")
          .doc(batchDoc.id)
          .collection("employees")
          .get();

// ===========================================================
// ATTENDANCE
// ===========================================================

      final attendanceDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("batches")
          .doc(batchDoc.id)
          .collection("attendance")
          .doc(dateKey)
          .get();

// Agar is batch ki attendance hi nahi hai
// to report mein batch show nahi hoga.
      if (!attendanceDoc.exists) {
        continue;
      }

      final attendanceData =
          attendanceDoc.data() ?? <String, dynamic>{};

      int present = 0;
      int absent = 0;

      List<Map<String, dynamic>> presentEmployees = [];
      List<Map<String, dynamic>> absentEmployees = [];

// ===========================================================
// CHECK EVERY EMPLOYEE
// ===========================================================

      for (final employeeDoc in employeesSnapshot.docs) {
        final employeeData = employeeDoc.data();

        final employeeId = employeeDoc.id;

        final employeeName =
            employeeData["name"]?.toString() ?? "Unknown";

        final employeeID =
            employeeData["urID"]?.toString().trim() ?? "";

        final displayID =
        employeeID.isEmpty ? "NO ID" : employeeID;

        final status = attendanceData[employeeId];

// PRESENT
        if (status == "Present") {
          present++;

          presentEmployees.add({
            "id": displayID,
            "name": employeeName,
          });
        }

// ABSENT
        else if (status == "Absent") {
          absent++;

          absentEmployees.add({
            "id": displayID,
            "name": employeeName,
          });
        }
      }

      final total = present + absent;

      if (total == 0) {
        continue;
      }

      final percentage =
          (present / total) * 100;

      totalPresent += present;
      totalAbsent += absent;

      batchHistory.add({

        "batchId": batchDoc.id,

        "batchName":
        batchData["batchName"] ?? "Unknown Batch",

        "present": present,

        "absent": absent,

        "total": total,

        "percentage": percentage,

        "presentEmployees":
        presentEmployees,

        "absentEmployees":
        absentEmployees,
      });
    }

    return {

      "totalPresent":
      totalPresent,

      "totalAbsent":
      totalAbsent,

      "batches":
      batchHistory,
    };
  }

// ===============================================================
// DATE KEY
// ===============================================================

  String getDateKey() {
    return
      "${selectedDate.year.toString().padLeft(4, "0")}-"
          "${selectedDate.month.toString().padLeft(2, "0")}-"
          "${selectedDate.day.toString().padLeft(2, "0")}";
  }

// ===============================================================
// DATE FORMAT
// ===============================================================

  String getFormattedDate() {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return
      "${selectedDate.day} "
          "${months[selectedDate.month - 1]} "
          "${selectedDate.year}";
  }

// ===============================================================
// DATE PICKER
// ===============================================================

  Future<void> pickDate() async {
    final DateTime? pickedDate =
    await showDatePicker(

      context: context,

      initialDate: selectedDate,

      firstDate: DateTime(2020),

      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

// ===============================================================
// PDF
// ===============================================================

  Future<void> downloadReport() async {
    final data = await getReportData();

    final int totalPresent =
        data["totalPresent"] ?? 0;

    final int totalAbsent =
        data["totalAbsent"] ?? 0;

    final int totalAttendance =
        totalPresent + totalAbsent;

    final double attendancePercentage =
    totalAttendance == 0
        ? 0
        : (totalPresent / totalAttendance) * 100;

    final List listBatches =
        data["batches"] ?? [];

    final pdf = pw.Document();

    pdf.addPage(

      pw.MultiPage(

        build: (context) {
          return [

// ===================================================
// TITLE
// ===================================================

            pw.Center(
              child: pw.Text(
                "Attendaily Attendance Report",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Center(
              child: pw.Text(
                "Date: ${getDateKey()}",
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(
                  fontSize: 12,
                ),
              ),
            ),

            pw.SizedBox(height: 25),

// ===================================================
// SUMMARY
// ===================================================

            pw.Text(
              "Total Employees: $totalAttendance",
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Text(
              "Present: $totalPresent",
            ),

            pw.Text(
              "Absent: $totalAbsent",
            ),

            pw.Text(
              "Attendance: "
                  "${attendancePercentage.toStringAsFixed(0)}%",
            ),

            pw.SizedBox(height: 25),

// ===================================================
// BATCH DETAILS
// ===================================================

            pw.Text(
              "Batch Details",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            if (listBatches.isEmpty)

              pw.Text(
                "No attendance records found.",
              )

            else
              pw.Table.fromTextArray(

                headers: [
                  "Batch",
                  "Total",
                  "Present",
                  "Absent",
                  "%",
                ],

                data: listBatches
                    .map(
                      (batch) =>
                  [

                    batch["batchName"]
                        ?.toString() ??
                        "Unknown",

                    batch["total"]
                        .toString(),

                    batch["present"]
                        .toString(),

                    batch["absent"]
                        .toString(),

                    "${(batch["percentage"] ?? 0).toStringAsFixed(0)}%",
                  ],
                )
                    .toList(),
              ),

            pw.SizedBox(height: 30),

// ===================================================
// EMPLOYEES
// ===================================================

            ...listBatches.expand(
                  (batch) {
                final List<
                    Map<String, dynamic>>
                presentEmployees =
                List<
                    Map<String, dynamic>
                >.from(
                  batch["presentEmployees"] ??
                      [],
                );

                final List<
                    Map<String, dynamic>>
                absentEmployees =
                List<
                    Map<String, dynamic>
                >.from(
                  batch["absentEmployees"] ??
                      [],
                );

                return [

                  pw.Center(
                    child: pw.Text(
                      "Batch: "
                          "${batch["batchName"] ?? "Unknown"}",

                      textAlign:
                      pw.TextAlign.center,

                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight:
                        pw.FontWeight.bold,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 13),

// PRESENT

                  pw.Text(
                    "Present Employees",
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight:
                      pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 5),

                  if (presentEmployees.isEmpty)

                    pw.Text(
                      "No present employees",
                    )

                  else
                    pw.Table.fromTextArray(

                      headers: [
                        "Name",
                        "Employee ID",
                      ],

                      data:
                      presentEmployees
                          .map(
                            (employee) =>
                        [

                          employee["name"]
                              ?.toString() ??
                              "",

                          employee["id"]
                              ?.toString()
                              .isNotEmpty ==
                              true
                              ? employee["id"]
                              .toString()
                              : "NO ID",
                        ],
                      )
                          .toList(),
                    ),

                  pw.SizedBox(height: 15),

// ABSENT

                  pw.Text(
                    "Absent Employees",
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight:
                      pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 5),

                  if (absentEmployees.isEmpty)

                    pw.Text(
                      "No absent employees",
                    )

                  else
                    pw.Table.fromTextArray(

                      headers: [
                        "Name",
                        "Employee ID",
                      ],

                      data:
                      absentEmployees
                          .map(
                            (employee) =>
                        [

                          employee["name"]
                              ?.toString() ??
                              "",

                          employee["id"]
                              ?.toString()
                              .isNotEmpty ==
                              true
                              ? employee["id"]
                              .toString()
                              : "NO ID",
                        ],
                      )
                          .toList(),
                    ),

                  pw.SizedBox(height: 30),
                ];
              },
            ),
          ];
        },
      ),
    );

// ===========================================================
// SAVE PDF
// ===========================================================

    final bytes = await pdf.save();

    //print("PDF CREATED: ${bytes.length} bytes");

    try {
      final result = await FileSaver.instance.saveFile(
        name: "attendance_report_${getDateKey()}",
        bytes: bytes,
        fileExtension: "pdf",
        mimeType: MimeType.pdf,
      );

     // print("PDF SAVED: $result");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "PDF saved successfully",
            ),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: "VIEW",
              onPressed: () async {
                if (result != null && result
                    .toString()
                    .isNotEmpty) {
                  await OpenFilex.open(result.toString());
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print("PDF SAVE ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "PDF error: $e",
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }}}




      @override
      Widget build(BuildContext context) {
        final screenWidth =
            MediaQuery
                .of(context)
                .size
                .width;

        final bool isMobile =
            screenWidth < 700;

        return Scaffold(

          backgroundColor:
          const Color(0xffF5F7FB),

          appBar: AppBar(

            backgroundColor:
            const Color(0xff263b84),

            elevation: 0,

            foregroundColor:
            Colors.white,

            title: const Text(
              "Daily Report",
              style: TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          body: FutureBuilder<Map<String, dynamic>>(

            future: getReportData(),

            builder: (context, snapshot) {
// =======================================================
// LOADING
// =======================================================

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const ReportLoad();
              }

// =======================================================
// ERROR
// =======================================================

              if (snapshot.hasError) {
                return Center(

                  child: Padding(
                    padding:
                    const EdgeInsets.all(20),

                    child: Text(
                      "Something went wrong:\n"
                          "${snapshot.error}",

                      textAlign:
                      TextAlign.center,
                    ),
                  ),
                );
              }

              final data =
                  snapshot.data ??
                      {
                        "totalPresent": 0,
                        "totalAbsent": 0,
                        "batches": [],
                      };

// =======================================================
// SUMMARY VALUES
// =======================================================

              final int totalPresent =
                  data["totalPresent"] ?? 0;

              final int totalAbsent =
                  data["totalAbsent"] ?? 0;

              final int totalEmployees =
                  totalPresent + totalAbsent;

              final double attendancePercentage =
              totalEmployees == 0
                  ? 0
                  : (totalPresent /
                  totalEmployees) *
                  100;

              final double progress =
                  attendancePercentage / 100;

              final List batches =
                  data["batches"] ?? [];

// =======================================================
// EMPLOYEE STATUS LIST
// =======================================================

              final List<
                  Map<String, dynamic>>
              employeeStatus = [];

              for (final batch in batches) {
                final String batchName =
                    batch["batchName"]
                        ?.toString() ??
                        "Unknown Batch";

                final List<
                    Map<String, dynamic>>
                presentEmployees =
                List<
                    Map<String, dynamic>
                >.from(
                  batch["presentEmployees"] ??
                      [],
                );

                final List<
                    Map<String, dynamic>>
                absentEmployees =
                List<
                    Map<String, dynamic>
                >.from(
                  batch["absentEmployees"] ??
                      [],
                );

// PRESENT

                for (final employee
                in presentEmployees) {
                  employeeStatus.add({

                    "name":
                    employee["name"]
                        ?.toString() ??
                        "Unknown",

                    "id":
                    employee["id"]
                        ?.toString() ??
                        "NO ID",

                    "batch":
                    batchName,

                    "status":
                    "Present",

                    "isPresent":
                    true,
                  });
                }

// ABSENT

                for (final employee
                in absentEmployees) {
                  employeeStatus.add({

                    "name":
                    employee["name"]
                        ?.toString() ??
                        "Unknown",

                    "id":
                    employee["id"]
                        ?.toString() ??
                        "NO ID",

                    "batch":
                    batchName,

                    "status":
                    "Absent",

                    "isPresent":
                    false,
                  });
                }
              }

// =======================================================
// UI
// =======================================================

              return CustomScrollView(

                slivers: [

// ===================================================
// HEADER
// ===================================================

                  SliverToBoxAdapter(

                    child: Padding(

                      padding:
                      EdgeInsets.fromLTRB(
                        isMobile ? 15 : 30,
                        25,
                        isMobile ? 15 : 30,
                        10,
                      ),

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          const Text(
                            "Today's Report",

                            style: TextStyle(
                              fontSize: 26,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              Color(0xff20242C),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Daily attendance overview",

                            style: TextStyle(
                              fontSize: 14,
                              color:
                              Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 18),

// DATE CARD

                          Container(

                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),

                            decoration:
                            BoxDecoration(

                              color:
                              Colors.white,

                              borderRadius:
                              BorderRadius.circular(
                                14,
                              ),

                              boxShadow: [

                                BoxShadow(
                                  color:
                                  Colors.black
                                      .withOpacity(
                                    0.05,
                                  ),
                                  blurRadius: 10,
                                  offset:
                                  const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),

                            child: Row(

                              children: [

                                Container(

                                  height: 42,
                                  width: 42,

                                  decoration:
                                  BoxDecoration(

                                    color:
                                    const Color(
                                      0xff263b84,
                                    ).withOpacity(
                                      0.1,
                                    ),

                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      10,
                                    ),
                                  ),

                                  child:
                                  const Icon(
                                    Icons
                                        .calendar_today_rounded,
                                    color:
                                    Color(
                                      0xff263b84,
                                    ),
                                    size: 21,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(

                                  child:
                                  Column(

                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                    children: [

                                      const Text(
                                        "Report Date",

                                        style:
                                        TextStyle(
                                          fontSize: 12,
                                          color:
                                          Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 3),

                                      Text(
                                        getFormattedDate(),

                                        style:
                                        const TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight
                                              .w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(

                                  onPressed:
                                  pickDate,

                                  icon:
                                  const Icon(
                                    Icons
                                        .keyboard_arrow_down_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

// ===================================================
// SUMMARY CARDS
// ===================================================

                  SliverToBoxAdapter(

                    child: Padding(

                      padding:
                      EdgeInsets.symmetric(
                        horizontal:
                        isMobile ? 15 : 30,
                        vertical: 10,
                      ),

                      child:
                      LayoutBuilder(

                        builder:
                            (context,
                            constraints) {
                          final double
                          cardWidth =
                          isMobile
                              ? (constraints
                              .maxWidth -
                              12) /
                              2
                              : (constraints
                              .maxWidth -
                              36) /
                              4;

                          return Wrap(

                            spacing: 12,
                            runSpacing: 12,

                            children: [

                              _summaryCard(
                                width:
                                cardWidth,
                                title:
                                "Total Employees",
                                value:
                                totalEmployees
                                    .toString(),
                                icon:
                                Icons
                                    .people_alt_rounded,
                              ),

                              _summaryCard(
                                width:
                                cardWidth,
                                title:
                                "Present",
                                value:
                                totalPresent
                                    .toString(),
                                icon:
                                Icons
                                    .check_circle_rounded,
                              ),

                              _summaryCard(
                                width:
                                cardWidth,
                                title:
                                "Absent",
                                value:
                                totalAbsent
                                    .toString(),
                                icon:
                                Icons
                                    .cancel_rounded,
                              ),

                              _summaryCard(
                                width:
                                cardWidth,
                                title:
                                "Attendance",
                                value:
                                "${attendancePercentage.toStringAsFixed(0)}%",
                                icon:
                                Icons
                                    .analytics_rounded,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

// ===================================================
// ATTENDANCE OVERVIEW
// ===================================================

                  SliverToBoxAdapter(

                    child: Padding(

                      padding:
                      EdgeInsets.fromLTRB(
                        isMobile ? 15 : 30,
                        20,
                        isMobile ? 15 : 30,
                        10,
                      ),

                      child: Container(

                        padding:
                        const EdgeInsets.all(
                          20,
                        ),

                        decoration:
                        BoxDecoration(

                          color:
                          Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),

                          boxShadow: [

                            BoxShadow(
                              color:
                              Colors.black
                                  .withOpacity(
                                0.04,
                              ),
                              blurRadius: 12,
                              offset:
                              const Offset(
                                0,
                                4,
                              ),
                            ),
                          ],
                        ),

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            const Text(
                              "Attendance Overview",

                              style:
                              TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

// MOBILE
                            if (isMobile)

                              Column(

                                children: [

                                  _progressCircle(
                                    progress:
                                    progress,
                                    percentage:
                                    attendancePercentage,
                                  ),

                                  const SizedBox(
                                    height: 25,
                                  ),

                                  _overviewStats(
                                    totalPresent:
                                    totalPresent,
                                    totalAbsent:
                                    totalAbsent,
                                    totalEmployees:
                                    totalEmployees,
                                  ),
                                ],
                              )

// DESKTOP / TABLET
                            else
                              Row(

                                children: [

                                  _progressCircle(
                                    progress:
                                    progress,
                                    percentage:
                                    attendancePercentage,
                                  ),

                                  const SizedBox(
                                    width: 30,
                                  ),

                                  Expanded(

                                    child:
                                    _overviewStats(
                                      totalPresent:
                                      totalPresent,
                                      totalAbsent:
                                      totalAbsent,
                                      totalEmployees:
                                      totalEmployees,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

// ===================================================
// BATCH REPORT TITLE
// ===================================================

                  SliverToBoxAdapter(

                    child: Padding(

                      padding:
                      EdgeInsets.fromLTRB(
                        isMobile ? 15 : 30,
                        20,
                        isMobile ? 15 : 30,
                        10,
                      ),

                      child: const Text(
                        "Batch Report",

                        style:
                        TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

// ===================================================
// BATCHES
// ===================================================

                  SliverToBoxAdapter(

                    child: Padding(

                      padding:
                      EdgeInsets.symmetric(
                        horizontal:
                        isMobile ? 15 : 30,
                      ),

                      child: batches.isEmpty

                          ? _emptyState(
                        text:
                        "No attendance records found for this date.",
                      )

                          : Column(

                        children: [

                          for (
                          int i = 0;
                          i < batches.length;
                          i++
                          )

                            Padding(

                              padding:
                              EdgeInsets.only(
                                bottom:
                                i ==
                                    batches.length -
                                        1
                                    ? 0
                                    : 12,
                              ),

                              child:
                              _batchCard(
                                batchName:
                                batches[i]
                                ["batchName"]
                                    ?.toString() ??
                                    "Unknown Batch",

                                total:
                                batches[i]
                                ["total"]
                                    .toString(),

                                present:
                                batches[i]
                                ["present"]
                                    .toString(),

                                absent:
                                batches[i]
                                ["absent"]
                                    .toString(),

                                percentage:
                                "${(batches[i]["percentage"] ?? 0)
                                    .toStringAsFixed(0)}%",
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

// ===================================================
// EMPLOYEE STATUS
// ===================================================

                  SliverToBoxAdapter(

                    child: Padding(

                      padding:
                      EdgeInsets.fromLTRB(
                        isMobile ? 15 : 30,
                        25,
                        isMobile ? 15 : 30,
                        10,
                      ),

                      child: const Text(
                        "Employee Status",

                        style:
                        TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

// ===================================================
// EMPLOYEE LIST
// ===================================================

                  SliverToBoxAdapter(

                    child: Padding(

                      padding:
                      EdgeInsets.symmetric(
                        horizontal:
                        isMobile ? 15 : 30,
                      ),

                      child: employeeStatus.isEmpty

                          ? _emptyState(
                        text:
                        "No employee attendance found.",
                      )

                          : Container(

                        decoration:
                        BoxDecoration(

                          color:
                          Colors.white,

                          borderRadius:
                          BorderRadius
                              .circular(
                            18,
                          ),

                          boxShadow: [

                            BoxShadow(
                              color:
                              Colors.black
                                  .withOpacity(
                                0.04,
                              ),
                              blurRadius:
                              10,
                            ),
                          ],
                        ),

                        child: Column(

                          children: [

                            for (
                            int i = 0;
                            i <
                                employeeStatus
                                    .length;
                            i++
                            )

                              _employeeRow(

                                name:
                                employeeStatus[
                                i]
                                ["name"]
                                    .toString(),

                                batch:
                                employeeStatus[
                                i]
                                ["batch"]
                                    .toString(),

                                employeeId:
                                employeeStatus[
                                i]
                                ["id"]
                                    .toString(),

                                status:
                                employeeStatus[
                                i]
                                ["status"]
                                    .toString(),

                                isPresent:
                                employeeStatus[
                                i]
                                ["isPresent"] ==
                                    true,

                                showDivider:
                                i !=
                                    employeeStatus
                                        .length -
                                        1,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

// ===================================================
// PDF BUTTON
// ===================================================

                  SliverToBoxAdapter(

                    child: Padding(

                      padding:
                      EdgeInsets.fromLTRB(
                        isMobile ? 15 : 30,
                        25,
                        isMobile ? 15 : 30,
                        35,
                      ),

                      child: SizedBox(

                        height: 55,
                        width:
                        double.infinity,

                        child:
                        ElevatedButton.icon(

                          onPressed:
                          batches.isEmpty
                              ? null
                              : downloadReport,

                          icon:
                          const Icon(
                            Icons
                                .picture_as_pdf_rounded,
                            color:
                            Colors.white,
                          ),

                          label:
                          const Text(
                            "Generate PDF Report",

                            style:
                            TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),

                          style:
                          ElevatedButton
                              .styleFrom(

                            backgroundColor:
                            const Color(
                              0xff263b84,
                            ),

                            foregroundColor:
                            Colors.white,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                14,
                              ),
                            ),

                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }


// ===============================================================
// PROGRESS CIRCLE
// ===============================================================

  Widget _progressCircle({
    required double progress,
    required double percentage,
  }) {
    return SizedBox(

      height: 125,
      width: 125,

      child: Stack(

        alignment:
        Alignment.center,

        children: [

          SizedBox(

            height: 125,
            width: 125,

            child:
            CircularProgressIndicator(

              value:
              progress,

              strokeWidth: 12,

              backgroundColor:
              Colors.grey.shade200,

              color:
              const Color(
                0xff263b84,
              ),
            ),
          ),

          Column(

            mainAxisAlignment:
            MainAxisAlignment
                .center,

            children: [

              Text(

                "${percentage.toStringAsFixed(0)}%",

                style:
                const TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(
                    0xff263b84,
                  ),
                ),
              ),

              const Text(
                "Present",

                style:
                TextStyle(
                  fontSize: 12,
                  color:
                  Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// ===============================================================
// OVERVIEW STATS
// ===============================================================

  Widget _overviewStats({
    required int totalPresent,
    required int totalAbsent,
    required int totalEmployees,
  }) {
    return Column(

      children: [

        _statusRow(
          title:
          "Present",
          value:
          totalPresent.toString(),
          icon:
          Icons.check_circle,
        ),

        const SizedBox(
          height: 15,
        ),

        _statusRow(
          title:
          "Absent",
          value:
          totalAbsent.toString(),
          icon:
          Icons.cancel,
        ),

        const SizedBox(
          height: 15,
        ),

        _statusRow(
          title:
          "Total",
          value:
          totalEmployees.toString(),
          icon:
          Icons.people,
        ),
      ],
    );
  }

// ===============================================================
// SUMMARY CARD
// ===============================================================

  Widget _summaryCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(

      width: width,

      child: Container(

        padding:
        const EdgeInsets.all(
          16,
        ),

        decoration:
        BoxDecoration(

          color:
          Colors.white,

          borderRadius:
          BorderRadius.circular(
            16,
          ),

          boxShadow: [

            BoxShadow(
              color:
              Colors.black
                  .withOpacity(
                0.04,
              ),
              blurRadius: 10,
              offset:
              const Offset(
                0,
                4,
              ),
            ),
          ],
        ),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [

            Icon(
              icon,
              color:
              const Color(
                0xff263b84,
              ),
              size: 27,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              value,

              style:
              const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              title,

              style:
              TextStyle(
                fontSize: 12,
                color:
                Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ===============================================================
// STATUS ROW
// ===============================================================

  Widget _statusRow({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(

      children: [

        Icon(
          icon,
          size: 22,
          color:
          const Color(
            0xff263b84,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(

          child: Text(
            title,

            style:
            const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w500,
            ),
          ),
        ),

        Text(
          value,

          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

// ===============================================================
// BATCH CARD
// ===============================================================

  Widget _batchCard({
    required String batchName,
    required String total,
    required String present,
    required String absent,
    required String percentage,
  }) {
    return Container(

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        boxShadow: [

          BoxShadow(
            color:
            Colors.black
                .withOpacity(
              0.04,
            ),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(

        children: [

          Row(

            children: [

              Container(

                height: 44,
                width: 44,

                decoration:
                BoxDecoration(

                  color:
                  const Color(
                    0xff263b84,
                  ).withOpacity(
                    0.1,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    11,
                  ),
                ),

                child:
                const Icon(
                  Icons.groups_rounded,
                  color:
                  Color(
                    0xff263b84,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(

                child: Text(
                  batchName,

                  style:
                  const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              Text(
                percentage,

                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(
                    0xff263b84,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Row(

            children: [

              Expanded(
                child:
                _batchStat(
                  title:
                  "Total",
                  value:
                  total,
                ),
              ),

              Expanded(
                child:
                _batchStat(
                  title:
                  "Present",
                  value:
                  present,
                ),
              ),

              Expanded(
                child:
                _batchStat(
                  title:
                  "Absent",
                  value:
                  absent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// ===============================================================
// BATCH STAT
// ===============================================================

  Widget _batchStat({
    required String title,
    required String value,
  }) {
    return Column(

      children: [

        Text(
          value,

          style:
          const TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          title,

          style:
          TextStyle(
            fontSize: 11,
            color:
            Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

// ===============================================================
// EMPLOYEE ROW
// ===============================================================

  Widget _employeeRow({
    required String name,
    required String batch,
    required String employeeId,
    required String status,
    required bool isPresent,
    required bool showDivider,
  }) {
    return Container(

      decoration:
      BoxDecoration(

        border: showDivider

            ? Border(
          bottom:
          BorderSide(
            color:
            Colors.grey.shade200,
          ),
        )

            : null,
      ),

      child: Padding(

        padding:
        const EdgeInsets
            .symmetric(
          horizontal: 16,
          vertical: 13,
        ),

        child: Row(

          children: [

            CircleAvatar(

              radius: 22,

              backgroundColor:
              const Color(
                0xff263b84,
              ).withOpacity(
                0.1,
              ),

              child:
              const Icon(
                Icons.person,
                color:
                Color(
                  0xff263b84,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Text(
                    name,

                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    "$batch • ID: $employeeId",

                    style:
                    TextStyle(
                      fontSize: 11,
                      color:
                      Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Container(

              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 10,
                vertical: 6,
              ),

              decoration:
              BoxDecoration(

                color: isPresent

                    ? Colors.green
                    .withOpacity(
                  0.1,
                )

                    : Colors.red
                    .withOpacity(
                  0.1,
                ),

                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),

              child: Text(
                status,

                style:
                TextStyle(
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w600,

                  color: isPresent
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ===============================================================
// EMPTY STATE
// ===============================================================

  Widget _emptyState({
    required String text,
  }) {
    return Container(

      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        30,
      ),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),

      child: Column(

        children: [

          Icon(
            Icons
                .event_busy_rounded,

            size: 45,

            color:
            Colors.grey.shade400,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            text,

            textAlign:
            TextAlign.center,

            style:
            TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }



class ReportLoad extends StatelessWidget {
  const ReportLoad({super.key});
Widget skeletonBox({
double? height,
double? width,
double radius = 10,
}) {
return  Shimmer.fromColors(
baseColor: Colors.grey.shade200,
highlightColor: Colors.grey.shade100,
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
   return  Skeletonizer(
enabled: true,
child: CustomScrollView(
slivers: [
SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.only(top: 50,left: 50,right: 50),
child: skeletonBox(
height:130,
width: double.infinity,
radius: 12,
),
),
),
SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
child: skeletonBox(
height: 200,
width: double.infinity,
radius: 12,
),
),
),

SliverList(
delegate: SliverChildBuilderDelegate(
(context, index) {

return Padding(
padding: const EdgeInsets.symmetric(
horizontal: 30,
vertical: 10,
),
child: Shimmer.fromColors(
baseColor: Colors.grey.shade200,
highlightColor: Colors.grey.shade100,
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 20,
vertical: 25,
),
width: double.infinity,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(8),
),
child: Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: [

Container(
height: 16,
width: 110,
color: Colors.white,
),

Container(
height: 16,
width: 40,
color: Colors.white,
),
],
),
),
),
);
},

childCount: 4,
),
),
],
)

);}
}