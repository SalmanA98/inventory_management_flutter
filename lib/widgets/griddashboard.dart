import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/addproducts.dart';
import '../screens/manageproducts.dart';
import '../screens/sellproducts.dart';
import '../screens/refundCheckSale.dart';
import '../screens/manageemployees.dart';
import '../screens/salehistory.dart';
import '../models/homepage_items.dart';

// ignore: must_be_immutable
class GridDashboard extends StatelessWidget {
  final String isAdmin;
  GridDashboard(this.isAdmin);

  DashItems item1 = new DashItems(
    title: "Sell Products",
    screen: SellProducts(),
    img: "assets/images/sell_logo.png",
  );

  DashItems item2 = new DashItems(
    title: "Manage Products",
    screen: ManageProducts(),
    img: "assets/images/edit_logo.png",
  );

  DashItems item3 = new DashItems(
    title: "Add Products",
    screen: AddProducts(),
    img: "assets/images/add_logo.png",
  );

  DashItems item4 = new DashItems(
    title: "Refund Sale",
    screen: RefundSaleID(),
    img: "assets/images/refund_logo.png",
  );

  DashItems item5 = new DashItems(
      title: "Sales History",
      screen: SalesHistory(),
      img: "assets/images/history_logo.png",
      visibile: false);

  DashItems item6 = new DashItems(
      title: "Manage Employees",
      screen: ManageEmployees(),
      img: "assets/images/employees.png",
      visibile: false);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    List<DashItems> myList = [item1, item2, item3, item4, item5, item6];
    var color = 0xff453658;
    return Flexible(
      child: GridView.count(
          childAspectRatio: 1.0,
          padding: EdgeInsets.only(left: 16, right: 16),
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          children: myList.map((data) {
            return Visibility(
                visible: isAdmin == 'e' ? data.visibile : true,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => data.screen));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(color),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          data.img,
                          width: 42,
                        ),
                        SizedBox(
                          height: mediaQuery.size.height * 0.02,
                        ),
                        Text(
                          data.title,
                          style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ));
          }).toList()),
    );
  }
}
