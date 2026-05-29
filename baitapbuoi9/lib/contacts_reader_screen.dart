import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';

class ContactsReaderScreen extends StatefulWidget {
  const ContactsReaderScreen({super.key});

  @override
  State<ContactsReaderScreen> createState() => _ContactsReaderScreenState();
}

class _ContactsReaderScreenState extends State<ContactsReaderScreen> {
  bool _isLoading = true;
  List<ContactInfo> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chức năng này chỉ hoạt động trên Mobile (Android/iOS)')),
        );
      }
      return;
    }

    final status = await Permission.contacts.request();

    if (status.isGranted) {
      try {
        final contacts = await FlutterContactsService.getContacts();
        if (mounted) {
          setState(() {
            _contacts = contacts.toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi đọc danh bạ: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập danh bạ bị từ chối')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đọc Danh Bạ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? const Center(child: Text('Không có liên hệ nào.'))
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    final phoneNumber = (contact.phones != null && contact.phones!.isNotEmpty)
                        ? contact.phones!.first.value
                        : 'Không có số điện thoại';

                    return ListTile(
                      title: Text(contact.displayName ?? 'Không có tên'),
                      subtitle: Text(phoneNumber ?? 'Không có số điện thoại'),
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    );
                  },
                ),
    );
  }
}
