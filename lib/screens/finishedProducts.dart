import 'package:flutter/material.dart';
import '../models/products.dart';
import '../widgets/customAppBar.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/database.dart';
import '../widgets/cart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FinishedProducts extends StatefulWidget {
  final List<Products> finishedProductsList;
  FinishedProducts(this.finishedProductsList);
  @override
  _FinishedProductsState createState() => _FinishedProductsState();
}

class _FinishedProductsState extends State<FinishedProducts> {
  List<Products> productsCopy = [];

  void _deleteProduct(String productName) {
    databaseReference
        .child('D')
        .child('Products')
        .child(productName)
        .remove()
        .then((_) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed Product Successfully!'),
        ),
      );
    }).onError((error, stacktrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    });
  }

  @override
  void initState() {
    productsCopy.addAll(widget.finishedProductsList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(children: [
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
                    child: Text(
                      'Finished Products',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    )),
                if (widget.finishedProductsList.isNotEmpty)
                  Container(
                    height: screenMaxHeight * .70,
                    child: ListView.builder(
                      padding: EdgeInsets.all(0.0),
                      itemCount: widget.finishedProductsList.length,
                      itemBuilder: (context, index) {
                        return createCartListItem(
                            index, widget.finishedProductsList);
                      },
                    ),
                  ),
                if (widget.finishedProductsList.isEmpty)
                  Container(
                      height: screenMaxHeight * 0.20,
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Image.asset(
                        'assets/images/empty_products.png',
                      )),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  createCartListItem(int index, List<Products> list) {
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
                              child: Text(
                                list[index].name,
                                style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold)),
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "AED: ${list[index].price}",
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color: Colors.grey,
                                      padding: const EdgeInsets.only(
                                          bottom: 2, right: 12, left: 12),
                                      child: Text(
                                        list[index].qty,
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
                          _deleteProduct(
                              widget.finishedProductsList[index].name);
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
