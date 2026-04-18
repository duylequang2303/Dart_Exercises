// =============================================================
// Bai 5: Music Player UI - Giao dien nghe nhac hien dai
// Tinh nang:
//   - Album Art hinh tron xoay khi dang phat
//   - Slider thoi gian co the tua
//   - Danh sach bai hat ben duoi (scrollable)
//   - Nut Play/Pause/Next/Prev voi hieu ung dep
// =============================================================

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// ==============================================================
// Model Song cho man hinh nay
// ==============================================================
class MusicTrack {
  final String title;
  final String artist;
  final String album;
  final String assetPath;
  final Color primaryColor;
  final Color accentColor;
  final IconData genreIcon;

  const MusicTrack({
    required this.title,
    required this.artist,
    required this.album,
    required this.assetPath,
    required this.primaryColor,
    required this.accentColor,
    required this.genreIcon,
  });
}

// ==============================================================
// Man hinh Music Player chinh
// ==============================================================
class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with TickerProviderStateMixin {

  // Doi tuong AudioPlayer
  final AudioPlayer _player = AudioPlayer();

  // Danh sach bai hat demo
  final List<MusicTrack> _tracks = const [
    MusicTrack(
      title: 'Giấc Mơ Đêm Khuya',
      artist: 'Luna Eclipse',
      album: 'Đêm Neon',
      assetPath: 'audios/sample1.wav',
      primaryColor: Color(0xFF6C63FF),
      accentColor: Color(0xFF9B59B6),
      genreIcon: Icons.auto_awesome,
    ),
    MusicTrack(
      title: 'Sóng Biển Xanh',
      artist: 'Blue Horizon',
      album: 'Đại Dương Sâu',
      assetPath: 'audios/sample2.wav',
      primaryColor: Color(0xFF00BCD4),
      accentColor: Color(0xFF2196F3),
      genreIcon: Icons.waves,
    ),
    MusicTrack(
      title: 'Hoàng Hôn Rực Rỡ',
      artist: 'Golden Hour',
      album: 'Hè Vàng',
      assetPath: 'audios/sample3.wav',
      primaryColor: Color(0xFFFF9800),
      accentColor: Color(0xFFFF6B9D),
      genreIcon: Icons.wb_sunny,
    ),
  ];

  int _currentIndex = 0;          // Chi muc bai dang chon/phat
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isShuffle = false;        // Che do xao tron
  bool _isRepeat = false;         // Che do lap lai

