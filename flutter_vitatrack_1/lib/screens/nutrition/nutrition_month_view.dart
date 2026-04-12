import 'package:flutter/material.dart';
import 'dart:math' as math;

// ── Enums & helpers ────────────────────────────────────────────────────
enum _CalLevel { none, low, mid, high, peak }

extension _CalLevelColor on _CalLevel {
  Color get color {
    switch (this) {
      case _CalLevel.none: return const Color(0xFF1A2A1A);
      case _CalLevel.low:  return const Color(0xFF1D4A1D);
      case _CalLevel.mid:  return const Color(0xFF2E832E);
      case _CalLevel.high: return const Color(0xFF3A9F3A);
      case _CalLevel.peak: return const Color(0xFF4CB84C);
    }
  }
}

_CalLevel _levelFrom(int cal) {
  if (cal == 0)    return _CalLevel.none;
  if (cal < 1500)  return _CalLevel.low;
  if (cal < 1800)  return _CalLevel.mid;
  if (cal < 2100)  return _CalLevel.high;
  return _CalLevel.peak;
}

// ── Streak dot ─────────────────────────────────────────────────────────
enum _DotState { done, today, missed }

class _StreakDot {
  final String label;
  final _DotState state;
  const _StreakDot(this.label, this.state);
}

// ── Macro stat ─────────────────────────────────────────────────────────
class _MacroStat {
  final String name;
  final String value;
  final int percent;
  final Color color;
  const _MacroStat(this.name, this.value, this.percent, this.color);
}

// ── Main widget ────────────────────────────────────────────────────────
class NutritionMonthView extends StatelessWidget {
  const NutritionMonthView({super.key});

  static const _cyan   = Color(0xFF00E5FF);
  static const _purple = Color(0xFF7C4DFF);
  static const _cardBg = Color(0xFF1A2236);

  // 91 synthetic daily-calorie values (13 weeks × 7 days)
  static final List<int> _heatData = List.generate(91, (i) {
    final r = math.Random(i * 31 + 7);
    if (i > 85) return 0; // future days
    return 1300 + r.nextInt(1000);
  });

  static const _streakDots = [
    _StreakDot('T2', _DotState.done),
    _StreakDot('T3', _DotState.done),
    _StreakDot('T4', _DotState.done),
    _StreakDot('T5', _DotState.done),
    _StreakDot('T6', _DotState.done),
    _StreakDot('T7', _DotState.done),
    _StreakDot('CN', _DotState.today),
  ];

  static const _macros = [
    _MacroStat('Protein',  '2,550g', 71, Color(0xFFFF6B6B)),
    _MacroStat('Carbs',    '6,900g', 80, _cyan),
    _MacroStat('Chất béo', '1,620g', 77, Color(0xFFFFC107)),
    _MacroStat('Chất xơ',    '540g', 60, Color(0xFF4CAF50)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummaryCards(),
                    _buildSectionTitle('Chuỗi ngày ghi nhận'),
                    _buildStreakBox(),
                    _buildSectionTitle('Heatmap calories'),
                    _buildHeatmap(),
                    _buildSectionTitle('Tổng chất dinh dưỡng'),
                    _buildMacroGrid(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Dinh dưỡng',
                  style: TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
              SizedBox(height: 2),
              Text('Tháng 4, 2026',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
                color: Color(0xFF1A2236), shape: BoxShape.circle),
            child: const Icon(Icons.search,
                color: Color(0xFF8899AA), size: 18),
          ),
        ],
      ),
    );
  }

  // ── Summary cards ─────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _InfoCard(
              label: 'TB / ngày',
              value: '1,890 kcal',
              valueColor: _cyan)),
          const SizedBox(width: 10),
          Expanded(child: _InfoCard(
              label: 'Ngày đạt mục tiêu',
              value: '19 / 30',
              valueColor: const Color(0xFF4CAF50))),
        ],
      ),
    );
  }

  // ── Streak box ─────────────────────────────────────────────────────
  Widget _buildStreakBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chuỗi hiện tại',
                    style: TextStyle(
                        color: Color(0xFF8899AA), fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('7',
                        style: TextStyle(
                            color: _purple,
                            fontSize: 28,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text('🔥',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
                const Text('ngày liên tiếp',
                    style: TextStyle(
                        color: Color(0xFF8899AA), fontSize: 11)),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _streakDots
                  .map((d) => _buildDot(d))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(_StreakDot d) {
    Color bg, fg, border;
    switch (d.state) {
      case _DotState.done:
        bg     = _purple.withOpacity(.13);
        fg     = _purple;
        border = _purple.withOpacity(.4);
        break;
      case _DotState.today:
        bg     = _purple;
        fg     = Colors.white;
        border = _purple;
        break;
      case _DotState.missed:
        bg     = const Color(0xFF252F42);
        fg     = const Color(0xFF8899AA);
        border = const Color(0xFF252F42);
        break;
    }
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1)),
      alignment: Alignment.center,
      child: Text(d.label,
          style: TextStyle(
              color: fg,
              fontSize: 9,
              fontWeight: FontWeight.w600)),
    );
  }

  // ── Heatmap ────────────────────────────────────────────────────────
  Widget _buildHeatmap() {
    const today = 86; // index = today in _heatData

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Tháng 3',
                    style: TextStyle(
                        color: Color(0xFF8899AA), fontSize: 10)),
                Text('Tháng 4',
                    style: TextStyle(
                        color: Color(0xFF8899AA), fontSize: 10)),
              ],
            ),
            const SizedBox(height: 8),
            // Grid — 13 columns (weeks), 7 rows (days)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 13,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemCount: 91,
              itemBuilder: (ctx, i) {
                // Row-major → column-major transpose
                final col = i % 13;
                final row = i ~/ 13;
                final idx = col * 7 + row;
                final isFuture = idx >= today;
                final cal = (idx < _heatData.length && !isFuture)
                    ? _heatData[idx]
                    : 0;
                final isToday = idx == today;

                return Container(
                  decoration: BoxDecoration(
                    color: isFuture
                        ? _cyan.withOpacity(.08)
                        : _levelFrom(cal).color,
                    borderRadius: BorderRadius.circular(3),
                    border: isToday
                        ? Border.all(
                            color: _cyan.withOpacity(.6), width: 1)
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Thấp ',
                    style: TextStyle(
                        color: Color(0xFF8899AA), fontSize: 10)),
                for (final lvl in _CalLevel.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: lvl.color,
                        borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                const Text(' Cao',
                    style: TextStyle(
                        color: Color(0xFF8899AA), fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Macro grid ─────────────────────────────────────────────────────
  Widget _buildMacroGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
        children: _macros.map((m) => _MacroCard(macro: m)).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _InfoCard(
      {required this.label,
      required this.value,
      required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF8899AA), fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final _MacroStat macro;
  const _MacroCard({required this.macro});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(macro.name,
                  style: const TextStyle(
                      color: Color(0xFF8899AA), fontSize: 11)),
              Text('${macro.percent}%',
                  style: TextStyle(color: macro.color, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(macro.value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: macro.percent / 100,
              backgroundColor: const Color(0xFF252F42),
              valueColor: AlwaysStoppedAnimation(macro.color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}