import 'package:flutter/material.dart';
import '../core/theme.dart';

class StatCard extends StatelessWidget {
  final String tieuDe;
  final String giaTri;
  final String donVi;
  final IconData icon;
  final Color mauIcon;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.tieuDe,
    required this.giaTri,
    required this.donVi,
    required this.icon,
    required this.mauIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VitaTrackTheme.mauCard,
      borderRadius: BorderRadius.circular(VitaTrackTheme.boGocVua),
      child: InkWell(
        onTap: onTap ?? () {}, 
        borderRadius: BorderRadius.circular(VitaTrackTheme.boGocVua),
        splashColor: mauIcon.withOpacity(0.2), 
        highlightColor: mauIcon.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: mauIcon, size: 20),
                  const SizedBox(width: 8),
                  Text(tieuDe, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    giaTri,
                    style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(donVi, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}