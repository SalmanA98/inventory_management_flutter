import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../widgets/customAppBar.dart';
import '../widgets/customButton.dart';
import '../models/paymentdetails.dart';
import '../models/products.dart';
import '../models/invoice.dart';
import './homepage.dart';

// ignore: must_be_immutable
class CompletedSale extends StatefulWidget {
  final List<Map<String, Object>> details;

  CompletedSale({@required this.details});

  @override
  _CompletedSaleState createState() => _CompletedSaleState();
}

class _CompletedSaleState extends State<CompletedSale> {
  final List<PaymentDetails> _paymentDetails = [];

  List<Products> _productsSold;

  void _getSaleData() {
    _productsSold = widget.details[4]['Items Purchased'];
    for (int i = 0; i < widget.details.length; i++) {
      widget.details[i].forEach((key, value) {
        if (key.toString() != 'Items Purchased') {
          _paymentDetails.add(
              PaymentDetails(title: key.toString(), value: value.toString()));
        }
      });
    }
  }

  Future<void> _onBackPressed(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
  }

  void _showSuccessDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2),
      width: double.infinity,
      buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
      headerAnimationLoop: true,
      useRootNavigator: true,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Sale Successful',
      desc: 'Please save the invoice manually to not lose it!',
      dismissOnBackKeyPress: true,
      btnOkText: 'Got It!',
      btnOkOnPress: () {},
    )..show();
  }

  @override
  void initState() {
    super.initState();
    _getSaleData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _showSuccessDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _onBackPressed(context),
          child: Column(
            children: [
              CustomAppBar(
                title: 'Sale Details',
                subtitle: 'View your save details!',
                needBackButton: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 15, bottom: 5),
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: const Text(
                              'Payment Details',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          )),
                      ..._paymentDetails.map((element) {
                        return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      element.title,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(element.value)),
                                ],
                              ),
                              Divider(
                                color: Theme.of(context).primaryColor,
                              )
                            ]));
                      }).toList(),
                      Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: CustomButton(
                          buttonFunction: () {
                            _createPDF();
                          },
                          buttonText: 'Invoice PDF',
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: CustomButton(
                          buttonFunction: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => HomePage()));
                          },
                          buttonText: 'Go Back',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPDF() async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));
    //Generate PDF grid.
    final PdfGrid grid = getGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult result = drawHeader(page, pageSize, grid);
    //Draw grid
    drawGrid(page, grid, result);
    //Add invoice footer
    drawFooter(page, pageSize);
    //Save the PDF document
    final List<int> bytes = document.save();
    //Dispose the document.
    document.dispose();
    //Save and launch the file.
    await saveAndLaunchFile(bytes,
        '${widget.details[0]['Customer Name']}~${widget.details[2]['Date']}~${widget.details[3]['Time']}.pdf');
  }

  PdfLayoutResult drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    //Draw string
    page.graphics.drawString(
        'HEKAYET ETR', PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(65, 104, 205)));

    page.graphics.drawString(
        'INVOICE', PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
        brush: PdfBrushes.white,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));

    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);

    //Create data foramt and convert it to text.
    final String rightInfo =
        'Sale ID: ${widget.details[9]['Sale ID']}\r\nDate: ${widget.details[2]['Date']}\r\nTime: ${widget.details[3]['Time']}\r\nEmployee ID: ${widget.details[8]['Employee ID'].toString().toUpperCase()}';

    final Size contentSize = contentFont.measureString(rightInfo);
    // ignore: leading_newlines_in_multiline_strings
    final String leftInfo =
        '''Customer Details: \r\nCustomer Name: ${widget.details[0]['Customer Name']} 
        \r\nCustomer Number:  ${widget.details[1]['Customer Number']} \r\n\Payment Method:  ${widget.details[7]['Payment Method']}''';

    PdfTextElement(text: rightInfo, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 30), 120,
            contentSize.width + 30, pageSize.height - 120));

    return PdfTextElement(text: leftInfo, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, 120,
            pageSize.width - (contentSize.width + 30), pageSize.height - 120));
  }

  void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect totalPriceCellBounds;
    Rect quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0));

    //Draw VAT
    page.graphics.drawString('VAT',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            quantityCellBounds.left,
            result.bounds.bottom + 10,
            quantityCellBounds.width,
            quantityCellBounds.height));
    page.graphics.drawString('${widget.details[5]['VAT'].toString()}',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            totalPriceCellBounds.left,
            result.bounds.bottom + 10,
            totalPriceCellBounds.width,
            totalPriceCellBounds.height));

    //Draw Discount
    page.graphics.drawString('Discount',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            quantityCellBounds.left,
            result.bounds.bottom + 20,
            quantityCellBounds.width,
            quantityCellBounds.height));
    page.graphics.drawString('${widget.details[6]['Discount'].toString()}%',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            totalPriceCellBounds.left,
            result.bounds.bottom + 20,
            totalPriceCellBounds.width,
            totalPriceCellBounds.height));

    //Draw grand total.
    page.graphics.drawString('Grand Total',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            quantityCellBounds.left,
            result.bounds.bottom + 30,
            quantityCellBounds.width,
            quantityCellBounds.height));
    page.graphics.drawString(
        'AED: ${widget.details[10]['Total Price'].toString()}',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            totalPriceCellBounds.left,
            result.bounds.bottom + 30,
            totalPriceCellBounds.width,
            totalPriceCellBounds.height));
  }

  void drawFooter(PdfPage page, Size pageSize) {
    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219, 255), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    //Draw line
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
        Offset(pageSize.width, pageSize.height - 100));

    const String footerContent =
        // ignore: leading_newlines_in_multiline_strings
        '''800 Interchange Blvd.\r\n\r\nSuite 2501, Austin,
         TX 78721\r\n\r\nAny Questions? support@adventure-works.com''';

    //Added 30 as a margin for the layout
    page.graphics.drawString(
        footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 70, 0, 0));
  }

  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 5);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'SI. No.';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Product Name';
    headerRow.cells[2].value = 'Price';
    headerRow.cells[3].value = 'Quantity';
    headerRow.cells[4].value = 'Total';

//Add rows
    for (int i = 0; i < _productsSold.length; i++) {
      double totOfProd = double.tryParse(_productsSold[i].price) *
          int.tryParse(_productsSold[i].qty);
      addProducts(
          (i + 1).toString(),
          _productsSold[i].name,
          double.tryParse(_productsSold[i].price),
          int.tryParse(_productsSold[i].qty),
          totOfProd,
          grid);
    }

    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  void addProducts(String productId, String productName, double price,
      int quantity, double total, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = productId;
    row.cells[1].value = productName;
    row.cells[2].value = price.toString();
    row.cells[3].value = quantity.toString();
    row.cells[4].value = total.toString();
  }

  double getTotalAmount(PdfGrid grid) {
    double total = 0;
    for (int i = 0; i < grid.rows.count; i++) {
      final String value =
          grid.rows[i].cells[grid.columns.count - 1].value as String;
      total += double.parse(value);
    }
    return total;
  }
}
