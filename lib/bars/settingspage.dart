import 'package:attendaily/login/login_Page.dart';
import 'package:attendaily/notification_service.dart';
import 'package:attendaily/privacy.dart';
import 'package:attendaily/uiHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendaily/uiHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool isLoggingOut = false;
  final TextEditingController editname = TextEditingController();

  bool isDark = false;

  //cards
  Widget reminderCard() {
    return
      Padding(
        padding: const EdgeInsets.only(
            left: 10, right: 10, top: 15, bottom: 10),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Reminder(),));
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 2),
                  blurRadius: 5,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reminder notification",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,size: 15,)
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget nameCard() {
    return
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 5,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),

            child: InkWell(
              onTap: () async {
                editname.text = await userService.getUserName();

                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text("Edit"),
                    content: TextField(
                      controller: editname,
                      decoration: const InputDecoration(
                          hintText: "Enter new name"
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () {
                        Navigator.pop(context);
                      }, child: Text("Cancel", style: TextStyle(
                          color: Colors.grey),)),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .blue, foregroundColor: Colors.white),

                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;
                            final newName = editname.text.trim();
                            if (newName.isEmpty) return;
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(user.uid)
                                .update({
                              "name": newName,
                            });

                            setState(() {});
                            editname.clear();

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }, child: Text("Save"))
                    ],

                  );
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit name",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: Colors.black,
                  ),
                ],
              ),
            ),


          ),
        ),
      );
  }

  Widget privacyCard() {
    return
      Padding(
        padding: const EdgeInsets.only(
            left: 10, right: 10, top: 15, bottom: 10),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 5,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),

            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => privacy(),));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Privacy policy",
                    style: TextStyle(
                      color: Colors.black,

                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: Colors.black,
                  ),
                ],
              ),
            ),


          ),
        ),
      );
  }

  Widget aboutCard() {
    return
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 5,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            //about
            child: InkWell(
              onTap: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Center(child: Text("About Attendaily")),
                    content: SizedBox(
                      height: 300,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3, bottom: 14),
                            child: Text(
                              "Make your attendance simple", style: TextStyle(
                                fontSize: 13, color: Colors.grey
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              "Attendaily is a simple attendance "
                                  "management application designed to make "
                                  "attendance tracking easier and more organized.This application helps you to add many batches and employees inside it",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              "Developed by Bovexa Labs", style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 35),
                            child: Text("version1.0.1", style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14
                            ),),
                          )


                        ],
                      ),
                    ),
                  );
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "About Attendaily",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: Colors.black,
                  ),
                ],
              ),
            ),


          ),
        ),
      );
  }

  Widget looutCard() {
    return
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 13),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 5,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            //navigate to logout page
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Log Out"),
                      content: const Text(
                        "Are you sure you want to log out?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),

                        ElevatedButton(
                          onPressed:  isLoggingOut
                              ? null
                              : () async {
                            setState(() {
                              isLoggingOut = true;
                            });

                            try {
                              await FirebaseAuth.instance.signOut();

                              if (!mounted) return;

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => loginPage(),
                                ),
                                    (route) => false,
                              );
                            } catch (e) {
                              if (!mounted) return;

                              setState(() {
                                isLoggingOut = false;
                              });

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Logout failed: $e",
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: Color(0xff344da6),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Logout"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red,

                      fontSize: 14,
                    ),
                  ),
                  const Icon(
                    Icons.logout,
                    size: 15,
                    color: Colors.red,
                  ),
                ],
              ),
            ),


          ),
        ),
      );
  }

  Widget logoutCard() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 13,
      ),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 5,
              color: Colors.grey.shade400,
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text("Log Out"),

                  content: const Text(
                    "Are you sure you want to log out?",
                  ),

                  actions: [
                    // Cancel
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: const Text("Cancel"),
                    ),

                    // Logout
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut();

                          if (!mounted) return;

                          Navigator.pop(dialogContext);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => loginPage(),
                            ),
                                (route) => false,
                          );
                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Logout failed: $e",
                              ),
                            ),
                          );
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff344da6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),

                      child: const Text("Logout"),
                    ),
                  ],
                );
              },
            );
          },

          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),

                Icon(
                  Icons.logout,
                  size: 15,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }








  Widget profile() {
    return
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 20,
        ),
        child: FutureBuilder(
          future: userService.getUserName(),
          builder: (context, snapshot) {
            return InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => manage(),));
              },
              child: Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 5,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(

                          children: [
                            Icon(Icons.person, size: 40),
                            Padding(
                              padding: const EdgeInsets.only(left: 17),
                              child:
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  final data = snapshot.data?.data() as Map<
                                      String,
                                      dynamic>?;

                                  return Text(
                                    data?["name"] ?? "",
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios_rounded)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left :58),
                        child: Text("Manage your account",style: TextStyle(color: Colors.grey),),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
  }

//settings pages
  Widget mobileReminder() {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xff263b84),
        foregroundColor: Colors.white,
        title: Text("Settings",
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),),),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30,top: 10),
                child: Text("Profile",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),),
              ),
              profile(),

              Padding(
                padding: const EdgeInsets.only(left: 30,top: 10),
                child: Text("Manage",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),),
              ),
              nameCard(),
              privacyCard(),
              Padding(
                padding: const EdgeInsets.only(left: 30,top: 10),
                child: Text("Others",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),),
              ),
              logoutCard(),


            ],
          ),
        ),
      ),

    );
  }

  Widget tabletReminder() {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xff263b84),
        foregroundColor: Colors.white,
        title: Text("Settings",
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),),),
        body:
        SingleChildScrollView(child:
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 40),
            child:  Padding(
              padding: const EdgeInsets.symmetric(vertical: 200),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(
                      offset: Offset(2, 2),
                      color: Colors.grey,
                      blurRadius: 5,
                      spreadRadius: 1,
                    )],

                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 30,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ================= LEFT SIDE =================
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const Text(
                                "Profile",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),

                              profile(),

                              const SizedBox(height: 25),

                              ],
                          ),
                        ),

                        const SizedBox(width: 40),

                        // ================= RIGHT SIDE =================
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              const Text(
                                "Accounts",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),

                              nameCard(),

                              privacyCard(),

                              const SizedBox(height: 25),

                              const Text(
                                "Log out",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),

                              logoutCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ),
            ),

        ),);
  }
  Widget windowsReminder() {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xff263b84),
        foregroundColor: Colors.white,
        title: Text("Settings",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),),),

      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200,
            ),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40,
                ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ================= LEFT SIDE =================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Profile
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                                bottom: 8,
                              ),
                              child: Text(
                                "Profile",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: FutureBuilder(
                                future: userService.getUserName(),
                                builder: (context, snapshot) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => manage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            offset: const Offset(0, 2),
                                            blurRadius: 6,
                                            color: Colors.grey.shade300,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 15,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [

                                            Row(
                                              children: [

                                                const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                ),

                                                const SizedBox(width: 15),

                                                Expanded(
                                                  child: StreamBuilder(
                                                    stream: FirebaseFirestore.instance
                                                        .collection("users")
                                                        .doc(
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid,
                                                    )
                                                        .snapshots(),
                                                    builder: (context, snapshot) {
                                                      final data =
                                                      snapshot.data?.data()
                                                      as Map<String, dynamic>?;

                                                      return Text(
                                                        data?["name"] ?? "",
                                                        style: const TextStyle(
                                                          fontSize: 25,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                        overflow:
                                                        TextOverflow.ellipsis,
                                                      );
                                                    },
                                                  ),
                                                ),

                                                const Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 22,
                                                ),
                                              ],
                                            ),

                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 65,
                                                top: 8,
                                              ),
                                              child: Text(
                                                "Manage your account",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Others
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                                bottom: 8,
                              ),
                              child: Text(
                                "Others",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19,
                                ),
                              ),
                            ),

                            logoutCard(),
                          ],
                        ),
                      ),

                      // ================= SPACE BETWEEN COLUMNS =================
                      const SizedBox(width: 45),

                      // ================= RIGHT SIDE =================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Appearance




                            const SizedBox(height: 30),

                            // Manage
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                                bottom: 8,
                              ),
                              child: Text(
                                "Manage",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19,
                                ),
                              ),
                            ),

                            nameCard(),

                            const SizedBox(height: 15),

                            privacyCard(),


                          ],
                        ),
                      ),
                    ],
                  ),

              ),
            ),
          ),
        ),
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
      return mobileReminder();
    }
    else if (width < 1050) {
      return tabletReminder();
    }
    else {
      return windowsReminder();
    }
  }

}

