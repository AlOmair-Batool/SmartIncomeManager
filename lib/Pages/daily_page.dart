import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sim/theme/colors.dart';

import '../json/daily_json.dart';
import '../json/day_month.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sim/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:telephony/telephony.dart';
import 'dart:async';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}
class DailyPage extends StatefulWidget {
  @override
  _DailyPageState createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  //messeges retrieving
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  String _message = "";
  final telephony = Telephony.instance;
  List<SmsMessage> messages = <SmsMessage>[];

  //variables needed for printing contents of the messages on the transactions list
  String? message1 = "";
  String? message2 = "";
  String? transactionType = "";
  String? amount="";
  String? date="";
  String? time="";

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
    getAllSMS();

  }
  getAllSMS() async {
    messages = await telephony.getInboxSms(
      // filter: SmsFilter.where(SmsColumn.ADDRESS)
      //     .equals("alinmabank")
    );

    for (var element in messages) {
      print(element.address);
      print(element.body);
      print(element.subject);
    }

    //identification of Alinma messages
    String message1 = "Deposit ATM Amount: 250 SAR Account: **8000 On: 2022-03-14 21:52";
    String message2 = message1.toLowerCase();

    if (message2.contains("withdrawal") || message2.contains("purchase") ||
        message2.contains("debit transfer internal")) {
      transactionType = "Withdrawal";
    }

    else if (message2.contains("deposit") || message2.contains("refund") ||
        message2.contains("credit transfer internal")) {
      transactionType = "Deposit";
    }

    //amount regex
    // var amountReg = RegExp(r'(?<=amount *:?)(.*)(?=sar)');
    var amountReg = RegExp(r'(?<=amount:)(.*)(?=sar)');
    var amountMatch = amountReg.firstMatch(message2);

    //date extraction
    RegExp dateReg = RegExp(r'(\d{4}-\d{2}-\d{2})');
    var dateMatch = dateReg.firstMatch(message2);

    //time extraction
    RegExp timeReg = RegExp(r'(\d{2}:\d{2})');
    var timeMatch = timeReg.firstMatch(message2);

    if (amountMatch != null && dateMatch != null && timeMatch != null) {
      amount = amountMatch.group(0);
      date = dateMatch.group(0);
      time = timeMatch.group(0);
    }
  }




    int activeDay = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      body: getBody(),
    );
  }
  Widget getBody() {

    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: white, boxShadow: [
                BoxShadow(
                  color: grey.withOpacity(0.01),
                  spreadRadius: 10,
                  blurRadius: 3,
                  // changes position of shadow
                ),
              ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 60, right: 20, left: 20, bottom: 25),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Daily Transaction",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: black),
                        ),
                        Icon(AntDesign.search1)
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(days.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                activeDay = index;
                              });
                            },
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 40) / 7,
                              child: Column(
                                children: [
                                  Text(
                                    days[index]['label'],
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: activeDay == index
                                            ? primary
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: activeDay == index
                                                ? primary
                                                : black.withOpacity(0.1))),
                                    child: Center(
                                      child: Text(
                                        days[index]['day'],
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: activeDay == index
                                                ? white
                                                : black),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                  children: List.generate(daily.length, (index) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: (size.width - 40) * 0.7,
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: grey.withOpacity(0.1),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        daily[index]['icon'],
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Container(
                                    width: (size.width - 90) * 0.5,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          //daily[index]['name'],
                                          transactionType.toString(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: black,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          // daily[index]['date'],
                                          date.toString()+" "+time.toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: black.withOpacity(0.5),
                                              fontWeight: FontWeight.w400),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),


                            //money container
                            Container(
                              width: (size.width - 40) * 0.3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    //daily[index]['price'],
                                    amount.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.green),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 65, top: 8),
                          child: Divider(
                            thickness: 0.8,
                          ),
                        )
                      ],
                    );
                  })),
            ),
          ],
        ));
  }
}
