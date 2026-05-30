import 'package:flutter/material.dart';
import '../database_helper.dart';

class AddTransactionPage extends StatefulWidget {
  final String userId;
  const AddTransactionPage({super.key, required this.userId});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _nameCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  String _type = 'chi'; // 'thu' hoac 'chi'
  String? _selectedCategory;
  List<String> _categories = [];
  String _imagePath = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load danh muc theo loai thu/chi
  void _loadCategories() async {
    final rows = await DatabaseHelper.instance.queryWhere(
      'DanhMuc', 'categoryType = ?', [_type]);
    setState(() {
      _categories = rows.map((r) => r['categoryName'] as String).toList();
      _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
    });
  }

  // Chon ngay
  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // chi cho chon hom nay tro ve truoc
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Gia lap chon anh (khong dung image_picker de don gian)
  void _pickImage() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Chup hinh'),
            onTap: () {
              setState(() => _imagePath = 'camera_photo.jpg');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Chon tu thu vien'),
            onTap: () {
              setState(() => _imagePath = 'gallery_photo.jpg');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _save() async {
    final name   = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());

    // Validate
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap ten thu chi!')));
      return;
    }
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('So tien khong hop le!')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long chon danh muc!')));
      return;
    }

    // Luu vao DB
    await DatabaseHelper.instance.insert('GiaoDich', {
      'date':        _selectedDate.toIso8601String(),
      'type':        _type,
      'totalAmount': amount,
      'description': name,
      'category':    _selectedCategory,
      'illustration': _imagePath,
      'user_id':     widget.userId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Luu thanh cong!'),
        backgroundColor: Colors.green,
      ));

    // Quay lai trang truoc (SummaryPage)
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Them Giao Dich')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Toggle Thu / Chi
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _type = 'thu');
                      _loadCategories();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == 'thu' ? Colors.blue : Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text('Thu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _type == 'thu' ? Colors.white : Colors.black,
                        )),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _type = 'chi');
                      _loadCategories();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == 'chi' ? Colors.blue : Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text('Chi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _type == 'chi' ? Colors.white : Colors.black,
                        )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tieu de
            Center(
              child: Text(
                _type == 'thu' ? 'Them thu nhap' : 'Them chi tieu',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Ten thu chi
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Ten thu chi'),
            ),
            const SizedBox(height: 16),

            // So tien
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'So tien',
                suffixText: 'VND',
              ),
            ),
            const SizedBox(height: 16),

            // Chon ngay
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Danh muc dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Danh muc'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: 16),

            // Chon anh
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _imagePath.isEmpty
                          ? Icons.camera_alt
                          : Icons.check_circle,
                      color: _imagePath.isEmpty ? Colors.grey : Colors.green,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _imagePath.isEmpty ? 'Chon hinh anh' : _imagePath,
                  style: TextStyle(
                    color: _imagePath.isEmpty ? Colors.grey : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ghi chu
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Ghi chu'),
            ),
            const SizedBox(height: 24),

            // Nut Luu
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('LUU', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}