class manage extends StatefulWidget{
  @override
  State<manage> createState() => _manageState();
}

class _manageState extends State<manage> {
  TextEditingController editName = TextEditingController();
  TextEditingController current = TextEditingController();
  TextEditingController New = TextEditingController();
  TextEditingController confirm = TextEditingController();


  //functions
  Future<void> nameDialog()async{
    editName.text = await userService.getUserName();
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Edit"),
        content: TextField(
          controller: editName,
          decoration: const InputDecoration(
              hintText: "Enter new name"
          ),
        ),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
          },
              child: Text(
                "Cancel", style: TextStyle(color: Colors.grey),)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white),

              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;
                final newName = editName.text.trim();
                if (newName.isEmpty) return;
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .update({
                  "name": newName,
                });

                setState(() {});
                editName.clear();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              }, child: Text("Save"))
        ],

      );
    }


    );
  }

  void changePassword(){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Change Password"),
        content: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              controller: current,
              decoration: const InputDecoration(
                  hintText: "Current password"
              ),
            ),
            TextField(
              obscureText: true,
              controller: New,
              decoration: const InputDecoration(
                  hintText: "New password"
              ),
            ),
            TextField(
              obscureText: true,
              controller: confirm,
              decoration: const InputDecoration(
                  hintText: "Confirm password"
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text(
            "Cancel", style: TextStyle(color: Colors.grey),)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white),
              onPressed: () async {
                //password change ka procedure
                final currentPassword = current.text.trim();
                final NewPassword = New.text.trim();
                final confirmPassword = confirm.text.trim();

                if (currentPassword.isEmpty ||
                    NewPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          "Fill al required blanks")));
                  return;
                }
                if (NewPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          "New passwords not match")));
                  return;
                }
                if (NewPassword.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          "Password must be at least 6 characters")));
                  return;
                }
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null || user.email == null) {
                    return;
                  }
                  final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: currentPassword);
                  await user.reauthenticateWithCredential(
                      credential);

                  await user.updatePassword(NewPassword);

                  current.clear();
                  New.clear();
                  confirm.clear();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                            "Password changed successfully")));
                  }
                }
                on FirebaseAuthException catch (e) {
                  String message = "Something is went wrong";
                  if (e.code == "wrong-password" ||
                      e.code == "invalid-credential") {
                    message = "Current Password is wrong";
                  }
                  else if (e.code == "weak-password") {
                    message = "Password is to weak";
                  }
                  else if (e.code == "requires-recent-login") {
                    message =
                    "Please login again to check new password";
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)));
                  }
                }
              },


              child: Text("Save"))
        ],
      );
    });
  }
 //changing
  Widget changeNameCard(){
    return
    InkWell(
      onTap: (){
        nameDialog();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        padding: EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(
              offset: Offset(2, 4),
              color: Colors.grey,
              blurRadius: 5,
              spreadRadius: 1,
            )
            ]
        ),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.person, color: Colors.black,),
                Text("Change Name", style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500),),
                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors
                    .black,)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text("Change your name", style: TextStyle(
                  color: Colors.grey),),
            )
          ],),

      ),
    );
  }
  Widget changePasswordCard(){
    return
    InkWell(
      onTap: (){
        changePassword();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        padding: EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(
              offset: Offset(2, 4),
              color: Colors.grey,
              blurRadius: 5,
              spreadRadius: 1,
            )
            ]
        ),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.person, color: Colors.black,),
                Text("Change Password", style: TextStyle(color: Colors
                    .black, fontWeight: FontWeight.w500),),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded, color: Colors.black,)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text("Update your Password",
                style: TextStyle(color: Colors.grey),),
            )
          ],),
      ),
    );
  }

  /////////////////////////////////
  //responsive notifications
  ////////////////////////////////
