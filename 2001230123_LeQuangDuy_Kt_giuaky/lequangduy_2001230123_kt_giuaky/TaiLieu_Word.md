# MÃ NGUỒN CHỨNG MINH THEO TỪNG CÂU CHỨNG NĂNG
*(Dùng để copy-paste trực tiếp vào báo cáo Word)*

---

## CÂU 1: GIAO DIỆN CHÍNH (MAIN INTERFACE)

### 1.1. Code GridView hiển thị danh sách hình ảnh/video:
```dart
GridView.builder(
  itemCount: medias.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1.0,
  ),
  itemBuilder: (context, index) {
    final item = medias[index];
    final thumb = item.thumbnail ?? item.url;
    final isVideo = item.type == 'video';
    return GestureDetector(
      onTap: () => _showNotesBottomSheet(context, item), // Nhấn vào item show popup
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: thumb,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
            ),
            if (isVideo)
              const Positioned(
                right: 8,
                top: 8,
                child: Icon(Icons.play_circle_outline, color: Colors.white, size: 36),
              ),
          ],
        ),
      ),
    );
  },
)
```

### 1.2. Code Popup (Bottom Sheet) hiển thị danh sách ghi chú đã lưu và nút "Xem chi tiết":
```dart
void _showNotesBottomSheet(BuildContext context, MediaItemModel item) {
  Future<List<Note>> notesFuture = DatabaseHelper.instance.getNotesByMediaId(item.mediaId);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (contextSB, setStateSB) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ghi chú: ${item.mediaId}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(contextSB); // Đóng Bottom Sheet
                          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(media: item))); // Qua trang chi tiết
                        },
                        child: const Text('Xem chi tiết'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 320,
                    child: FutureBuilder<List<Note>>(
                      future: notesFuture,
                      builder: (context, snapshot) {
                        // ... Tải và hiển thị danh sách ListTile các ghi chú ...
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
```

### 1.3. Code FloatingActionButton thêm ảnh và ghi chú mới:
```dart
floatingActionButton: FloatingActionButton(
  onPressed: () async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Thêm media (ảnh/video)'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final newMediaId = await Navigator.push<String?>(context, MaterialPageRoute(builder: (_) => const AddMediaScreen()));
                  if (newMediaId != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddNoteScreen(mediaId: newMediaId)));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_add),
                title: const Text('Thêm ghi chú'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNoteScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  },
  child: const Icon(Icons.add),
)
```

---

## CÂU 2: MÀN HÌNH CHI TIẾT HÌNH ẢNH/VIDEO (IMAGE DETAIL SCREEN)

### 2.1. Code hiển thị hình ảnh/video full màn hình (sử dụng Stack, Positioned.fill và extendBodyBehindAppBar):
```dart
Scaffold(
  extendBodyBehindAppBar: true, // Cho phép hình ảnh tràn xuống dưới AppBar
  appBar: AppBar(
    title: const Text('Chi tiết media', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    backgroundColor: Colors.black.withOpacity(0.4), // AppBar mờ ảo
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  body: Stack(
    children: [
      // Ảnh/Video chiếm toàn bộ màn hình
      Positioned.fill(
        child: Container(
          color: Colors.black,
          child: widget.media.type == 'image'
              ? InteractiveViewer(
                  maxScale: 5.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.media.url,
                    fit: BoxFit.contain, // Phóng to vừa vặn màn hình điện thoại
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
                  ),
                )
              : VideoPlayerWidget(...), // Phát video toàn màn hình
        ),
      ),
      
      // Lớp phủ điều khiển mờ ở đáy màn hình
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ... Hiển thị ID và các nút chức năng ...
            ],
          ),
        ),
      ),
    ],
  ),
)
```

### 2.2. Code nút thêm ghi chú liên quan đến image/video đang xem:
```dart
// Nút bấm "Thêm ghi chú" nằm ở thanh điều khiển dưới đáy
ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  onPressed: () async {
    // Điều hướng sang màn hình thêm ghi chú truyền kèm mediaId đang xem
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddNoteScreen(mediaId: widget.media.mediaId)),
    );
    setState(() {
      _loadNotes(); // Tải lại danh sách ghi chú sau khi thêm mới
    });
  },
  icon: const Icon(Icons.add_comment),
  label: const Text('Thêm ghi chú'),
)
```

