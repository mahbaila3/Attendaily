import 'package:attendaily/addEmployee.dart';
import 'package:attendaily/batchPage.dart';
import 'package:attendaily/employeeDetails.dart';
import 'package:attendaily/uiHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';


class batchDetail extends StatefulWidget{
  final String batchId;
  const batchDetail({ super.key, required this.batchId, });
  @override
  State<batchDetail> createState() => _batchDetailState();
}

class _batchDetailState extends State<batchDetail> {
 Color white =Colors.white;
 String getTodayDateKey() {
   final now = DateTime.now();

   return "${now.year}-"
       "${now.month.toString().padLeft(2, '0')}-"
       "${now.day.toString().padLeft(2, '0')}";
 }

 Future<void>deleteBatch()async{
   final user=FirebaseAuth.instance.currentUser;
   if(user==null){
     return;
   }
   try{
     final batchDel=FirebaseFirestore.instance
         .collection("users")
         .doc(user.uid)
         .collection("batches")
         .doc(widget.batchId);
     //employees delete
     final employees=await batchDel
     .collection("employees")
     .get();
     for(final doc in employees.docs){
       await doc.reference.delete();
     }
   //attendance delete
     final attendance=await batchDel
     .collection("attendance")
     .get();
     for(final doc in attendance.docs){
       await doc.reference.delete();
     }
     await batchDel.delete();
     if(mounted){
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Batch deleted successfully")));
     }

   }catch(e){
     if(mounted){
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Batch delete error:$e")));

     }
   }
 }


