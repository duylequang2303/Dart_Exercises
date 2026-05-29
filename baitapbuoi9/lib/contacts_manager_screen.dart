import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'add_edit_contact_screen.dart';

class ContactsManagerScreen extends StatefulWidget {
  const ContactsManagerScreen({Key? key}) : super(key: key);

  @override
  _ContactsManagerScreenState createState() => _ContactsManagerScreenState();
}

class _ContactsManagerScreenState extends State<ContactsManagerScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _contacts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  void _refreshContacts() async {
    final data = await _dbHelper.getContacts(query: _searchController.text);
    setState(() {
      _contacts = data;
    });
  }

  void _deleteContact(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa liên hệ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteContact(id);
              Navigator.pop(context);
              _refreshContacts();
            },
            child: const Text('XÓA', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh bạ'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditContactScreen()),
              );
              if (result == true) _refreshContacts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tên, số điện thoại...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => _refreshContacts(),
            ),
          ),
          Expanded(
            child: _contacts.isEmpty
                ? const Center(child: Text('Chưa có liên hệ nào.'))
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      Uint8List? avatarBytes = contact['avatar'];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            backgroundImage: avatarBytes != null ? MemoryImage(avatarBytes) : null,
                            child: avatarBytes == null
                                ? const Icon(Icons.person, color: Colors.blueAccent)
                                : null,
                          ),
                          title: Text(
                            contact['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${contact['phone']}\n${contact['email'] ?? ''}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteContact(contact['id']),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditContactScreen(contact: contact),
                              ),
                            );
                            if (result == true) _refreshContacts();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
