import 'package:flutter/material.dart';
import 'package:inventory_management/widgets/customAppBar.dart';
import 'package:inventory_management/widgets/customButton.dart';
import '../widgets/textfieldDatePicker.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/excelSheet.dart';

class SalesHistory extends StatefulWidget {
  @override
  _SalesHistoryState createState() => _SalesHistoryState();
}

class _SalesHistoryState extends State<SalesHistory> {
  DateTime _fromDate;

  DateTime _toDate;

  DateTime _today = DateTime.now();

  bool isStart = false;

  void getSaleData() {
    List<String> datesList = [];
    String filename = DateFormat('yyyy-MM-dd').format(_fromDate) +
        '__' +
        DateFormat('yyyy-MM-dd').format(_toDate) +
        '__INVOICE_DATA';
    if (_toDate != null && _fromDate != null) {
      if (_toDate.isBefore(_today)) {
        if (_toDate.isAfter(_fromDate)) {
          // getSaleFromDB();
          for (int i = 0; i <= _toDate.difference(_fromDate).inDays; i++) {
            datesList.add(DateFormat('yyyy-MM-dd')
                .format(_fromDate.add(Duration(days: i)))
                .toString());
          }
          getSaleFromDB(datesList, filename, context);
          setState(() {
            isStart = true;
          });
        } else {
          Fluttertoast.showToast(
              msg: 'From cannot be after To!',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg: 'Cannot check future sale!',
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Dates cannot be empty!',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 50),
            child: CustomAppBar(
                title: 'Sales History',
                subtitle: 'View the sales history based on date'),
          ),
          Expanded(
            child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        width: double.infinity,
                        child: Card(
                          elevation: 3,
                          child: Container(
                              padding: EdgeInsets.all(10),
                              child: ListTile(
                                leading: Icon(Icons.info_outline),
                                title:
                                    Text('This requires internet connection'),
                              )),
                        ),
                      ),
                      if (!isStart)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: MyTextFieldDatePicker(
                            labelText: "From (Date)",
                            prefixIcon: Icon(Icons.date_range),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            lastDate: DateTime.now(),
                            firstDate:
                                DateTime.now().subtract(Duration(days: 366)),
                            initialDate:
                                DateTime.now().subtract(Duration(days: 1)),
                            onDateChanged: (selectedDate) {
                              // Do something with the selected date
                              _fromDate = selectedDate;
                            },
                          ),
                        ),
                      if (!isStart)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: MyTextFieldDatePicker(
                            labelText: "To (Date)",
                            prefixIcon: Icon(Icons.date_range),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            lastDate: DateTime.now(),
                            firstDate:
                                DateTime.now().subtract(Duration(days: 366)),
                            initialDate:
                                DateTime.now().subtract(Duration(days: 1)),
                            onDateChanged: (selectedDate) {
                              // Do something with the selected date
                              _toDate = selectedDate;
                            },
                          ),
                        ),
                      if (!isStart)
                        Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: CustomButton(
                              buttonFunction: getSaleData,
                              buttonText: 'Show Data'),
                        ),
                      if (isStart)
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: CircularProgressIndicator(),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Text('Please Wait...'),
                            )
                          ],
                        ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
