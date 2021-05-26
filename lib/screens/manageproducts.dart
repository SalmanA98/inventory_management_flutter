import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './finishedProducts.dart';
import './addproducts.dart';
import './editproduct.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import '../models/products.dart';

class ManageProducts extends StatefulWidget {
  final String _username;
  const ManageProducts(this._username);
  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final List<Products> _availableProducts = [];
  final List<Products> _finishedProducts = [];
  bool _fetchedData = false;
//For searching
  List<Products> _productsCopy = [];
  bool _showSearchBar = false;
  String _searchText = 'Show';
  TextEditingController _searchController = TextEditingController();

  Future<void> _getAllProducts(BuildContext context) async {
    String _shopLocation;

    if (widget._username.toLowerCase().startsWith('a')) {
      _shopLocation = widget._username.substring(1, 2).toUpperCase();
    } else {
      _shopLocation = widget._username.substring(2, 3).toUpperCase();
    }

    await databaseReference
        .child(_shopLocation)
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
      _productsCopy.addAll(_availableProducts);

      setState(() {
        _fetchedData = true;
      });
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  void _searchInProducts(String searchedProduct) {
    List<Products> dummySearchList = [];
    dummySearchList.addAll(_productsCopy);
    if (searchedProduct.isNotEmpty) {
      List<Products> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.name.toLowerCase().contains(searchedProduct.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _availableProducts.clear();
        _availableProducts.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _availableProducts.clear();
        _availableProducts.addAll(_productsCopy);
      });
    }
  }

  void _editProduct(Products product) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditProduct(
                productName: product.name,
                currentPrice: product.price,
                currentQty: product.qty,
                currentUser: widget._username)));
  }

  void _addProduct() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => AddProducts(widget._username)));
  }

  @override
  void initState() {
    super.initState();
    _getAllProducts(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButtonLocation:
          !_fetchedData ? null : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: !_fetchedData
          ? null
          : FloatingActionButton(
              child: const Icon(
                Icons.add_box_outlined,
              ),
              onPressed: _addProduct,
            ),
      bottomNavigationBar: !_fetchedData
          ? null
          : BottomAppBar(
              color: Theme.of(context).primaryColor,
              shape: CircularNotchedRectangle(),
              notchMargin: 1.0,
              elevation: 5,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).scaffoldBackgroundColor),
                      label: FittedBox(child: Text(_searchText)),
                      icon: Icon(
                        Icons.search_outlined,
                      ),
                      onPressed: () {
                        if (_showSearchBar) {
                          setState(() {
                            _showSearchBar = false;
                            _searchText = 'Show';
                          });
                        } else {
                          setState(() {
                            _showSearchBar = true;
                            _searchText = 'Hide';
                          });
                        }
                      },
                    ),
                  ),
                  Container(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).scaffoldBackgroundColor),
                      label: FittedBox(child: Text('Finished')),
                      icon: Icon(
                        Icons.arrow_forward_outlined,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    FinishedProducts(_finishedProducts)));
                      },
                    ),
                  ),
                ],
              ),
            ),
      body: !_fetchedData
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
                      child: FittedBox(child: Text('Please Wait..')))
                ],
              ),
            )
          : SafeArea(
              child: Column(children: [
                CustomAppBar(
                    title: 'Manage Products',
                    subtitle: 'Manage your products!'),
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
                            child: Text(
                              'Available Products',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (_showSearchBar)
                          Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                  top: 10, right: 10, left: 10, bottom: 5),
                              child: Card(
                                child: new ListTile(
                                  leading: new Icon(Icons.search),
                                  title: new TextField(
                                    controller: _searchController,
                                    decoration: new InputDecoration(
                                        hintText: 'Search',
                                        border: InputBorder.none),
                                    onChanged: (searchedProduct) =>
                                        _searchInProducts(searchedProduct),
                                  ),
                                  trailing: new IconButton(
                                    icon: new Icon(Icons.cancel),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _availableProducts.clear();
                                        _availableProducts
                                            .addAll(_productsCopy);
                                      });
                                      // onSearchTextChanged('');
                                    },
                                  ),
                                ),
                              )),
                        if (_availableProducts.isNotEmpty)
                          Container(
                            height: _showSearchBar
                                ? screenMaxHeight * 0.58
                                : screenMaxHeight * .68,
                            child: ListView.builder(
                              padding: EdgeInsets.all(0.0),
                              itemCount: _availableProducts.length,
                              itemBuilder: (context, index) {
                                return CartItem(
                                  editProduct: _editProduct,
                                  index: index,
                                  list: _availableProducts,
                                );
                              },
                            ),
                          ),
                        if (_availableProducts.isEmpty)
                          Container(
                              height: screenMaxHeight * 0.60,
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
            ),
    );
  }
}

class CartItem extends StatelessWidget {
  const CartItem({
    @required this.editProduct,
    @required this.index,
    @required this.list,
    Key key,
  }) : super(key: key);

  final int index;
  final List<Products> list;
  final Function(Products product) editProduct;

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
                          Icons.edit,
                          color: Colors.black,
                          size: 15,
                        ),
                        onPressed: () {
                          editProduct(list[index]);
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
