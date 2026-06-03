import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/ai_coach_dependencies_provider.dart';

// Import các provider và entity mới
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/food_search_provider.dart';
import 'package:flutter_vitatrack_1/features/nutrition/domain/entities/food_entity.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  String _query = '';

  void _openAiCamera() async {
    HapticFeedback.mediumImpact();
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      if (!mounted) return;

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AiCameraSheet(base64Image: base64Image),
      );
    } catch (e) {
      debugPrint("Lỗi camera: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không thể mở máy ảnh: $e"),
          backgroundColor: VitaTrackTheme.mauNguyHiem,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theo dõi danh sách kết quả từ API
    final apiResults = ref.watch(foodSearchProvider);
    final searchNotifier = ref.read(foodSearchProvider.notifier);

    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      appBar: AppBar(
        backgroundColor: VitaTrackTheme.mauCard,
        title: const Text('Thêm bữa ăn',
            style: TextStyle(
                color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: VitaTrackTheme.mauChu),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) {
                setState(() => _query = v);
                // Gọi API tìm kiếm mỗi khi người dùng nhập
                searchNotifier.timKiem(v);
              },
              style: const TextStyle(color: VitaTrackTheme.mauChu),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn (ví dụ: pho, milk...)',
                hintStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                prefixIcon: const Icon(Icons.search, color: VitaTrackTheme.mauChinh),
                fillColor: VitaTrackTheme.mauCard,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),
          ),

          // Nút nhận diện AI & Nhập tay
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openAiCamera,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          VitaTrackTheme.mauChinh.withValues(alpha: 0.15),
                          VitaTrackTheme.mauPhu.withValues(alpha: 0.15),
                        ]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded, color: VitaTrackTheme.mauChinh, size: 20),
                          SizedBox(width: 8),
                          Text('Quét AI', style: TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showManualEntryDialog(),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: VitaTrackTheme.mauCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: VitaTrackTheme.mauCardNhat),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_note_rounded, color: VitaTrackTheme.mauChinh, size: 20),
                          SizedBox(width: 8),
                          Text('Nhập tự do', style: TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Kết quả tìm kiếm',
                  style: TextStyle(
                      color: VitaTrackTheme.mauChu,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),

          // Danh sách kết quả từ API
          Expanded(
            child: apiResults.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Lỗi tìm kiếm: ${e.toString()}',
                    style: const TextStyle(color: VitaTrackTheme.mauNguyHiem)),
              ),
              data: (results) => results.isEmpty
                  ? Center(
                      child: Text(
                        _query.isEmpty ? 'Nhập tên món ăn để tìm kiếm' : 'Không tìm thấy kết quả',
                        style: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return _foodCard(item);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodCard(FoodEntity item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: VitaTrackTheme.mauChinh.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              image: item.hinhAnh != null
                  ? DecorationImage(
                      image: NetworkImage(item.hinhAnh!), fit: BoxFit.cover)
                  : null,
            ),
            child: item.hinhAnh == null
                ? const Icon(Icons.restaurant_rounded,
                    color: VitaTrackTheme.mauChinh, size: 20)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.tenMonAn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: VitaTrackTheme.mauChu,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                    'P: ${item.protein.toStringAsFixed(1)}g · C: ${item.carbs.toStringAsFixed(1)}g · F: ${item.fat.toStringAsFixed(1)}g',
                    style: const TextStyle(
                        color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.calo}',
                  style: const TextStyle(
                      color: VitaTrackTheme.mauChinh,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const Text('kcal/100g',
                  style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showPortionDialog(item),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: VitaTrackTheme.mauThanhCong, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _showPortionDialog(FoodEntity item) {
    final nameLower = item.tenMonAn.toLowerCase();
    
    // Uống
    final isDrink = nameLower.contains('nước') || 
                    nameLower.contains('sữa') || 
                    nameLower.contains('cà phê') || 
                    nameLower.contains('cafe') || 
                    nameLower.contains('trà') || 
                    nameLower.contains('tea') || 
                    nameLower.contains('coffee') || 
                    nameLower.contains('milk') || 
                    nameLower.contains('juice') ||
                    nameLower.contains('bia') ||
                    nameLower.contains('rượu') ||
                    nameLower.contains('sinh tố');

    // Suất ăn / Tô / Bát / Đĩa (phức tạp)
    final isComplex = nameLower.contains('cơm') ||
                      nameLower.contains('phở') ||
                      nameLower.contains('bún') ||
                      nameLower.contains('hủ tiếu') ||
                      nameLower.contains('mì') ||
                      nameLower.contains('bánh mì') ||
                      nameLower.contains('salad') ||
                      nameLower.contains('lẩu') ||
                      nameLower.contains('xôi');

    String unit = 'gram';
    String unitShort = 'g';
    String promptText = 'Bạn ăn bao nhiêu gam?';
    List<dynamic> quickOptions = [50, 100, 150, 200, 300];
    String initialText = '100';

    if (isDrink) {
      unit = 'ml';
      unitShort = 'ml';
      promptText = 'Bạn uống bao nhiêu ml?';
      quickOptions = [100, 200, 300, 400, 500];
      initialText = '200';
    } else if (isComplex) {
      unit = 'phần';
      unitShort = ' phần'; // Dấu cách để hiển thị đẹp: 1 phần, 2 phần
      promptText = 'Bạn ăn bao nhiêu phần? (VD: 1 phần, 1.5 phần)';
      quickOptions = [0.5, 1, 1.5, 2, 3];
      initialText = '1';
    }

    final controller = TextEditingController(text: initialText);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: VitaTrackTheme.mauCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.tenMonAn,
                style: const TextStyle(
                  color: VitaTrackTheme.mauChu,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                isComplex ? '${item.calo} kcal / 1 phần' : '${item.calo} kcal / 100$unitShort',
                style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Text(
                promptText,
                style: const TextStyle(
                  color: VitaTrackTheme.mauChu,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  suffixText: unit,
                  suffixStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                  fillColor: VitaTrackTheme.mauCardNhat,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Quick select buttons
              Wrap(
                spacing: 8,
                children: quickOptions.map((v) => GestureDetector(
                  onTap: () => controller.text = '$v',
                  child: Chip(
                    label: Text('$v$unitShort', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 12)),
                    backgroundColor: VitaTrackTheme.mauCardNhat,
                    padding: EdgeInsets.zero,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VitaTrackTheme.mauChinh,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final numV = double.tryParse(controller.text) ?? (isComplex ? 1.0 : 100.0);
                    final multiplier = isComplex ? numV : (numV / 100);
                    final caloDaTinh = (item.calo * multiplier).round();
                    
                    HapticFeedback.mediumImpact();
                    ref.read(nutritionProvider.notifier).themMonAn(
                      caloDaTinh,
                      item.protein * multiplier,
                      item.carbs * multiplier,
                      item.fat * multiplier,
                      tenMonAn: '${item.tenMonAn} ($numV $unit)',
                    );

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Đã thêm $numV $unit ${item.tenMonAn} ($caloDaTinh kcal)!'),
                      backgroundColor: VitaTrackTheme.mauThanhCong,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  child: const Text(
                    'Xác nhận',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            bool isEstimating = false;

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: VitaTrackTheme.mauCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nhập thức ăn tự do', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: VitaTrackTheme.mauChu),
                    decoration: InputDecoration(
                      labelText: 'Tên món ăn (Ví dụ: Cơm canh thập cẩm)',
                      labelStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                      filled: true,
                      fillColor: VitaTrackTheme.mauNen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: isEstimating
                          ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                          : IconButton(
                              icon: const Icon(Icons.auto_awesome, color: VitaTrackTheme.mauChinh),
                              tooltip: 'AI Ước tính Calo',
                              onPressed: () async {
                                final query = nameController.text.trim();
                                if (query.isEmpty) return;
                                
                                setModalState(() => isEstimating = true);
                                try {
                                  final groqKey = dotenv.env['GROQ_API_KEY'] ?? '';
                                  final dataSource = ref.read(foodApiDataSourceProvider);
                                  final results = await dataSource.estimateByAI(query, groqKey);
                                  
                                  if (results.isNotEmpty) {
                                    calController.text = results.first.calo.toString();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI không thể ước tính món này')));
                                  }
                                } catch (e) {
                                  final errorMsg = e.toString().replaceAll('Exception: ', '');
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
                                } finally {
                                  if (mounted) setModalState(() => isEstimating = false);
                                }
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: calController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: VitaTrackTheme.mauChu),
                    decoration: InputDecoration(
                      labelText: 'Lượng Calo (kcal)',
                      labelStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                      filled: true,
                      fillColor: VitaTrackTheme.mauNen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VitaTrackTheme.mauThanhCong,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final calo = int.tryParse(calController.text.trim()) ?? 0;
                        if (name.isEmpty || calo <= 0) return;
                        
                        ref.read(nutritionProvider.notifier).themMonAn(
                          calo, 0, 0, 0,
                          tenMonAn: name,
                        );
                        Navigator.pop(ctx); // Đóng bottom sheet
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm món ăn!'), behavior: SnackBarBehavior.floating));
                          Navigator.pop(context); // Quay về màn hình dinh dưỡng chính
                        }
                      },
                      child: const Text('Lưu món ăn', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AiCameraSheet extends ConsumerStatefulWidget {
  final String base64Image;
  const _AiCameraSheet({required this.base64Image});

  @override
  ConsumerState<_AiCameraSheet> createState() => _AiCameraSheetState();
}

class _AiCameraSheetState extends ConsumerState<_AiCameraSheet> {
  int _step = 0; // 0: loading, 1: success, 2: error
  Map<String, dynamic> _result = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  void _analyzeImage() async {
    try {
      final groq = ref.read(groqApiDataSourceProvider);
      final res = await groq.analyzeFoodImage(widget.base64Image);
      if (mounted) {
        setState(() {
          _result = res;
          _step = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _step = 2;
          _errorMessage = e.toString().replaceAll('GroqApiException: ', '').replaceAll('GeminiApiException: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(20)),
      child: _step == 0 
          ? _buildLoading() 
          : _step == 1 
              ? _buildResult(context)
              : _buildError(),
    );
  }

  Widget _buildLoading() => Column(mainAxisSize: MainAxisSize.min, children: const [
        SizedBox(height: 12),
        CircularProgressIndicator(color: VitaTrackTheme.mauChinh, strokeWidth: 3),
        SizedBox(height: 18),
        Text('AI đang phân tích món ăn...',
            style: TextStyle(
                color: VitaTrackTheme.mauChu,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Nhận diện thành phần dinh dưỡng',
            style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
        SizedBox(height: 18),
      ]);

  Widget _buildError() => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        const Icon(Icons.error_outline_rounded, color: VitaTrackTheme.mauNguyHiem, size: 48),
        const SizedBox(height: 18),
        const Text('Lỗi phân tích',
            style: TextStyle(
                color: VitaTrackTheme.mauChu,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_errorMessage ?? 'Vui lòng thử chụp lại ảnh rõ nét hơn.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ),
      ]);

  Widget _buildResult(BuildContext context) {
    final ten = _result['tenMonAn'] as String? ?? 'Món ăn';
    final calo = (_result['calo'] as num?)?.toInt() ?? 0;
    final protein = (_result['protein'] as num?)?.toDouble() ?? 0.0;
    final carbs = (_result['carbs'] as num?)?.toDouble() ?? 0.0;
    final fat = (_result['fat'] as num?)?.toDouble() ?? 0.0;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check_circle_rounded,
          color: VitaTrackTheme.mauThanhCong, size: 48),
      const SizedBox(height: 12),
      Text('Đã nhận diện: $ten',
          style: const TextStyle(
              color: VitaTrackTheme.mauChu,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _macroChip('$calo kcal', VitaTrackTheme.mauChinh),
        _macroChip('P: ${protein.toStringAsFixed(1)}g', VitaTrackTheme.mauNguyHiem),
        _macroChip('C: ${carbs.toStringAsFixed(1)}g', VitaTrackTheme.mauCanhBao),
        _macroChip('F: ${fat.toStringAsFixed(1)}g', VitaTrackTheme.mauPhu),
      ]),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: VitaTrackTheme.mauChinh,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(nutritionProvider.notifier).themMonAn(
              calo, protein, carbs, fat,
              tenMonAn: ten,
            );
            Navigator.pop(context);
          },
          child: const Text('Thêm vào nhật ký',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ),
    ]);
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}