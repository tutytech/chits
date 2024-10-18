import 'package:chitfunds/screens/amountransfer.dart';
import 'package:chitfunds/screens/createbranch.dart';
import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/screens/createcustomer.dart';
import 'package:chitfunds/screens/createscheme.dart';
import 'package:chitfunds/screens/createstaff.dart';
import 'package:chitfunds/screens/customerreceipt.dart';
import 'package:chitfunds/screens/editcomapnydetails.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(218, 209, 209, 204),
            ),
            child: Text(
              'Menu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Customer Info'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateCustomer()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Branch'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateBranch()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Center'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateCenter()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Scheme'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateScheme()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Loan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AmountTransfer()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Receipt'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Receipt()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.transfer_within_a_station),
            title: const Text('Voucher'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AmountTransfer()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => ReportsPage()),
              // );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Staff Create'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateStaff()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_box),
            title: const Text('Closed Accounts'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => ClosedAccountsPage()),
              // );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => SettingsPage()),
              // );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Edit Company Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditCompany()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('SMS Settings'),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => SMSSettingsPage()),
                    // );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
