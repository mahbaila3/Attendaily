import 'package:attendaily/first.dart';
import 'package:attendaily/login/signup_Page.dart';
import 'package:attendaily/main.dart';
import 'package:attendaily/navigation.dart';
import 'package:attendaily/uiHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class loginPage extends StatefulWidget{
  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  TextEditingController emailcontroller= TextEditingController();

  TextEditingController passcontroller = TextEditingController();
  
  login(String email,String password)async{
    if (email.isEmpty || password.isEmpty){
      return uiHelper.CustomAlertBox(context, "Enter required fields");
    }
    else{
      UserCredential? usercredential;
      try{
        usercredential=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((value){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => navigation(),));
        });
      }
      on FirebaseAuthException catch(ex){
        return uiHelper.CustomAlertBox(context, ex.code.toString());
      }
    }
  }

  Widget mobile(){
    return Container(

      color: Color(0xff263b84),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 35,top:150),
            child: Text("Welcome back" ,style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,fontSize: 30,
            ),),
          ),
          Padding(
            padding: const EdgeInsets.only(top:5,left: 35),
            child: Text(" to Attendaily",style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 18,
            ),),
          ),
          SizedBox(height: 50,),
          Expanded(
            child:   Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                color: Colors.white,
              ),
              child: Container(child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10,top: 20),
                      child: Text("Log In",style: TextStyle(fontSize: 27,fontWeight: FontWeight.w700,color:Color(0xff263b84) ),),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 30,left: 20),
                      child: Text("Email",style: TextStyle(fontSize: 18,color:Colors.black ),),
                    ),
                    uiHelper.CustomTextField(emailcontroller, "Enter your Email", Icons.email, false),

                    Padding(
                      padding: const EdgeInsets.only(top: 20,left: 20),
                      child: Text("Password",style: TextStyle(fontSize: 18,color:Colors.black ),),
                    ),
                    uiHelper.CustomTextField(passcontroller, "Enter  your Password", Icons.password,true),
                    Padding(
                      padding: const EdgeInsets.only(top: 50,bottom: 10,left: 10,right: 10 ),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)
                                ),
                                foregroundColor: Colors.white,backgroundColor: Color(0xff263b84)),
                            onPressed: (){
                              login(emailcontroller.text.toString(), passcontroller.text.toString());
                            }, child: Text("Log In",style: TextStyle(fontSize: 18),)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10,left: 20,right: 20),
                      child: Row(
                        children: [
                          Text("Don't have an account",style: TextStyle(fontSize: 15,color:Colors.grey.shade700 ),),
                          TextButton(onPressed: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>signuppage()));
                          }, child: Text("Sign In",style: TextStyle(fontSize: 15,color: Color(0xff263b84)),))
                        ],
                      ),
                    ),

                  ],
                ),
              ),),
            ),
          ),


        ],
      ),
    );
  }
  Widget tablet(){
    return
    Container(

      color: Color(0xff263b84),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 35,top:150),
            child: Text("Welcome back",style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,fontSize: 50,
            ),),
          ),
          Padding(
            padding: const EdgeInsets.only(top:5,left: 40),
            child: Text("to Attendaily",style: TextStyle(
              color: Colors.grey.shade400,
              fontSize:25,
            ),),
          ),
          SizedBox(height: 60,),
          Expanded(
            child:   Container(
              padding: EdgeInsets.symmetric(horizontal: 50,vertical: 20),
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
                color: Colors.white,
              ),
              child: Center(
                child: ConstrainedBox(

                  constraints: BoxConstraints(
                      maxWidth: 900
                  ),
                  child: Container(child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30,top: 20),
                          child: Text("Log In",style: TextStyle(fontSize: 38,fontWeight: FontWeight.w700,color:Color(0xff263b84) ),),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top:60,left: 100),
                          child: Text("Email",style: TextStyle(fontSize: 25,color:Colors.black ),),
                        ),Padding(
                          padding: const EdgeInsets.symmetric( horizontal:100,vertical: 5),
                          child: Container(
                            child:uiHelper.CustomTextField(emailcontroller, "Enter your Email", Icons.email, false),
                          ),
                        ),


                        Padding(
                          padding: const EdgeInsets.only(top:60,left: 100),
                          child: Text("Password",style: TextStyle(fontSize: 25,color:Colors.black ),),
                        ),Padding(
                          padding: const EdgeInsets.symmetric( horizontal:100,vertical: 5),
                          child: Container(
                            child:uiHelper.CustomTextField(passcontroller, "Enter your password", Icons.password, true),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 80,bottom: 10,left: 90,right:90 ),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    foregroundColor: Colors.white,backgroundColor: Color(0xff263b84)),
                                onPressed: (){
                                  login(emailcontroller.text.toString(), passcontroller.text.toString());
                                }, child: Text("Log In",style: TextStyle(fontSize: 22),)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50,left: 90,right: 20),
                          child: Row(
                            children: [
                              Text("Don't have an account",style: TextStyle(fontSize: 20,color:Colors.grey.shade700 ),),
                              TextButton(onPressed: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>signuppage()));
                              }, child: Text("Sign In",style: TextStyle(fontSize: 17,color: Color(0xff263b84)),))
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),),
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
Widget desktop(){
    return
  Row(
    children: [

      // =========================
      // LEFT SIDE IMAGE
      // =========================

      Expanded(
        child: Container(
          height: 700,
          color: const Color(0xff263b84),

          padding: const EdgeInsets.all(20),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 550,
                maxHeight: 650,
              ),

              child: Image.asset(
                "assets/images/intro2.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),

      // =========================
      // DIVIDER
      // =========================

      Container(
        height: 700,
        width: 1,
        color: Colors.grey.shade400,
      ),

      // =========================
      // RIGHT SIDE
      // =========================

      Expanded(
        child: Container(
          height: 700,
          color: const Color(0xff263b84),

          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              // Title
              const Text(
                "Welcome back to Attendaily!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // WHITE LOGIN CONTAINER
              // =========================

              Expanded(
                child: Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 550,
                      ),

                      child: SingleChildScrollView(
                        physics:
                        const BouncingScrollPhysics(),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 30,
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            // =========================
                            // LOGIN TITLE
                            // =========================

                            const Center(
                              child: Text(
                                "Log In",
                                style: TextStyle(
                                  color: Color(0xff263b84),
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 55),

                            // =========================
                            // EMAIL
                            // =========================

                            const Text(
                              "Email",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              height: 50,
                              child: uiHelper.CustomTextField(
                                emailcontroller,
                                "Enter your email",
                                Icons.email,
                                false,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // =========================
                            // PASSWORD
                            // =========================

                            const Text(
                              "Password",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                                height: 50,
                                child: uiHelper.CustomTextField(passcontroller, "Enter your password", Icons.password, true)
                            ),

                            const SizedBox(height: 45),

                            // =========================
                            // LOGIN BUTTON
                            // =========================

                            SizedBox(
                              height: 50,
                              width: double.infinity,

                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xff263b84),

                                  foregroundColor:
                                  Colors.white,

                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                ),

                                onPressed: () {
                                  login(emailcontroller.text.toString(), passcontroller.text.toString());
                                },

                                child: const Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // =========================
                            // SIGN UP
                            // =========================

                            Center(
                              child: Wrap(
                                alignment:
                                WrapAlignment.center,

                                crossAxisAlignment:
                                WrapCrossAlignment.center,

                                children: [

                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                      Colors.grey.shade700,
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              signuppage(),
                                        ),
                                      );
                                    },

                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                        Color(0xff263b84),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {

return Scaffold(
body: LayoutBuilder(
builder: (context, constraints) {
final width = constraints.maxWidth;

if (width < 600) {
return mobile();
} else if (width < 1050) {
return tablet();
} else {
return desktop();
}
},
),
);
}}