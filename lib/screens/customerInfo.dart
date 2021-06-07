import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../widgets/customAppBar.dart';
import '../models/sellToDb.dart';
import '../models/products.dart';

class CustomerInfo extends StatefulWidget {
  final List<Products> cartProducts;
  final String _username;
  const CustomerInfo(this.cartProducts, this._username);

  @override
  _CustomerInfoState createState() => _CustomerInfoState();
}

class _CustomerInfoState extends State<CustomerInfo> {
  final TextEditingController _customerNameInput = TextEditingController();

  final TextEditingController _customerNumInput = TextEditingController();

  final TextEditingController _discInput = TextEditingController();

  final TextEditingController _employeeIdInput = TextEditingController();

  bool _isCurrentEmployee = false;
  String _vat;
  String _paymentMethod;

  int _valueVat = -1;
  int _valuePM = -1;

  bool _showProgress = false;

  final List<String> _vatList = const ['VAT', 'No VAT'];
  final List<String> _paymentList = const ['Cash', 'Card'];

  void _onVatChoice(int value) {
    switch (value) {
      case -1:
        Fluttertoast.showToast(
            msg: 'Choose VAT/No Vat!',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1);
        break;
      case 0:
        _vat = '5%';
        break;
      case 1:
        _vat = '0%';
        break;
    }
  }

  void _onPaymentChoice(int value) {
    switch (value) {
      case -1:
        Fluttertoast.showToast(
            msg: 'Choose Payment Method!',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1);
        break;
      case 0:
        _paymentMethod = 'Cash';
        break;
      case 1:
        _paymentMethod = 'Card';
        break;
    }
  }

  void _completeSale() {
    String numberPattern = r'(^(?:05)(?:0|5|2|6|8|4)[0-9]{7}$)';
    RegExp regExp = new RegExp(numberPattern);

    if (!_isCurrentEmployee) {
      _employeeIdInput.text = widget._username.toString().toUpperCase();
    }
    if (_customerNameInput.text.isEmpty ||
        _customerNumInput.text.isEmpty ||
        _vat.isEmpty ||
        _paymentMethod.isEmpty ||
        _employeeIdInput.text.isEmpty ||
        _discInput.text.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Fields/Choices cannot be empty!',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    } else if (!regExp.hasMatch(_customerNumInput.text)) {
      Fluttertoast.showToast(
          msg: 'Please enter a valid mobile number! (example: 0501234567)',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1);
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.INFO,
        borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2),
        width: double.infinity,
        buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
        headerAnimationLoop: true,
        useRootNavigator: true,
        animType: AnimType.BOTTOMSLIDE,
        title: 'Confirm Details',
        desc:
            'Are you sure every detail is right? This cannot be undone once you press \'confirm\'.',
        dismissOnBackKeyPress: true,
        btnCancelOnPress: () {},
        btnOkText: 'Confirm',
        btnOkOnPress: () {
          setState(() {
            _showProgress = true;
          });
          var sell = WriteSaleToDb(
              customerName: _customerNameInput.text,
              customerNum: _customerNumInput.text,
              discount: _discInput.text,
              employeeID: _employeeIdInput.text,
              finalItems: widget.cartProducts,
              paymentMethod: _paymentMethod,
              vat: _vat);
          sell.processSale(context);
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
      )..show();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _customerNameInput.dispose();
    _customerNumInput.dispose();
    _discInput.dispose();
    _employeeIdInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _showProgress
            ? null
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: CustomButton(
                  buttonFunction: _completeSale,
                  buttonText: 'Complete Sale',
                ),
              ),
        body: _showProgress
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
                    CustomAppBar(
                      title: 'Final Step',
                      subtitle: 'Enter details & complete sale!',
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => WidgetsBinding
                            .instance.focusManager.primaryFocus
                            ?.unfocus(),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  child: const Text(
                                    'Customer Details',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: CustomTextField(
                                    textController: _customerNameInput,
                                    textHint: 'Customer Name',
                                    textIcon: Icon(Icons.person)),
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: CustomTextField(
                                    textController: _customerNumInput,
                                    textHint: 'Customer Number',
                                    keyboardType: TextInputType.phone,
                                    maximumLength: 10,
                                    textIcon: Icon(Icons.phone)),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.contain,
                                      child: const Text(
                                        'Employee Details',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Switch.adaptive(
                                        value: _isCurrentEmployee,
                                        onChanged: (val) {
                                          setState(() {
                                            _isCurrentEmployee = val;
                                          });
                                        })
                                  ],
                                ),
                              ),
                              if (_isCurrentEmployee)
                                Container(
                                    margin: EdgeInsets.all(10),
                                    child: CustomTextField(
                                        textController: _employeeIdInput,
                                        textHint: 'Employee ID',
                                        maximumLength: 7,
                                        textIcon: Icon(
                                            Icons.person_outline_rounded))),
                              if (!_isCurrentEmployee)
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 3,
                                    child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: ListTile(
                                          leading:
                                              const Icon(Icons.info_outline),
                                          subtitle: const Text(
                                              'Current employee is assumed to be the merchant'),
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
                                    'Payment Details',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: CustomTextField(
                                    textController: _discInput,
                                    textHint: 'Discount',
                                    maximumLength: 2,
                                    keyboardType: TextInputType.number,
                                    textIcon:
                                        Icon(Icons.monetization_on_rounded)),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: double.infinity,
                                padding: EdgeInsets.all(5),
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: const Text(
                                    'Choose VAT:',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Wrap(
                                children: List<Widget>.generate(
                                  2,
                                  (int index) {
                                    return Container(
                                      margin: EdgeInsets.all(5),
                                      child: ChoiceChip(
                                        label: Text(_vatList[index]),
                                        selected: _valueVat == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            _valueVat = selected ? index : -1;
                                          });
                                          _onVatChoice(_valueVat);
                                        },
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: double.infinity,
                                padding: EdgeInsets.all(5),
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: const Text(
                                    'Payment Method:',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Wrap(
                                children: List<Widget>.generate(
                                  2,
                                  (int index) {
                                    return Container(
                                      margin: EdgeInsets.all(5),
                                      child: ChoiceChip(
                                        label: Text(_paymentList[index]),
                                        selected: _valuePM == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            _valuePM = selected ? index : -1;
                                          });
                                          _onPaymentChoice(_valuePM);
                                        },
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
