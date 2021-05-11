import 'package:flutter/material.dart';
import 'package:inventory_management/models/employee.dart';
import 'package:inventory_management/widgets/customButton.dart';
import 'package:inventory_management/widgets/customTextField.dart';
import '../models/paymentdetails.dart';
import '../widgets/customAppBar.dart';
import 'package:google_fonts/google_fonts.dart';

class EditEmployee extends StatefulWidget {
  final Employee _employee;
  EditEmployee(this._employee);

  @override
  _EditEmployeeState createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  final List<PaymentDetails> employeeDetails = [];
  final List<PaymentDetails> editable = [];
  final _ageController = TextEditingController();
  final _numberController = TextEditingController();

  void _loadDetails() {
    employeeDetails
        .add(PaymentDetails(title: 'ID', value: widget._employee.id));
    employeeDetails.add(
      PaymentDetails(title: 'Name', value: widget._employee.name),
    );
    editable.add(
      PaymentDetails(title: 'Age', value: widget._employee.age),
    );
    editable.add(
      PaymentDetails(title: 'Number', value: widget._employee.number),
    );
    editable.add(
      PaymentDetails(
          title: 'Admin Privilege', value: widget._employee.adminPriv),
    );
    editable.add(
      PaymentDetails(
          title: 'Location',
          value: widget._employee.id.toString().substring(2, 3)),
    );
  }

  enterDetailsBox(
      String message, TextEditingController controller, String hint) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Details'),
            content: CustomTextField(
                textController: controller,
                textHint: hint,
                keyboardType: TextInputType.number,
                textIcon: Icon(Icons.edit)),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Save Changes'))
            ],
          );
        });
  }

  void _editAttribute(String attribute) {
    if (attribute?.toLowerCase() == 'age') {
      enterDetailsBox('Enter the Age', _ageController, 'Updated Age');
    } else if (attribute?.toLowerCase() == 'admin privilege') {
      print('Admin');
    } else if (attribute?.toLowerCase() == 'number') {
      enterDetailsBox('Enter the Number', _numberController, 'Updated Number');
    } else if (attribute?.toLowerCase() == 'location') {}
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _ageController.dispose();
    _numberController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                  title: 'Edit User',
                  subtitle: 'Update/Remove the user chosen'),
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 15),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Employee Details',
                    style: GoogleFonts.openSans(
                      textStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )),
              ...employeeDetails.map((element) {
                return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              element.title,
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(element.value),
                          ],
                        ),
                        Divider(
                          color: Colors.black,
                        )
                      ],
                    ));
              }),
              ...editable.map((element) {
                return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 15),
                                  child: Text(
                                    element.title,
                                    style: GoogleFonts.openSans(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                InkWell(
                                    onTap: () => _editAttribute(element.title),
                                    child: Icon(Icons.edit)),
                              ],
                            ),
                            Text(element.value),
                          ],
                        ),
                        Divider(
                          color: Colors.black,
                        )
                      ],
                    ));
              }),
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: CustomButton(
                    buttonFunction: () {},
                    buttonText: 'Apply Changes',
                  )),
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CustomButton(
                    buttonFunction: () {},
                    buttonText: 'Delete User',
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
