import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_telephony/telephony.dart';

class SmsReaderScreen extends StatefulWidget {
  const SmsReaderScreen({super.key});

  @override
  State<SmsReaderScreen> createState() => _SmsReaderScreenState();
}

class _SmsReaderScreenState extends State<SmsReaderScreen> {
  bool _isLoading = true;
  List<SmsMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadSms();
  }

  Future<void> _loadSms() async {
    if (!Platform.isAndroid) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chức năng này chỉ hoạt động trên Android')),
        );
      }
      return;
    }

    // Request permissions
    final smsStatus = await Permission.sms.request();
    final phoneStatus = await Permission.phone.request();

    if (smsStatus.isGranted && phoneStatus.isGranted) {
      try {
        final messages = await Telephony.instance.getInboxSms(
          columns: [
            SmsColumn.ADDRESS,
            SmsColumn.BODY,
            SmsColumn.DATE,
            SmsColumn.TYPE
          ],
          sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
        );

        if (mounted) {
          setState(() {
            _messages = messages;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi đọc tin nhắn: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập bị từ chối')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đọc SMS'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? const Center(child: Text('Không có tin nhắn nào.'))
              : ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return ListTile(
                      title: Text(
                        message.body ?? 'Không có nội dung',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('Từ: ${message.address ?? 'Không rõ'}'),
                    );
                  },
                ),
    );
  }
}
