import 'package:flutter/material.dart';

class privacy extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
 return Scaffold(
   appBar:  AppBar(
     backgroundColor: Color(0xff263b84),
     iconTheme: const IconThemeData(
       color: Colors.white
     ),
     title: Text("Privacy policy",style: TextStyle(color: Colors.white,fontSize: 23),),
   ),
   backgroundColor: Colors.grey.shade50,
   body: SingleChildScrollView(
     child: Padding(
       padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Center(child: Text("Attendaily",style: TextStyle(color:Colors.black,fontSize: 18),)),

             Padding(
               padding: const EdgeInsets.symmetric(vertical: 20),
               child: Text("Sharing and Protection of Your Information",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
             ),
             Text("We do not sell or rent your personal information to third parties.\n\nYour information may only be shared when it is necessary to provide the application's services, comply with applicable laws, protect the security of the application, or prevent misuse and unauthorized activity.",
               style: TextStyle(color: Colors.black,fontSize: 15),
             ),
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 20),
               child: Text("Account and Login Security",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
             ),
             Text("We take reasonable steps to protect your account and personal information from unauthorized access, misuse, or disclosure.\n\nLogin and session-related information is handled carefully and is used to keep your account secure and maintain your signed-in session.",
               style: TextStyle(color: Colors.black,fontSize: 15),
             ),
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 20),
               child: Text("Your privacy and contact us",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
             ),
             Text("You have the right to understand how your information is used and to request help regarding your account or personal information.\n\nIf you have any questions, concerns, or requests related to this Privacy Policy or your information, you can contact us. through the support contact provided in the application.",
               style: TextStyle(color: Colors.black,fontSize: 15,),
             ),
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 40),
               child: Center(child: Text("version 1.0.1",style: TextStyle(color: Colors.black,fontSize: 17,))),
             ),


     
           
           
           
           
           
           
           
           
           
           ],
         ),
     ),
   ),

 );
  }
}