import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/ai_coach_dependencies_provider.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';

class MealPlanBottomSheetContent extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> initialMeals;
  final int targetCalo;

  const MealPlanBottomSheetContent({
    Key? key,
    required this.initialMeals,
    required this.targetCalo,
  }) : super(key: key);

  @override
  ConsumerState<MealPlanBottomSheetContent> createState() => _MealPlanBottomSheetContentState();
}

class _MealPlanBottomSheetContentState extends ConsumerState<MealPlanBottomSheetContent> {
  late List<Map<String, dynamic>> _meals;
  bool _isRegenerating = false;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _meals = List.from(widget.initialMeals);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleRegenerate() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) return;

    setState(() {
      _isRegenerating = true;
    });

    try {
      final apiKey = kGroqApiKey;
      final planner = ref.read(aiPlannerDataSourceProvider);
      final newMeals = await planner.generateMealPlan(apiKey, widget.targetCalo, userFeedback: feedback);

      if (!mounted) return;
      setState(() {
        _isRegenerating = false;
        if (newMeals != null && newMeals.isNotEmpty) {
          _meals = newMeals;
          _feedbackController.clear();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật thực đơn theo yêu cầu!'), backgroundColor: VitaTrackTheme.mauThanhCong));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tạo lại thực đơn lúc này.')));
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRegenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCals = _meals.fold<int>(0, (sum, m) => sum + ((m['calo'] as num?)?.toInt() ?? 0));
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: VitaTrackTheme.mauNen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: VitaTrackTheme.mauCardNhat, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Thực đơn AI đề xuất', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Tổng: $totalCals kcal', style: const TextStyle(color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          if (_isRegenerating)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: VitaTrackTheme.mauChinh),
                    SizedBox(height: 16),
                    Text('AI đang điều chỉnh lại thực đơn...', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  final name = meal['tenMonAn'] ?? 'Món ăn';
                  final cal = (meal['calo'] as num?)?.toInt() ?? 0;
                  final p = (meal['protein'] as num?)?.toDouble() ?? 0;
                  final c = (meal['carbs'] as num?)?.toDouble() ?? 0;
                  final f = (meal['fat'] as num?)?.toDouble() ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(name, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16))),
                            Text('$cal kcal', style: const TextStyle(color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('P: ${p}g', style: const TextStyle(color: VitaTrackTheme.mauNguyHiem, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Text('C: ${c}g', style: const TextStyle(color: VitaTrackTheme.mauCanhBao, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Text('F: ${f}g', style: const TextStyle(color: VitaTrackTheme.mauPhu, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            
          // Khu vực nhập phản hồi
          Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _feedbackController,
                        style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'VD: Tôi muốn ăn chay, ít ngọt...',
                          hintStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14),
                          filled: true,
                          fillColor: VitaTrackTheme.mauCard,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _isRegenerating ? null : _handleRegenerate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: VitaTrackTheme.mauChinh, shape: BoxShape.circle),
                        child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: VitaTrackTheme.mauCardNhat),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VitaTrackTheme.mauThanhCong,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isRegenerating ? null : () async {
                          setState(() {
                            _isRegenerating = true;
                          });
                          try {
                            for (final m in _meals) {
                              await ref.read(nutritionProvider.notifier).themMonAn(
                                (m['calo'] as num?)?.toInt() ?? 0,
                                (m['protein'] as num?)?.toDouble() ?? 0,
                                (m['carbs'] as num?)?.toDouble() ?? 0,
                                (m['fat'] as num?)?.toDouble() ?? 0,
                                tenMonAn: m['tenMonAn'] ?? 'Món ăn',
                              );
                            }
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã áp dụng thực đơn vào nhật ký!'), backgroundColor: VitaTrackTheme.mauThanhCong));
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _isRegenerating = false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                          }
                        },
                        child: _isRegenerating 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Áp dụng ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
