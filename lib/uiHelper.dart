

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class uiHelper{
static CustomTextField(TextEditingController controller,String text,IconData iconData,bool toHide){
  return Padding(
    padding: const EdgeInsets.only(top: 10,bottom: 2,left: 10,right: 10),
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(

        controller: controller,
        obscureText: toHide,

        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          // for outline color
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white
                )
          ),
          suffixIcon: Icon(iconData),
          hintText: text,
          // to show when selected
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
              width: 2
            ),
            borderRadius: BorderRadius.circular(10)
          )

        ),


      ),
    ),
  );
}
static CustomAlertBox(BuildContext context,String text){
  return showDialog(context: context, builder: (BuildContext context){
    return AlertDialog(title: Text(text),
    actions: [
      TextButton(onPressed: (){
        Navigator.pop(context);
      }, child: Text("OK"))
    ],)

    ;
  });
}
}
class userService {
  static Future<String> getUserName() async {
    final user=  FirebaseAuth.instance.currentUser;
    if(user==null){
      return "";
    }
    final doc= await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    return doc.data()?["name"]??"";
  }
  static Stream<String> getUserNameStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value("");
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      return doc.data()?["name"] ?? "";
    });
  }

}