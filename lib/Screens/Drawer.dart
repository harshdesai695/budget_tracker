// ignore_for_file: prefer_const_constructors

import 'package:budget_tracker/Screens/CategoryScreen.dart';
import 'package:budget_tracker/Screens/MonthlySummaryScreen.dart'; // <-- ADDED import
import 'package:budget_tracker/Services/SignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: (user != null)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            (user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null)
                                as ImageProvider?,
                        child: (user.photoURL == null)
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.displayName ?? 'Budget User',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'Budget Tracker',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.house),
            title: Text('Home'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Manage Categories'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => CategoryScreen()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.calendar_month_outlined,
            ), // Changed icon slightly
            title: Text('Monthly Summary'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MonthlySummaryScreen()),
              );
            },
          ),

          if (user != null) ...[
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                SignInMethods().signoutgoogle(context); // Sign out
              },
            ),
          ],
        ],
      ),
    );
  }
}
