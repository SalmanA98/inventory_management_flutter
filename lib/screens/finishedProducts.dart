import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/products.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';

class FinishedProducts extends StatefulWidget {
  final List<Products> finishedProductsList;
  FinishedProducts(this.finishedProductsList);
  @override
  _FinishedProductsState createState() => _FinishedProductsState();
}

class _FinishedProductsState extends State<FinishedProducts> {
  List<Products> productsCopy = [];

  void _deleteProduct(Products product) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2),
      width: double.infinity,
      buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
      headerAnimationLoop: true,
      useRootNavigator: true,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Confirm Delete',
      desc:
          'Are you sure you want to remove the product: ${product.name}? This cannot be undone once you press \'confirm\'.',
      dismissOnBackKeyPress: true,
      btnCancelOnPress: () {},
      btnOkText: 'Confirm',
      btnOkOnPress: () {
        databaseReference
            .child('D')
            .child('Products')
            .child(product.name)
            .remove()
            .then((_) {
          setState(() {
            widget.finishedProductsList.remove(product);
          });
          Fluttertoast.showToast(
              msg: 'Removed Product Successfully',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1);
        }).onError((error, stacktrace) {
          print('ERROR: ${error.toString()}\nSTACK: $stacktrace');
          Fluttertoast.showToast(
              msg: error.toString(),
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1);
        });
      },
    )..show();
  }

  @override
  void initState() {
    super.initState();
    productsCopy.addAll(widget.finishedProductsList);
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          CustomAppBar(
              title: 'Manage Products', subtitle: 'Manage your products!'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(top: 15),
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: const Text(
                          'Finished Products',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    child: Card(
                      elevation: 3,
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: ListTile(
                            leading: const Icon(Icons.info_outline),
                            subtitle: const Text(
                                'Please remove or update the empty (qty -> 0) products'),
                          )),
                    ),
                  ),
                  if (widget.finishedProductsList.isNotEmpty)
                    Container(
                      height: screenMaxHeight * .60,
                      child: ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        itemCount: widget.finishedProductsList.length,
                        itemBuilder: (context, index) {
                          return CartItem(
                            index: index,
                            list: widget.finishedProductsList,
                            deleteProduct: _deleteProduct,
                          );
                        },
                      ),
                    ),
                  if (widget.finishedProductsList.isEmpty)
                    Container(
                        height: screenMaxHeight * 0.60,
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Image.asset(
                          'assets/images/no_items_found.png',
                        )),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  const CartItem(
      {Key key,
      @required this.index,
      @required this.list,
      @required this.deleteProduct})
      : super(key: key);

  final int index;
  final List<Products> list;
  final Function(Products product) deleteProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Card(
          elevation: 5,
          child: Stack(
            children: <Widget>[
              Container(
                margin:
                    EdgeInsets.only(left: 5, right: 16, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    //    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          color: Colors.blue.shade200,
                          image: DecorationImage(
                              image: AssetImage("assets/images/logo.png"))),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(right: 8, top: 4),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  list[index].name,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      "AED: ${list[index].price}",
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color: Colors.grey,
                                      padding: const EdgeInsets.only(
                                          bottom: 2, right: 12, left: 12),
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          list[index].qty,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      flex: 100,
                    )
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: 15, top: 8),
                    child: Container(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.black,
                          size: 15,
                        ),
                        onPressed: () {
                          deleteProduct(list[index]);
                        },
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Theme.of(context).errorColor),
                    ),
                  ))
            ],
          )),
    );
  }
}
