import 'package:flutter/material.dart';
import '../screens/addproducts.dart';
import '../screens/manageproducts.dart';
import '../screens/sellproducts.dart';
import '../screens/refundCheckSale.dart';
import '../screens/manageemployees.dart';
import '../screens/salehistory.dart';
import '../models/homepage_items.dart';

// ignore: must_be_immutable
class GridDashboard extends StatefulWidget {
  final bool isAdmin;
  final String username;
  GridDashboard({@required this.isAdmin, @required this.username});

  @override
  _GridDashboardState createState() => _GridDashboardState();
}

class _GridDashboardState extends State<GridDashboard> {
  List<DashItems> myList;

  @override
  void initState() {
    super.initState();
    DashItems item1 = new DashItems(
      title: "Sell Products",
      screen: SellProducts(widget.username),
      img: "assets/images/sell_logo.png",
    );

    DashItems item2 = new DashItems(
      title: "Manage Products",
      screen: ManageProducts(widget.username),
      img: "assets/images/edit_logo.png",
    );

    DashItems item3 = new DashItems(
      title: "Add Products",
      screen: AddProducts(widget.username),
      img: "assets/images/add_logo.png",
    );

    DashItems item4 = new DashItems(
      title: "Refund Sale",
      screen: RefundSaleID(widget.username),
      img: "assets/images/refund_logo.png",
    );

    DashItems item5 = new DashItems(
      title: "Sales History",
      screen: SalesHistory(),
      img: "assets/images/history_logo.png",
    );

    DashItems item6 = new DashItems(
      title: "Manage Employees",
      screen: ManageEmployees(widget.username),
      img: "assets/images/employees.png",
    );
    myList = [item1, item2, item3, item4, item5, item6];
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GridView.count(
          childAspectRatio: 1.0,
          padding: EdgeInsets.only(left: 16, right: 16),
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          children: myList.map((data) {
            return Visibility(
                visible: widget.isAdmin,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => data.screen));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Image.asset(
                            data.img,
                            width: 42,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(data.title,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          }).toList()),
    );
  }
}
