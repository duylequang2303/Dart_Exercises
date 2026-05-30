import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/note.dart';

/// Màn hình thêm / sửa ghi chú
class AddNoteScreen extends StatefulWidget {
  final Note? note;
  final String? mediaId;

  const AddNoteScreen({this.note, this.mediaId, super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _mediaIdController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Nếu đang ở chế độ sửa (widget.note != null), điền sẵn dữ liệu
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _mediaIdController = TextEditingController(text: widget.note?.mediaId ?? widget.mediaId ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _mediaIdController.dispose();
    super.dispose();
  }

  /// Xử lý lưu ghi chú: validate form, gọi insert hoặc update
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final mediaId = _mediaIdController.text.trim();

    try {
      if (widget.note != null) {
        // Chế độ sửa: giữ createdAt cũ
        final updated = Note(
          id: widget.note!.id,
          title: title,
          content: content.isEmpty ? null : content,
          mediaId: mediaId,
          createdAt: widget.note!.createdAt,
        );
        await DatabaseHelper.instance.updateNote(updated);
      } else {
        final newNote = Note(
          title: title,
          content: content.isEmpty ? null : content,
          mediaId: mediaId,
        );
        await DatabaseHelper.instance.insertNote(newNote);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công!')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi lưu: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.note != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa ghi chú' : 'Thêm ghi chú')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Tiêu đề bắt buộc';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Nội dung'),
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mediaIdController,
                decoration: const InputDecoration(labelText: 'Media ID'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveNote,
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
