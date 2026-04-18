// =============================================================
// Bai tap 4: Simple Audio Player
// Tinh nang: Phat nhac tu assets voi danh sach 3 bai hat,
//            nut Play, Pause, Stop, Next, Previous,
//            tu dong chuyen bai khi het.
// =============================================================

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// ==============================================================
// Model dai dien cho mot bai hat trong danh sach phat
// ==============================================================
class Song {
  final String title;    // Ten bai hat
  final String artist;   // Ten nghe si
  final String assetPath; // Duong dan trong assets
  final Color themeColor; // Mau sac dai dien cho bai hat

  const Song({
    required this.title,
    required this.artist,
    required this.assetPath,
    required this.themeColor,
  });
}

// ==============================================================
// Man hinh Audio Player
// ==============================================================
class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {

  // Doi tuong AudioPlayer de phat nhac
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Danh sach 3 bai hat tu thu muc assets/audios/
  final List<Song> _playlist = const [
    Song(
      title: 'Sample Track 01',
      artist: 'Artist One',
      assetPath: 'audios/sample1.wav',
      themeColor: Color(0xFF6C63FF),
    ),
    Song(
      title: 'Sample Track 02',
      artist: 'Artist Two',
      assetPath: 'audios/sample2.wav',
      themeColor: Color(0xFFFF6B9D),
    ),
    Song(
      title: 'Sample Track 03',
      artist: 'Artist Three',
      assetPath: 'audios/sample3.wav',
      themeColor: Color(0xFF00BCD4),
    ),
  ];

  // Chi muc bai hat dang phat (mac dinh bai dau tien)
  int _currentIndex = 0;

  // Trang thai player
  PlayerState _playerState = PlayerState.stopped;

  // Vi tri hien tai trong bai hat
  Duration _currentPosition = Duration.zero;

  // Tong thoi luong bai hat
  Duration _totalDuration = Duration.zero;

  // Am luong hien tai (0.0 - 1.0)
  double _volume = 1.0;

  // Animation controller cho dia nhac xoay
  late AnimationController _diskAnimController;

