import 'package:attendaily/batchDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class batchPage extends StatefulWidget{
  @override
  State<batchPage> createState() => _batchPageState();
}

class _batchPageState extends State<batchPage> {
  final TextEditingController searchController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text("Batches",style: TextStyle(color: Colors.white,fontSize: 23),),
        backgroundColor: Color(0xff263b84)),
// body

      body:
      Container(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 700
              ),
              child: Container(
                  padding: EdgeInsets.only(top: 30,bottom: 25,left: 20,right: 20),
                  child:TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Search batches...",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),


                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xff263b84),
                          width: 1.5,
                        ),
                      ),
                    ),
                  )
                  ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('batches')
                    .snapshots(),

                builder: (context, snapshot) {

                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Error
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                      ),
                    );
                  }

                  // No batches
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No batches found"),
                    );
                  }

                //  final batches = snapshot.data!.docs;

                  final allBatches = snapshot.data!.docs;

                  final searchText =
                  searchController.text.toLowerCase().trim();

                  final filteredbatches = allBatches.where((batch) {
                    final batchName =
                    (batch["batchName"] ?? "").toString().toLowerCase();

                    final leaderName =
                    (batch["leaderName"] ?? "").toString().toLowerCase();

                    return batchName.contains(searchText) ||
                        leaderName.contains(searchText);
                  }).toList();

                  if (filteredbatches.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matching batches found",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredbatches.length,

                    itemBuilder: (context, index) {

                      final batch = filteredbatches[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45,vertical: 13),
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => batchDetail(
                              batchId: batch.id,
                            ),));

                          },
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 500
                              ),
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(

                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
                                    child: Row(
                                      spacing: 10,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.account_circle,color: Color(0xff263b84),size: 50,), //0xff263b84
                                       Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text(batch["batchName"],style: TextStyle(color: Colors.black87,fontSize: 18,fontWeight: FontWeight.w900),),
                                           SizedBox(height: 2,),
                                           Text("Leader :${batch["leaderName"]}",style: TextStyle(color: Colors.grey,fontSize: 14,),)
                                         ],
                                       ),
                                       Spacer(),
                                       Icon(Icons.arrow_forward_ios_rounded,color: Colors.black,)

                                       // Text(batch["batchName"],style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w900),),
                                       // Spacer(),
                                        //Text("Leader :${batch["leaderName"]}",style: TextStyle(color: Colors.grey,fontSize: 14),)


                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}