 //responsive
 Widget attendanceCard(
     IconData icon,
     String value,
     String title,
     Color color,
     ) {
   return Container(
     height: 110,
     decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(13),
       color: Colors.white,
       border: Border.all(
         color: color,
         width: 1,
       ),
     ),
     child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Icon(
           icon,
           size: 30,
           color: color,
         ),

         const SizedBox(height: 3),

         Text(
           value,
           style: const TextStyle(
             color: Colors.black,
             fontWeight: FontWeight.bold,
             fontSize: 25,
           ),
         ),

         Text(
           title,
           style: const TextStyle(
             color: Colors.black,
             fontSize: 15,
           ),
         ),
       ],
     ),
   );
 }
 Widget desktop(String batchName,leaderName,phoneNumber,User user){

   return Scaffold(
     appBar: AppBar(
  backgroundColor: Color(0xff263b84),
   iconTheme: const IconThemeData(
     color: Colors.white,
   ),
       title: Text("Batch Details",style: TextStyle(color: Colors.white,fontSize: 23),),),
     body: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [

         // ================= LEFT SIDE =================
         Expanded(
           flex: 4,
           child: Container(
             height: double.infinity,
             padding: const EdgeInsets.all(30),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [

                 // Batch Details
                 Text(
                   "Batch Details",
                   style: TextStyle(
                     color: Colors.blue.shade900,
                     fontSize: 22,
                     fontWeight: FontWeight.w700,
                   ),
                 ),

                 const SizedBox(height: 25),

                 // Batch Card
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                     color: Color(0xff344da6),
                     borderRadius: BorderRadius.circular(18),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.grey.shade300,
                         blurRadius: 8,
                         offset: const Offset(0, 3),
                       ),
                     ],
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [

                       Row(
                         children: [
                           const Icon(
                             Icons.account_circle,
                             size: 55,
                             color: Colors.white,
                           ),

                           const SizedBox(width: 12),

                           Expanded(
                             child: Text(
                               batchName,
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 23,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ),
                           Container(
                               child:  IconButton(onPressed: (){
                                 showModalBottomSheet(context: context, builder: (context){
                                   return SafeArea(
                                     child: Column(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Container(
                                             width: double.infinity,
                                             child: TextButton(onPressed: (){
                                               Navigator.push(context, MaterialPageRoute(builder: (context) => edit(
                                                 batchId: widget.batchId,
                                               ),));

                                             }, child: Text("Edit",style: TextStyle(fontSize: 20),),)),
                                         Container(
                                             width: double.infinity,
                                             child: TextButton(onPressed: ()async{
                                               Navigator.pop(context);
                                               final confirm=await showDialog<bool>(context: context,
                                                   builder: (context){
                                                     return AlertDialog(
                                                       title: Text("Delete batch"),
                                                       content: Text("Are you sure to delete batch:$batchName\n\n"
                                                           "All attendance and employees of this batch are also be deleted"
                                                       ),
                                                       actions: [
                                                         TextButton(onPressed: (){
                                                           Navigator.pop(context,false);
                                                         }, child: Text("Cancel")),
                                                         TextButton(onPressed: (){
                                                           Navigator.pop(context,true);
                                                         }, child: Text("Delete",style: TextStyle(color: Colors.red),))
                                                       ],
                                                     );
                                                   });
                                               if(confirm==true){
                                                 await deleteBatch();
                                                 if(mounted){
                                                   Navigator.pop(this.context,true);
                                                 }
                                               }

                                             }, child: Text("Delete",style: TextStyle(color: Colors.red,fontSize: 20),)))
                                       ],
                                     ),
                                   );
                                 });

                               }, icon: Icon(Icons.edit_rounded,color: Colors.white,size: 28,))
                           )
                         ],
                       ),

                       const SizedBox(height: 30),

                       // Leader
                       Row(
                         children: [
                           const Icon(
                             Icons.person,
                             color: Colors.white,
                           ),

                           const SizedBox(width: 10),

                           Column(
                             crossAxisAlignment:
                             CrossAxisAlignment.start,
                             children: [
                               Text(
                                 "Team Leader",
                                 style: TextStyle(
                                   color: Colors.grey.shade300,
                                   fontSize: 13,
                                 ),
                               ),
                               Text(
                                 leaderName,
                                 style: const TextStyle(
                                   color: Colors.white,
                                   fontSize: 16,
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),

                       const SizedBox(height: 22),

                       // Phone
                       Row(
                         children: [
                           const Icon(
                             Icons.phone,
                             color: Colors.white,
                           ),

                           const SizedBox(width: 10),

                           Column(
                             crossAxisAlignment:
                             CrossAxisAlignment.start,
                             children: [
                               Text(
                                 "Phone",
                                 style: TextStyle(
                                   color: Colors.grey.shade300,
                                   fontSize: 13,
                                 ),
                               ),
                               Text(
                                 phoneNumber,
                                 style: const TextStyle(
                                   color: Colors.white,
                                   fontSize: 16,
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ],
                   ),
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

                   // Attendance Heading
                   Row(
                     children: [
                       Icon(
                         Icons.calendar_month,
                         color: Colors.blue.shade900,
                       ),
                       const SizedBox(width: 7),
                       Text(
                         "Attendance",
                         style: TextStyle(
                           color: Colors.blue.shade900,
                           fontSize: 21,
                           fontWeight: FontWeight.w700,
                         ),
                       ),
                     ],
                   ),

                   const SizedBox(height: 20),

                   // Attendance Cards
                   StreamBuilder<QuerySnapshot>(
                     stream: FirebaseFirestore.instance
                         .collection("users")
                         .doc(user.uid)
                         .collection("batches")
                         .doc(widget.batchId)
                         .collection("employees")
                         .snapshots(),

                     builder: (context, employeeSnapshot) {

                       if (employeeSnapshot.connectionState ==
                           ConnectionState.waiting) {
                         return const Center(
                           child: CircularProgressIndicator(),
                         );
                       }

                       final totalEmployees =
                           employeeSnapshot.data?.docs.length ?? 0;

                       return StreamBuilder<DocumentSnapshot>(
                         stream: FirebaseFirestore.instance
                             .collection("users")
                             .doc(user.uid)
                             .collection("batches")
                             .doc(widget.batchId)
                             .collection("attendance")
                             .doc(getTodayDateKey())
                             .snapshots(),

                         builder: (context, attendanceSnapshot) {

                           int present = 0;
                           int absent = 0;

                           bool attendanceMarked =
                               attendanceSnapshot.hasData &&
                                   attendanceSnapshot.data!.exists;

                           if (attendanceMarked) {
                             final attendanceData =
                             attendanceSnapshot.data!.data()
                             as Map<String, dynamic>;

                             attendanceData.forEach((key, value) {
                               if (value == "Present") {
                                 present++;
                               }

                               if (value == "Absent") {
                                 absent++;
                               }
                             });
                           }

                           return Row(
                             children: [

                               Expanded(
                                 child: attendanceCard(
                                   Icons.account_circle,
                                   "$totalEmployees",
                                   "Total",
                                   Colors.blue,
                                 ),
                               ),

                               const SizedBox(width: 15),

                               Expanded(
                                 child: attendanceCard(
                                   Icons.check_circle,
                                   attendanceMarked
                                       ? "$present"
                                       : "0",
                                   "Present",
                                   Colors.green,
                                 ),
                               ),

                               const SizedBox(width: 15),

                               Expanded(
                                 child: attendanceCard(
                                   Icons.cancel,
                                   attendanceMarked
                                       ? "$absent"
                                       : "0",
                                   "Absent",
                                   Colors.red,
                                 ),
                               ),
                             ],
                           );
                         },
                       );
                     },
                   ),

                   const SizedBox(height: 35),

                   // Employees Heading
                   Row(
                     mainAxisAlignment:
                     MainAxisAlignment.spaceBetween,
                     children: [

                       Row(
                         children: [
                           Icon(
                             Icons.group,
                             color: Colors.blue.shade900,
                           ),
                           const SizedBox(width: 7),
                           Text(
                             "Employees",
                             style: TextStyle(
                               color: Colors.blue.shade900,
                               fontSize: 20,
                               fontWeight: FontWeight.w700,
                             ),
                           ),
                         ],
                       ),

                       ElevatedButton(
                         onPressed: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => addEmployee(
                                 batchId: widget.batchId,
                               ),
                             ),
                           );
                         },
                         style: ElevatedButton.styleFrom(
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10)
                           ),
                           backgroundColor: Color(0xff344da6),
                           foregroundColor: Colors.white,
                         ),
                         child: const Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(Icons.add),
                             SizedBox(width: 5),
                             Text("Add"),
                           ],
                         ),
                       ),
                     ],
                   ),

                   const SizedBox(height: 15),

                   // Employees
                   StreamBuilder<QuerySnapshot>(
                     stream: FirebaseFirestore.instance
                         .collection("users")
                         .doc(user.uid)
                         .collection("batches")
                         .doc(widget.batchId)
                         .collection("employees")
                         .snapshots(),

                     builder: (context, snapshot) {

                       if (snapshot.connectionState ==
                           ConnectionState.waiting) {
                         return const Center(
                           child: CircularProgressIndicator(),
                         );
                       }

                       if (snapshot.hasError) {
                         return Center(
                           child: Text(
                             "Error ${snapshot.error}",
                           ),
                         );
                       }

                       if (!snapshot.hasData) {
                         return const SizedBox();
                       }

                       if (snapshot.data!.docs.isEmpty) {
                         return const Padding(
                           padding: EdgeInsets.only(top: 60),
                           child: Center(
                             child: Text(
                               "No employees added yet",
                               style: TextStyle(
                                 color: Colors.grey,
                                 fontSize: 16,
                               ),
                             ),
                           ),
                         );
                       }

                       final employees =
                           snapshot.data!.docs;

                       return Column(
                         children: employees.map((doc) {

                           final employee =
                           doc.data()
                           as Map<String, dynamic>;

                           return InkWell(
                             onTap: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) =>
                                       employeeDetails(
                                         urID: employee["urID"] ?? "",
                                         employeeDocId: doc.id,
                                         batchName: batchName,
                                         name: employee["name"] ?? "",
                                         type: employee["type"] ?? "",
                                         phoneNumber:
                                         employee["phoneNumber"] ?? "",
                                         Rname: employee["Rname"] ?? "",
                                         Rnum: employee["Rnum"] ?? "",
                                         batchId: widget.batchId,
                                       ),
                                 ),
                               );
                             },

                             child: Container(
                               width: double.infinity,
                               padding: const EdgeInsets.symmetric(
                                 horizontal: 15,
                                 vertical: 12,
                               ),
                               margin: const EdgeInsets.only(
                                 bottom: 12,
                               ),
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 boxShadow: [
                                   BoxShadow(
                                     offset: const Offset(0, 2),
                                     color: Colors.grey.shade300,
                                     blurRadius: 5,
                                   ),
                                 ],
                                 borderRadius:
                                 BorderRadius.circular(12),
                               ),

                               child: Row(
                                 children: [

                                   Icon(
                                     Icons.account_circle,
                                     size: 55,
                                     color: Colors.indigo.shade300,
                                   ),

                                   const SizedBox(width: 15),

                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                       children: [

                                         Text(
                                           employee["name"] ?? "",
                                           style: const TextStyle(
                                             color: Colors.black87,
                                             fontWeight:
                                             FontWeight.w700,
                                             fontSize: 18,
                                           ),
                                         ),

                                         const SizedBox(height: 5),

                                         Row(
                                           children: [
                                             Text(
                                               employee["urID"] ?? "No ID",
                                               style: const TextStyle(
                                                 color: Colors.grey,
                                               ),
                                             ),

                                             const SizedBox(width: 15),

                                             Container(
                                               width: 1,
                                               height: 20,
                                               color:
                                               Colors.grey.shade300,
                                             ),

                                             const SizedBox(width: 15),

                                             Text(
                                               employee["type"] ?? "",
                                               style: const TextStyle(
                                                 color: Colors.grey,
                                               ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     ),
                                   ),

                                   const Icon(
                                     Icons.arrow_forward_ios_rounded,
                                     size: 18,
                                     color: Colors.black87,
                                   ),
                                 ],
                               ),
                             ),
                           );

                         }).toList(),
                       );
                     },
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold( body:
      Center( child: Text("User is not logged in"), ), ); }
return Scaffold(
//appBar: AppBar(backgroundColor: Color(0xff192040),),
body: StreamBuilder<DocumentSnapshot>( stream: FirebaseFirestore.instance
.collection('users') .doc(user.uid)
.collection('batches') .doc(widget.batchId) .snapshots(),
builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator(),);
  }
  if (snapshot.hasError) {
    return Center(child: Text("Error: ${snapshot.error}",),);
  }
  if (!snapshot.hasData || !snapshot.data!.exists) {
    return const Center(child:
    Text("Batch not found", style: TextStyle(fontSize: 18,),),);
  }
  final data = snapshot.data!.data() as Map<String, dynamic>;
  final batchName = data['batchName'] ?? 'No batch name';
  final leaderName = data['leaderName'] ?? 'No leader name';
  final phoneNumber = data['phoneNumber'] ?? 'No phone number';

  if (MediaQuery
      .of(context)
      .size
      .width >= 1050) {
    return desktop(
        batchName,
        leaderName,
        phoneNumber,
        user,
    );
  }
  else {

    return CustomScrollView(
    slivers: [
      SliverAppBar(
        iconTheme:  IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff243f9e),
        expandedHeight: 220,stretch: true,
        centerTitle: true,
        collapsedHeight: 80,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18)
        ),
        title: Text("Batches detail",style: TextStyle(color: Colors.white,fontSize:20),),
      flexibleSpace: FlexibleSpaceBar(
        background: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(

              margin: EdgeInsets.all(15),
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(
                  offset: Offset(2, 1),
                  blurRadius: 5,
                  color: Colors.blue.shade600,
                )],
                color: Color(0xff344da6),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 3),
                child: Column(

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Container(
                          child: Row(
                            children: [
                             Icon(Icons.account_circle ,size:50,color: white,),
                              SizedBox(width: 10,),
                              Text(batchName,style:TextStyle(color: white,fontSize: 22),)
                            ],
                          ),
                        ),
                        Container(
                          child:  IconButton(onPressed: (){
                            showModalBottomSheet(context: context, builder: (context){
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                              width: double.infinity,
                                              child: TextButton(onPressed: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => edit(
                                                  batchId: widget.batchId,
                                                ),));

                                              }, child: Text("Edit",style: TextStyle(fontSize: 20),),)),
                                          Container(
                                              width: double.infinity,
                                              child: TextButton(onPressed: ()async{
                                                Navigator.pop(context);
                                                final confirm=await showDialog<bool>(context: context,
                                                    builder: (context){
                                                  return AlertDialog(
                                                    title: Text("Delete batch"),
                                                    content: Text("Are you sure to delete batch:$batchName\n\n"
                                                    "All attendance and employees of this batch are also be deleted"
                                                    ),
                                                    actions: [
                                                      TextButton(onPressed: (){
                                                        Navigator.pop(context,false);
                                                      }, child: Text("Cancel")),
                                                      TextButton(onPressed: (){
                                                        Navigator.pop(context,true);
                                                      }, child: Text("Delete",style: TextStyle(color: Colors.red),))
                                                    ],
                                                  );
                                                    });
                                                if(confirm==true){
                                                  await deleteBatch();
                                                  if(mounted){
                                                    Navigator.pop(this.context,true);
                                                  }
                                                }

                                              }, child: Text("Delete",style: TextStyle(color: Colors.red,fontSize: 20),)))
                                        ],
                                      ),
                                    );
                            });

                          }, icon: Icon(Icons.edit_rounded,color: Colors.white,size: 28,))
                        ),

                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 16),


                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.person,color: white,),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Team Leader",style: TextStyle(color: Colors.grey.shade300),),
                                      Text(leaderName,style: TextStyle(color: white),),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                              Container(
                                  height: 45,
                                  width: 1,
                                  color: Colors.white24,
                                ),
                             SizedBox(width: 15,),


                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.phone,color: white,),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Phone",style: TextStyle(color: Colors.grey.shade300),),
                                      Text(phoneNumber,style: TextStyle(color: white),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      width: 250,
                      height: 1,
                      color: Colors.white24,
                    )

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
      SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.only(left: 15,top: 20),
          child: Row(

            children: [
              Icon(Icons.calendar_month,color: Colors.blue.shade900,),
              SizedBox(
                width: 5,
              ),
              Text("Attendance",style: TextStyle(color: Colors.blue.shade900,fontSize: 20,fontWeight: FontWeight.w700),),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("batches")
           .doc(widget.batchId)
           .collection("employees")
            .snapshots(),
          builder: (context,employeeSnapshot){
           if (employeeSnapshot.connectionState==ConnectionState.waiting){
             return Center(child: CircularProgressIndicator());
           }
           if (employeeSnapshot.hasError){
             return Center(child: Text("Error: ${employeeSnapshot.error}"),);
           }
           final totalEmployees=employeeSnapshot.data?.docs.length??0;  
           
           return StreamBuilder<DocumentSnapshot>(
               stream: FirebaseFirestore.instance
               .collection("users")
               .doc(user.uid)
               .collection("batches")
               .doc(widget.batchId)
               .collection("attendance")
               .doc(getTodayDateKey())
               .snapshots(),
               builder: (context,attendanceSnapshot){
                 int present=0;
                 int absent=0;

                 bool attendanceMarked =
                     attendanceSnapshot.hasData &&
                         attendanceSnapshot.data!.exists;

                 if (attendanceMarked){
                   final attendanceData=
                       attendanceSnapshot.data!.data()as Map<String,dynamic>;
                   attendanceData.forEach((key,value){
                     if (value=="Present"){
                       present++;
                     }
                     if (value=="Absent"){
                      absent++;
                     }
                   });
                 }
                 double percentage=totalEmployees==0?0:(present/totalEmployees)*100;
                 return Padding(
                   padding: const EdgeInsets.all(12),
                   child: Container(
                     padding: EdgeInsets.all(10),
                     width: double.infinity,
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Container(

                           height: 110,
                           width: 100,
                           decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(13),
                               color: white,
                               border: Border.all(
                                 color: Colors.blue,
                                 width: 1,

                               )
                           ),
                           child: Padding(
                             padding: const EdgeInsets.all(9),
                             child: Column(
                               children: [
                                 Icon(Icons.account_circle,size: 30,color: Color(0xff243f9e)),
                                 SizedBox(
                                   height:2,
                                 ),
                                 Text("$totalEmployees",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize:  25),),
                                 Text("Total",style: TextStyle(color:Colors.black, fontWeight: FontWeight.w500, fontSize:  15),)

                               ],
                             ),
                           ),


                         ),
                         Container(

                           height: 110,
                           width:100,
                           decoration: BoxDecoration(

                               borderRadius: BorderRadius.circular(13),
                               color: white,
                               border: Border.all(
                                 color: Colors.green,
                                 width: 1,

                               )

                           ),
                           child: Padding(
                             padding: const EdgeInsets.all(10),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Icon(Icons.check_circle,size: 27,color: Colors.green,),
                                 SizedBox(height: 2,),
                                 Text( attendanceMarked
                                     ? "$present"
                                     : "0",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize:  25),),
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
                               color: white,
                               border: Border.all(
                                 color: Colors.red,
                                 width: 1,

                               )
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
                                 Text( attendanceMarked
                                     ? "$absent"
                                     : "0",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize:  25),),
                                 Text("Absent",style: TextStyle(color:Colors.black, fontWeight: FontWeight.w500, fontSize:  15),)


                               ],
                             ),
                           ),


                         ),
                       ],
                     ),
                   ),
                 );
               });
          },

        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // LEFT
              Row(
                children: [
                  Icon(
                    Icons.group,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Employees",
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              // RIGHT
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => addEmployee(
                        batchId: widget.batchId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(12) 
                  ),
                  backgroundColor: Color(0xff243f9e),
                  foregroundColor: white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: white,
                    ),
                    const SizedBox(width: 4),
                    const Text("Add"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("batches")
                .doc(widget.batchId)
                .collection("employees")
                .snapshots(),
            builder: (context,snapshot){
  if (snapshot.connectionState==ConnectionState.waiting){
  return  const Center(child:      CircularProgressIndicator());
  }
  if(snapshot.hasError){
  return Center(child: Text("Error ${snapshot.error}"));
  }
  if (!snapshot.hasData) {
  return const SizedBox();
  }

  if (snapshot.data!.docs.isEmpty) {
  return const Center(
  child: Padding(
    padding: EdgeInsets.only(top: 60),
    child: Text(
    "No employees added yet",
    style: TextStyle(
    color: Colors.grey,
    fontSize: 16,
    ),
    ),
  ),
  );
  }
  final employees=snapshot.data!.docs;
  return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
  child: Column(
  children: employees.map((doc) {

  final employee=  doc.data() as Map<String, dynamic>;   //{
  //...(doc.data() as Map<String, dynamic>),
  //"EmployeeID": doc.id,
  //};

  return InkWell(
    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => employeeDetails(
      urID: employee["urID"]?? "",
      employeeDocId: doc.id,
      batchName:batchName,
      name:employee["name"]?? "",
      type:employee["type"]?? "",
      phoneNumber:employee ["phoneNumber"]?? "",
     Rname: employee["Rname"]?? "",
      Rnum: employee["Rnum"]?? "",
      batchId:widget.batchId,

    ),));},
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(

        color: Colors.white,
        boxShadow: [BoxShadow(
            offset: Offset(0, 2),
            color: Colors.grey,

            blurRadius: 2
        )],
        borderRadius: BorderRadius.circular(10),

      ),
      child: Row(
  spacing: 10,
        children: [
          Icon(Icons.account_circle,size: 70,color: Color(0xff243f9e)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee["name"],style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w700,fontSize: 20),),
                Row(


                  children: [
                    Text(employee["urID"]?? "No ID",style: TextStyle(color: Colors.grey,),),
                    SizedBox(width: 20,),
                    Container(
                      width: 1 ,
                      height: 25,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(width: 20,),
                    Text(employee["type"],style: TextStyle(color:Colors.grey,),)
                  ],
                )
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios_rounded,color: Colors.black87,)
        ],
      ),


      )
  );

  }).toList(),
  ),);

  })
      )]
  );}
}),
);}}

