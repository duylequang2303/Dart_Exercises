import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/note.dart';
import '../models/media_item.dart';
import 'detail_screen.dart';
import 'add_note_screen.dart';
import 'add_media_screen.dart';

// Model đơn giản cho media item (ảnh/video)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Home loads media from SQLite

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thư viện hình ảnh - video'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              // Lấy NavigatorState trước để tránh dùng BuildContext sau async gap
              final navigator = Navigator.of(context);
              // Mở SearchDelegate và chờ kết quả
              final Note? selectedNote = await showSearch<Note?>(context: context, delegate: NoteSearchDelegate());
              if (selectedNote != null) {
                final note = selectedNote;
                final media = await DatabaseHelper.instance.getMediaByMediaId(note.mediaId);
                if (media != null) {
                  navigator.push(MaterialPageRoute(builder: (_) => DetailScreen(media: media)));
                } else {
                  // fallback
                  navigator.push(MaterialPageRoute(builder: (_) => DetailScreen(media: MediaItemModel(mediaId: note.mediaId, url: 'https://picsum.photos/600/400', type: 'image'))));
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<MediaItemModel>>(
          future: DatabaseHelper.instance.getAllMedia(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
            final medias = snapshot.data ?? [];
            if (medias.isEmpty) return const Center(child: Text('Chưa có media nào. Hãy thêm mới.'));
            return GridView.builder(
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
                  onTap: () => _showNotesBottomSheet(context, item),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Thumbnail (ảnh hoặc ảnh đại diện cho video)
                        CachedNetworkImage(
                          imageUrl: thumb,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                        // Nếu là video, hiển thị icon play
                        if (isVideo)
                          const Positioned(
                            right: 8,
                            top: 8,
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Mở bottom sheet cho lựa chọn: thêm media hoặc thêm ghi chú
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
                          // Sau khi thêm media, chuyển sang thêm ghi chú cho media đó
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
      ),
    );
  }

  /// Hiển thị BottomSheet chứa danh sách ghi chú liên quan tới `item`.
  /// Sử dụng FutureBuilder để load dữ liệu từ SQLite (không dùng setState ở đây).
  void _showNotesBottomSheet(BuildContext context, MediaItemModel item) {
    // notesFuture được lưu trong closure để có thể làm mới khi cần bằng setStateSB
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
                            // Đóng bottom sheet rồi mở DetailScreen
                            Navigator.pop(contextSB);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(media: item),
                              ),
                            );
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
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Lỗi: ${snapshot.error}'));
                          }
                          final notes = snapshot.data ?? [];
                          if (notes.isEmpty) {
                            return const Center(child: Text('Không có ghi chú cho media này.'));
                          }
                          return ListView.separated(
                            itemCount: notes.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final note = notes[i];
                              final ts = note.createdAt.toLocal().toString().split('.')[0];
                              return ListTile(
                                title: Text(note.title),
                                subtitle: Text(
                                  '${note.content ?? ''}\n$ts',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                isThreeLine: true,
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'view') {
                                          Navigator.pop(contextSB);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DetailScreen(media: item),
                                            ),
                                          );
                                        } else if (value == 'edit') {
                                          final result = await Navigator.push<bool?>(
                                            context,
                                            MaterialPageRoute(builder: (_) => AddNoteScreen(note: note)),
                                          );
                                          if (result == true) {
                                            setStateSB(() {
                                              notesFuture = DatabaseHelper.instance.getNotesByMediaId(item.mediaId);
                                            });
                                          }
                                        } else if (value == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (dctx) => AlertDialog(
                                              title: const Text('Xác nhận'),
                                              content: const Text('Bạn có chắc muốn xóa ghi chú này?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Hủy')),
                                                TextButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Xóa')),
                                              ],
                                            ),
                                          );
                                            if (confirm == true) {
                                            await DatabaseHelper.instance.deleteNote(note.id!);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa')));
                                            }
                                            setStateSB(() {
                                              notesFuture = DatabaseHelper.instance.getNotesByMediaId(item.mediaId);
                                            });
                                          }
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(value: 'view', child: Text('Xem chi tiết')),
                                        PopupMenuItem(value: 'edit', child: Text('Sửa')),
                                        PopupMenuItem(value: 'delete', child: Text('Xóa')),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push<bool?>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddNoteScreen(mediaId: item.mediaId),
                                ),
                              );
                              if (result == true) {
                                setStateSB(() {
                                  notesFuture = DatabaseHelper.instance.getNotesByMediaId(item.mediaId);
                                });
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm ghi chú'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Placeholder classes removed; AddNoteScreen and DetailScreen are used instead.

/// SearchDelegate để tìm ghi chú theo tiêu đề.
class NoteSearchDelegate extends SearchDelegate<Note?> {
  NoteSearchDelegate() : super(searchFieldLabel: 'Tìm theo tiêu đề');

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final q = query.trim();
    if (q.isEmpty) {
      return const Center(child: Text('Nhập từ khóa để tìm kiếm'));
    }

    // Sử dụng FutureBuilder để gọi SQLite (không dùng setState)
    return FutureBuilder<List<Note>>(
      future: DatabaseHelper.instance.searchNotesByTitle(q),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) return const Center(child: Text('Không tìm thấy ghi chú.'));

            return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final note = results[index];
            return ListTile(
              title: Text(note.title),
              subtitle: Text(
                note.content ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(note.mediaId),
              onTap: () {
                // Trả về note đã chọn cho caller (sẽ điều hướng từ HomeScreen)
                close(context, note);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Gợi ý: nhập tiêu đề để tìm kiếm ghi chú'));
    }
    // Khi gõ, hiển thị kết quả tạm giống buildResults
    return buildResults(context);
  }
}