---

## CÂU 3: MÀN HÌNH THÊM/SỬA GHI CHÚ (ADD/EDIT NOTE SCREEN)

### 3.1. Code Form nhập liệu: Tiêu đề, Nội dung, ID liên quan có Validator:
```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(labelText: 'Tiêu đề'),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Tiêu đề bắt buộc'; // Cảnh báo trống
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
      // ... Nút Lưu ...
    ],
  ),
)
```

### 3.2. Code lưu dữ liệu vào SQLite (hàm saveNote gọi CRUD trong Helper):
```dart
Future<void> _saveNote() async {
  if (!_formKey.currentState!.validate()) return; // Kiểm tra lỗi validation
  setState(() => _saving = true);

  final title = _titleController.text.trim();
  final content = _contentController.text.trim();
  final mediaId = _mediaIdController.text.trim();

  try {
    if (widget.note != null) {
      // Chế độ CẬP NHẬT (Sửa ghi chú cũ)
      final updated = Note(
        id: widget.note!.id,
        title: title,
        content: content.isEmpty ? null : content,
        mediaId: mediaId,
        createdAt: widget.note!.createdAt,
      );
      await DatabaseHelper.instance.updateNote(updated);
    } else {
      // Chế độ THÊM MỚI (Lưu ghi chú mới)
      final newNote = Note(
        title: title,
        content: content.isEmpty ? null : content,
        mediaId: mediaId,
      );
      await DatabaseHelper.instance.insertNote(newNote);
    }
    
    // Thông báo thành công và quay lại
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công!')));
    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi lưu: $e')));
  } finally {
    setState(() => _saving = false);
  }
}
```

---

## CÂU 4: YÊU CẦU KHÁC (SQLITE, TÌM KIẾM, THÔNG BÁO)

### 4.1. Code khởi tạo DB SQLite và câu lệnh tạo bảng:
```dart
// SQLite _onCreate tạo bảng notes
FutureOr<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT,
      media_id TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )
  ''');
}
```

### 4.2. Code tìm kiếm ghi chú theo tiêu đề bằng SQLite truy vấn LIKE:
```dart
// Câu lệnh truy vấn SQL LIKE %query% để tìm kiếm
Future<List<Note>> searchNotesByTitle(String query) async {
  final db = await database;
  final maps = await db.query(
    'notes',
    where: 'title LIKE ?',
    whereArgs: ['%$query%'],
    orderBy: 'created_at DESC',
  );
  return maps.map((m) => Note.fromMap(m)).toList();
}
```

### 4.3. Code bộ lọc Tìm kiếm (NoteSearchDelegate) trong HomeScreen:
```dart
class NoteSearchDelegate extends SearchDelegate<Note?> {
  NoteSearchDelegate() : super(searchFieldLabel: 'Tìm theo tiêu đề');
  
  // ... Các nút xử lý AppBar ...

  @override
  Widget buildResults(BuildContext context) {
    final q = query.trim();
    if (q.isEmpty) return const Center(child: Text('Nhập từ khóa để tìm kiếm'));

    return FutureBuilder<List<Note>>(
      future: DatabaseHelper.instance.searchNotesByTitle(q), // Tìm ghi chú
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final results = snapshot.data ?? [];
        if (results.isEmpty) return const Center(child: Text('Không tìm thấy ghi chú.'));

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final note = results[index];
            return ListTile(
              title: Text(note.title),
              subtitle: Text(note.content ?? ''),
              onTap: () => close(context, note),
            );
          },
        );
      },
    );
  }
  
  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}
```

### 4.4. Code thông báo (SnackBar) khi thao tác thành công:
```dart
// Thông báo lưu thành công
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công!')));

// Thông báo xóa thành công
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa thành công')));
```
