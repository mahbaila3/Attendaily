import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendaily/employeeDetails.dart';


class SearchPage extends StatefulWidget{
  const SearchPage({super.key,});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchCont=TextEditingController();
  List<Map<String,dynamic>>allEmployees=[];
  List<Map<String,dynamic>>searchResults=[];
  bool isLoading=true;
  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  // function
  Future<void>loadEmployees()async{
    final user=await FirebaseAuth.instance.currentUser;
    if(user==null){
      return;
    }
    try{
      final batchesSnapshot=await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("batches")
          .get();

      List<Map<String,dynamic>>employees=[];
      for(final batchDoc in batchesSnapshot.docs){
        final batchData=batchDoc.data();

        final employeesSnapshot=await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("batches")
        .doc(batchDoc.id)
        .collection("employees")
        .get();

        for (final employeesDoc in employeesSnapshot.docs){
          final employeeData=employeesDoc.data();
          employees.add({
            "employeeDocId": employeesDoc.id,

            "batchId": batchDoc.id,

            "batchName":
            batchData["batchName"]?.toString() ?? "Unknown Batch",

            "urID":
            employeeData["urID"]?.toString() ?? "",

            "name":
            employeeData["name"]?.toString() ?? "Unknown",

            "type":
            employeeData["type"]?.toString() ?? "",

            "phoneNumber":
            employeeData["phoneNumber"]?.toString() ?? "",

            "Rname":
            employeeData["Rname"]?.toString() ?? "",

            "Rnum":
            employeeData["Rnum"]?.toString() ?? "",
          });
        }
      }
      setState(() {

        allEmployees=employees;
        isLoading=false;
      });
    }catch(e){
      setState(() {
        isLoading=false;
      });
    }
  }
  void searchEmployee(String value){
    final query=value.trim().toLowerCase();
    if(query.isEmpty){
      setState(() {
        searchResults=[];
      });
      return;
    }
    setState(() {
      searchResults=allEmployees.where((employee){
        final name=employee["name"]?.toString().toLowerCase() ?? "";
        final urID=employee["urID"]?.toString().toLowerCase() ?? "";
        return name.contains(query) ||
            urID.contains(query);
      }).toList();
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
            backgroundColor: Color(0xff263b84),
        title:  Text("Search Employee",style: TextStyle(fontSize: 23,color: Colors.white,fontWeight: FontWeight.w600),)),
      body: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30,left: 20,right: 20,bottom: 13),
                  child: ConstrainedBox(
                   constraints: BoxConstraints(
                     maxWidth: 600,
                   ),
                    child: TextField(
                      controller: searchCont,
                      onChanged: searchEmployee,
                      decoration: InputDecoration(

                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 17,
                        ),
                        enabledBorder: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey,width: 1),


                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff263b84,),width: 1.5),
                            borderRadius: BorderRadius.circular(14)
                        ),

                        hintText: "Search Name or Emp-001",helperStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchCont.text.isNotEmpty?IconButton(onPressed:(){
                          searchCont.clear();
                          setState(() {
                            searchResults=[];
                          });
                        }, icon: Icon(Icons.clear)):null,


                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                if(isLoading) const CircularProgressIndicator()
                else if (searchCont.text.isEmpty)
                  Center(
                    child: const Text(
                      "Search employee by name or ID",
                    ),
                  )
                else if(searchResults.isEmpty)
                    Center(child: const Text("Employee not found",style: TextStyle(color: Colors.grey),))
                  else Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context,index){
                            final employee=searchResults[index];
                            return  InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            employeeDetails(

                                              urID:
                                              employee["urID"],

                                              employeeDocId:
                                              employee["employeeDocId"],

                                              batchName:
                                              employee["batchName"],

                                              batchId:
                                              employee["batchId"],

                                              name:
                                              employee["name"],

                                              type:
                                              employee["type"],

                                              phoneNumber:
                                              employee["phoneNumber"],

                                              Rname:
                                              employee["Rname"],

                                              Rnum:
                                              employee["Rnum"],)));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10,left: 10,right: 10),
                                child: Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    leading: const Icon(Icons.account_circle),
                                    title: Text(employee["name"],),
                                    subtitle: Text(
                                      "${employee["urID"].toString().isEmpty ? "NO ID" : employee["urID"]} • ${employee["batchName"]}",
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}