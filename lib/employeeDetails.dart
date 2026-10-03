 import 'package:attendaily/uiHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class employeeDetails extends StatefulWidget{
  final String urID;
  final String employeeDocId;
  final String batchName;
  final String batchId;
  final String name;
  final String type;
  final String phoneNumber;
  final String Rname;
  final String Rnum;
  const employeeDetails( {
    super.key,
    required this .urID,
    required this.employeeDocId,
    required this .batchName,
    required this.batchId,
    required this.name,
    required this .type,
    required this.phoneNumber,
    required this.Rname,
    required this.Rnum,
});

  @override
  State<employeeDetails> createState() => _employeeDetailsState();
}

class _employeeDetailsState extends State<employeeDetails> {
  String employeeName = "";
  String employeeType = "";
  String employeePhone = "";
  String otherName = "";
  String otherPhone = "";

  @override
  void initState() {
    super.initState();

    employeeName = widget.name;
    employeeType = widget.type;
    employeePhone = widget.phoneNumber;
    otherName = widget.Rname;
    otherPhone = widget.Rnum;
  }
  Future<void> loadEmployee() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("batches")
        .doc(widget.batchId)
        .collection("employees")
        .doc(widget.employeeDocId)
        .get();

    if (doc.exists && mounted) {
      final data = doc.data() as Map<String, dynamic>;

      setState(() {
        employeeName = data["name"] ?? "";
        employeeType = data["type"] ?? "";
        employeePhone = data["phoneNumber"] ?? "";
        otherName = data["Rname"] ?? "";
        otherPhone = data["Rnum"] ?? "";
      });
    }
  }
  Future<String>getTodayAttendance()async{
    final user=FirebaseAuth.instance.currentUser;
    if(user==null){
      return "Not Marked";
    }
    final now=DateTime.now();
    final dateKey="${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final doc =await FirebaseFirestore.instance
    .collection("users")
    .doc(user.uid)
    .collection("batches")
    .doc(widget.batchId)
    .collection("attendance")
    .doc(dateKey)
    .get();
    if (!doc.exists){
      return "Not Marked";
    }
    final data=doc.data();
    if (data==null){
      return "Not Marked";
    }
    return data[widget.employeeDocId]?.toString() ?? "Not Marked";
  }
  Future<void>deleteEmployee()async{
    final user=FirebaseAuth.instance.currentUser;
    if (user==null){
      return;
    }
    try{
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("batches")
          .doc(widget.batchId)
          .collection("employees")
          .doc(widget.employeeDocId)
          .delete();
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Employee deleted successfully")));
        Navigator.pop(context,true);
      }
    }catch (e){
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Employee delete error")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xff243f9e),

    appBar: AppBar(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      backgroundColor: Color(0xff243f9e),title: Text("Employee Detail",style: TextStyle(color: Colors.white ),),),
body: Container(
  decoration: BoxDecoration(
    color:Colors.white,
    borderRadius:BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
  ),
  child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          padding: EdgeInsets.only(top: 15,right: 15,left: 15,bottom: 7),
          child: Row(
            children: [
              Icon(Icons.account_circle,size: 80,color: Color(0xff344da6),),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text(employeeName,style: TextStyle(color: Colors.indigo.shade900,fontWeight: FontWeight.w700,fontSize: 26),),
                  Row(


                    children: [
                      Text( widget.urID.isEmpty ? "NO ID" : widget.urID,style: TextStyle(color: Colors.grey,fontSize: 15),),
                      SizedBox(width: 20,),
                      Container(
                        width: 1 ,
                        height: 25,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(width: 20,),
                      Text(employeeType,style: TextStyle(color:Colors.grey,fontSize: 15),)
                    ],
                  )
                ],
              ),
              Spacer(),
              IconButton(onPressed: (){
                showModalBottomSheet(context: context, builder: (context){
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min ,
                      children: [
                         Container(
                             width: double.infinity,
                             child: TextButton(onPressed: ()async{
                                final result=await Navigator.push(context, MaterialPageRoute(builder: (context) =>Edit(
                                 batchId: widget.batchId ,
                                 employeeId: widget.employeeDocId,
                               ),));
                               if (result == true) {
                                 await loadEmployee();
                               }
                             }, child: Text("Edit",style: TextStyle(fontSize: 20),),)
                           ),
                        Container(
                          width: double.infinity,
                          child: TextButton(onPressed: ()async{
                            final confirm=await showDialog<bool>(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    title:const Text("Delete Employee"),
                                    content:  Text("Are you sure to delete $employeeName?"),
                                    actions: [
                                      TextButton(onPressed: (){
                                        Navigator.pop(context,false);
                                      }, child: Text("Cancel")),
                                      TextButton(onPressed: (){
                                        Navigator.pop(context,true);
                                      }, child: Text("Delete",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w500),))
                                    ],
                                  );
                                });
                             if(confirm==true){
                               await deleteEmployee();
                             }


                          }, child: Text("Delete",style: TextStyle(fontSize: 20,color: Colors.red),),)
                        ),
                    
                      ],
                    ),
                  );
                });
              }, icon: Icon(Icons.edit,color: Colors.blue.shade900,size: 28,))
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Container(height:0.9,width: double.infinity,color: Colors.grey.shade300,),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13,vertical: 10),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text("Information",style: TextStyle(color: Colors.black87,fontSize: 18,fontWeight: FontWeight.w700),),
              ),
               Row(
                 spacing: 15,
                 children: [
                   Icon(Icons.phone,color: Colors.grey,),
                   Text(employeePhone,style: TextStyle(color: Colors.grey,),)
                 ],
               ),
              Row(
                spacing: 15,
                children: [
                  Icon(Icons.work,color: Colors.grey,),
                  Text(widget.type,style: TextStyle(color: Colors.grey,),)
                ],
              ),
              Row(
                spacing: 15,
                children: [
                  Icon(Icons.batch_prediction,color: Colors.grey,),
                  Text("Batch : ${widget.batchName}",style: TextStyle(color: Colors.grey,),),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text("Other Contact",style: TextStyle(color: Colors.black87,fontSize: 18,fontWeight: FontWeight.w700),),
              ),
              Row(
                spacing: 15,
                children: [
                  Icon(Icons.person,color: Colors.grey,),
                  Text(otherName,style: TextStyle(color: Colors.grey,),),
                ],
              ),
              Row(
                spacing: 15,
                children: [
                  Icon(Icons.phone,color: Colors.grey,),
                  Text(otherPhone,style: TextStyle(color: Colors.grey,),),
                ],
              ),
              Center(child: Padding(
                padding: const EdgeInsets.only(top: 10,bottom: 20),
                child: Text("Today's Attendance",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w700),),
              )),
              
              FutureBuilder<String>(
                  future: getTodayAttendance(),
                  builder: (context,snapshot){
                    print("FUTURE BUILDER CALLED");
                    print("Status: ${snapshot.data}");
                    print("Error: ${snapshot.error}");
                    if (snapshot.connectionState==ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator());
                    }
                    final status=snapshot.data;
                    if (status=="Present"){
                      return  Row(
                        spacing: 9,
                        children: [
                          Container(width: 20,height: 20,decoration: BoxDecoration(color: Colors.green.shade800,shape: BoxShape.circle),),
                          Text("Present",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                        ],
                      );
                    }
                    if (status=="Absent"){
                      return  Row(
                        spacing: 9,
                        children: [
                          Container(width: 20,height: 20,decoration: BoxDecoration(color: Colors.red.shade800,shape: BoxShape.circle),),
                          Text("Absent",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                        ],
                      );
                    }
                    return  Row(
                      spacing: 9,
                      children: [
                        Container(width: 20,height: 20,decoration: BoxDecoration(color: Colors.grey,shape: BoxShape.circle),),
                        Text("Not Marked",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                      ],
                    );
                  }),
              
              


            ],
          )

        ),
      )

    ],
  ),
)
  );
  }
}

