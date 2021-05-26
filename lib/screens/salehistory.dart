import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import '../widgets/customAppBar.dart';
import '../widgets/customButton.dart';
import '../widgets/textfieldDatePicker.dart';
import '../models/excelSheet.dart';
import '../models/database.dart';

class SalesHistory extends StatefulWidget {
  @override
  _SalesHistoryState createState() => _SalesHistoryState();
}

class _SalesHistoryState extends State<SalesHistory> {
  DateTime _fromDate;

  DateTime _toDate;

  DateTime _today = DateTime.now();

  bool _isStart = false;

  List<String> _locations = [];

  int _locationChipChoice = -1;

  String _shopLocation;

  bool _fetchedLocations = false;

  void _getSaleData() {
    List<String> datesList = [];

    if (_toDate != null && _fromDate != null && _shopLocation != null) {
      if (_toDate.isBefore(_today)) {
        if (_toDate.isAfter(_fromDate)) {
          String filename = DateFormat('yyyy-MM-dd').format(_fromDate) +
              '__' +
              DateFormat('yyyy-MM-dd').format(_toDate) +
              '__INVOICE_DATA';
          showDialog(
              context: context,
              builder: (_) => NetworkGiffyDialog(
                    image: Image.asset('assets/images/logo.png'),
                    title: Text('Confirm Dates?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.w600)),
                    description: Text(
                      'This cannot be undone.\nThis requires internet connection. Are you sure?',
                      textAlign: TextAlign.center,
                    ),
                    entryAnimation: EntryAnimation.BOTTOM_LEFT,
                    onOkButtonPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(context);

                      for (int i = 0;
                          i <= _toDate.difference(_fromDate).inDays;
                          i++) {
                        datesList.add(DateFormat('yyyy-MM-dd')
                            .format(_fromDate.add(Duration(days: i)))
                            .toString());
                      }
                      getSaleFromDB(
                          datesList, filename, context, _shopLocation);
                      setState(() {
                        _isStart = true;
                      });
                    },
                    onCancelButtonPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(context);
                    },
                  ));
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
          msg: 'Fields cannot be empty!',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }
  }

  void _onLocationChanged(String locationChosen, int choice) {
    if (choice != -1) {
      _shopLocation = locationChosen.substring(0, 1).toUpperCase();
      print(_shopLocation);
    } else {
      Fluttertoast.showToast(
          msg: 'Location cannot be empty!',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  Future<void> _getAllLocations() async {
    await databaseReference.child('Locations').once().then((datasnapshot) {
      if (datasnapshot.value != null) {
        List<dynamic> values = datasnapshot.value;
        values.forEach((element) {
          if (element != null) {
            _locations.add(element.toString());
          }
        });
      }
      setState(() {
        _fetchedLocations = true;
      });
      // print(datasnapshot.value);
    }).catchError((errorMessage) {
      Fluttertoast.showToast(
          msg: errorMessage.toString(),
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    });
  }

  @override
  void initState() {
    super.initState();
    _getAllLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_fetchedLocations
          ? SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: FittedBox(
                          fit: BoxFit.contain,
                          child: const Text('Please Wait..')))
                ],
              ),
            )
          : SafeArea(
              child: Column(
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
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                width: double.infinity,
                                child: Card(
                                  elevation: 3,
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: ListTile(
                                        leading: const Icon(Icons.info_outline),
                                        title: const Text(
                                            'This requires internet connection'),
                                      )),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: const Text(
                                    'Date',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              if (!_isStart)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: MyTextFieldDatePicker(
                                    labelText: "From (Date)",
                                    prefixIcon: Icon(Icons.date_range),
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                    lastDate: DateTime.now(),
                                    firstDate: DateTime.now()
                                        .subtract(Duration(days: 366)),
                                    initialDate: DateTime.now()
                                        .subtract(Duration(days: 1)),
                                    onDateChanged: (selectedDate) {
                                      // Do something with the selected date
                                      _fromDate = selectedDate;
                                    },
                                  ),
                                ),
                              if (!_isStart)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: MyTextFieldDatePicker(
                                    labelText: "To (Date)",
                                    prefixIcon: Icon(Icons.date_range),
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                    lastDate: DateTime.now(),
                                    firstDate: DateTime.now()
                                        .subtract(Duration(days: 366)),
                                    initialDate: DateTime.now()
                                        .subtract(Duration(days: 1)),
                                    onDateChanged: (selectedDate) {
                                      // Do something with the selected date
                                      _toDate = selectedDate;
                                    },
                                  ),
                                ),
                              Container(
                                  margin: EdgeInsets.only(top: 10),
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: const Text(
                                        'Location',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ))),
                              Wrap(
                                children: List<Widget>.generate(
                                  _locations.isNotEmpty ? _locations.length : 0,
                                  (int index) {
                                    return Container(
                                      margin: EdgeInsets.all(5),
                                      child: ChoiceChip(
                                        label: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(_locations[index])),
                                        selected: _locationChipChoice == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            _locationChipChoice =
                                                selected ? index : -1;
                                          });
                                          _onLocationChanged(_locations[index],
                                              _locationChipChoice);
                                        },
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                              if (!_isStart)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: CustomButton(
                                      buttonFunction: _getSaleData,
                                      buttonText: 'Show Data'),
                                ),
                              if (_isStart)
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
                                      child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: const Text('Please Wait...')),
                                    )
                                  ],
                                ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            ),
    );
  }
}
