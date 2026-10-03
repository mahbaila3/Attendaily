import 'package:attendaily/uiHelper.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class addBatch extends StatefulWidget{
  @override
  State<addBatch> createState() => _addBatchState();
}

class _addBatchState extends State<addBatch> {
  TextEditingController batchname=TextEditingController();

  TextEditingController leadername=TextEditingController();

  TextEditingController phonenumber=TextEditingController();

  bool isSaving = false;
  bool isSaved = false;

   double gap=34;

   String message="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
iconTheme: const IconThemeData(
  color: Colors.white
),
       title: Center(child: Text("Add Batch",style: TextStyle(color: Colors.white),)),
     backgroundColor: Color(0xff263b84)),
      body:
      SingleChildScrollView(
        child: Container(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          
                      // =====================================
                      // BATCH DETAILS
                      // =====================================
          
                      const Center(
                        child: Text(
                          "Batch Details",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 24,
                          ),
                        ),
                      ),
          
                      const SizedBox(height: 30),
          
                      const Text(
                        "Name",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
          
                      uiHelper.CustomTextField(
                        batchname,
                        "Enter batch name",
                        Icons.batch_prediction,
                        false,
                      ),
          
                      const SizedBox(height: 40),
          
                      // =====================================
                      // LEADER DETAILS
                      // =====================================
          
                      const Center(
                        child: Text(
                          "Leader Details",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
          
                      const SizedBox(height: 30),
          
                      const Text(
                        "Name",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
          
                      uiHelper.CustomTextField(
                        leadername,
                        "Enter leader name",
                        Icons.person,
                        false,
                      ),
          
                      const SizedBox(height: 30),
          
                      // =====================================
                      // PHONE NUMBER
                      // =====================================
          
                      const Text(
                        "Phone number",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
          
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 2,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                blurRadius: 1,
                                color: Colors.black.withOpacity(0.02),
                              ),
                            ],
                          ),
                          child: IntlPhoneField(
                            keyboardType: TextInputType.number,
                            controller: phonenumber,
                            initialCountryCode: "Pk",
                            decoration: InputDecoration(
                              hintText: "Enter phone number",
                              fillColor: Colors.white,
                              filled: true,
          
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
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
          
                      const SizedBox(height: 20),
          
                      // =====================================
                      // SAVE BUTTON
                      // =====================================
          
                      if (!isSaved)
                        Padding(
                          padding: const EdgeInsets.only(top: 20,left: 10,right: 10),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                message = "";
          
                                if (leadername.text
                                    .trim()
                                    .isEmpty ||
                                    phonenumber.text
                                        .trim()
                                        .isEmpty ||
                                    batchname.text
                                        .trim()
                                        .isEmpty) {
                                  message = "Enter required fields";
                                } else if (leadername.text
                                    .trim()
                                    .isEmpty) {
                                  message = "Enter leader name";
                                } else if (phonenumber.text
                                    .trim()
                                    .isEmpty) {
                                  message = "Enter phone number";
                                } else if (batchname.text
                                    .trim()
                                    .isEmpty) {
                                  message = "Enter batch name";
                                }
          
                                if (message.isNotEmpty) {
                                  uiHelper.CustomAlertBox(
                                    context,
                                    message,
                                  );
                                  return;
                                }
          
                                setState(() {
                                  isSaving = true;
                                });
          
                                try {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
          
                                  if (user == null) {
                                    setState(() {
                                      isSaving = false;
                                    });
                                    return;
                                  }
          
                                  final uid = user.uid;
          
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(uid)
                                      .collection("batches")
                                      .add({
                                    "batchName":
                                    batchname.text.trim(),
                                    "leaderName":
                                    leadername.text.trim(),
                                    "phoneNumber":
                                    phonenumber.text.trim(),
                                    "createdAt":
                                    FieldValue.serverTimestamp(),
                                  });
          
                                  setState(() {
                                    isSaving = false;
                                    isSaved = true;
                                  });
                                } catch (e) {
                                  print(
                                    "FIRESTORE ERROR: $e",
                                  );
          
                                  setState(() {
                                    isSaving = false;
                                    isSaved = false;
                                  });
                                }
                              },
          
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff263b84),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                              ),
          
                              child: isSaving
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
          
                      // =====================================
                      // SAVED MESSAGE
                      // =====================================
          
                      if (isSaved)
                        Column(
                          children: [
          
                            const SizedBox(height: 15),
          
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 22,
                                ),
          
                                SizedBox(width: 6),
          
                                Text(
                                  "Saved",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
          
                            const SizedBox(height: 20),
          
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    batchname.clear();
                                    leadername.clear();
                                    phonenumber.clear();
                                    isSaved = false;
                                  });
                                },
          
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff263b84),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                ),
          
                                child: const Text(
                                  "Add another batch",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
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
            ),
          ),
        ),
      ),

    );
  }
}

