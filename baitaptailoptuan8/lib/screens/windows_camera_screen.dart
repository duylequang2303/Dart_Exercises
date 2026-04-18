import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class WindowsCameraScreen extends StatefulWidget {
  const WindowsCameraScreen({super.key});

  @override
  State<WindowsCameraScreen> createState() => _WindowsCameraScreenState();
}

class _WindowsCameraScreenState extends State<WindowsCameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitializing = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMsg = "Không tìm thấy WebCam/Camera nào trên máy!";
          _isInitializing = false;
        });
        return;
      }

      // Khởi tạo camera đầu tiên tìm thấy
      _controller = CameraController(_cameras[0], ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = "Lỗi khởi tạo Camera: $e";
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, file); // Trả về file ảnh dạng XFile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chụp ảnh: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Nút Back trong viền trong suốt
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Chụp ảnh từ Camera', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _isInitializing
            ? const CircularProgressIndicator(color: Colors.white)
            : _errorMsg != null
                ? Text(_errorMsg!, style: const TextStyle(color: Colors.white, fontSize: 16))
                : CameraPreview(_controller!), // Hiển thị luồng video từ webcam
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _controller != null && _controller!.value.isInitialized
          ? SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: _captureImage,
                backgroundColor: Colors.white,
                shape: const CircleBorder(side: BorderSide(color: Colors.grey, width: 4)),
                child: const Icon(Icons.camera, color: Colors.black87, size: 36),
              ),
            )
          : null,
    );
  }
}