  // Animation controller cho dia nhac xoay
  late AnimationController _rotationCtrl;
  // Animation controller cho hieu ung song am thanh
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    // Khoi tao animation xoay dia nhac
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Khoi tao animation pulsing (nhip dap)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Lang nghe thay doi vi tri phat
    _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    // Lang nghe tong do dai bai hat
    _player.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });

    // Lang nghe trang thai player
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _playerState = state);
        if (state == PlayerState.playing) {
          _rotationCtrl.repeat();
        } else {
          _rotationCtrl.stop();
        }
      }
    });

    // Tu dong chuyen bai khi het
    _player.onPlayerComplete.listen((_) {
      _onTrackComplete();
    });
  }

  // ============================================================
  // Xu ly khi bai hat ket thuc
  // ============================================================
  void _onTrackComplete() {
    if (_isRepeat) {
      // Lap lai bai hien tai
      _playTrack(_currentIndex);
    } else {
      // Chuyen bai tiep theo
      _playNext();
    }
  }

  // ============================================================
  // Phat bai hat theo chi muc
  // ============================================================
  Future<void> _playTrack(int index) async {
    setState(() {
      _currentIndex = index;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    try {
      await _player.play(AssetSource(_tracks[index].assetPath));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể phát "${_tracks[index].title}". '
              'Hãy thay file nhạc thật vào assets/audios/',
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else if (_playerState == PlayerState.paused) {
      await _player.resume();
    } else {
      await _playTrack(_currentIndex);
    }
  }

  Future<void> _playNext() async {
    final next = (_currentIndex + 1) % _tracks.length;
    await _playTrack(next);
  }

  Future<void> _playPrev() async {
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final prev = (_currentIndex - 1 + _tracks.length) % _tracks.length;
    await _playTrack(prev);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    _pulseCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = _tracks[_currentIndex];
    final isPlaying = _playerState == PlayerState.playing;

    return Scaffold(
      body: Container(
        // Gradient nen doi mau theo bai hat dang chon
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              track.primaryColor.withValues(alpha: 0.25),
              const Color(0xFF0A0A14),
              const Color(0xFF0A0A14),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(track),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildAlbumArt(track, isPlaying),
                      const SizedBox(height: 24),
                      _buildTrackInfo(track),
                      const SizedBox(height: 20),
                      _buildProgressSection(),
                      const SizedBox(height: 16),
                      _buildControls(isPlaying, track),
                      const SizedBox(height: 28),
                      _buildPlaylistSection(isPlaying),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AppBar tuy chinh
  // ============================================================
  Widget _buildAppBar(MusicTrack track) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Icon nhac cu trang tri
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: track.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(track.genreIcon, color: track.primaryColor, size: 20),
          ),
          const Expanded(
            child: Text(
              'Now Playing',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Nut menu (trang tri)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded,
                color: Colors.white60, size: 22),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Album Art - Dia nhac xoay
  // ============================================================
  Widget _buildAlbumArt(MusicTrack track, bool isPlaying) {
    return AnimatedBuilder(
      animation: _rotationCtrl,
      builder: (_, child) => Transform.rotate(
        angle: isPlaying ? _rotationCtrl.value * 2 * 3.14159 : 0,
        child: child,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vong sang nhung ben ngoai (glow)
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (ctx, child) => Container(
              width: 240 + (_pulseCtrl.value * (isPlaying ? 16 : 0)),
              height: 240 + (_pulseCtrl.value * (isPlaying ? 16 : 0)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: track.primaryColor
                        .withValues(alpha: 0.3 * _pulseCtrl.value),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Vien ngoai cung
          Container(
            width: 236,
            height: 236,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  track.primaryColor.withValues(alpha: 0.8),
                  track.accentColor.withValues(alpha: 0.6),
                  track.primaryColor.withValues(alpha: 0.4),
                  track.accentColor.withValues(alpha: 0.8),
                  track.primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          // Vong tron chinh cua dia nhac
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1A1A2E),
                  track.primaryColor.withValues(alpha: 0.5),
                  const Color(0xFF0A0A14),
                ],
                stops: const [0.35, 0.7, 1.0],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cac ranh dia trang tri
                for (double r in [0.88, 0.72, 0.56, 0.40])
                  Container(
                    width: 220 * r,
                    height: 220 * r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                  ),
                // Lo trung tam voi icon the loai
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0A0A14),
                    border: Border.all(
                      color: track.primaryColor.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: track.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    track.genreIcon,
                    color: track.primaryColor,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Thong tin bai hat: Ten, Nghe si, Album
  // ============================================================
  Widget _buildTrackInfo(MusicTrack track) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${track.artist} • ${track.album}',
                  style: TextStyle(
                    color: track.primaryColor.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Nut yeu thich (trang tri)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded,
                color: Colors.white38, size: 24),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Thanh tien trinh + thoi gian
  // ============================================================
  Widget _buildProgressSection() {
    final track = _tracks[_currentIndex];
    final total = _duration.inSeconds.toDouble();
    final current = _position.inSeconds.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Slider tua nhac
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: track.primaryColor,
              inactiveTrackColor: track.primaryColor.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              overlayColor: track.primaryColor.withValues(alpha: 0.25),
            ),
            child: Slider(
              key: const Key('slider_music_progress'),
              value: total > 0 ? current.clamp(0, total) : 0,
              min: 0,
              max: total > 0 ? total : 1,
              onChanged: total > 0
                  ? (v) => _player.seek(Duration(seconds: v.toInt()))
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
                Text(_fmt(_duration),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Bo nut dieu khien chinh
  // ============================================================
  Widget _buildControls(bool isPlaying, MusicTrack track) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nut Shuffle
          _buildSmallBtn(
            key: 'btn_shuffle',
            icon: Icons.shuffle_rounded,
            color: _isShuffle ? track.primaryColor : Colors.white38,
            size: 24,
            onTap: () => setState(() => _isShuffle = !_isShuffle),
          ),

          // Nut Previous
          _buildSmallBtn(
            key: 'btn_prev',
            icon: Icons.skip_previous_rounded,
            color: Colors.white,
            size: 38,
            onTap: _playPrev,
          ),

          // Nut Play/Pause (nut chinh, lon hon)
          GestureDetector(
            key: const Key('btn_play_pause'),
            onTap: _togglePlayPause,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    track.primaryColor,
                    track.accentColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: track.primaryColor.withValues(alpha: 0.55),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          // Nut Next
          _buildSmallBtn(
            key: 'btn_next',
            icon: Icons.skip_next_rounded,
            color: Colors.white,
            size: 38,
            onTap: _playNext,
          ),

          // Nut Repeat
          _buildSmallBtn(
            key: 'btn_repeat',
            icon: Icons.repeat_rounded,
            color: _isRepeat ? track.primaryColor : Colors.white38,
            size: 24,
            onTap: () => setState(() => _isRepeat = !_isRepeat),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBtn({
    required String key,
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key(key),
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }

  // ============================================================
  // Danh sach bai hat ben duoi
  // ============================================================
  Widget _buildPlaylistSection(bool isPlaying) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieu de section
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                const Text(
                  'UP NEXT',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _tracks[_currentIndex]
                        .primaryColor
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_tracks.length} bài',
                    style: TextStyle(
                      color: _tracks[_currentIndex].primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Danh sach bai hat
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tracks.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: 1,
                indent: 56,
              ),
              itemBuilder: (context, index) {
                final t = _tracks[index];
                final isActive = index == _currentIndex;

                return ListTile(
                  key: Key('track_item_$index'),
                  onTap: () => _playTrack(index),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  leading: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive
                          ? LinearGradient(colors: [
                              t.primaryColor,
                              t.accentColor
                            ])
                          : null,
                      color: isActive
                          ? null
                          : t.primaryColor.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      isActive && isPlaying
                          ? Icons.graphic_eq_rounded
                          : t.genreIcon,
                      color: isActive ? Colors.white : t.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      color: isActive ? t.primaryColor : Colors.white,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${t.artist} • ${t.album}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  trailing: isActive
                      ? Icon(Icons.equalizer_rounded,
                          color: t.primaryColor, size: 22)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 13),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