Widget mobileReminder(){
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xff263b84),

      iconTheme: const IconThemeData(color: Colors.white),
      title: Text("Manage your account",style: TextStyle(color: Colors.white,fontSize: 23),),),
    body: Container(
      padding: EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 40),
      child: Column(
        children: [
         
          Padding(
            padding: const EdgeInsets.only(top: 70,bottom: 30),
            child: changeNameCard(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: changePasswordCard(),
          ),
          Spacer(),
          Text("Version 1.0.1",style: TextStyle(fontSize: 18),)
        ],
      ),
    ),
    
  );
}
Widget tabletReminder(){
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xff263b84),

      iconTheme: const IconThemeData(color: Colors.white),
      title: Text("Manage your account",style: TextStyle(color: Colors.white,fontSize: 25),),),
    body: Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.only(top: 200,bottom: 30,left: 50,right: 50),
            child:changeNameCard(),

          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 90,left: 50,right: 50),
            child: changePasswordCard(),
          ),
          Spacer(),
          Text("Version 1.0.1",style: TextStyle(fontSize: 25),)
        ],
      ),
    ),

  );
}
  Widget windowsReminder(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff263b84),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Manage your account",style: TextStyle(fontSize: 25,color: Colors.white),),),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 15),
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.only(top:100,bottom: 30,left: 400,right: 400),
              child: changeNameCard(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 90,left: 400,right: 400),
              child: changePasswordCard(),
            ),
            Spacer(),
            Text("Version 1.0.1",style: TextStyle(fontSize: 23),)
          ],
        ),
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
      return mobileReminder();
    }
    else if (width < 1050) {
      return tabletReminder();
    }
    else {
      return windowsReminder();
    }
  }

}

