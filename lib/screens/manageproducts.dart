import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import './addproducts.dart';
import './editproduct.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import '../models/products.dart';

class ManageProducts extends StatefulWidget {
  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final List<Products> _availableProducts = [];
  final List<Products> _finishedProducts = [];
  bool _showFinishedProduct = false;
  bool _fetchedData = false;

  Future<void> _getAllProducts(BuildContext context) async {
    await databaseReference
        .child('D')
        .child('Products')
        .once()
        .then((DataSnapshot dataSnapshot) {
      Map<dynamic, dynamic> values = dataSnapshot.value;
      values.forEach((key, value) {
        setState(() {
          if (int.tryParse(value['Qty'].toString()) > 0) {
            _availableProducts.add(Products(
                name: key,
                price: value['Price'].toString(),
                qty: value['Qty'].toString()));
          } else {
            _finishedProducts.add(Products(
                name: key,
                price: value['Price'].toString(),
                qty: value['Qty'].toString()));
          }
        });
      });
      setState(() {
        _fetchedData = true;
      });
    }).onError((error, stackTrace) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    });
  }

  @override
  void initState() {
    _getAllProducts(context);
    super.initState();
  }

  void _editProduct(Products product) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditProduct(
                productName: product.name,
                currentPrice: product.price,
                currentQty: product.qty)));
  }

  void _addProduct() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddProducts()));
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add_box_outlined,
        ),
        onPressed: _addProduct,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        shape: CircularNotchedRectangle(),
        notchMargin: 1.0,
        elevation: 5,
        child: new Row(
          children: <Widget>[
            SizedBox(
              height: screenMaxHeight * 0.060,
            ),
          ],
        ),
      ),
      body: !_fetchedData
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text('Please Wait..'))
              ],
            )
          : Column(children: [
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
                            'Available Products',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          )),
                      if (_availableProducts.isNotEmpty)
                        Container(
                          height: screenMaxHeight * .483,
                          child: ListView.builder(
                            itemCount: _availableProducts.length,
                            itemBuilder: (context, index) {
                              return createCartListItem(
                                  index, _availableProducts);
                            },
                          ),
                        ),
                      if (_availableProducts.isEmpty)
                        Container(
                            height: screenMaxHeight * 0.20,
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Image.asset(
                              'assets/images/empty_products.png',
                            )),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Finished Products',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Switch.adaptive(
                                value: _showFinishedProduct,
                                onChanged: (val) {
                                  setState(() {
                                    _showFinishedProduct = val;
                                  });
                                }),
                          ],
                        ),
                      ),
                      if (_showFinishedProduct && _finishedProducts.isNotEmpty)
                        Container(
                          height: screenMaxHeight * .483,
                          child: ListView.builder(
                            itemCount: _finishedProducts.length,
                            itemBuilder: (context, index) {
                              return createCartListItem(
                                  index, _finishedProducts);
                            },
                          ),
                        ),
                      if (_showFinishedProduct && _finishedProducts.isEmpty)
                        FittedBox(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/empty_products.png',
                            )),
                      if (!_showFinishedProduct)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          child: Card(
                              elevation: 3,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: ListTile(
                                    leading: Icon(Icons.info_outline),
                                    title: Text(
                                        'Please Delete/Update Finished Products')),
                              )),
                        ),
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
                          Icons.edit,
                          color: Colors.black,
                          size: 15,
                        ),
                        onPressed: () {
                          _editProduct(list[index]);
                        },
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Theme.of(context).accentColor),
                    ),
                  ))
            ],
          )),
    );
  }
}
