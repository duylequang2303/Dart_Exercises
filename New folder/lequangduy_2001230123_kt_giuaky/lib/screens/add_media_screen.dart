import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../db/database_helper.dart';
import '../models/media_item.dart';

/// Màn hình thêm media: chọn từ gallery (image/video) hoặc nhập URL
class AddMediaScreen extends StatefulWidget {
  const AddMediaScreen({super.key});

  @override
  State<AddMediaScreen> createState() => _AddMediaScreenState();
}

class _AddMediaScreenState extends State<AddMediaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  String _type = 'image';
  XFile? _pickedFile;
  bool _saving = false;

  final _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    if (_type == 'image') {
      final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
      if (picked != null) setState(() => _pickedFile = picked);
    } else {
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) setState(() => _pickedFile = picked);
    }
  }

  Future<void> _saveMedia() async {
    if (_pickedFile == null && (_urlController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn file hoặc nhập URL')));
      return;
    }
    setState(() => _saving = true);

    try {
      final id = const Uuid().v4();
      final url = _pickedFile != null ? _pickedFile!.path : _urlController.text.trim();
      final media = MediaItemModel(
        mediaId: id,
        url: url,
        type: _type,
        thumbnail: _type == 'image' ? url : null,
      );
      await DatabaseHelper.instance.insertMedia(media);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm media thành công')));
      Navigator.pop(context, id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm media')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Ảnh'),
                    leading: Radio<String>(
                      value: 'image',
                      groupValue: _type,
                      onChanged: (v) {
                        if (v != null) setState(() => _type = v);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Video'),
                    leading: Radio<String>(
                      value: 'video',
                      groupValue: _type,
                      onChanged: (v) {
                        if (v != null) setState(() => _type = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn từ thư viện'),
            ),
            const SizedBox(height: 12),
            const Text('Hoặc nhập URL (HTTP/HTTPS)'),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'URL media'),
              ),
            ),
            const SizedBox(height: 12),
            if (_pickedFile != null)
              Text('Đã chọn: ${_pickedFile!.name}'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveMedia,
                child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Lưu media'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
