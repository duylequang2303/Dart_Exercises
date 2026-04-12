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
  int get percent => (ratio * 100).round();
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

  // ── Bar chart ────────────────────────────────────────────────────────
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
                children: _days.map((day) {
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
                                                color: _cyan.withOpacity(.5),
                                                width: 1.5)
                                            : null,
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: maxH * frac,
                                      decoration: BoxDecoration(
                                        color: day.isToday
                                            ? _cyan.withOpacity(.35)
                                            : _purple.withOpacity(.45),
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(6)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(day.label,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: day.isToday
                                      ? _cyan
                                      : const Color(0xFF8899AA))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mục tiêu: $goal kcal/ngày',
                    style: TextStyle(fontSize: 10, color: Color(0xFF8899AA))),
                Row(
                  children: [
                    Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                            color: _cyan,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 4),
                    const Text('Hôm nay',
                        style: TextStyle(fontSize: 10, color: Color(0xFF8899AA))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Macro grid ───────────────────────────────────────────────────────
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
        children: _macros
            .map((m) => _MacroCard(macro: m))
            .toList(),
      ),
    );
  }

  // ── Best / worst ─────────────────────────────────────────────────────
  Widget _buildBestWorst() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _BestWorstCard(
            icon: '🏆', label: 'Tốt nhất',
            day: _bestDay.label,
            cal: _bestDay.calories,
            sub: 'Gần mục tiêu nhất',
            calColor: const Color(0xFF4CAF50),
          )),
          const SizedBox(width: 10),
          Expanded(child: _BestWorstCard(
            icon: '📉', label: 'Thiếu nhất',
            day: _worstDay.label,
            cal: _worstDay.calories,
            sub: 'Thiếu ${2200 - _worstDay.calories} kcal',
            calColor: const Color(0xFFFF6B6B),
          )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _InfoCard(
      {required this.label, required this.value, required this.valueColor});

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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: '${macro.current}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                TextSpan(
                    text: 'g / ${macro.goal}g',
                    style: const TextStyle(
                        color: Color(0xFF8899AA), fontSize: 11)),
              ],
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: macro.ratio,
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

class _BestWorstCard extends StatelessWidget {
  final String icon, label, day, sub;
  final int cal;
  final Color calColor;
  const _BestWorstCard({
    required this.icon, required this.label,
    required this.day, required this.cal,
    required this.sub, required this.calColor,
  });

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
          Text('$icon $label',
              style: const TextStyle(
                  color: Color(0xFF8899AA), fontSize: 11)),
          const SizedBox(height: 6),
          Text(day,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('$cal kcal',
              style: TextStyle(
                  color: calColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(
                  color: Color(0xFF8899AA), fontSize: 10)),
        ],
      ),
    );
  }
}