class Reminder extends StatefulWidget{
  const Reminder({super.key});
  @override
  State<Reminder> createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  bool reminderenabled = false;
  String repeatType = "Every Day";

  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

  //days
  final List<String>days = [
    "Mon",
    "Tue",
    "Wed",
    "Thur",
    "Fri",
    "Sat",
    "Sun",
  ];
  final Set<String> selectedDays = {};
  Future<void> loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedDays =
        prefs.getStringList("reminderDays") ?? [];

    if (!mounted) return;

    setState(() {
      reminderenabled =
          prefs.getBool("reminderEnabled") ?? false;

      repeatType =
          prefs.getString("repeatType") ?? "Every Day";

      final hour = prefs.getInt("reminderHour");
      final minute = prefs.getInt("reminderMinute");

      if (hour != null && minute != null) {
        selectedTime = TimeOfDay(
          hour: hour,
          minute: minute,
        );
      }

      selectedDays
        ..clear()
        ..addAll(savedDays);
    });
  }

  Future<void> changeReminderStatus(bool value) async {
    setState(() {
      reminderenabled = value;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("reminderEnabled", value);

    if (!value) {
      await NotificationService.cancelReminders();
    }
  }

  Future <void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
        context: context, initialTime: selectedTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String get formatedTime {
    return selectedTime.format(context);
  }
  @override
  void initState() {
    super.initState();
    loadReminderSettings();
  }


  Widget mobileReminder() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff263b84),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Reminder Notification",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // REMINDER SWITCH
            // =========================

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),

                secondary: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.blue,
                  ),
                ),

                title: const Text(
                  "Attendance Reminder",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                subtitle: const Text(
                  "Get notified when it's time to mark attendance",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                value: reminderenabled,

                // AUR YAHAN
                onChanged: changeReminderStatus,


              ),
            ),

            // =========================
            // REMINDER TIME
            // =========================

            const Padding(
              padding: EdgeInsets.only(
                top: 35,
                bottom: 15,
              ),
              child: Text(
                "Reminder Time",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            InkWell(
              onTap: reminderenabled ? selectTime : null,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [

                    Icon(
                      Icons.access_time_rounded,
                      color: reminderenabled
                          ? Colors.blue
                          : Colors.grey,
                    ),

                    const SizedBox(width: 14),

                    Text(
                      formatedTime,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: reminderenabled
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),

                    const Spacer(),

                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: reminderenabled
                          ? Colors.black54
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            // =========================
            // REPEAT
            // =========================

            const Padding(
              padding: EdgeInsets.only(
                top: 30,
                bottom: 12,
              ),
              child: Text(
                "Repeat",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [

                  // EVERY DAY

                  RadioListTile<String>(
                    value: "Every Day",
                    groupValue: repeatType,

                    activeColor: const Color(0xff263b84),

                    onChanged: reminderenabled
                        ? (value) {
                      setState(() {
                        repeatType = value!;
                      });
                    }
                        : null,

                    title: const Text(
                      "Every Day",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: const Text(
                      "Send reminder every day",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),

                  // SELECTED DAYS

                  RadioListTile<String>(
                    value: "Selected Days",
                    groupValue: repeatType,

                    activeColor: const Color(0xff263b84),

                    onChanged: reminderenabled
                        ? (value) {
                      setState(() {
                        repeatType = value!;
                      });
                    }
                        : null,

                    title: const Text(
                      "Selected Days",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: const Text(
                      "Choose specific days",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // SELECTED DAYS
            // =========================

            if (repeatType == "Selected Days") ...[

              const Padding(
                padding: EdgeInsets.only(
                  top: 25,
                  bottom: 12,
                ),
                child: Text(
                  "Selected Days",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: days.map((day) {

                  final bool selected =
                  selectedDays.contains(day);

                  return GestureDetector(
                    onTap: reminderenabled
                        ? () {
                      setState(() {
                        if (selected) {
                          selectedDays.remove(day);
                        } else {
                          selectedDays.add(day);
                        }
                      });
                    }
                        : null,

                    child: AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 200),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),

                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xff263b84)
                            : Colors.white,

                        borderRadius:
                        BorderRadius.circular(12),

                        border: Border.all(
                          color: selected
                              ? const Color(0xff263b84)
                              : Colors.grey.shade300,
                        ),
                      ),

                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // =========================
            // SAVE BUTTON
            // IMPORTANT:
            // YE IF KE BAHAR HAI
            // =========================

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(

                onPressed: reminderenabled
                    ? () async {

                  // Selected Days validation
                  if (repeatType == "Selected Days" &&
                      selectedDays.isEmpty) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please select at least one day",
                        ),
                      ),
                    );

                    return;
                  }

                  // Save settings
                  final prefs =
                  await SharedPreferences
                      .getInstance();

                  await prefs.setBool(
                    "reminderEnabled",
                    true,
                  );

                  await prefs.setString(
                    "repeatType",
                    repeatType,
                  );

                  await prefs.setInt(
                    "reminderHour",
                    selectedTime.hour,
                  );

                  await prefs.setInt(
                    "reminderMinute",
                    selectedTime.minute,
                  );

                  await prefs.setStringList(
                    "reminderDays",
                    selectedDays.toList(),
                  );

                  // Schedule notification
                  await NotificationService
                      .sheduleReminder(
                    hour: selectedTime.hour,
                    minute: selectedTime.minute,
                    repeatType: repeatType,
                    selecteddays: selectedDays,
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Reminder settings saved",
                      ),
                    ),
                  );
                }
                    : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xff263b84),

                  foregroundColor: Colors.white,

                  disabledBackgroundColor:
                  Colors.grey.shade300,

                  disabledForegroundColor:
                  Colors.grey.shade500,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),

                child: const Text(
                  "Save Reminder",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


//tablet layout

  Widget tabletReminder() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
        title: Text("Reminder Notification",
          style: TextStyle(fontSize: 25, color: Colors.white),),),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 50,right: 50,top: 40),
                  child: Container(
                    width: double.infinity,
                    child: SwitchListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        secondary: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(13),),
                          child: const Icon(Icons.notifications_active_outlined,
                            color: Colors.blue,size: 30,),
                        ),
                        title: const Text("Attendance Reminder", style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600,),),
                        subtitle: const Text(
                          "Get notified when it's time to mark attendance",
                          style: TextStyle(fontSize: 15, color: Colors.grey,),),
                        value: reminderenabled,
                        onChanged: (value) async {
                          setState(() {
                            reminderenabled = value;
                          });
                          if (!value) {
                            await NotificationService.cancelReminders();
                          }
                        }),

                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top:70, bottom: 50),
                  child: Text("Reminder Time",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),),
                ),
                InkWell(
                  onTap: reminderenabled ? selectTime : null,
                  child: Container(
                    padding: EdgeInsets.all(17),
                    child: Row(
                      spacing: 14,
                      children: [
                        Icon(Icons.access_time_rounded,size: 30,
                          color: reminderenabled ? Colors.blue : Colors.grey,),
                        Text(formatedTime, style: TextStyle(fontSize: 21,
                            fontWeight: FontWeight.w500,
                            color: reminderenabled ? Colors.black87 : Colors
                                .grey),),
                        Icon(Icons.arrow_forward_ios_rounded,size: 30,)
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50,bottom: 50),
                  child: Text("Repeat", style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 20),),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    //reminderenabled?Colors.blue:Colors.grey.shade100,
                    decoration: BoxDecoration(

                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(value: "Every Day",
                          groupValue: repeatType,
                          activeColor: Colors.blue,
                          onChanged: reminderenabled ? (value) {
                            setState(() {
                              repeatType = value!;
                            });
                          } : null,
                          title: Text("Every Day", style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),),
                          subtitle: Text("Send reminder every day",
                            style: TextStyle(fontSize: 17),),
                        ),
                        Divider(
                          height: 10,
                          color: Colors.grey.shade200,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: RadioListTile<String>(value: "Selected Days",
                            groupValue: repeatType,
                            activeColor: Colors.blue,
                            onChanged: reminderenabled ? (value) {
                              setState(() {
                                repeatType = value!;
                              });
                            } : null,
                            title: const Text("Selected Days", style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600,),),
                            subtitle: const Text(
                              "Choose specific days", style: TextStyle(
                              fontSize: 15,),),),
                        ),
                      ],),),
                ),
                if(repeatType == "Selected Days")...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text("Selected Days", style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),),
                  ),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children:
                    days.map((day) {
                      final bool selected = selectedDays.contains(day);
                      return GestureDetector(onTap: reminderenabled ? () {
                        setState(() {
                          if (selected) {
                            selectedDays.remove(day);
                          } else {
                            selectedDays.add(day);
                          }
                        });
                      } : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11,),
                          decoration: BoxDecoration(
                            color: selected ? Colors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? Colors.blue : Colors.grey
                                  .shade300,),),
                          child: Text(day, style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : Colors
                                .black87,),),),);
                    }).toList(),),


                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 80),
                    child: SizedBox(width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: reminderenabled ? () async {
                          await NotificationService.sheduleReminder(
                            hour: selectedTime.hour,
                            minute: selectedTime.minute,
                            repeatType: repeatType,
                            selecteddays: selectedDays,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Reminder settings saved",),),);
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),),),
                        child: const Text("Save Reminder",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight
                              .w600,),),),),
                  ),
                ],
              ]
          ),
        ),
      ),);
  }

