import 'dart:io';
import 'package:inventory_management/screens/homepage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import '../models/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

Future<void> getSaleFromDB(
    List<String> dateList, String filename, BuildContext context) async {
  final Workbook workbook = Workbook();

// Accessing worksheet via index.
  final Worksheet sheet = workbook.worksheets[0];

  //Adding style to heading
  Style headingStyle = workbook.styles.add('headingStyle');
  headingStyle.bold = true;
  headingStyle.fontSize = 14;
  headingStyle.backColor = '#00FFFF';

// Set the text value.
  // Setting value in the cell.
  sheet.getRangeByName('A1').setText('Date');
  sheet.getRangeByName('B1').setText('Time');
  sheet.getRangeByName('C1').setText('Customer Name');
  sheet.getRangeByName('D1').setText('Customer Number');
  sheet.getRangeByName('E1').setText('Employee');
  sheet.getRangeByName('F1').setText('Payment Method');
  sheet.getRangeByName('G1').setText('Product Name');
  sheet.getRangeByName('H1').setText('Quantity');
  sheet.getRangeByName('I1').setText('Base Price');
  sheet.getRangeByName('J1').setText('VAT');
  sheet.getRangeByName('K1').setText('Discount');
  sheet.getRangeByName('L1').setText('Total Price');
  sheet.getRangeByName('M1').setText('Refunded Product');
  sheet.getRangeByName('N1').setText('Refunded Qty');
  sheet.getRangeByName('O1').setText('Refunded Amount');
  sheet.getRangeByName('P1').setText('Final Amount');
  sheet.getRangeByName('A1').cellStyle = headingStyle;
  sheet.getRangeByName('B1').cellStyle = headingStyle;
  sheet.getRangeByName('C1').cellStyle = headingStyle;
  sheet.getRangeByName('D1').cellStyle = headingStyle;
  sheet.getRangeByName('E1').cellStyle = headingStyle;
  sheet.getRangeByName('F1').cellStyle = headingStyle;
  sheet.getRangeByName('G1').cellStyle = headingStyle;
  sheet.getRangeByName('H1').cellStyle = headingStyle;
  sheet.getRangeByName('I1').cellStyle = headingStyle;
  sheet.getRangeByName('J1').cellStyle = headingStyle;
  sheet.getRangeByName('K1').cellStyle = headingStyle;
  sheet.getRangeByName('L1').cellStyle = headingStyle;
  sheet.getRangeByName('M1').cellStyle = headingStyle;
  sheet.getRangeByName('N1').cellStyle = headingStyle;
  sheet.getRangeByName('O1').cellStyle = headingStyle;
  sheet.getRangeByName('P1').cellStyle = headingStyle;

  int dateRow = 2;
  int detailsRow = 2;
  int prodRow = 2;
  int noOfProducts;
  Map<dynamic, dynamic> testThis;
  for (int i = 0; i < dateList.length; i++) {
    await databaseReference
        .child('D')
        .child('Sales')
        .child(dateList[i])
        .once()
        .then((datasnapshot) {
      if (datasnapshot.value != null) {
        Map<dynamic, dynamic> results = datasnapshot.value;
        sheet.getRangeByName('A$dateRow').setText(datasnapshot.key);
        results.forEach((time, details) {
          noOfProducts = int.tryParse(details['Number of products'].toString());
          for (int i = 0; i <= noOfProducts; i++) {
            if (details[i.toString()] != null) {
              testThis = details[i.toString()];

              testThis.forEach((prodName, prodDetails) {
                sheet.getRangeByName('G$prodRow').setText(prodName.toString());
                sheet
                    .getRangeByName('H$prodRow')
                    .setText(prodDetails['Qty'].toString());
                sheet
                    .getRangeByName('I$prodRow')
                    .setText(prodDetails['Base Price'].toString());
                sheet
                    .getRangeByName('M$prodRow')
                    .setText(prodDetails['Refunded'].toString());
                sheet
                    .getRangeByName('N$prodRow')
                    .setText(prodDetails['Refunded Qty'].toString());
                prodRow++;
              });
            }
          }

          sheet.getRangeByName('B$detailsRow').setText(time.toString());
          sheet
              .getRangeByName('C$detailsRow')
              .setText(details['Customer Name'].toString());
          sheet
              .getRangeByName('D$detailsRow')
              .setText(details['Customer Number'].toString());
          sheet
              .getRangeByName('E$detailsRow')
              .setText(details['Seller'].toString());
          sheet
              .getRangeByName('F$detailsRow')
              .setText(details['Payment Method'].toString());

          // sheet.getRangeByName('H$detailsRow').setText(details['Customer Name'].toString());
          //  sheet.getRangeByName('I$detailsRow').setText(details['Customer Name'].toString());
          sheet
              .getRangeByName('J$detailsRow')
              .setText(details['VAT'].toString());
          sheet
              .getRangeByName('K$detailsRow')
              .setText(details['Discount'].toString());
          sheet
              .getRangeByName('L$detailsRow')
              .setText(details['Final Price'].toString());
          //  sheet
          // .getRangeByName('M$detailsRow')
          // .setText(details['Refund Details'].toString());
          sheet
              .getRangeByName('O$detailsRow')
              .setText(details['Refunded Amount'].toString());
          sheet
              .getRangeByName('P$detailsRow')
              .setText(details['Total After Refund'].toString());
          detailsRow += noOfProducts;
          dateRow += noOfProducts;
        });
      }
    }).catchError((error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

// Save and dispose the document.
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

// Get external storage directory
  final directory = await getExternalStorageDirectory();

// Get directory path
  final path = directory.path;

// Create an empty file to write Excel data
  File file = File('$path/$filename.xlsx');

// Write Excel data
  await file.writeAsBytes(bytes, flush: true);

// Open the Excel document in mobile
  OpenFile.open('$path/$filename.xlsx');

  Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
}