class edit extends StatefulWidget{
  final String batchId;

  const edit({
    super.key,
    required this.batchId,
  });
  @override
  State<edit> createState() => _editState();
}

class _editState extends State<edit> {
  TextEditingController batchEdit=TextEditingController();

  TextEditingController leaderEdit=TextEditingController();

  TextEditingController phoneEdit=TextEditingController();
  bool isLoading =true;
  bool isSaving=false;
  @override
  void initState() {
    super.initState();
    loadEmployee();
  }
  Future<void>loadEmployee()async
{

final user = FirebaseAuth.instance.currentUser;

if (user == null) {
return;
}

try {
final doc = await FirebaseFirestore.instance
.collection("users")
.doc(user.uid)
.collection("batches")
.doc(widget.batchId)
.get();

if (doc.exists) {
final data = doc.data() as Map<String, dynamic>;

batchEdit.text = data["batchName"] ?? "";
leaderEdit.text = data["leaderName"] ?? "";
phoneEdit.text = data["phoneNumber"] ?? "";
}
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Error loading batch"),
),
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}}

Future<void> updateBatch() async {
final user = FirebaseAuth.instance.currentUser;

if (user == null) {
return;
}

setState(() {
isSaving = true;
});

try {
await FirebaseFirestore.instance
.collection("users")
.doc(user.uid)
.collection("batches")
.doc(widget.batchId)
.update({
"batchName": batchEdit.text.trim(),
"leaderName": leaderEdit.text.trim(),
"phoneNumber": phoneEdit.text.trim(),
});

if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Batch updated successfully"),
),
);

