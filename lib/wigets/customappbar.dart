import 'package:chitfunds/screens/LoginScreen.dart';
import 'package:chitfunds/storage/savedata.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: PreferencesUtils.getUserName(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        String userEmail = snapshot.data ?? "Guest";
        return AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          // title: FutureBuilder<String?>(
          //   future: PreferencesUtils.getToken(), // Fetch the URL asynchronously
          //   builder: (context, snapshot) {
          //     String userImageUrl =
          //         snapshot.data ?? 'assets/images/dummyimage.png';
          //     // return UserMenuBar(
          //     //   Username: userEmail,
          //     //   // userImageUrl: userImageUrl,
          //     // );
          //   },
          // ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing by tapping outside the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed 'No'
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed 'Yes'
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    // If user confirmed logout
    if (shouldLogout == true) {
      print('Logout action triggered');

      // Clear local storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Local storage cleared');

      // Navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(),
        ),
      );
    }
  }
}
