import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class SmsAnalyzerScreen extends StatefulWidget {
  const SmsAnalyzerScreen({Key? key}) : super(key: key);

  @override
  _SmsAnalyzerScreenState createState() => _SmsAnalyzerScreenState();
}

class _SmsAnalyzerScreenState extends State<SmsAnalyzerScreen> {
  final Telephony _telephony = Telephony.instance;
  List<SmsMessage> _allMessages = [];
  bool _isLoading = true;

  // Filter By Number
  final TextEditingController _numberController = TextEditingController();
  List<SmsMessage> _filteredByNumber = [];

  // Categorization
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadSmsData();
  }

  Future<void> _loadSmsData() async {
    var status = await Permission.sms.request();
    if (status.isGranted) {
      final messages = await _telephony.getInboxSms();
      setState(() {
        _allMessages = messages;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quyền truy cập SMS bị từ chối')),
      );
    }
  }

  // --- Tab 1: Statistics Logic ---
  Map<String, int> _getTopSenders() {
    Map<String, int> counts = {};
    for (var msg in _allMessages) {
      String address = msg.address ?? 'Unknown';
      counts[address] = (counts[address] ?? 0) + 1;
    }
    var sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries.take(5));
  }

  // --- Tab 3: Date Grouping Logic ---
  Map<String, int> _groupByMonth() {
    Map<String, int> groups = {};
    for (var msg in _allMessages) {
      if (msg.date != null) {
        String month = DateFormat('MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(msg.date!));
        groups[month] = (groups[month] ?? 0) + 1;
      }
    }
    return groups;
  }

  // --- Tab 4: Classification Logic ---
  bool _isAds(String body) {
    return body.trimLeft().startsWith('[QC]');
  }

  bool _isOtp(String body) {
    return body.contains('[OTP]') && RegExp(r'\b\d{6}\b').hasMatch(body);
  }

  String? _extractOtp(String body) {
    final match = RegExp(r'\b\d{6}\b').firstMatch(body);
    return match?.group(0);
  }

  List<SmsMessage> _getCategorizedMessages() {
    if (_selectedCategory == 'Quảng cáo') {
      return _allMessages.where((m) => _isAds(m.body ?? '')).toList();
    } else if (_selectedCategory == 'OTP') {
      return _allMessages.where((m) => _isOtp(m.body ?? '')).toList();
    }
    return _allMessages;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phân tích SMS'),
          backgroundColor: Colors.indigo,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Thống kê'),
              Tab(text: 'Theo số'),
              Tab(text: 'Theo ngày'),
              Tab(text: 'Phân loại'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildStatsTab(),
                  _buildByNumberTab(),
                  _buildByDateTab(),
                  _buildClassificationTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsTab() {
    final topSenders = _getTopSenders();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: Colors.indigo[50],
            child: ListTile(
              leading: const Icon(Icons.sms, color: Colors.indigo),
              title: const Text('Tổng số tin nhắn', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('${_allMessages.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Top 5 số gửi nhiều nhất:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: topSenders.length,
              itemBuilder: (context, index) {
                String address = topSenders.keys.elementAt(index);
                int count = topSenders.values.elementAt(index);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(address),
                    trailing: Text('$count tin nhắn'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildByNumberTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập số điện thoại...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _filteredByNumber = _allMessages
                        .where((m) => m.address != null && m.address!.contains(_numberController.text))
                        .toList();
                  });
                },
                child: const Text('Lọc'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredByNumber.isEmpty
              ? const Center(child: Text('Chưa có dữ liệu lọc.'))
              : ListView.builder(
                  itemCount: _filteredByNumber.length,
                  itemBuilder: (context, index) {
                    final msg = _filteredByNumber[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(msg.date ?? 0);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        title: Text(msg.body ?? ''),
                        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(date)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildByDateTab() {
    final groups = _groupByMonth();
    final sortedMonths = groups.keys.toList()
      ..sort((a, b) {
        DateTime dateA = DateFormat('MM/yyyy').parse(a);
        DateTime dateB = DateFormat('MM/yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        String month = sortedMonths[index];
        int count = groups[month]!;
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.indigo),
            title: Text('Tháng $month', style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('$count tin nhắn'),
          ),
        );
      },
    );
  }

  Widget _buildClassificationTab() {
    final categorized = _getCategorizedMessages();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            spacing: 10,
            children: ['Tất cả', 'Quảng cáo', 'OTP'].map((cat) {
              return FilterChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categorized.length,
            itemBuilder: (context, index) {
              final msg = categorized[index];
              final body = msg.body ?? '';
              final isOtp = _isOtp(body);
              final otpCode = _extractOtp(body);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: isOtp
                      ? Text(otpCode ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red))
                      : Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(msg.address ?? 'Unknown'),
                  trailing: isOtp ? const Icon(Icons.copy, color: Colors.grey) : null,
                  onTap: isOtp
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Mã OTP'),
                              content: Text('Mã của bạn là: $otpCode'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: otpCode ?? ''));
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Đã sao chép mã OTP')),
                                    );
                                  },
                                  child: const Text('SAO CHÉP'),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
