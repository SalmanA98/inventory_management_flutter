import 'package:flutter/material.dart';
import 'package:inventory_management/widgets/customButton.dart';
import 'package:inventory_management/screens/customerInfo.dart';
import '../models/products.dart';

class Cart extends StatefulWidget {
  final List<Products> cartItems;
  final String _username;
  Cart(this.cartItems, this._username);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<String> qtyInCart = [];
  void _removeFromCart(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
  }

  void _getCustomerInfo() {
    for (int i = 0; i < widget.cartItems.length; i++) {
      widget.cartItems[i].qty = qtyInCart[i];
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CustomerInfo(widget.cartItems, widget._username)));
  }

  void _updateQty(int index, bool isAdd) {
    if (isAdd) {
      setState(() {
        if (int.tryParse(widget.cartItems[index].qty) >
            int.tryParse(qtyInCart[index])) {
          qtyInCart[index] = (int.tryParse(qtyInCart[index]) + 1).toString();
        }
      });
    } else if (!isAdd) {
      setState(() {
        if (int.tryParse(qtyInCart[index]) > 1) {
          qtyInCart[index] = (int.tryParse(qtyInCart[index]) - 1).toString();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.cartItems.length; i++) {
      qtyInCart.add('1');
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 10, left: 10),
            child: FittedBox(
              child: Text(
                'Cart',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (widget.cartItems.isEmpty)
            FittedBox(
                fit: BoxFit.fill,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/empty_products.png',
                )),
          if (widget.cartItems.isNotEmpty)
            Container(
              height: screenMaxHeight * .35,
              margin: EdgeInsets.all(9),
              child: ListView.builder(
                  itemCount: widget.cartItems.length,
                  itemBuilder: (ctx, index) {
                    return createCartListItem(index);
                  }),
            ),
          if (widget.cartItems.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              child: CustomButton(
                buttonFunction: _getCustomerInfo,
                buttonText: 'Proceed To Checkout',
              ),
            )
        ],
      ),
    );
  }

  createCartListItem(int index) {
    return Stack(
      children: <Widget>[
        Container(
            margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: Card(
              elevation: 5,
              child: Row(
                children: <Widget>[
                  Container(
                    margin:
                        EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        //   color: Colors.blue.shade200,
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
                                widget.cartItems[index].name,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    "AED: ${widget.cartItems[index].price}",
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove,
                                          size: 24,
                                          // color: Colors.grey.shade700,
                                        ),
                                        onPressed: () {
                                          _updateQty(index, false);
                                        },
                                      ),
                                      Container(
                                        color: Colors.grey,
                                        padding: const EdgeInsets.only(
                                            bottom: 2, right: 12, left: 12),
                                        child: Text(
                                          qtyInCart[index],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          size: 24,
                                          // color: Colors.grey.shade700,
                                        ),
                                        onPressed: () {
                                          _updateQty(index, true);
                                        },
                                      )
                                    ],
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
            )),
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
                    Icons.close_outlined,
                    color: Colors.black,
                    size: 15,
                  ),
                  onPressed: () {
                    _removeFromCart(index);
                  },
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: Theme.of(context).errorColor),
              ),
            ))
      ],
    );
  }
}
