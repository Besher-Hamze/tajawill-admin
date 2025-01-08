import 'package:flutter/material.dart';
import 'package:tajawil_admin/screens/categories_screen.dart';
import 'package:tajawil_admin/screens/services_screen.dart';
import 'package:tajawil_admin/screens/users_screen.dart';

import '../widget/dashboard_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        elevation: 0,
      ),
      body: GridView.count(
        padding: EdgeInsets.all(16),
        crossAxisCount: 2,
        children: [
          DashboardCard(
            title: 'Users',
            icon: Icons.people,
            onTap: () => Navigator.push(
              context,
                  MaterialPageRoute(builder: (_) => UsersScreen()),
            ),
          ),
          DashboardCard(
            title: 'Services',
            icon: Icons.business,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ServicesScreen()),
            ),
          ),
          DashboardCard(
            title: 'Category',
            icon: Icons.category_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategoriesScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
