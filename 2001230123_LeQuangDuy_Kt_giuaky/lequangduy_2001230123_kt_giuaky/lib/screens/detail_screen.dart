import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../db/database_helper.dart';
import '../models/note.dart';
import '../models/media_item.dart';
import 'add_note_screen.dart';

/// Màn hình chi tiết hiển thị ảnh/video full và danh sách ghi chú liên quan.
class DetailScreen extends StatefulWidget {
  final MediaItemModel media;

  const DetailScreen({required this.media, super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<List<Note>> _notesFuture;
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoFuture;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    if (widget.media.type == 'video') {
      if (widget.media.url.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.media.url));
      } else {
        _videoController = VideoPlayerController.file(File(widget.media.url));
      }
      _initializeVideoFuture = _videoController!.initialize().then((_) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _loadNotes() {
    // Tải ghi chú liên quan tới mediaId bằng Future; dùng FutureBuilder trong UI
    _notesFuture = DatabaseHelper.instance.getNotesByMediaId(widget.media.mediaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Cho phép ảnh tràn lên dưới AppBar
      appBar: AppBar(
        title: const Text('Chi tiết media', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Ảnh hoặc video full màn hình (tràn hết body)
          Positioned.fill(
            child: Container(
              color: Colors.black, // Nền đen cho sang trọng
              child: widget.media.type == 'image'
                  ? InteractiveViewer(
                      maxScale: 5.0,
                      child: CachedNetworkImage(
                        imageUrl: widget.media.url,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                        ),
                      ),
                    )
                  : (_videoController == null
                      ? const Center(child: Text('Không thể phát video', style: TextStyle(color: Colors.white)))
                      : FutureBuilder(
                          future: _initializeVideoFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              );
                            }
                            return Center(
                              child: AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    VideoPlayer(_videoController!),
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black45,
                                        child: IconButton(
                                          icon: Icon(
                                            _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (_videoController!.value.isPlaying) {
                                                _videoController!.pause();
                                              } else {
                                                _videoController!.play();
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
            ),
          ),
          // Lớp phủ thông tin và các nút bấm ở dưới cùng
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Media ID: ${widget.media.mediaId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Nút Thêm ghi chú
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNoteScreen(mediaId: widget.media.mediaId),
                              ),
                            );
                            setState(() {
                              _loadNotes();
                            });
                          },
                          icon: const Icon(Icons.add_comment),
                          label: const Text('Thêm ghi chú'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nút Xem danh sách ghi chú
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _showNotesBottomSheet(context);
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('Xem ghi chú'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị bottom sheet chứa danh sách ghi chú cho media này
  void _showNotesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ghi chú cho ${widget.media.mediaId}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(
                height: 350,
                child: FutureBuilder<List<Note>>(
                  future: _notesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    }
                    final notes = snapshot.data ?? [];
                    if (notes.isEmpty) {
                      return const Center(child: Text('Chưa có ghi chú nào.'));
                    }
                    return ListView.separated(
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        final ts = note.createdAt.toLocal().toString().split('.')[0];
                        return ListTile(
                          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(note.content ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(ts, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    final result = await Navigator.push<bool?>(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddNoteScreen(note: note)),
                                    );
                                    if (result == true) {
                                      setState(() {
                                        _loadNotes();
                                      });
                                      // Refresh sheet bằng cách đóng và mở lại với dữ liệu mới
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                        _showNotesBottomSheet(context);
                                      }
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
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa thành công')));
                                      }
                                      setState(() {
                                        _loadNotes();
                                      });
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                        _showNotesBottomSheet(context);
                                      }
                                    }
                                  }
                                },
                                itemBuilder: (_) => const [
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
            ],
          ),
        );
      },
    );
  }
}