class Edit extends StatefulWidget{
  final String batchId;
  final String employeeId;

  const Edit({
    super.key,
    required this.batchId,
    required this.employeeId,
});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  TextEditingController Ename=TextEditingController();

  TextEditingController Etype=TextEditingController();

  TextEditingController Eph=TextEditingController();

  TextEditingController Oname=TextEditingController();

  TextEditingController Oph=TextEditingController();
  bool isLoading=true;
  bool isSaving=false;

@override
  void initState() {
    super.initState();
    loadEmployee();
  }
  Future<void>loadEmployee ()async{                                           ///load function
  final user= FirebaseAuth.instance.currentUser;
  if(user==null){
    return;
  }
  try {
    final doc =await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("batches")
        .doc(widget.batchId)
        .collection("employees")
        .doc(widget.employeeId)
        .get();
    if (doc.exists){
      final  data=doc.data()as Map<String,dynamic>;
      Ename.text=data ["name"]??"";
      Etype.text=data ["type"]??"";
      Eph.text=data ["phoneNumber"]??"";
      Oname.text=data ["Rname"]??"";
      Oph.text=data ["Rnum"]??"";

    }
  }
  catch (e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading employee")));
      }
  }
  finally{
    if(mounted){
      setState(() {
        isLoading=false;
      });
    }
  }
  }
  Future<void>updateEmployee()async{                                                 //update employee
  final  user=FirebaseAuth.instance.currentUser;
  if (user==null){
    return;
  }
  if(Ename.text.trim().isEmpty){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Employee name is required")));
    return;
  }
  setState(() {
    isSaving=true;
  });
  try {await FirebaseFirestore .instance
  .collection("users")
  .doc(user.uid)
  .collection("batches")
  .doc(widget.batchId)
  .collection("employees")
  .doc(widget.employeeId)
  .update({
    "name":Ename.text.trim(),
    "type":Etype.text.trim(),
    "phoneNumber":Eph.text.trim(),
    "Rname":Oname.text.trim(),
    "Rnum":Oph.text.trim(),
  });
  if (mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Employee update Successfully")));
    Navigator.pop(context,true);
  }
}
  catch (e){
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating employee")));
    }
  }
  finally {
    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }
  }
  @override
  void dispose() {
    Ename.dispose();
    Etype.dispose();
    Eph.dispose();
    Oname.dispose();
    Oph.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(

        title: Text("Edit Employee",style: TextStyle(fontWeight: FontWeight.bold),)),
    body: isLoading?Center(
    child: CircularProgressIndicator()):
    SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        child: Column(
            children: [
        Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          //  padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              spacing: 30,

              children: [
                uiHelper.CustomTextField(Ename,"Enter new name", Icons.edit, false),//employee type
                uiHelper.CustomTextField(Etype, "Enter new type", Icons.edit, false),//employee type

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [BoxShadow(
                            offset: Offset(2, 4),
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 1
                        )]

                    ),
                    child: IntlPhoneField(
                        keyboardType: TextInputType.number,
                        controller: Eph,                  //employee phone number
                        initialCountryCode: "Pk",

                        decoration: InputDecoration(
                            hintText: "Enter new phone ",
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
                Text("Change other contact",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700,fontSize: 20),),
                uiHelper.CustomTextField(Oname,"Enter new name", Icons.edit, false),   //other name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [BoxShadow(
                            offset: Offset(2, 4),
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 1
                        )]

                    ),
                    child: IntlPhoneField(
                        keyboardType: TextInputType.number,
                        controller: Oph,                     //other phone number
                        initialCountryCode: "Pk",

                        decoration: InputDecoration(
                            hintText: "Enter new phone ",
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

              ],
            )
        ),
      ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100,vertical: 60),
          child:
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xff243f9e),
                ),
                onPressed:
                isSaving ? null : updateEmployee,
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
 ),
 );
 }}