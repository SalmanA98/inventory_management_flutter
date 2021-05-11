import 'package:flutter/material.dart';
import '../models/products.dart';
import '../widgets/customAppBar.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/database.dart';
import '../widgets/cart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SellProducts extends StatefulWidget {
  @override
  _SellProductsState createState() => _SellProductsState();
}

class _SellProductsState extends State<SellProducts> {
  final List<Products> products = [];
  final List<Products> toCart = [];
  int availableQty;

  Future<void> getAllProducts(BuildContext context) async {
    await databaseReference
        .child('D')
        .child('Products')
        .once()
        .then((DataSnapshot dataSnapshot) {
      Map<dynamic, dynamic> values = dataSnapshot.value;
      values.forEach((key, value) {
        setState(() {
          if (int.tryParse(value['Qty'].toString()) > 0) {
            products.add(Products(
                name: key,
                price: value['Price'].toString(),
                qty: value['Qty'].toString()));
          }
        });
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

  void _addItemToCart(Products product) {
    if (!toCart.contains(product)) {
      toCart.add(product);
      Fluttertoast.showToast(
          msg: 'Added ${product.name} to cart!',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }
  }

  showError(String errormessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('SORRY!'),
            content: Text(errormessage),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  void _showCart(List<Products> itemsInCart) {
    if (itemsInCart.isNotEmpty) {
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return SingleChildScrollView(child: Cart(itemsInCart));
          });
    } else {
      showError('Cart is Empty!');
    }
  }

  @override
  void initState() {
    getAllProducts(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.shopping_bag_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          _showCart(toCart);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.indigo,
        shape: CircularNotchedRectangle(),
        notchMargin: 2.0,
        elevation: 5,
        child: new Row(
          children: <Widget>[
            SizedBox(
              height: screenMaxHeight * 0.060,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          CustomAppBar(
            title: 'Sell Products',
            subtitle: 'Add Products to cart!',
          ),
          Container(
            height: screenMaxHeight * .683,
            margin: EdgeInsets.all(9),
            child: ListView.builder(
              itemCount: products.length == null ? 0 : products.length,
              itemBuilder: (context, index) {
                return createCartListItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  createCartListItem(int index) {
    return Card(
        elevation: 5,
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 5, right: 16, top: 10, bottom: 10),
              decoration: BoxDecoration(
                  //color: Colors.white,
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
                        color: Colors.blue,
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
                              products[index].name,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "AED: ${products[index].price}",
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    color: Colors.grey,
                                    padding: const EdgeInsets.only(
                                        bottom: 2, right: 12, left: 12),
                                    child: Text(
                                      products[index].qty,
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
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 15,
                      ),
                      onPressed: () {
                        _addItemToCart(products[index]);
                      },
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: Colors.green),
                  ),
                ))
          ],
        ));
  }
}

// Card(
//                   elevation: 5,
//                   child: Container(
//                     margin: EdgeInsets.all(10),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                           child: FittedBox(child: Text('${(index + 1)}'))),
//                       title: Text(products[index].name),
//                       subtitle: Text(
//                           'Price: ${products[index].price}\nQty Available: ${products[index].qty}'),
//                       trailing: IconButton(
//                         icon: Icon(Icons.add_shopping_cart),
//                         onPressed: () {
//                           _addItemToCart(products[index]);
//                         },
//                       ),
//                     ),
//                   ),
//                 );
