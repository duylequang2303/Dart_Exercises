import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'add_transaction_page.dart';

class SummaryPage extends StatefulWidget {
  final String userId;
  const SummaryPage({super.key, required this.userId});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  double _tongThu = 0;
  double _tongChi = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final thu = await DatabaseHelper.instance.sumGiaoDich(widget.userId, 'thu');
    final chi = await DatabaseHelper.instance.sumGiaoDich(widget.userId, 'chi');
    setState(() {
      _tongThu = thu;
      _tongChi = chi;
    });
  }

  String _formatMoney(double amount) {
    // Format kieu 5.000.000
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCan = _tongThu - _tongChi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tong Hop Chi Tieu'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Card tong hop
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Tong thu
                  const Text('Tong thu',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoney(_tongThu),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tong chi
                  const Text('Tong chi',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    '-${_formatMoney(_tongChi)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Divider(height: 32),

                  // Con can
                  const Text('Con lai',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoney(canCan),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: canCan >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Nut them giao dich
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionPage(userId: widget.userId),
            ),
          );
          // Neu luu thanh cong thi load lai
          if (result == true) _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Them giao dich'),
      ),
    );
  }
}