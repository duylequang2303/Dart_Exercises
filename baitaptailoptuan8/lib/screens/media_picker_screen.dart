// =============================================================
// Bai tap 1 & 2: Media Picker Screen
// Tinh nang: Chon/chup anh, chon/quay video, xem anh toan man hinh
// =============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

// ==============================================================
// Man hinh chinh cua Media Picker
// ==============================================================
class MediaPickerScreen extends StatefulWidget {
  const MediaPickerScreen({super.key});

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
  // Doi tuong ImagePicker de mo camera / gallery
  final ImagePicker _picker = ImagePicker();

  // Luu duong dan anh da chon/chup
  File? _selectedImage;

  // Controller de dieu khien video player
  VideoPlayerController? _videoController;

  // Trang thai dang tai media
  bool _isLoading = false;

  // ============================================================
  // Ham chon anh tu Gallery
  // ============================================================
  Future<void> _pickImageFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        await _disposeVideo();
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      _showErrorSnackBar('Loi khi chon anh: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // Ham chup anh tu Camera
  // ============================================================
  Future<void> _captureImageFromCamera() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _showErrorSnackBar('Tinh nang chup anh tu Camera khong duoc ho tro tren Windows/Desktop.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        await _disposeVideo();
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      _showErrorSnackBar('Loi khi chup anh: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // Ham chon video tu Gallery
  // ============================================================
  Future<void> _pickVideoFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (pickedFile != null) {
        await _initVideoPlayer(File(pickedFile.path));
        setState(() => _selectedImage = null);
      }
    } catch (e) {
      if (Platform.isWindows) {
        _showErrorSnackBar('Loi video (Windows): Can file .mp4 chuan hoac thieu codec. Chi tiet: $e');
      } else {
        _showErrorSnackBar('Loi khi chon video: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // Bai tap 3: Quay video tu Camera va tu dong phat lai
  // ============================================================
  Future<void> _recordVideoFromCamera() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _showErrorSnackBar('Tinh nang quay video tu Camera khong duoc ho tro tren Windows/Desktop.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Mo camera de quay video (toi da 2 phut)
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );

      if (pickedFile != null) {
        // Khoi tao VideoPlayerController voi file vua quay
        await _initVideoPlayer(File(pickedFile.path));
        setState(() => _selectedImage = null);
      }
    } catch (e) {
      _showErrorSnackBar('Loi khi quay video: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // Khoi tao VideoPlayerController va tu dong phat video
  // ============================================================
  Future<void> _initVideoPlayer(File videoFile) async {
    // Giai phong controller cu neu co
    await _disposeVideo();

    // Tao controller moi tu file video
    final controller = VideoPlayerController.file(videoFile);
    _videoController = controller;

    // Tai metadata video
    await controller.initialize();

    // Tu dong phat video sau khi khoi tao xong
    await controller.play();

    // Lap lai video khi ket thuc
    await controller.setLooping(true);

    setState(() {});
  }

  // ============================================================
  // Giai phong tai nguyen VideoPlayerController
  // ============================================================
  Future<void> _disposeVideo() async {
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
  }

  // ============================================================
  // Hien thi thong bao loi
  // ============================================================
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Media Picker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Chon / Chup Media'),
            const SizedBox(height: 12),
            _buildActionButtonsGrid(),
            const SizedBox(height: 28),
            _buildSectionTitle('Ket qua'),
            const SizedBox(height: 12),
            _buildMediaPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF9E9EFF),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }

  // ============================================================
  // Luoi 4 nut chuc nang
  // ============================================================
  Widget _buildActionButtonsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildActionCard(
          id: 'btn_pick_image_gallery',
          icon: Icons.photo_library_rounded,
          label: 'Chon anh\ntư Gallery',
          color: const Color(0xFF6C63FF),
          onTap: _isLoading ? null : _pickImageFromGallery,
        ),
        _buildActionCard(
          id: 'btn_capture_image_camera',
          icon: Icons.camera_alt_rounded,
          label: 'Chup anh\ntư Camera',
          color: const Color(0xFF00BCD4),
          onTap: _isLoading ? null : _captureImageFromCamera,
        ),
        _buildActionCard(
          id: 'btn_pick_video_gallery',
          icon: Icons.video_library_rounded,
          label: 'Chon video\ntư Gallery',
          color: const Color(0xFFFF6B9D),
          onTap: _isLoading ? null : _pickVideoFromGallery,
        ),
        _buildActionCard(
          id: 'btn_record_video_camera',
          icon: Icons.videocam_rounded,
          label: 'Quay video\ntư Camera',
          color: const Color(0xFFFF9800),
          onTap: _isLoading ? null : _recordVideoFromCamera,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String id,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key(id),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.85),
                color.withValues(alpha: 0.55),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Widget hien thi anh hoac video da chon
  // ============================================================
  Widget _buildMediaPreview() {
    if (_isLoading) return _buildLoadingWidget();
    if (_videoController != null && _videoController!.value.isInitialized) {
      return _buildVideoPreview();
    }
    if (_selectedImage != null) return _buildImagePreview();
    return _buildEmptyState();
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6C63FF)),
            SizedBox(height: 16),
            Text('Đang xử lý...', style: TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.perm_media_rounded, size: 56, color: Color(0xFF4A4A6A)),
            SizedBox(height: 12),
            Text(
              'Chua co media nao duoc chon',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Hien thi anh (nhan vao de xem toan man hinh)
  // ============================================================
  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app, size: 14, color: Color(0xFF9E9EFF)),
              SizedBox(width: 6),
              Text(
                'Nhan vao anh de xem toan man hinh',
                style: TextStyle(color: Color(0xFF9E9EFF), fontSize: 12),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImage(imageFile: _selectedImage!),
              ),
            );
          },
          child: Hero(
            tag: 'selected_image',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 260,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Hien thi video player voi nut Play/Pause
  // ============================================================
  Widget _buildVideoPreview() {
    final controller = _videoController!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Khung video voi ty le dung
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          // Thanh dieu khien
          _buildVideoControls(controller),
        ],
      ),
    );
  }

  // ============================================================
  // Thanh dieu khien video: Play/Pause, thanh tien trinh, Mute
  // ============================================================
  Widget _buildVideoControls(VideoPlayerController controller) {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Thanh tien trinh (co the tua)
          VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Color(0xFF6C63FF),
              bufferedColor: Color(0xFF2A2A4A),
              backgroundColor: Color(0xFF0F0F1A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nut Play / Pause
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  return IconButton(
                    key: const Key('btn_video_play_pause'),
                    onPressed: () {
                      setState(() {
                        value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                    icon: Icon(
                      value.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_filled_rounded,
                      color: const Color(0xFF6C63FF),
                      size: 44,
                    ),
                    tooltip: value.isPlaying ? 'Tam dung' : 'Phat',
                  );
                },
              ),
              const SizedBox(width: 16),
              // Nut tat/bat am thanh
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  return IconButton(
                    key: const Key('btn_video_mute'),
                    onPressed: () {
                      setState(() {
                        controller.setVolume(value.volume > 0 ? 0.0 : 1.0);
                      });
                    },
                    icon: Icon(
                      value.volume > 0
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: Colors.white60,
                      size: 28,
                    ),
                    tooltip: value.volume > 0 ? 'Tat am thanh' : 'Bat am thanh',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==============================================================
// Bai 2 Nang Cao: Man hinh xem anh toan man hinh
// ==============================================================
class FullScreenImage extends StatelessWidget {
  final File imageFile;

  const FullScreenImage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Anh toan man hinh voi Hero animation va pinch-to-zoom
          Center(
            child: Hero(
              tag: 'selected_image',
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 5.0,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          // Nut quay lai
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              key: const Key('btn_close_fullscreen'),
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Goi y pinch-to-zoom
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pinch, size: 16, color: Colors.white60),
                    SizedBox(width: 6),
                    Text(
                      'Chum/Gian de zoom',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
