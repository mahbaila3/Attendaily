
import 'dart:math';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:attendaily/employeeDetails.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_saver/file_saver.dart';

import 'dart:typed_data';                                                                //delete krna hy
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget{

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {




  DateTime ? selectedDate;
  //colors
  Color white=Colors.white;
  Color grey=Colors.grey;



  Future<void> pickdate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ??  DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate !=null){
      setState(() {
        selectedDate=pickedDate;
      });
    }
  }
String getDateKey(){
    DateTime date=selectedDate??DateTime.now();
return "${date.year.toString().padLeft(4,"0")}-"
  "${date.month.toString().padLeft(2,"0")}-"
  "${date.day.toString().padLeft(2,"0")}";
  }

                                                                   //function

  Future<Map<String,dynamic>> getHistory()async{
    final user=FirebaseAuth.instance.currentUser;
    if(user==null){
      return{
        "totalPresent":0,
        "totalAbsent":0,
        "batches":[],
      };
    }
    final dateKey=getDateKey();
    final batchSnapshot=await FirebaseFirestore.instance
    .collection("users")
    .doc(user.uid)
    .collection("batches")
    .get();

    int totalPresent=0;
    int totalAbsent=0;

    List<Map<String,dynamic>>batchHistory=[];
    for(var batchDoc in batchSnapshot.docs){
      final batchData=batchDoc.data();
      final employeesSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("batches")
          .doc(batchDoc.id)
          .collection("employees")
          .get();
      final attendanceDoc=await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("batches")
      .doc(batchDoc.id)
      .collection("attendance")
      .doc(dateKey)
      .get();

      if(!attendanceDoc.exists){
        continue;
      }
      final attendanceData=attendanceDoc.data()??<String,dynamic>{};
      if(attendanceData==null){
        continue;
      }
    int present = 0;
    int absent = 0;

    List<Map<String, dynamic>> presentEmployees = [];
    List<Map<String, dynamic>> absentEmployees = [];

    for (final employeeDoc in employeesSnapshot.docs) {
    final employeeData = employeeDoc.data();

    final employeeId = employeeDoc.id;

    final employeeName =
    employeeData["name"]?.toString() ?? "Unknown";

    final employeeID =
        employeeData["urID"]?.toString().trim() ?? "";

    final displayID = employeeID.isEmpty
        ? "NO ID"
        : employeeID;

    final status = attendanceData[employeeId];

    if (status == "Present") {
    present++;

    presentEmployees.add({
    "id": displayID,
    "name": employeeName,
    });
    } else if (status == "Absent") {
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

    final percentage = (present / total) * 100;

    totalPresent += present;
    totalAbsent += absent;


    batchHistory.add({
        "batchId": batchDoc.id,
        "batchName": batchData["batchName"] ?? "Unknown Batch",
        "present": present,
        "absent": absent,
        "total": total,
        "percentage": percentage,
    "presentEmployees": presentEmployees,
    "absentEmployees": absentEmployees,
      });
    }
    return{
      "totalPresent":totalPresent,
      "totalAbsent":totalAbsent,
      "batches":batchHistory,
    };
  }
  Future<void> downloadReport() async {
    print("DOWNLOAD BUTTON CLICKED");

    final data = await getHistory();

    final int totalPresent = data["totalPresent"] ?? 0;
    final int totalAbsent = data["totalAbsent"] ?? 0;

    final int totalAttendance = totalPresent + totalAbsent;

    final double attendancePercentage = totalAttendance == 0
        ? 0
        : (totalPresent / totalAttendance) * 100;

    final List listBatches = data["batches"] ?? [];

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            // =========================
            // MAIN REPORT
            // =========================
                pw.Center(
                  child:
                  pw.Text(
                    textAlign: pw.TextAlign.center,
                    "Attendaily Attendance Report",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                ),

            pw.SizedBox(height:20),
                 pw.Center(
                   child:
                   pw.Text(
                     textAlign: pw.TextAlign.center,
                     "Date: ${getDateKey()}",
                     style: const pw.TextStyle(
                       fontSize: 12,
                     ),
                   ),

                 ),

            pw.SizedBox(height: 25),

            pw.Text("Total Employees: $totalAttendance",style: pw.TextStyle(fontSize: 15,fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Present: $totalPresent"),
            pw.Text("Absent: $totalAbsent"),



              pw.Text(
                textAlign: pw.TextAlign.center,
                "Attendance: ${attendancePercentage.toStringAsFixed(0)}%",
              ),



            pw.SizedBox(height: 25),

            // =========================
            // BATCH DETAILS
            // =========================

            pw.Text(
              "Batch Details",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              headers: [
                "Batch",
                "Total",
                "Present",
                "Absent",
                "%",
              ],
              data: listBatches.map((batch) {
                return [
                  batch["batchName"] ?? "Unknown",
                  batch["total"].toString(),
                  batch["present"].toString(),
                  batch["absent"].toString(),
                  "${batch["percentage"].toStringAsFixed(0)}%",
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 30),

            // =========================
            // EACH BATCH EMPLOYEES
            // =========================

            ...listBatches.expand((batch) {
              final List<Map<String, dynamic>> presentEmployees =
              List<Map<String, dynamic>>.from(
                batch["presentEmployees"] ?? [],
              );

              final List<Map<String, dynamic>> absentEmployees =
              List<Map<String, dynamic>>.from(
                batch["absentEmployees"] ?? [],
              );

              return [
                // BATCH NAME
                pw.Center(
                  child:
                  pw.Text(
                    textAlign: pw.TextAlign.center,
                    "Batch: ${batch["batchName"] ?? "Unknown"}",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                ),


                pw.SizedBox(height: 13),

                // PRESENT
                pw.Text(
                  "Present Employees",
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 5),

                if (presentEmployees.isEmpty)
                  pw.Text("No present employees")
                else
                  pw.Table.fromTextArray(
                    headers: [
                      "Name",
                      "Employee ID",
                    ],
                    data: presentEmployees.map((employee) {
                      return [
                        employee["name"]?.toString() ?? "",
                        employee["id"]?.toString().isNotEmpty == true
                            ? employee["id"].toString()
                            : "NO ID",

                      ];
                    }).toList(),
                  ),

                pw.SizedBox(height: 15),

                // ABSENT
                pw.Text(
                  "Absent Employees",
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 5),

                if (absentEmployees.isEmpty)
                  pw.Text("No absent employees")
                else
                  pw.Table.fromTextArray(
                    headers: [
                      "Name",
                      "Employee ID",
                    ],
                    data: absentEmployees.map((employee) {
                      return [
                        employee["name"]?.toString() ?? "",
                        employee["id"]?.toString().isNotEmpty == true
                            ? employee["id"].toString()
                            : "NO ID",
                      ];
                    }).toList(),
                  ),

                pw.SizedBox(height: 30),
              ];
            }),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    print("PDF CREATED: ${bytes.length} bytes");

    try {
      final result = await FileSaver.instance.saveFile(
        name: "attendance_report_${getDateKey()}",
        bytes: bytes,
        fileExtension: "pdf",
        mimeType: MimeType.pdf,
      );

      print("PDF SAVED: $result");

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
                if (result != null && result.toString().isNotEmpty) {
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
      }
    }
    // final bytes = await pdf.save();
    //
    //     await SharePlus.instance.share(
    //       ShareParams(
    //         files: [
    //           XFile.fromData(
    //             bytes,
    //             name: "attendance_report_${getDateKey()}.pdf",
    //             mimeType: "application/pdf",
    //           ),
    //         ],
    //         text: "Attendaily Attendance Report",
    //       ),
    //     );
  }

  //responsive circle


//responsive
Widget mobile(){
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xff263b84),
      iconTheme: const IconThemeData(
          color: Colors.white
      ),
      title: Text("History",style: TextStyle(color: Colors.white,fontSize: 23),),
    ),
    backgroundColor: Color(0xffF8FAFC),

    body: FutureBuilder<Map<String,dynamic>>(
        future: getHistory(),
        builder: (context, snapshot) {


          if(snapshot.connectionState==ConnectionState.waiting){
            return const HistorySkeleton();
          }
          if(snapshot.hasError){
            return const  Center(child: Text("Something went wrong",style: TextStyle(fontSize: 16),));
          }
          final data=snapshot.data??{};
          final int totalPresent=data["totalPresent"]??0;
          final int totalAbsent=data["totalAbsent"]??0;
          final listBatches=data["batches"]??[];
          final int totalAttendance=totalPresent+totalAbsent;
          final double attendancePercentage=totalAttendance==0?0:(totalPresent/totalAttendance)*100;




          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.only(left:50,right: 50,top:50,),
                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(onPressed: (){
                        pickdate();
                      },
                          style: ElevatedButton.styleFrom(

                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              )

                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate== null?
                                "Select A date":"${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                ,style: TextStyle(color: Colors.black87,fontSize: 18),),
                              Icon(Icons.keyboard_arrow_down_rounded,size: 25,color: Colors.black87)
                            ],
                          )),
                    )
                ),
              ),
              if(listBatches.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: attendancePercentage / 100,
                        ),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeOut,

                        builder: (context, value, child) {
                          return SizedBox(
                            height: 200,
                            width: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [

                                SizedBox(
                                  height: 150,
                                  width: 150,
                                  child: CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 13,
                                    backgroundColor: Colors.grey.shade300,
                                    color: Color(0xff263b84),
                                  ),
                                ),

                                Text(
                                  "${(value * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    ),
                  ),
                ),


              if(listBatches.isNotEmpty)
                SliverToBoxAdapter(
                  child:  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          Container(

                            height: 110,
                            width:100,
                            decoration: BoxDecoration(

                                borderRadius: BorderRadius.circular(13),
                                color: Colors.white,
                                boxShadow: [BoxShadow(
                                    offset: Offset(2, 2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    color: Colors.grey
                                )]

                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.check_circle,size: 27,color: Colors.green,),
                                  SizedBox(height: 2,),
                                  Text( "$totalPresent",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize:  25),),
                                  Text("Present",style: TextStyle(color:Colors.black,  fontSize:  15),)

                                ],
                              ),
                            ),


                          ),
                          Container(

                            height: 110,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                color: Colors.white,
                                boxShadow: [BoxShadow(
                                    offset: Offset(2, 2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    color: Colors.grey
                                )]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(9),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.cancel,size: 30,color: Colors.red,),
                                  SizedBox(
                                    height:2,
                                  ),
                                  Text( "$totalAbsent",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize:  25),),
                                  Text("Absent",style: TextStyle(color:Colors.black, fontWeight: FontWeight.w500, fontSize:  15),)


                                ],
                              ),
                            ),


                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if(listBatches.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(

                      top: 25,
                      bottom: 10,
                    ),

                    child:  Center(
                      child: Text(
                        selectedDate == null
                            ? "Today's Attendance"
                            :
                        "${selectedDate!.day}/"
                            "${selectedDate!.month}/"
                            "${selectedDate!.year}",

                        style: TextStyle(
                          color: Colors.grey,

                        ),
                      ),
                    ),

                  ),
                ),
              if (listBatches.isEmpty)

                SliverFillRemaining(
                  hasScrollBody: false,


                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Icon(
                          Icons.event_busy,
                          size: 50,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 10),

                        Text(
                          "No attendance records",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if(listBatches.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30,top: 25,bottom: 20),
                    child: Text("Batches",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700,fontSize: 19),),
                  ),
                ),

              SliverList(delegate: SliverChildBuilderDelegate(
                    (context,index){
                  final batch= listBatches[index];
                  final String batchName=batch["batchName"];

                  final double percentage=batch["percentage"];

                  return  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30,vertical:10),
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => batchH(
                          batchName: batch["batchName"],
                          selectedDate: selectedDate ?? DateTime.now(),
                          present: batch["present"] ?? 0,
                          absent: batch["absent"] ?? 0,
                          presentEmployees:
                          List<Map<String, dynamic>>.from(
                            batch["presentEmployees"] ?? [],
                          ),
                          absentEmployees:
                          List<Map<String, dynamic>>.from(
                            batch["absentEmployees"] ?? [],
                          ),

                        ),));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:  Colors.white,

                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(batchName,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
                            Text("${percentage.toStringAsFixed(0)}%",style: TextStyle(color: Colors.grey,fontSize: 15),)
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: listBatches.length,


              )),

              //download section
              if(listBatches.isNotEmpty)
                SliverToBoxAdapter(
                  child:
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                        child: TextButton.icon(
                          onPressed: listBatches.isEmpty
                              ? null
                              : downloadReport,
                          icon: const Icon(Icons.download),
                          label: const Text("Download Report"),
                        ),

                    ),
                  ),
                )
            ],
          );
        }
    ),

  );

}
  Widget tablet(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff263b84),
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
        title: Text("History",style: TextStyle(color: Colors.white,fontSize: 23,fontWeight: FontWeight.w600),),
      ),
      backgroundColor: Color(0xffF8FAFC),

      body: FutureBuilder<Map<String,dynamic>>(
          future: getHistory(),
          builder: (context, snapshot) {


            if(snapshot.connectionState==ConnectionState.waiting){
              return const HistorySkeleton();
            }
            if(snapshot.hasError){
              return const  Center(child: Text("Something went wrong",style: TextStyle(fontSize: 16),));
            }
            final data=snapshot.data??{};
            final int totalPresent=data["totalPresent"]??0;
            final int totalAbsent=data["totalAbsent"]??0;
            final listBatches=data["batches"]??[];
            final int totalAttendance=totalPresent+totalAbsent;
            final double attendancePercentage=totalAttendance==0?0:(totalPresent/totalAttendance)*100;




            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.only(left:230,right: 230,top:50,),
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: ElevatedButton(onPressed: (){
                          pickdate();
                        },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                )

                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate== null?
                                  "Select A date":"${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                  ,style: TextStyle(color: Colors.black87,fontSize:  18),),
                                Icon(Icons.keyboard_arrow_down_sharp,size: 25,color: Colors.black,)
                              ],
                            )),
                      )
                  ),
                ),
                if(listBatches.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: attendancePercentage / 100,
                          ),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeOut,

                          builder: (context, value, child) {
                            return SizedBox(
                              height: 300,
                              width: 300,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [

                                  SizedBox(
                                    height: 250,
                                    width: 250,
                                    child: CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 20,
                                      backgroundColor: Colors.grey.shade300,
                                      color: Color(0xff263b84),
                                    ),
                                  ),

                                  Text(
                                    "${(value * 100).toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      ),
                    ),
                  ),


                if(listBatches.isNotEmpty)
                  SliverToBoxAdapter(
                    child:  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            Container(

                              height: 180,
                              width:160,
                              decoration: BoxDecoration(

                                  borderRadius: BorderRadius.circular(13),
                                  color: Colors.white,
                                  boxShadow: [BoxShadow(
                                      offset: Offset(2, 2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      color: Colors.grey
                                  )]

                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.check_circle,size: 40,color: Colors.green,),
                                    SizedBox(height: 2,),
                                    Text( "$totalPresent",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize:  28),),
                                    Text("Present",style: TextStyle(color:Colors.black,  fontSize:  21),)

                                  ],
                                ),
                              ),


                            ),
                            Container(

                              height: 180,
                              width: 160,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  color: Colors.white,
                                  boxShadow: [BoxShadow(
                                      offset: Offset(2, 2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      color: Colors.grey
                                  )]
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(9),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.cancel,size: 40,color: Colors.red,),
                                    SizedBox(
                                      height:2,
                                    ),
                                    Text( "$totalAbsent",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize:  28),),
                                    Text("Absent",style: TextStyle(color:Colors.black, fontWeight: FontWeight.w500, fontSize:  21),)


                                  ],
                                ),
                              ),


                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if(listBatches.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(

                        top: 25,
                        bottom: 10,
                      ),

                      child:  Center(
                        child: Text(
                          selectedDate == null
                              ? "Today's Attendance"
                              :
                          "${selectedDate!.day}/"
                              "${selectedDate!.month}/"
                              "${selectedDate!.year}",

                          style: TextStyle(
                            color: Colors.grey,

                          ),
                        ),
                      ),

                    ),
                  ),
                if (listBatches.isEmpty)

                  SliverFillRemaining(
                    hasScrollBody: false,


                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Icon(
                            Icons.event_busy,
                            size: 50,
                            color: Colors.grey,
                          ),

                          SizedBox(height: 10),

                          Text(
                            "No attendance records",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if(listBatches.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 50,top: 25,bottom: 20),
                      child: Text("Batches",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700,fontSize: 25),),
                    ),
                  ),

                SliverList(delegate: SliverChildBuilderDelegate(
                      (context,index){
                    final batch= listBatches[index];
                    final String batchName=batch["batchName"];

                    final double percentage=batch["percentage"];

                    return  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30,vertical:10),
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => batchH(
                            batchName: batch["batchName"],
                            selectedDate: selectedDate ?? DateTime.now(),
                            present: batch["present"] ?? 0,
                            absent: batch["absent"] ?? 0,
                            presentEmployees:
                            List<Map<String, dynamic>>.from(
                              batch["presentEmployees"] ?? [],
                            ),
                            absentEmployees:
                            List<Map<String, dynamic>>.from(
                              batch["absentEmployees"] ?? [],
                            ),

                          ),));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 100,vertical: 25),
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:  Colors.white,

                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(batchName,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),),
                              Text("${percentage.toStringAsFixed(0)}%",style: TextStyle(color: Colors.grey,fontSize: 23),)
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: listBatches.length,


                )),

                //download section
                if(listBatches.isNotEmpty)
                  SliverToBoxAdapter(
                    child:
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Center(
                          child: TextButton.icon(
                            onPressed: listBatches.isEmpty
                                ? null
                                : downloadReport,
                            icon: const Icon(Icons.download),
                            label: const Text("Download Report"),
                          )

                      ),
                    ),
                  )
              ],
            );
          }
      ),

    );

  }
  Widget desktop(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff263b84),
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
        title: Text("History",style: TextStyle(color: Colors.white,fontSize: 23),),
      ),
      backgroundColor: Color(0xffF8FAFC),

      body: FutureBuilder<Map<String,dynamic>>(
          future: getHistory(),
          builder: (context, snapshot) {


            if(snapshot.connectionState==ConnectionState.waiting){
              return const HistorySkeleton();
            }
            if(snapshot.hasError){
              return const  Center(child: Text("Something went wrong",style: TextStyle(fontSize: 16),));
            }
            final data=snapshot.data??{};
            final int totalPresent=data["totalPresent"]??0;
            final int totalAbsent=data["totalAbsent"]??0;
            final listBatches=data["batches"]??[];
            final int totalAttendance=totalPresent+totalAbsent;
            final double attendancePercentage=totalAttendance==0?0:(totalPresent/totalAttendance)*100;




            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= LEFT SIDE =================
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [

                        // Date Button
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              pickdate();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate == null
                                      ? "Select A date"
                                      : "${selectedDate!.day}/"
                                      "${selectedDate!.month}/"
                                      "${selectedDate!.year}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),

                                Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  size: 25,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Circular Progress
                        if (listBatches.isNotEmpty)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: attendancePercentage / 100,
                            ),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return SizedBox(
                                height: 240,
                                width: 240,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [

                                    SizedBox(
                                      height: 190,
                                      width: 190,
                                      child: CircularProgressIndicator(
                                        value: value,
                                        strokeWidth: 15,
                                        backgroundColor:
                                        Colors.grey.shade300,
                                        color: Color(0xff263b84),
                                      ),
                                    ),

                                    Text(
                                      "${(value * 100).toStringAsFixed(0)}%",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // ================= DIVIDER =================
                Container(
                  width: 1,
                  color: Colors.grey.shade300,
                ),

                // ================= RIGHT SIDE =================
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Present / Absent Cards
                        if (listBatches.isNotEmpty)
                          Row(

                            children: [

                              Expanded(
                                child: Container(
                                  height: 120,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(13),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(2, 2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        color: Colors.grey.shade300,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 30,
                                        color: Colors.green,
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        "$totalPresent",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),

                                      const Text(
                                        "Present",
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 250),

                              Expanded(
                                child: Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(13),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(2, 2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        color: Colors.grey.shade300,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.cancel,
                                        size: 30,
                                        color: Colors.red,
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        "$totalAbsent",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),

                                      const Text(
                                        "Absent",
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 35),

                        // Date Heading
                        if (listBatches.isNotEmpty)
                          Center(
                            child: Text(
                              selectedDate == null
                                  ? "Today's Attendance"
                                  : "${selectedDate!.day}/"
                                  "${selectedDate!.month}/"
                                  "${selectedDate!.year}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                          ),

                        const SizedBox(height: 25),

                        // Batches Heading
                        if (listBatches.isNotEmpty)
                          const Text(
                            "Batches",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),

                        const SizedBox(height: 15),

                        // Batches
                        if (listBatches.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: listBatches.length,
                            itemBuilder: (context, index) {

                              final batch = listBatches[index];

                              final String batchName =
                              batch["batchName"];

                              final double percentage =
                              batch["percentage"];

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: InkWell(
                                  onTap: () {

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => batchH(
                                          batchName:
                                          batch["batchName"],

                                          selectedDate:
                                          selectedDate ??
                                              DateTime.now(),

                                          present:
                                          batch["present"] ?? 0,

                                          absent:
                                          batch["absent"] ?? 0,

                                          presentEmployees:
                                          List<Map<String, dynamic>>.from(
                                            batch["presentEmployees"] ??
                                                [],
                                          ),

                                          absentEmployees:
                                          List<Map<String, dynamic>>.from(
                                            batch["absentEmployees"] ??
                                                [],
                                          ),
                                        ),
                                      ),
                                    );
                                  },

                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 22,
                                    ),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(1, 2),
                                          blurRadius: 5,
                                          color: Colors.grey.shade200,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [

                                        Text(
                                          batchName,
                                          style: const TextStyle(
                                            fontWeight:
                                            FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),

                                        Text(
                                          "${percentage.toStringAsFixed(0)}%",
                                          style: TextStyle(
                                            color:
                                            Colors.grey.shade600,
                                            fontSize: 15,
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        // No records
                        if (listBatches.isEmpty)
                          SizedBox(
                            height: 300,
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: const [

                                  Icon(
                                    Icons.event_busy,
                                    size: 50,
                                    color: Colors.grey,
                                  ),

                                  SizedBox(height: 10),

                                  Text(
                                    "No attendance records",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Download
                        if (listBatches.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                            ),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: downloadReport,
                                icon: const Icon(Icons.download),
                                label: const Text(
                                  "Download Report",
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
      ),

    );

  }
  @override


  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    if (width < 600) {
      return mobile();
    }
    else if (width < 1050) {
      return tablet();
    }
    else {
      return desktop();
    }
  }
}

//history batch
class batchH extends StatelessWidget{
  final String batchName;
  final DateTime selectedDate;

  final int present;
  final int absent;

  final List<Map<String, dynamic>> presentEmployees;
  final List<Map<String, dynamic>> absentEmployees;

  const batchH({
    super.key,
    required this.batchName,
    required this.selectedDate,
    required this.present,
    required this.absent,
    required this.presentEmployees,
    required this.absentEmployees,
  });
  double get percentage {
    final total = present + absent;
    return total == 0 ? 0.0 : (present / total) * 100;
  }

  double get progress {
    return percentage / 100;
  }


  Widget mobile(){
    return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xff263b84),
      iconTheme: const IconThemeData(
          color: Colors.white
      ),
      title: Text("Batch: ${batchName}",style: TextStyle(fontSize: 23,color: Colors.white),),),
    body:SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Summary",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),

            Padding(
              padding: const EdgeInsets.only(top:9,left: 10),
              child: Text(
                "${selectedDate.day.toString().padLeft(2, '0')}/"
                    "${selectedDate.month.toString().padLeft(2, '0')}/"
                    "${selectedDate.year}",

                style: TextStyle(color: Colors.grey.shade400),),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25,horizontal:5),
              child: Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        Container(

                          height: 110,
                          width:100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [BoxShadow(
                                offset: Offset(2, 2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                color: Colors.grey,
                              )]

                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.check_circle,size: 27,color: Colors.green,),
                                SizedBox(height: 2,),
                                Text( "$present",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize:  25),),


                              ],
                            ),
                          ),


                        ),
                        Container(

                          height: 110,
                          width: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: Colors.white,
                              boxShadow: [BoxShadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  color: Colors.grey
                              )]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(9),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.cancel,size: 30,color: Colors.red,),
                                SizedBox(
                                  height:2,
                                ),
                                Text( "$absent",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize:  25),),


                              ],
                            ),
                          ),


                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Present",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w900),),

                          Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: Text("Absent",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w900),),
                          )

                        ],),
                    )
                  ],


                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Attendance",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),),
                Spacer(),
                Text("${percentage.toStringAsFixed(0)}%",
                  style: TextStyle(color: Colors.grey,fontSize: 17),)
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30,bottom: 30),
              child: Text("Present",style: TextStyle(fontWeight: FontWeight.w600,fontSize:19),),),
            if (presentEmployees.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Text(
                  "No present employees",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

            // PRESENT EMPLOYEES
            ...presentEmployees.map(
                  (employee) {
                return Container(
                  margin:
                  EdgeInsets.symmetric(vertical: 1),

                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),

                  child: Row(
                    children: [

                      Text(
                        employee["name"],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),

                      Spacer(),

                      Text(
                        employee["id"]?.toString().isNotEmpty == true
                            ? employee["id"].toString()
                            : "NO ID",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ABSENT
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 30,
              ),

              child: Text(
                "Absent",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                ),
              ),
            ),

            if (absentEmployees.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Text(
                  "No absent employees",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

            // ABSENT EMPLOYEES
            ...absentEmployees.map(
                  (employee) {
                return Container(
                  margin:
                  EdgeInsets.symmetric(vertical: 1),

                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),

                  child: Row(
                    children: [

                      Text(
                        employee["name"],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),

                      Spacer(),

                      Text(
                        employee["id"]?.toString().isNotEmpty == true
                            ? employee["id"].toString()
                            : "NO ID",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),


            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    ),);
  }
   Widget tablet(){

   return Scaffold(
       appBar: AppBar(
         backgroundColor: Color(0xff263b84),
         iconTheme: const IconThemeData(
             color: Colors.white
         ),
         title: Text("Batch: ${batchName}",style: TextStyle(fontSize: 23,color: Colors.white),),),
     body: SingleChildScrollView(
       child: Center(
         child: ConstrainedBox(
           constraints: const BoxConstraints(
             maxWidth: 900,
           ),
           child: Padding(
             padding: const EdgeInsets.symmetric(
               horizontal: 25,
               vertical: 30,
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [

                 // ================= HEADER =================

                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [

                     const Text(
                       "Summary",
                       style: TextStyle(
                         fontSize: 25,
                         fontWeight: FontWeight.w700,
                       ),
                     ),

                     Text(
                       "${selectedDate.day.toString().padLeft(2, '0')}/"
                           "${selectedDate.month.toString().padLeft(2, '0')}/"
                           "${selectedDate.year}",
                       style: TextStyle(
                         color: Colors.grey.shade500,
                         fontSize: 15,
                       ),
                     ),
                   ],
                 ),

                 const SizedBox(height: 25),

                 // ================= TOP CARDS =================

                 Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [

                     // ================= SUMMARY =================

                     Expanded(
                       child: Container(
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(16),
                           boxShadow: [
                             BoxShadow(
                               offset: const Offset(2, 3),
                               blurRadius: 10,
                               spreadRadius: 1,
                               color: Colors.grey.withOpacity(0.15),
                             ),
                           ],
                         ),
                         child: Column(
                           crossAxisAlignment:
                           CrossAxisAlignment.start,
                           children: [



                             const SizedBox(height: 20),

                             Row(
                               mainAxisAlignment:
                               MainAxisAlignment.spaceEvenly,
                               children: [

                                 // PRESENT

                                 Column(
                                   children: [

                                     Container(
                                       height: 85,
                                       width: 85,
                                       decoration: BoxDecoration(
                                         shape: BoxShape.circle,
                                         color: Colors.white,
                                         boxShadow: [
                                           BoxShadow(
                                             offset:
                                             const Offset(2, 2),
                                             blurRadius: 6,
                                             spreadRadius: 1,
                                             color: Colors.grey
                                                 .withOpacity(0.25),
                                           ),
                                         ],
                                       ),
                                       child: Column(
                                         mainAxisAlignment:
                                         MainAxisAlignment.center,
                                         children: [

                                           const Icon(
                                             Icons.check_circle,
                                             size: 25,
                                             color: Colors.green,
                                           ),

                                           const SizedBox(height: 3),

                                           Text(
                                             "$present",
                                             style:
                                             const TextStyle(
                                               fontSize: 22,
                                               fontWeight:
                                               FontWeight.bold,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),

                                     const SizedBox(height: 8),

                                     const Text(
                                       "Present",
                                       style: TextStyle(
                                         fontSize: 15,
                                         fontWeight: FontWeight.w700,
                                       ),
                                     ),
                                   ],
                                 ),

                                 // ABSENT

                                 Column(
                                   children: [

                                     Container(
                                       height: 85,
                                       width: 85,
                                       decoration: BoxDecoration(
                                         shape: BoxShape.circle,
                                         color: Colors.white,
                                         boxShadow: [
                                           BoxShadow(
                                             offset:
                                             const Offset(2, 2),
                                             blurRadius: 6,
                                             spreadRadius: 1,
                                             color: Colors.grey
                                                 .withOpacity(0.25),
                                           ),
                                         ],
                                       ),
                                       child: Column(
                                         mainAxisAlignment:
                                         MainAxisAlignment.center,
                                         children: [

                                           const Icon(
                                             Icons.cancel,
                                             size: 27,
                                             color: Colors.red,
                                           ),

                                           const SizedBox(height: 3),

                                           Text(
                                             "$absent",
                                             style:
                                             const TextStyle(
                                               fontSize: 22,
                                               fontWeight:
                                               FontWeight.bold,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),

                                     const SizedBox(height: 8),

                                     const Text(
                                       "Absent",
                                       style: TextStyle(
                                         fontSize: 15,
                                         fontWeight: FontWeight.w700,
                                       ),
                                     ),
                                   ],
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ),
                     ),

                     const SizedBox(width: 18),

                     // ================= ATTENDANCE =================

                     Expanded(
                       child: Container(
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(16),
                           boxShadow: [
                             BoxShadow(
                               offset: const Offset(2, 3),
                               blurRadius: 10,
                               spreadRadius: 1,
                               color: Colors.grey.withOpacity(0.15),
                             ),
                           ],
                         ),
                         child: Column(
                           crossAxisAlignment:
                           CrossAxisAlignment.start,
                           children: [

                             Row(
                               mainAxisAlignment:
                               MainAxisAlignment.spaceBetween,
                               children: [

                                 const Text(
                                   "Attendance",
                                   style: TextStyle(
                                     fontWeight: FontWeight.w700,
                                     fontSize: 19,
                                   ),
                                 ),

                                 Text(
                                   "${percentage.toStringAsFixed(0)}%",
                                   style: TextStyle(
                                     color: Colors.grey.shade600,
                                     fontSize: 16,
                                     fontWeight: FontWeight.w600,
                                   ),
                                 ),
                               ],
                             ),

                             const SizedBox(height: 25),

                             ClipRRect(
                               borderRadius:
                               BorderRadius.circular(10),
                               child: LinearProgressIndicator(
                                 value: progress,
                                 minHeight: 9,
                                 backgroundColor:
                                 Colors.grey.shade200,
                                 valueColor:
                                 const AlwaysStoppedAnimation(
                                   Colors.blue,
                                 ),
                               ),
                             ),

                             const SizedBox(height: 18),

                             Text(
                               "$present Present / $absent Absent",
                               style: TextStyle(
                                 color: Colors.grey.shade600,
                                 fontSize: 14,
                               ),
                             ),

                             const SizedBox(height: 8),


                           ],
                         ),
                       ),
                     ),
                   ],
                 ),

                 const SizedBox(height: 30),

                 // ================= EMPLOYEE LISTS =================

                 Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [

                     // ================= PRESENT =================

                     Expanded(
                       child: Container(
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(16),
                           boxShadow: [
                             BoxShadow(
                               offset: const Offset(2, 3),
                               blurRadius: 10,
                               spreadRadius: 1,
                               color: Colors.grey.withOpacity(0.15),
                             ),
                           ],
                         ),
                         child: Column(
                           crossAxisAlignment:
                           CrossAxisAlignment.start,
                           children: [

                             const Text(
                               "Present Employees",
                               style: TextStyle(
                                 fontWeight: FontWeight.w700,
                                 fontSize: 19,
                               ),
                             ),

                             const SizedBox(height: 18),

                             if (presentEmployees.isEmpty)
                               const Padding(
                                 padding: EdgeInsets.symmetric(
                                   vertical: 12,
                                 ),
                                 child: Text(
                                   "No present employees",
                                   style: TextStyle(
                                     color: Colors.grey,
                                   ),
                                 ),
                               ),

                             ...presentEmployees.map(
                                   (employee) {

                                 return Container(
                                   margin:
                                   const EdgeInsets.symmetric(
                                     vertical: 3,
                                   ),
                                   padding:
                                   const EdgeInsets.symmetric(
                                     horizontal: 12,
                                     vertical: 12,
                                   ),
                                   decoration: BoxDecoration(
                                     color: Colors.grey.shade50,
                                     borderRadius:
                                     BorderRadius.circular(9),
                                   ),
                                   child: Row(
                                     children: [

                                       Container(
                                         height: 34,
                                         width: 34,
                                         decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           color: Colors.green
                                               .withOpacity(0.1),
                                         ),
                                         child: const Icon(
                                           Icons.check,
                                           color: Colors.green,
                                           size: 18,
                                         ),
                                       ),

                                       const SizedBox(width: 10),

                                       Expanded(
                                         child: Text(
                                           employee["name"],
                                           style:
                                           const TextStyle(
                                             fontSize: 15,
                                             fontWeight:
                                             FontWeight.w500,
                                           ),
                                         ),
                                       ),

                                       Text(
                                         employee["id"]
                                             ?.toString()
                                             .isNotEmpty ==
                                             true
                                             ? employee["id"]
                                             .toString()
                                             : "NO ID",
                                         style: TextStyle(
                                           color:
                                           Colors.grey.shade500,
                                           fontSize: 13,
                                         ),
                                       ),
                                     ],
                                   ),
                                 );
                               },
                             ),
                           ],
                         ),
                       ),
                     ),

                     const SizedBox(width: 18),

                     // ================= ABSENT =================

                     Expanded(
                       child: Container(
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(16),
                           boxShadow: [
                             BoxShadow(
                               offset: const Offset(2, 3),
                               blurRadius: 10,
                               spreadRadius: 1,
                               color: Colors.grey.withOpacity(0.15),
                             ),
                           ],
                         ),
                         child: Column(
                           crossAxisAlignment:
                           CrossAxisAlignment.start,
                           children: [

                             const Text(
                               "Absent Employees",
                               style: TextStyle(
                                 fontWeight: FontWeight.w700,
                                 fontSize: 19,
                               ),
                             ),

                             const SizedBox(height: 18),

                             if (absentEmployees.isEmpty)
                               const Padding(
                                 padding: EdgeInsets.symmetric(
                                   vertical: 12,
                                 ),
                                 child: Text(
                                   "No absent employees",
                                   style: TextStyle(
                                     color: Colors.grey,
                                   ),
                                 ),
                               ),

                             ...absentEmployees.map(
                                   (employee) {

                                 return Container(
                                   margin:
                                   const EdgeInsets.symmetric(
                                     vertical: 3,
                                   ),
                                   padding:
                                   const EdgeInsets.symmetric(
                                     horizontal: 12,
                                     vertical: 12,
                                   ),
                                   decoration: BoxDecoration(
                                     color: Colors.grey.shade50,
                                     borderRadius:
                                     BorderRadius.circular(9),
                                   ),
                                   child: Row(
                                     children: [

                                       Container(
                                         height: 34,
                                         width: 34,
                                         decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           color: Colors.red
                                               .withOpacity(0.1),
                                         ),
                                         child: const Icon(
                                           Icons.close,
                                           color: Colors.red,
                                           size: 18,
                                         ),
                                       ),

                                       const SizedBox(width: 10),

                                       Expanded(
                                         child: Text(
                                           employee["name"],
                                           style:
                                           const TextStyle(
                                             fontSize: 15,
                                             fontWeight:
                                             FontWeight.w500,
                                           ),
                                         ),
                                       ),

                                       Text(
                                         employee["id"]
                                             ?.toString()
                                             .isNotEmpty ==
                                             true
                                             ? employee["id"]
                                             .toString()
                                             : "NO ID",
                                         style: TextStyle(
                                           color:
                                           Colors.grey.shade500,
                                           fontSize: 13,
                                         ),
                                       ),
                                     ],
                                   ),
                                 );
                               },
                             ),
                           ],
                         ),
                       ),
                     ),
                   ],
                 ),

                 const SizedBox(height: 25),
               ],
             ),
           ),
         ),
       ),
     ),
   );
   }
  Widget desktop(){
   return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xff263b84),
      iconTheme: const IconThemeData(
          color: Colors.white
      ),
      title: Text("Batch: ${batchName}",style: TextStyle(fontSize: 23,color: Colors.white),),),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= HEADER =================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    const Text(
                      "Summary",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      "${selectedDate.day.toString().padLeft(2, '0')}/"
                          "${selectedDate.month.toString().padLeft(2, '0')}/"
                          "${selectedDate.year}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ================= SUMMARY + ATTENDANCE =================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ================= SUMMARY CARD =================

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 25,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 2),
                              blurRadius: 7,
                              color: Colors.grey.shade300,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [



                            const SizedBox(height: 25),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [

                                // PRESENT
                                Column(
                                  children: [

                                    Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            offset:
                                            const Offset(2, 2),
                                            spreadRadius: 1,
                                            blurRadius: 6,
                                            color: Colors.grey.shade300,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [

                                          const Icon(
                                            Icons.check_circle,
                                            size: 32,
                                            color: Colors.green,
                                          ),

                                          const SizedBox(height: 7),

                                          Text(
                                            "$present",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 27,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    const Text(
                                      "Present",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                // ABSENT
                                Column(
                                  children: [

                                    Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            offset:
                                            const Offset(2, 2),
                                            spreadRadius: 1,
                                            blurRadius: 6,
                                            color: Colors.grey.shade300,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [

                                          const Icon(
                                            Icons.cancel,
                                            size: 32,
                                            color: Colors.red,
                                          ),

                                          const SizedBox(height: 7),

                                          Text(
                                            "$absent",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 27,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    const Text(
                                      "Absent",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 25),

                    // ================= ATTENDANCE CARD =================

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 2),
                              blurRadius: 7,
                              color: Colors.grey.shade300,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [

                                const Text(
                                  "Attendance",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  "${percentage.toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 12,
                                backgroundColor:
                                Colors.grey.shade200,
                                valueColor:
                                const AlwaysStoppedAnimation(
                                  Colors.blue,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "$present Present  •  $absent Absent",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // ================= EMPLOYEES =================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ================= PRESENT =================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          const Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                              bottom: 15,
                            ),
                            child: Text(
                              "Present Employees",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                  color: Colors.grey.shade300,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [

                                if (presentEmployees.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(25),
                                    child: Text(
                                      "No present employees",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                ...presentEmployees.map(
                                      (employee) {
                                    return Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 17,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                            Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [

                                          Expanded(
                                            child: Text(
                                              employee["name"],
                                              style:
                                              const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          Text(
                                            employee["id"]
                                                ?.toString()
                                                .isNotEmpty ==
                                                true
                                                ? employee["id"]
                                                .toString()
                                                : "NO ID",
                                            style: TextStyle(
                                              color:
                                              Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 30),

                    // ================= ABSENT =================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          const Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                              bottom: 15,
                            ),
                            child: Text(
                              "Absent Employees",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                  color: Colors.grey.shade300,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [

                                if (absentEmployees.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(25),
                                    child: Text(
                                      "No absent employees",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                ...absentEmployees.map(
                                      (employee) {
                                    return Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 17,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                            Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [

                                          Expanded(
                                            child: Text(
                                              employee["name"],
                                              style:
                                              const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          Text(
                                            employee["id"]
                                                ?.toString()
                                                .isNotEmpty ==
                                                true
                                                ? employee["id"]
                                                .toString()
                                                : "NO ID",
                                            style: TextStyle(
                                              color:
                                              Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ),);
  }


@override
  Widget build(BuildContext context) {

    final total=present+absent;

    final percentage=total==0?0.0:(present/total)*100;

    final progress=percentage/100;
    final width = MediaQuery
        .of(context)
        .size
        .width;
    if (width < 600) {
      return mobile();
    }
    else if (width < 1050) {
      return tablet();
    }
    else {
      return desktop();
    }
}
}
class HistorySkeleton extends StatelessWidget{
  const HistorySkeleton({super.key});
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

  //responsive
  Widget mobile(){
    return  Skeletonizer(
        enabled: true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 50,left: 50,right: 50),
                child: skeletonBox(
                  height: 60,
                  width: double.infinity,
                  radius: 12,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 110,vertical: 30),
                child: skeletonBox(
                  height: 110,
                  width: double.infinity,
                  radius: 12,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    skeletonBox(
                      height: 100,
                      width: 90,
                      radius: 12,
                    ),

                    skeletonBox(
                      height: 100,
                      width: 90,
                      radius: 12,
                    ),
                  ],),
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

    );
  }
  Widget tablet(){
    return  Skeletonizer(
        enabled: true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 100,left: 190,right: 190),
                child: skeletonBox(
                  height: 100,
                  width: double.infinity,
                  radius: 12,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 200,vertical: 50),
                child: skeletonBox(
                  height: 200,
                  width: double.infinity,
                  radius: 12,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    skeletonBox(
                      height: 120,
                      width: 150,
                      radius: 12,
                    ),

                    skeletonBox(
                      height: 120,
                      width: 150,
                      radius: 12,
                    ),
                  ],),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 30,
                    ),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 15,
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
                              height: 50,
                              width: 110,
                              color: Colors.white,
                            ),

                            Container(
                              height: 50,
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

    );
  }
  Widget desktop() {
    return Skeletonizer(
      enabled: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= LEFT SIDE =================

          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [

                  // Date
                  skeletonBox(
                    height: 60,
                    width: double.infinity,
                    radius: 12,
                  ),

                  const SizedBox(height: 50),

                  // Circular Progress
                  skeletonBox(
                    height: 190,
                    width: 190,
                    radius: 100,
                  ),
                ],
              ),
            ),
          ),

          // ================= RIGHT SIDE =================

          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Present + Absent
                    Row(
                      children: [

                        Expanded(
                          child: skeletonBox(
                            height: 110,
                            width: double.infinity,
                            radius: 12,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: skeletonBox(
                            height: 110,
                            width: double.infinity,
                            radius: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // Batches heading
                    skeletonBox(
                      height: 25,
                      width: 100,
                      radius: 6,
                    ),

                    const SizedBox(height: 20),

                    // Batch 1
                    skeletonBox(
                      height: 70,
                      width: double.infinity,
                      radius: 10,
                    ),

                    const SizedBox(height: 15),

                    // Batch 2
                    skeletonBox(
                      height: 70,
                      width: double.infinity,
                      radius: 10,
                    ),

                    const SizedBox(height: 15),

                    // Batch 3
                    skeletonBox(
                      height: 70,
                      width: double.infinity,
                      radius: 10,
                    ),

                    const SizedBox(height: 15),

                    // Batch 4
                    skeletonBox(
                      height: 70,
                      width: double.infinity,
                      radius: 10,
                    ),

                    const SizedBox(height: 30),

                    // Download
                    Center(
                      child: skeletonBox(
                        height: 45,
                        width: 160,
                        radius: 10,
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



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    if (width < 600) {
      return mobile();
    }
    else if (width < 1050) {
      return tablet();
    }
    else {
      return desktop();
    }
    }

            }