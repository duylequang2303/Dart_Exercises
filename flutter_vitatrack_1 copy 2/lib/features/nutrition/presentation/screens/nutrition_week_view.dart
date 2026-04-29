import 'package:flutter/material.dart';


class _DayCalorie {
  final String label;
  final int calories;
  final bool isToday;
  const _DayCalorie(this.label, this.calories, {this.isToday = false});
}

class _MacroStat {
  final String name;
  final int current;
  final int goal;
  final Color color;
  const _MacroStat(this.name, this.current, this.goal, this.color);
  double get ratio => (current / goal).clamp(0.0, 1.0);
}

// ── Widget chính ───────────────────────────────────────────────────────
class NutritionWeekView extends StatelessWidget {
  const NutritionWeekView({super.key});

  static const _cyan = Color(0xFF00E5FF);
  static const _purple = Color(0xFF7C4DFF);
  static const _cardBg = Color(0xFF1A2236);
  static const _barBg = Color(0xFF252F42);

  static final _days = [
    const _DayCalorie('T2', 2100),
    const _DayCalorie('T3', 1750),
    const _DayCalorie('T4', 1920),
    const _DayCalorie('T5', 1600),
    const _DayCalorie('T6', 2050),
    const _DayCalorie('T7', 2185),
    const _DayCalorie('CN', 1310, isToday: true),
  ];

  static final _macros = [
    const _MacroStat('Protein',  89,  120, Color(0xFFFF6B6B)),
    const _MacroStat('Carbs',   230,  280, _cyan),
    const _MacroStat('Chất béo', 54,   70, Color(0xFFFFC107)),
    const _MacroStat('Chất xơ',  19,   30, Color(0xFF4CAF50)),
  ];

  int get _avgCalories {
    final total = _days.fold(0, (s, d) => s + d.calories);
    return (total / _days.length).round();
  }

  int get _totalCalories => _days.fold(0, (s, d) => s + d.calories);

  _DayCalorie get _bestDay =>
      _days.reduce((a, b) => (a.calories - 2200).abs() < (b.calories - 2200).abs() ? a : b);

  _DayCalorie get _worstDay =>
      _days.reduce((a, b) => a.calories < b.calories ? a : b);

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
                    _buildSectionTitle('Calories theo ngày'),
                    _buildBarChart(),
                    _buildSectionTitle('Chất dinh dưỡng TB/ngày'),
                    _buildMacroGrid(),
                    _buildSectionTitle('Ngày tốt nhất / tệ nhất'),
                    _buildBestWorst(),
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
              Text('Tuần này',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _cardBg, shape: BoxShape.circle),
            child: const Icon(Icons.search, color: Color(0xFF8899AA), size: 18),
          ),
        ],
      ),
    );
  }

  // ── Summary cards ────────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _InfoCard(label: 'Trung bình / ngày',
              value: '$_avgCalories kcal', valueColor: _cyan)),
          const SizedBox(width: 10),
          Expanded(child: _InfoCard(label: 'Tổng tuần',
              value: '${_totalCalories.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
                  ' kcal', valueColor: _purple)),
        ],
      ),
    );
  }

  // ── Bar chart ───────────────────────────────────────────────────────-
  Widget _buildBarChart() {
    const goal = 2200;
    final maxCal = _days.map((d) => d.calories).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _days.map<Widget>((day) {
                  final frac = day.calories / maxCal;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${day.calories}',
                              style: TextStyle(
                                  fontSize: 8,
                                  color: day.isToday
                                      ? _cyan
                                      : Colors.white70)),
                          const SizedBox(height: 4),
                          Flexible(
                            child: LayoutBuilder(
                              builder: (ctx, cst) {
                                final maxH = cst.maxHeight;
                                return Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: maxH,
                                      decoration: BoxDecoration(
                                        color: _barBg,
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(6)),
                                        border: day.isToday
                                            ? Border.all(
                                                color: _cyan.withValues(alpha: .5),
                                                width: 1.5)
                                            : null,
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: maxH * frac,
                                      decoration: BoxDecoration(
                                        color: day.isToday
                                            ? _cyan.withValues(alpha: .35)
                                            : _purple.withValues(alpha: .45),
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(6)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionMetric('Trung bình', '$_avgCalories kcal', _cyan),
                _buildSectionMetric('Tổng tuần', '$_totalCalories kcal', _purple),
                _buildSectionMetric('Mục tiêu', '$goal kcal', Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _buildMacroGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _macros.map<Widget>((m) => _MacroCard(m)).toList(),
      ),
    );
  }

  Widget _buildBestWorst() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _StatCard(label: 'Ngày tốt nhất', value: '${_bestDay.label} • ${_bestDay.calories} kcal')),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(label: 'Ngày tệ nhất', value: '${_worstDay.label} • ${_worstDay.calories} kcal')),
        ],
      ),
    );
  }

  Widget _buildSectionMetric(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF9AA6BD), fontSize: 12)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _InfoCard({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF11131A), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9AA6BD), fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final _MacroStat stat;
  const _MacroCard(this.stat);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF11131A), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.name, style: const TextStyle(color: Color(0xFF9AA6BD))),
          const SizedBox(height: 8),
          Text('${stat.current} / ${stat.goal}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: stat.ratio, color: stat.color, backgroundColor: const Color(0xFF1A2236)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF11131A), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9AA6BD), fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
