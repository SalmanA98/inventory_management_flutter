import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateItemList extends StatelessWidget {
  final int index;
  final String title;
  final String subTitle;
  final String extraTitle;
  final String imgUrl;
  final bool imgExist;
  final Icon trailingIcon;
  final bool updateQty;
  final Function(int index, bool isAdd) updateQtyButton;
  final Function(int index) trailingButtonFunction;

  CreateItemList(
      {@required this.index,
      @required this.title,
      @required this.subTitle,
      this.extraTitle,
      @required this.imgExist,
      @required this.trailingIcon,
      @required this.updateQty,
      @required this.trailingButtonFunction,
      this.updateQtyButton,
      this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: Card(
              elevation: 5,
              child: Row(
                children: <Widget>[
                  if (imgExist)
                    Container(
                      margin:
                          EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          color: Colors.blue.shade200,
                          image: DecorationImage(image: AssetImage(imgUrl))),
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
                              title,
                              style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                      fontSize: 15,
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
                                  subTitle,
                                ),
                                if (updateQty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            size: 24,
                                            color: Colors.grey.shade700,
                                          ),
                                          onPressed: () {
                                            updateQtyButton(index, false);
                                          },
                                        ),
                                        Container(
                                          color: Colors.grey.shade200,
                                          padding: const EdgeInsets.only(
                                              bottom: 2, right: 12, left: 12),
                                          child: Text(
                                            extraTitle,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            size: 24,
                                            color: Colors.grey.shade700,
                                          ),
                                          onPressed: () {
                                            updateQtyButton(index, true);
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
                    Icons.close,
                    color: Colors.white,
                    size: 15,
                  ),
                  onPressed: () {
                    trailingButtonFunction(index);
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
