import 'package:baihuongdan1/GirdItem.dart';
import 'package:flutter/material.dart';

class MyGirdView02 extends StatefulWidget {
  const MyGirdView02({super.key});
  @override
  State<MyGirdView02> createState() => _MyGirdView01State();
}

class _MyGirdView01State extends State<MyGirdView02> {
  List<GirdItem> lst = [
    GirdItem(title: 'Login', icon: Icons.login),
    GirdItem(title: 'Search', icon: Icons.search),
    GirdItem(title: 'Profile', icon: Icons.person),
    GirdItem(title: 'Setting', icon: Icons.settings),
    GirdItem(title: 'Cart', icon: Icons.shopping_cart),
    GirdItem(title: 'Payment', icon: Icons.payment),
    GirdItem(title: 'Task', icon: Icons.add_task),
    GirdItem(title: 'Alert', icon: Icons.add_alert),
    GirdItem(title: 'Bank', icon: Icons.account_balance),
    GirdItem(title: 'Walet', icon: Icons.account_balance_wallet),
    GirdItem(title: 'Email', icon: Icons.mail),
    GirdItem(title: 'More', icon: Icons.arrow_circle_right_outlined),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 234, 205, 18),
        title: const Text('GridView Trần Minh Phúc'),
      ),
      body: GridView.builder(
        itemCount: lst.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          return Card(
            child: Container(
              color: Colors.blue,
              child: Center(
                child: Column(
                  children: [
                    Icon(lst[index].icon, size: 50),
                    Text(lst[index].title, style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}