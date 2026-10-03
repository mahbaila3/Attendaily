import 'package:attendaily/login/login_Page.dart';
import 'package:attendaily/login/signup_Page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
class onBoard extends StatefulWidget{
  @override
  State<onBoard> createState() => _onBoardState();
}

class _onBoardState extends State<onBoard> {
  PageController pageController=PageController();

  bool onLast=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //pages
          PageView(
            onPageChanged: (index){
             setState(() {
               onLast=(index==2);
             });
            },
            controller: pageController,
            children: [
              Intro1(),
              Intro2(),
              Intro3(),


            ],
          ),
          //dot indicators
        Container(
            alignment: Alignment(0, 0.90),

            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: (){
                      pageController.jumpToPage(2);
                    },
                    child: Text("Skip")),
                SmoothPageIndicator(controller: pageController, count: 3),

                onLast?
    GestureDetector(

    onTap: (){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Intro4(),));
    },
    child: Text("Done"),):
                GestureDetector(
                    onTap: (){
                      pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                    },
                    child: Text("Next")),
              ],
            ))

        ],
      )
    );
  }
}
//1 page
class Intro1 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  body: Container(
    color: Colors.white,
    child: Column(

      spacing: 25,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 100,left: 40,right: 40),
          child: Container(

              height:300,
              width: double.infinity,
              child:Image.asset("assets/images/intro1.jpg",
              fit: BoxFit.contain,)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Text("Track your attendance", style:  TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.bold),),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right:  20,bottom: 10),
          child: Text("Keep track of your team's attendance without\nthe hassle of paper work.Mark employees as\npresent or absent and keep their daily records\n                      organized in one place.",
            style:TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 14) ,),
        )

      ],
    ),
  ),
  );
  }
}

//2 page
class Intro2 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
body: Container(
  width: double.infinity,
  padding: EdgeInsets.all(15),
  color: Colors.white,
  child: Column(

    spacing: 25,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 100,left: 40,right: 40),
        child: Container(
               color: Colors.white,
            height:300,
            width: double.infinity,
            child:Image.asset("assets/images/intro2.png",fit: BoxFit.contain,)),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Text("Manage your team", style:  TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.bold),),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 7),
        child: Text("Create batches, add employees,and keep all\n your team members organized.Everything \n  you need to manage your teams is right \n                     where you need it.",
          style:TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 14) ,),
      )

    ],
  ),
),
    );
  }
}
// 3 page
class Intro3 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
body: Container(
  color: Colors.white,
  child: Column(

    spacing: 25,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 100,left: 40,right: 40),
        child: Container(

            height:300,
            width: double.infinity,
            child:Image.asset("assets/images/intro3.jpg")),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Text("History & Reports", style:  TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.bold),),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 7),
        child: Text("View your attendance history, check daily records,\n   and generate PDF reports whenever you need\n       them. Keep your attendance information \n                 organized and easy to access.",
          style:TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 14) ,),
      ),


    ],
  ),
),
    );
  }
}
//intro 4
class Intro4 extends StatefulWidget{
  @override
  State<Intro4> createState() => _Intro4State();
}

class _Intro4State extends State<Intro4> {
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      "onboardingDone",
      true,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 25,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100,left: 40,right: 40,bottom: 40),
                child: Container(

                    height:250,
                    width: double.infinity,
                    child:Image.asset("assets/images/intro4.jpg")),
              ),
               Expanded(
                 child: Container(
                    width: double.infinity,

                    padding: EdgeInsets.only(top: 20,bottom: 15),
                    decoration: BoxDecoration(
                       borderRadius: BorderRadius.only(topRight: Radius.circular(27),topLeft: Radius.circular(27)),
                      color: Color(0xff263b84),

                    ),
                    child: Column(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(child: Column(
                          children: [
                            Text("Welcome",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w900,fontSize: 33),),
                            SizedBox(height: 10,),
                            Text("Log in to your existing account or create a\nnew one to unlock seamless attendance \n  tracking. Effortlessly  with Attendaily.",
                              style: TextStyle(
                                color: Colors.grey.shade100,
                              ),),
                          ],
                        )),



                            Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                                  children: [
                                 Container(
                                height:50,
                                   width: 120,

                                   child: ElevatedButton(

                                                            style: ElevatedButton.styleFrom(

                                                              shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)
                                                              ),
                                                              backgroundColor: Colors.white,
                                                            ),
                                              onPressed: ()async{
                                                              await completeOnboarding();
                                                              if(!mounted)return;
                                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>loginPage()));

                                              }, child: Text("Log IN",style: TextStyle(
                                       fontSize: 16,
                                       fontWeight: FontWeight.w900,
                                       color: Color(0xff263b84)),)),
                                 ),

                                     Container(
                                       width: 120,
                                       height: 50,
                                       child: OutlinedButton(

                                           style: OutlinedButton.styleFrom(
                                             side: const BorderSide(color: Colors.white,width: 2),
                                             shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius.circular(20)
                                             ),
                                             foregroundColor: Colors.white

                                           ),

                                           onPressed: ()async{
                                             await completeOnboarding();
                                             if(!mounted)return;
                                             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>signuppage()));
                                           },
                                           child: Text("Sign Up",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 16),)),
                                     )


                                  ],
                                ),



                      ],
                    ),
                  ),
               ),


            ],
          ),
        ),

    );
  }
}
