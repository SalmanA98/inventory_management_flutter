# inventory_management

A flutter project which helps the company maintain control over products, invoices, employees activity and sales. Uses firebase for authentication and realtime database capabilities.

Features:

- Sell Products
  - Sell one or more products
  - Ensures there is no discrepancies
  - Automatic creation of invoice as PDF
  
- Manage Products
  - Add New Products
  - Edit Existing Products (Update quantity, price)
  - Delete Exisitng Products
  
- Accessibility
  - Seperate accessibility based on admin privilege
  - Can be updated through updating employee data
 
- Manage Employees
  - Add New Employees
  - Edit Exisitng Employees (Update number, age, admin privilege)
  - Remove Employees
  
- View Sales History
  - Create invoice of all sales between any two dates
  - 3-clicks to produce well curated excel sheet

- Refund Sales
  - Uses unique Sale ID of every sale
  - Refundable for liquid cash transactions only
  - Updates sale data, product data.

## Getting Started

This project is a privately made app which uses Flutter.

Resources used in the app:

- Firebase Realtime Database: https://firebase.google.com/docs/database
- Firebase Authentication: https://firebase.google.com/docs/auth
- Animated Splash Screen: https://pub.dev/packages/animated_splash_screen
- Flutter Toast: https://pub.dev/packages/fluttertoast
- Syncfusion PDF [To create invoice]: https://pub.dev/packages/syncfusion_flutter_pdf
- Syncfusion XLSIO [To create excel sheet]: https://pub.dev/packages/syncfusion_flutter_xlsio
- Open File [To open files from directory]: https://pub.dev/packages/open_file
- Path Provider [To find common(IOS & Android) path used by the app]: https://pub.dev/packages/path_provider
- Flutter Launcher Icons [To create launch icon (cross-platform) easily]: https://pub.dev/packages/flutter_launcher_icons
- Progress State Button [Animated loading button]: https://pub.dev/packages/progress_state_button
- Giffy Dialog [Fancy dialog box]: https://pub.dev/packages/giffy_dialog  

For help getting started with Flutter, view
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
