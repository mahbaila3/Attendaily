import 'package:attendaily/uiHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class addEmployee extends StatefulWidget{

  final String batchId;
  const addEmployee({
    super.key,
    required this.batchId,
  });
  @override
  State<addEmployee> createState() => _addEmployeeState();
}

class _addEmployeeState extends State<addEmployee> {
  String message="";
  bool  isSaved= false;
  bool isSaving= false;
  int emptyfields=0;

  String? emptyfield;

  TextEditingController name =TextEditingController();
   TextEditingController urID=TextEditingController();
  TextEditingController phoneNumber=TextEditingController();

  TextEditingController type=TextEditingController();

  TextEditingController Rnum= TextEditingController();

  TextEditingController Rname=TextEditingController();

  Color black=Colors.black;

  @override
  Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
  iconTheme: const IconThemeData(
    color: Colors.white
  ),
  backgroundColor: Color(0xff263b84),
  title: Text(" Add Employees",style: TextStyle(color: Colors.white),),),

  // main body
 body:  SingleChildScrollView(
   child: Container(
     child: Center(
       child: ConstrainedBox(constraints: BoxConstraints(
         maxWidth: 500,
       ),
         child: SingleChildScrollView(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 30),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                     Center(child: Icon(Icons.account_circle,color: Color(0xff243f9e),size: 70,)),
                 SizedBox(
                   height: 20,
                 ),
                 Center(child: Text("Employees Details",style: TextStyle(color:black,fontWeight: FontWeight.w700,fontSize: 21),)),
                 SizedBox(height: 45,),
                 Text("Name",style: TextStyle(color:black,fontSize: 18,fontWeight: FontWeight.w500),),
                 uiHelper.CustomTextField(name, "Enter Employee name", Icons.person, false),
                 SizedBox(height: 30,),
                 Text("Employee ID",style: TextStyle(color:black,fontSize: 18,fontWeight: FontWeight.w500),),
                 uiHelper.CustomTextField(urID, "e.g. EMP-006", Icons.person, false),
                 SizedBox(height: 30,),
                 Text("Type",style: TextStyle(color:black,fontSize: 18,fontWeight: FontWeight.w500),),
                 uiHelper.CustomTextField(type, "e.g. manager", Icons.work_outline_sharp, false),
                 SizedBox(height: 30,),
                 Text("Phone Number",style: TextStyle(color:black,fontSize: 18,fontWeight: FontWeight.w500),),
                   Padding(
                     padding: const EdgeInsets.only(top: 5),
                     child: Container(
                       decoration: BoxDecoration(
                         boxShadow: [BoxShadow(
                           offset: Offset(0, 4),
                           color: black.withOpacity(0.02),
                           blurRadius: 1
                         )]
                       ),
                       child: IntlPhoneField(
                           keyboardType: TextInputType.number,
                           controller: phoneNumber,
                           initialCountryCode: "Pk",
     
                           decoration: InputDecoration(
                             hintText: "Enter phone number",
                             filled: true,fillColor: Colors.white,
                             enabledBorder: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(10),
                               borderSide: BorderSide(
                                 color: Colors.white,
                                 width: 2,
     
                               )
                             ),
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(10),
                             )
                           )
                         ),
     
                     ),
                   ),
                 SizedBox(height: 10,),
                 Text("Contact person",style: TextStyle(color:black,fontWeight: FontWeight.w700,fontSize: 19),),
                 SizedBox(height: 30,),
                 Text("Name",style: TextStyle(color:black,fontSize: 18,fontWeight: FontWeight.w500),),
                 uiHelper.CustomTextField(Rname, "e.g. father , friends ", Icons.person, false),
                 SizedBox(height: 30,),
                 Text("Phone number",style: TextStyle(color:black,fontSize: 18,fontWeight: FontWeight.w500),),
     
                 Padding(
                   padding: const EdgeInsets.only(top: 5),
                   child: Container(
                     decoration: BoxDecoration(
                         boxShadow: [BoxShadow(
                             offset: Offset(0, 4),
                             color: black.withOpacity(0.02),
                             blurRadius: 1
                         )]
                     ),
                     child: IntlPhoneField(
                           keyboardType: TextInputType.number,
                           controller: Rnum,
                           initialCountryCode: "Pk",
     
                           decoration: InputDecoration(
                               hintText: "e.g. father , friends ",
                               filled: true,fillColor: Colors.white,
                               enabledBorder: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                   borderSide: BorderSide(
                                     color: Colors.white,
                                     width: 2,
     
                                   )
                               ),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(10),
                               )
                           )
                       ),
     
                   ),
                 ),
                 SizedBox(
                   height: 20,
                 ),
                 if(!isSaved)
                 Padding(
                   padding: const EdgeInsets.only(top: 20,left: 60,right: 60),
                   child: SizedBox(
                     height: 50,
                     width: double.infinity,
                     child: ElevatedButton(onPressed:
                          isSaving
                         ?null:
                         ()async{
                             message="";
                            int emptyfields = 0;
                            String emptyfield = "";
                          if(name.text.trim().isEmpty){
                           emptyfields++;
                           emptyfield="Name";
                          }
                          if(phoneNumber.text.trim().isEmpty){
                            emptyfields++;
                            emptyfield="phoneNumber";
                          }
                          if(type.text.trim().isEmpty){
                            emptyfields++;
                            emptyfield="Type";
                          }
                             if(urID.text.trim().isEmpty){                                 //
                               emptyfields++;
                               emptyfield="Employee ID";
                             }
                          if(Rnum.text.trim().isEmpty){
                            emptyfields++;
                            emptyfield="Phone number";
                          }
                          if(Rname.text.trim().isEmpty){
                            emptyfields++;
                            emptyfield="ConTact name";
                          }
                          if (emptyfields==1){
                            uiHelper.CustomAlertBox(context, "$emptyfield is required");
                            return;
                          }
     
                          else if (emptyfields >1){
                            uiHelper.CustomAlertBox(context, "Enter all required fields ");
                          return;
                          }
                                      if(message.isNotEmpty){
                                          uiHelper.CustomAlertBox(context,message);
                                                   return;
                                                    }
                          setState(() {
     
                            isSaving=true;
                          });
                                                                                                   //                          else {
     
     
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                setState(() {
                                  isSaving=false;
                                });
                                return;
                              }
     
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user.uid)
                                  .collection("batches")
                                  .doc(widget.batchId)
                                  .collection("employees")
                                  .add({
                                "name": name.text.trim(),
                                "urID": urID.text.trim(),
                                "phoneNumber": phoneNumber.text.trim(),
                                "type": type.text.trim(),
                                "Rname": Rname.text.trim(),
                                "Rnum": Rnum.text.trim(),
                                "createdAt": FieldValue.serverTimestamp(),
                              });
                              setState(() {
                                isSaving=false;
                                isSaved=true;
                              });
     
                            }
                            catch (e) {
                             }
                         // }
                           //auth
     
     
     
                     },
                         style: ElevatedButton.styleFrom(
                           elevation: 0,
                           foregroundColor: Colors.white,
                           backgroundColor: Color(0xff263b84),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10)
                           )
                         ),
                         child: Text("Save",style: TextStyle(fontWeight: FontWeight.w500),)),
                   ),
                 ),
                 if(isSaved)
                   Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: .center,
                       children: [
                         Padding(
                           padding: const EdgeInsets.only(top: 15),
                           child: Row(
                             mainAxisAlignment: .center,
                             children: [
                               Icon(Icons.check_circle,size: 22,color: Colors.green,),
                               SizedBox(width: 6,),
                               Text("Saved",style: TextStyle(color: Colors.green,fontSize: 16,fontWeight: FontWeight.w600),)
                             ],
                           ),
                         ),
                         SizedBox(height: 20,),
                         Padding(
                           padding: const EdgeInsets.only(left: 60,right: 60,top: 10,bottom: 10),
                           child: SizedBox(
                             height: 50,
                             width: double.infinity,
                             child: ElevatedButton(onPressed: (){
                              setState(() {
                                urID.clear();
                                name.clear();
                                phoneNumber.clear();
                                type.clear();
                                Rname.clear();
                                Rnum.clear();
                                isSaved= false;
                              });
                             },
                                 style: ElevatedButton.styleFrom(
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(13)
                                     ),
                                     backgroundColor: Color(0xff263b84),foregroundColor: Colors.white),
                                 child: Text("Add another employee",style: TextStyle(fontWeight: FontWeight.w500),)),
                           ),
                         )
                       ],
                     ),
                   )
     
     
     
               ],
             ),
           ),
         ),
       ),
     ),
   ),
 ),


);
  }
}