  @override
  void initState() {
    super.initState();

    // Khoi tao animation controller cho hieu ung xoay dia nhac
    _diskAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(); // Tu dong lap

    // Lang nghe thay doi vi tri phat
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    });

    // Lang nghe thay doi tong thoi luong bai hat
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _totalDuration = duration);
      }
    });

    // Lang nghe trang thai player (playing, paused, stopped, completed)
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _playerState = state);
        // Dung animation khi khong play
        if (state == PlayerState.playing) {
          _diskAnimController.repeat();
        } else {
          _diskAnimController.stop();
        }
      }
    });

    // onPlayerComplete: Tu dong chuyen sang bai tiep theo khi ket thuc
    _audioPlayer.onPlayerComplete.listen((_) {
      _playNext();
    });
  }

  // ============================================================
  // Ham phat bai hat theo chi muc
  // ============================================================
  Future<void> _playAtIndex(int index) async {
    // Cap nhat chi muc bai hien tai
    setState(() {
      _currentIndex = index;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });

    try {
      // Phat bai hat tu asset
      await _audioPlayer.play(
        AssetSource(_playlist[index].assetPath),
      );

      // Dat am luong
      await _audioPlayer.setVolume(_volume);
    } catch (e) {
      // Xu ly loi khi file audio khong hop le hoac platform khong ho tro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Khong the phat "${_playlist[index].title}". '
              'Hay thay file MP3 that vao assets/audios/',
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

  // ============================================================
  // Nut Play
  // ============================================================
  Future<void> _play() async {
    if (_playerState == PlayerState.paused) {
      // Tiep tuc phat neu dang tam dung
      await _audioPlayer.resume();
    } else {
      // Phat bai hien tai tu dau
      await _playAtIndex(_currentIndex);
    }
  }

  // ============================================================
  // Nut Pause
  // ============================================================
  Future<void> _pause() async {
    await _audioPlayer.pause();
  }

  // ============================================================
  // Nut Stop
  // ============================================================
  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _currentPosition = Duration.zero;
    });
  }

  // ============================================================
  // Nut Next: Chuyen sang bai tiep theo (vong lai)
  // ============================================================
  Future<void> _playNext() async {
    final nextIndex = (_currentIndex + 1) % _playlist.length;
    await _playAtIndex(nextIndex);
  }

  // ============================================================
  // Nut Previous: Quay lai bai truoc (vong lai)
  // ============================================================
  Future<void> _playPrevious() async {
    // Neu da phat hon 3 giay thi quay lai dau bai hien tai
    if (_currentPosition.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      return;
    }
    final prevIndex =
        (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await _playAtIndex(prevIndex);
  }

  // ============================================================
  // Tua den vi tri cu the trong bai hat
  // ============================================================
  Future<void> _seekTo(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  // ============================================================
  // Dinh dang Duration thanh chuoi mm:ss
  // ============================================================
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _diskAnimController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = _playlist[_currentIndex];
    final isPlaying = _playerState == PlayerState.playing;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Audio Player',
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
      body: Container(
        // Gradient nen theo mau chu de cua bai hat hien tai
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0F0F1A),
              song.themeColor.withValues(alpha: 0.15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // ------------------------------------------------
                // Dia nhac xoay (album art)
                // ------------------------------------------------
                Expanded(
                  flex: 4,
                  child: Center(child: _buildDiskArt(song, isPlaying)),
                ),

                // ------------------------------------------------
                // Ten bai hat va nghe si
                // ------------------------------------------------
                _buildSongInfo(song),

                const SizedBox(height: 24),

                // ------------------------------------------------
                // Thanh tien trinh va thoi gian
                // ------------------------------------------------
                _buildProgressBar(),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // Cac nut dieu khien chinh
                // ------------------------------------------------
                _buildMainControls(isPlaying),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // Thanh am luong
                // ------------------------------------------------
                _buildVolumeControl(),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // Danh sach phat thu nho
                // ------------------------------------------------
                _buildMiniPlaylist(),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Widget dia nhac xoay
  // ============================================================
  Widget _buildDiskArt(Song song, bool isPlaying) {
    return AnimatedBuilder(
      animation: _diskAnimController,
      builder: (context, child) {
        return Transform.rotate(
          // Xoay theo animation (chi xoay khi dang phat)
          angle: isPlaying
              ? _diskAnimController.value * 2 * 3.14159
              : 0,
          child: child,
        );
      },
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              song.themeColor.withValues(alpha: 0.9),
              song.themeColor.withValues(alpha: 0.4),
              const Color(0xFF1A1A2E),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: song.themeColor.withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cac vong tron trang tri
            for (double r in [0.85, 0.65, 0.45])
              Container(
                width: 220 * r,
                height: 220 * r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
              ),
            // Tam tron trung tam (lo dia nhac)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F0F1A),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Icon(
                Icons.music_note_rounded,
                color: song.themeColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Widget hien thi ten bai hat va nghe si
  // ============================================================
  Widget _buildSongInfo(Song song) {
    return Column(
      children: [
        Text(
          song.title,
          key: const Key('text_song_title'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          song.artist,
          key: const Key('text_song_artist'),
          style: TextStyle(
            color: song.themeColor.withValues(alpha: 0.8),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Widget thanh tien trinh bai hat
  // ============================================================
  Widget _buildProgressBar() {
    final total = _totalDuration.inSeconds.toDouble();
    final current = _currentPosition.inSeconds.toDouble();

    return Column(
      children: [
        // Slider tua nhac
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: _playlist[_currentIndex].themeColor,
            inactiveTrackColor:
                _playlist[_currentIndex].themeColor.withValues(alpha: 0.2),
            thumbColor: _playlist[_currentIndex].themeColor,
            overlayColor:
                _playlist[_currentIndex].themeColor.withValues(alpha: 0.2),
          ),
          child: Slider(
            key: const Key('slider_progress'),
            value: total > 0 ? current.clamp(0, total) : 0,
            min: 0,
            max: total > 0 ? total : 1,
            onChanged: total > 0 ? _seekTo : null,
          ),
        ),

        // Hien thi thoi gian
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Widget cac nut dieu khien chinh: Prev, Play/Pause, Stop, Next
  // ============================================================
  Widget _buildMainControls(bool isPlaying) {
    final color = _playlist[_currentIndex].themeColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Nut Previous
        _buildControlButton(
          id: 'btn_previous',
          icon: Icons.skip_previous_rounded,
          size: 36,
          color: Colors.white70,
          onTap: _playPrevious,
          tooltip: 'Bai truoc',
        ),

        // Nut Play / Pause (lon hon)
        GestureDetector(
          key: const Key('btn_play_pause'),
          onTap: isPlaying ? _pause : _play,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        ),

        // Nut Stop
        _buildControlButton(
          id: 'btn_stop',
          icon: Icons.stop_rounded,
          size: 32,
          color: Colors.white70,
          onTap: _stop,
          tooltip: 'Dung',
        ),

        // Nut Next
        _buildControlButton(
          id: 'btn_next',
          icon: Icons.skip_next_rounded,
          size: 36,
          color: Colors.white70,
          onTap: _playNext,
          tooltip: 'Bai tiep theo',
        ),
      ],
    );
  }

  // ============================================================
  // Widget nut dieu khien nho
  // ============================================================
  Widget _buildControlButton({
    required String id,
    required IconData icon,
    required double size,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key(id),
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: size),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Widget thanh dieu chinh am luong
  // ============================================================
  Widget _buildVolumeControl() {
    return Row(
      children: [
        const Icon(Icons.volume_down_rounded, color: Colors.white38, size: 20),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: Colors.white54,
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white60,
            ),
            child: Slider(
              key: const Key('slider_volume'),
              value: _volume,
              min: 0.0,
              max: 1.0,
              onChanged: (value) async {
                setState(() => _volume = value);
                await _audioPlayer.setVolume(value);
              },
            ),
          ),
        ),
        const Icon(Icons.volume_up_rounded, color: Colors.white38, size: 20),
      ],
    );
  }

  // ============================================================
  // Widget danh sach phat thu nho
  // ============================================================
  Widget _buildMiniPlaylist() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: List.generate(_playlist.length, (index) {
          final song = _playlist[index];
          final isActive = index == _currentIndex;

          return ListTile(
            key: Key('playlist_item_$index'),
            onTap: () => _playAtIndex(index),
            dense: true,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: song.themeColor.withValues(alpha: isActive ? 0.9 : 0.3),
              ),
              child: Icon(
                isActive && _playerState == PlayerState.playing
                    ? Icons.graphic_eq_rounded  // Bieu tuong dang phat
                    : Icons.music_note_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            title: Text(
              song.title,
              style: TextStyle(
                color: isActive ? song.themeColor : Colors.white70,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              song.artist,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            trailing: isActive
                ? Icon(Icons.equalizer_rounded,
                    color: song.themeColor, size: 20)
                : null,
          );
        }),
      ),
    );
  }
}