Navigator.pop(context, true);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Error updating batch"),
),
);
}
} finally {
if (mounted) {
setState(() {
isSaving = false;
});
}
}
}

@override
void dispose() {
batchEdit.dispose();
leaderEdit.dispose();
phoneEdit.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(
"Edit Batch",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
children: [
Padding(
padding: const EdgeInsets.only(top: 90),
child: Container(
child: Column(
spacing: 30,
children: [
uiHelper.CustomTextField(
batchEdit,
"Enter new name",
Icons.edit,
false,
),

uiHelper.CustomTextField(
leaderEdit,
"Enter new Leader",
Icons.edit,
false,
),

Padding(
padding: const EdgeInsets.symmetric(
horizontal: 8,
vertical: 10,
),
child: Container(
decoration: BoxDecoration(
boxShadow: [
BoxShadow(
offset: Offset(2, 4),
color: Colors.black.withOpacity(0.02),
blurRadius: 1,
),
],
),
child: IntlPhoneField(
keyboardType: TextInputType.number,
controller: phoneEdit,
initialCountryCode: "Pk",
decoration: InputDecoration(
hintText: "Enter new phone",
filled: true,
fillColor: Colors.white,
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: BorderSide(
color: Colors.white,
width: 2,
),
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),
),
),
],
),
),
),

Padding(
padding: const EdgeInsets.symmetric(
horizontal: 100,
vertical: 60,
),
child: SizedBox(
width: double.infinity,
child: ElevatedButton(
style: ElevatedButton.styleFrom(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
foregroundColor: Colors.white,
backgroundColor: Colors.blue,
),
onPressed: isSaving ? null : updateBatch,
child: isSaving
? SizedBox(
height: 20,
width: 20,
child: CircularProgressIndicator(
color: Colors.white,
strokeWidth: 2,
),
)
: Text("Save"),
),
),
),
],
),
),
);}
}