//windows
  Widget windowsReminder() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Reminder Notification",
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= LEFT SIDE =================
              Expanded(
                child: Column(
                  children: [

                    // Attendance Reminder
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),

                        secondary: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            color: Colors.blue,
                          ),
                        ),

                        title: const Text(
                          "Attendance Reminder",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        subtitle: const Text(
                          "Get notified when it's time to mark attendance",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        value: reminderenabled,

                        onChanged: (value) async {
                          setState(() {
                            reminderenabled = value;
                          });

                          if (!value) {
                            await NotificationService.cancelReminders();
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Reminder Time
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Reminder Time",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 18),

                          InkWell(
                            onTap: reminderenabled ? selectTime : null,

                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: reminderenabled
                                    ? Colors.blue.withOpacity(0.06)
                                    : Colors.grey.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: reminderenabled
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.grey.shade300,
                                ),
                              ),

                              child: Row(
                                children: [

                                  Icon(
                                    Icons.access_time_rounded,
                                    color: reminderenabled
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),

                                  const SizedBox(width: 14),

                                  Text(
                                    formatedTime,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: reminderenabled
                                          ? Colors.black87
                                          : Colors.grey,
                                    ),
                                  ),

                                  const Spacer(),

                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: reminderenabled
                                        ? Colors.black54
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // SPACE BETWEEN COLUMNS
              const SizedBox(width: 30),

              // ================= RIGHT SIDE =================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Repeat Heading
                    const Padding(
                      padding: EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Text(
                        "Repeat",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Repeat Options
                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Column(
                        children: [

                          // Every Day
                          RadioListTile<String>(
                            value: "Every Day",
                            groupValue: repeatType,
                            activeColor: Colors.blue,

                            onChanged: reminderenabled
                                ? (value) {
                              setState(() {
                                repeatType = value!;
                              });
                            }
                                : null,

                            title: const Text(
                              "Every Day",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            subtitle: const Text(
                              "Send reminder every day",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),

                          Divider(
                            height: 3,
                            color: Colors.grey.shade200,
                          ),

                          // Selected Days
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),

                            child: RadioListTile<String>(
                              value: "Selected Days",
                              groupValue: repeatType,
                              activeColor: Colors.blue,

                              onChanged: reminderenabled
                                  ? (value) {
                                setState(() {
                                  repeatType = value!;
                                });
                              }
                                  : null,

                              title: const Text(
                                "Selected Days",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              subtitle: const Text(
                                "Choose specific days",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================= SELECTED DAYS =================
                    if (repeatType == "Selected Days") ...[
                      const SizedBox(height: 20),

                      const Text(
                        "Selected Days",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 9,
                        runSpacing: 9,

                        children: days.map((day) {
                          final bool selected =
                          selectedDays.contains(day);

                          return GestureDetector(
                            onTap: reminderenabled
                                ? () {
                              setState(() {
                                if (selected) {
                                  selectedDays.remove(day);
                                } else {
                                  selectedDays.add(day);
                                }
                              });
                            }
                                : null,

                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 200,
                              ),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 11,
                              ),

                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.blue
                                    : Colors.white,

                                borderRadius:
                                BorderRadius.circular(12),

                                border: Border.all(
                                  color: selected
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                ),
                              ),

                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // ================= SAVE BUTTON =================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                      ),

                      child: SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton(
                          onPressed: reminderenabled
                              ? () async {
                            await NotificationService
                                .sheduleReminder(
                              hour: selectedTime.hour,
                              minute: selectedTime.minute,
                              repeatType: repeatType,
                              selecteddays: selectedDays,
                            );

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Reminder settings saved",
                                ),
                              ),
                            );
                          }
                              : null,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,

                            disabledBackgroundColor:
                            Colors.grey.shade300,

                            disabledForegroundColor:
                            Colors.grey.shade500,

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),
                          ),

                          child: const Text(
                            "Save Reminder",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    if (width < 600) {
      return mobileReminder();
    }
    else if (width < 1000) {
      return tabletReminder();
    }
    else {
      return windowsReminder();
    }
  }

}
