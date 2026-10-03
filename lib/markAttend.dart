import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class markAttend extends StatefulWidget{
  const markAttend({super.key});
  @override
  State<markAttend> createState() => _markAttendState();
}

class _markAttendState extends State<markAttend> {
  String? selectedBatchId;
  String? selectedBatchName;
  Map<String, String> attendance = {};


  Future<void> saveAttendance() async {
    if (selectedBatchId == null) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

// Batch ke tamam employees Firebase se lao
    final employeesSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("batches")
        .doc(selectedBatchId)
        .collection("employees")
        .get();

    final totalEmployees = employeesSnapshot.docs.length;

// Agar batch mein koi employee hi nahi
    if (totalEmployees == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No employees found"),
        ),
      );

      return;
    }

// Sab employees ki attendance mark hui hai ya nahi
    if (attendance.length != totalEmployees) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please mark attendance for all employees",
          ),
        ),
      );

      return;
    }

// Har employee ko individually check karo
    for (final employeeDoc in employeesSnapshot.docs) {
      final employeeId = employeeDoc.id;

// Employee ki attendance missing hai
      if (!attendance.containsKey(employeeId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please mark attendance for all employees",
            ),
          ),
        );

        return;
      }

// Status Present ya Absent hona chahiye
      if (attendance[employeeId] != "Present" &&
          attendance[employeeId] != "Absent") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please mark attendance for all employees",
            ),
          ),
        );

        return;
      }
    }

// -----------------------------
// Ab attendance Firebase mein save hogi
// -----------------------------

    final now = DateTime.now();

    final dateKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("batches")
        .doc(selectedBatchId)
        .collection("attendance")
        .doc(dateKey)
        .set(
      {
        ...attendance,
        'date': dateKey,
        'savedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Attendance saved successfully"),
      ),
    );
  }
Future<void> loadAttendance(String batchId) async {
final user = FirebaseAuth.instance.currentUser;

if (user == null) {
return;
}

final now = DateTime.now();

final dateKey =
"${now.year}-"
"${now.month.toString().padLeft(2, '0')}-"
"${now.day.toString().padLeft(2, '0')}";

final doc = await FirebaseFirestore.instance
.collection("users")
.doc(user.uid)
.collection("batches")
.doc(batchId)
.collection("attendance")
.doc(dateKey)
.get();

// Aaj ki attendance save nahi hui
if (!doc.exists) {
return;
}

final data = doc.data();

if (data == null) {
return;
}

if (!mounted) return;

setState(() {
attendance.clear();

data.forEach((key, value) {
if (value == "Present" || value == "Absent") {
attendance[key] = value;
}
});
});
}
  @override
  Widget build(BuildContext context) {

    final user= FirebaseAuth.instance.currentUser;
    if (user == null){
      return const Scaffold(body: Center(child: Text("User not login")),);
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Color(0xff263b84),
        title: Text("Attendance",style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text("Mark Attendance",style: TextStyle(fontSize: 21,fontWeight: FontWeight.w700,color: Colors.black),)),
              SizedBox(height: 35,),
              Text("Select Batch",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 18),),
              SizedBox(height: 20,),
              StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .collection("batches")
                  .snapshots(),
                  builder: (context,snapshot){
                if(snapshot.connectionState==ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }
                if(snapshot.hasError){
                  return Text("Error: ${snapshot.hasError}");
                }
                if (!snapshot.hasData||snapshot.data!.docs.isEmpty){
                  return const Center(child: Text("No batches found"));
                }
                final batches=snapshot.data!.docs;
                 return  Center(
                   child: ConstrainedBox(
                       constraints: BoxConstraints(
                         maxWidth: 400,
                       ),
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 13),
                         child: Container(

                           padding: EdgeInsets.symmetric(horizontal: 15,vertical: 4),
                           decoration: BoxDecoration(
                             boxShadow: [BoxShadow(
                               offset: Offset(0, 2),
                               color: Colors.grey,
                               blurRadius: 5
                             )],
                             borderRadius: BorderRadius.circular(12),
                             color: Colors.white,
                             border: Border.all(color: Colors.white)
                           ),
                           child: DropdownButtonFormField<String>(

                               value: selectedBatchId,
                            // underline: const SizedBox(),
                               decoration: InputDecoration(
                                   border: InputBorder.none,
                                 hintText: "Select Batch"
                               ),
                               items: batches.map((docs){
                                 final data= docs.data()as Map<String,dynamic>;
                                 return DropdownMenuItem<String>
                                   (
                                     value: docs.id,
                                     child: Text(data['batchName']??"unnamed batch"),);
                               }).toList(),
                               onChanged: (value){
                                 if (value==null){
                                   return ;
                                 }
                                 final selectedDoc =                                             //
                                 batches.firstWhere(
                                       (doc) => doc.id == value,
                                 );
                                 final data =                                                  //
                                 selectedDoc.data()
                                 as Map<String, dynamic>;

                                 setState(() {
                                   selectedBatchId=value;
                                   selectedBatchName=data["batchName"]??"UnNamed batch";
                                  attendance.clear();
                                 });

                                 loadAttendance(value);
                               },
                           ),
                         ),
                       ),
                     ),
                 );

                  },
              ),
              const SizedBox(
                height: 20,
              ),
              if (selectedBatchId != null)
                Center(
                  child: Text(
                    "Batch: ${selectedBatchName ?? ''}" ,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 10,),
               Expanded(
                 child: StreamBuilder<QuerySnapshot>(

                      stream:  FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('batches')
                          .doc(selectedBatchId)
                          .collection('employees')
                          .snapshots(),
                       builder: (context,snapshot){
                       if (snapshot.connectionState==ConnectionState.waiting){
                         return  const Center
                           (child: CircularProgressIndicator());
                       }
                       if (snapshot.hasError){
                         return  Center(
                           child:  Text(
                             "Error: ${snapshot.hasError}",
                           ),
                         );
                       }
                       if (!snapshot.hasData||snapshot.data!.docs.isEmpty){
                         return Center(child: Text("No employees found"),
                         );
                       }
                       final employees=snapshot.data!.docs;
                       return ListView.builder(

                        //   shrinkWrap: true,
                           itemCount: employees.length,
                           itemBuilder: (context,index){
                             final employee=employees[index];
                             final data =employee.data()as Map<String,dynamic>;
                             final employeeId=employee.id;
                             final employeeName=data["name"]??"Undefined";
                             final employeeType =
                                 data['type'] ??
                                     '';
                            // final status=attendance[employeeId];

                                           return EmployeeAttendanceCard(
                                             employeeId: employeeId,
                                             employeeName: employeeName,
                                             employeeType: employeeType,
                                             initialStatus: attendance[employeeId],
                                             onStatusChanged: (status) {
                                               attendance[employeeId] = status;
                                             },
                                           );
                                           },
                                           );

                    },
                    ),
               ),

         if (selectedBatchId != null)
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 8),
               child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 450,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xff263b84),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              )
                          ),
                          onPressed: () async{
                            await saveAttendance();
                          },

                          child: const Text(
                            "Save Attendance",
                          ),
                        ),
                      ),
                    ),
                  ),
             ),



          ],
          ),),


  );




  }
}
class EmployeeAttendanceCard extends StatefulWidget{
  final String employeeId;
  final String employeeName;
  final String employeeType;
  final String? initialStatus;
  final Function(String status) onStatusChanged;



