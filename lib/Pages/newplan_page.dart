import 'package:sim/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sim/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sim/classes/language.dart';
import 'package:sim/classes/language_constants.dart';
import 'package:sim/main.dart';


class NewPlanPage extends StatefulWidget {
  @override
  _NewPlanPageState createState() => _NewPlanPageState();
}

class _NewPlanPageState extends State<NewPlanPage> {
  late double totalAmount = 0 ;
  late double savingPoint = 0 ;
  late double monthlyAllowance= 0;
  late double dailyAllowance = 0;
  late double balance = 0;

  int activeDay = 3;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  bool _isLoading=false; //bool variable created


  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });

    getAllTransactions();
  }

  int daysBetween() {
    DateTime to;
    DateTime from=DateTime.now();
    from = DateTime(from.year, from.month, from.day);
    if (from.day>26)
      to = DateTime(from.year, from.month+1, 26);
    else
      to = DateTime(from.year, from.month, 26);
    return  to.difference(from).inDays;
  }

  getAllTransactions() async{
    setState(() {
      _isLoading=true;
    });
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;


    // get  deposit
    double totalDeposit = 0;
    QuerySnapshot depositSnap = await FirebaseFirestore.instance.collection('Test').where('Type',isEqualTo: 'Deposit').get();

    for (var document in depositSnap.docs) {
      totalDeposit = totalDeposit + int.parse(document['Amount']);
    }


    // get withdrawals
    double totalWithdrawal = 0;
    QuerySnapshot withdrawalSnap = await FirebaseFirestore.instance.collection('Test').where('Type',isEqualTo: 'Withdrawal').get();

    for (var document in withdrawalSnap.docs) {
      totalWithdrawal = totalWithdrawal + int.parse(document['Amount']);
    }

    // total amount cal
    totalAmount = totalDeposit - totalWithdrawal;

////////////////////////////////////////////////////////////////////////////////

    DateTime currentDate = DateTime.now();


    String current27Day = currentDate.day >= 27?'27/${currentDate.month.toString().length == 1?'0'
        +currentDate.month.toString():currentDate.month.toString()}/${currentDate.year}'
        :'27/${(currentDate.month - 1).toString().length == 1?'0'+(currentDate.month - 1).toString():(currentDate.month - 1).toString()}'
        '/${currentDate.year}';


    double income=0;

    QuerySnapshot incomeSnap =
    await FirebaseFirestore.instance.collection('Test').where('Date',isEqualTo: current27Day).where('Type',isEqualTo: 'Deposit').get();

    for (var document in incomeSnap.docs) {
      income = income + int.parse(document['Amount']);
    }



    monthlyAllowance = income * 0.8;
    savingPoint = income * 0.2;

    balance = totalAmount - savingPoint;
    dailyAllowance = balance/daysBetween();


    setState(() {
      _isLoading=false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      body: getBody(),
      appBar: AppBar(
        title: Text(translation(context).my_plan),
        toolbarHeight: 75,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: black,
            fontSize: 19,
            fontWeight: FontWeight.bold
        ),

        automaticallyImplyLeading: false,

        elevation: 0,

      ),

    );


  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    List budget_json = [

      {
        "name": translation(context).monthly,
        "price": monthlyAllowance.toStringAsFixed(2)+translation(context).sar+" SAR",
        "label_percentage": "80%",
        "percentage": 0.8,
        "color": red,
        "load":const CircularProgressIndicator(
          backgroundColor: Colors.black26,
          valueColor: AlwaysStoppedAnimation<Color>(
              primary //<-- SEE HERE
          ),        )
      },
      {
        "name": translation(context).savings,
        "price": savingPoint.toStringAsFixed(2)+translation(context).sar+" SAR",
        "label_percentage": "20%",
        "percentage": 0.2,
        "color": blue,
        "load":const CircularProgressIndicator(
          backgroundColor: Colors.black26,
          valueColor: AlwaysStoppedAnimation<Color>(
              primary //<-- SEE HERE
          ),        )
      },
      {
        "name": translation(context).total,
        "price": totalAmount.toStringAsFixed(2)+translation(context).sar+" SAR",
        "label_percentage": "100%",
        "percentage": 1,
        "color": green,
        "load":const CircularProgressIndicator(
          backgroundColor: Colors.black26,
          valueColor: AlwaysStoppedAnimation<Color>(
              primary //<-- SEE HERE
          ),        )
      },

      {
        "name": translation(context).daily,
        "price": dailyAllowance.toStringAsFixed(2)+translation(context).sar+" SAR",
        "label_percentage": "",
        "percentage": 1,
        "color": white,
        "load":const CircularProgressIndicator(
          backgroundColor: Colors.black26,
          valueColor: AlwaysStoppedAnimation<Color>(
              primary //<-- SEE HERE
          ),        )
      }
    ];



    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(color: grey.withOpacity(0.01), boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.01),

                spreadRadius: 10,
                blurRadius: 3,
                // changes position of shadow
              ),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 30, right: 10, left: 20, bottom: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:  <Widget>[

                      Text(translation(context).this_plan, style: TextStyle( color: Colors.black.withOpacity(0.8),

                          fontSize:16,
                          fontWeight: FontWeight.w400
                      )),
                      SizedBox(
                        height: 0,
                      ),
                    ] ,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
                children: List.generate(budget_json.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: grey.withOpacity(0.01),
                              spreadRadius: 10,
                              blurRadius: 3,
                              // changes position of shadow
                            ),
                          ]),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 25, right: 25, bottom: 20, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              budget_json[index]['name'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xff67727d).withOpacity(0.6)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                Row(
                                  children: [
                                    !_isLoading?
                                    Text(
                                      budget_json[index]['price'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    )
                                        :  budget_json[index]['load'],
                                    SizedBox(
                                      width: 8,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    budget_json[index]['label_percentage'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: Color(0xff67727d).withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Stack(
                              children: [
                                Container(
                                  width: (size.width - 40),
                                  height: 4,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Color(0xff67727d).withOpacity(0.1)),
                                ),
                                Container(
                                  width: (size.width - 40) *
                                      budget_json[index]['percentage'],
                                  height: 4,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: budget_json[index]['color']),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                })),
          )
        ],
      ),
    );
  }
}