  const EmployeeAttendanceCard({
    super.key,
    required this.employeeId,
    required this.employeeName,
    required this.employeeType,
    required this.onStatusChanged,
    required this.initialStatus,
  });
  @override
  State<EmployeeAttendanceCard> createState() => _EmployeeAttendanceCardState();
}

class _EmployeeAttendanceCardState extends State<EmployeeAttendanceCard> {
  String? status;
  @override
  void initState() {
    super.initState();
    status = widget.initialStatus;
  }
  @override
  void didUpdateWidget(covariant EmployeeAttendanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialStatus != widget.initialStatus) {
      setState(() {
        status = widget.initialStatus;
      });
    }
  }


  @override
Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        child: Container(
          width: double.infinity,

          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),

          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                offset: Offset(2, 4),
                spreadRadius: 1,
                blurRadius: 5,
                color: Colors.grey,
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // =========================
              // EMPLOYEE INFO
              // =========================

              Row(
                children: [

                  Icon(
                    Icons.account_circle,
                    size: 50,
                    color: Color(0xff263b84),
                  ),

                  const SizedBox(width: 10),

                  // Employee name
                  Expanded(
                    child: Text(
                      widget.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Employee type
                  Text(
                    widget.employeeType,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              // =========================
              // ATTENDANCE BUTTONS
              // =========================

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  SizedBox(
                    height: 30,
                    width: 84,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                        status == "Present"
                            ? Colors.green.shade800
                            : Colors.green.shade300,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                      ),

                      onPressed: () {
                        setState(() {
                          status = "Present";
                        });

                        widget.onStatusChanged("Present");
                      },

                      child: const Text(
                        "Present",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    height: 30,
                    width: 84,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                        status == "Absent"
                            ? Colors.red.shade800
                            : Colors.red.shade300,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                      ),

                      onPressed: () {
                        setState(() {
                          status = "Absent";
                        });

                        widget.onStatusChanged("Absent");
                      },

                      child: const Text(
                        "Absent",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}