// =============================================================
// Bài tập 4: Trình phát nhạc đơn giản (Simple Audio Player)
// Tính năng: Phát nhạc từ assets với danh sách 3 bài hát,
//            nút Phát, Tạm dừng, Dừng, Kế tiếp, Trước đó,
//            tự động chuyển bài khi kết thúc.
// =============================================================

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// ==============================================================
// Model đại diện cho một bài hát trong danh sách phát
// ==============================================================
class Song {
  final String title;
  final String artist;
  final String assetPath;
  final Color themeColor;
  final IconData icon;

  const Song({
    required this.title,
    required this.artist,
    required this.assetPath,
    required this.themeColor,
    this.icon = Icons.music_note_rounded,
  });
}

// ==============================================================
// Màn hình Audio Player
// ==============================================================
class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Song> _playlist = const [
    Song(
      title: 'Bài hát mẫu số 1',
      artist: 'Nghệ sĩ Một',
      assetPath: 'audios/sample1.wav',
      themeColor: Color(0xFF6C63FF),
      icon: Icons.headphones_rounded,
    ),
    Song(
      title: 'Bài hát mẫu số 2',
      artist: 'Nghệ sĩ Hai',
      assetPath: 'audios/sample2.wav',
      themeColor: Color(0xFFFF6B9D),
      icon: Icons.radio_rounded,
    ),
    Song(
      title: 'Bài hát mẫu số 3',
      artist: 'Nghệ sĩ Ba',
      assetPath: 'audios/sample3.wav',
      themeColor: Color(0xFF00BCD4),
      icon: Icons.queue_music_rounded,
    ),
  ];

  int _currentIndex = 0;
  PlayerState _playerState = PlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _currentPosition = pos);
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _totalDuration = dur);
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
    _audioPlayer.onPlayerComplete.listen((_) => _playNext());
  }

  Future<void> _playAtIndex(int index) async {
    setState(() {
      _currentIndex = index;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });
    try {
      await _audioPlayer.play(AssetSource(_playlist[index].assetPath));
      await _audioPlayer.setVolume(_volume);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát "${_playlist[index].title}". Hãy thay file nhạc thật vào assets/audios/'),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _play() async {
    if (_playerState == PlayerState.paused) {
      await _audioPlayer.resume();
    } else {
      await _playAtIndex(_currentIndex);
    }
  }

  Future<void> _pause() async => _audioPlayer.pause();

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() => _currentPosition = Duration.zero);
  }

  Future<void> _playNext() async {
    await _playAtIndex((_currentIndex + 1) % _playlist.length);
  }

  Future<void> _playPrevious() async {
    if (_currentPosition.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      return;
    }
    await _playAtIndex((_currentIndex - 1 + _playlist.length) % _playlist.length);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = _playlist[_currentIndex];
    final isPlaying = _playerState == PlayerState.playing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trình Phát Nhạc', style: TextStyle(fontWeight: FontWeight.bold)),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF0F0F1A), song.themeColor.withValues(alpha: 0.12)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // -----------------------------------------------
                // Ảnh bìa album hình vuông có bo góc (TĨNH)
                // -----------------------------------------------
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [song.themeColor, song.themeColor.withValues(alpha: 0.4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: song.themeColor.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(song.icon, size: 80, color: Colors.white.withValues(alpha: 0.9)),
                          const SizedBox(height: 12),
                          Text(
                            'Bài ${_currentIndex + 1} / ${_playlist.length}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // -----------------------------------------------
                // Tên bài hát và nghệ sĩ
                // -----------------------------------------------
                Text(
                  song.title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  song.artist,
                  style: TextStyle(color: song.themeColor.withValues(alpha: 0.85), fontSize: 15),
                ),
                const SizedBox(height: 24),

                // -----------------------------------------------
                // Thanh tiến trình
                // -----------------------------------------------
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    activeTrackColor: song.themeColor,
                    inactiveTrackColor: song.themeColor.withValues(alpha: 0.2),
                    thumbColor: song.themeColor,
                    overlayColor: song.themeColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _totalDuration.inSeconds > 0
                        ? _currentPosition.inSeconds.toDouble().clamp(0, _totalDuration.inSeconds.toDouble())
                        : 0,
                    max: _totalDuration.inSeconds > 0 ? _totalDuration.inSeconds.toDouble() : 1,
                    onChanged: _totalDuration.inSeconds > 0
                        ? (v) => _audioPlayer.seek(Duration(seconds: v.toInt()))
                        : null,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(_currentPosition), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(_fmt(_totalDuration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 20),

                // -----------------------------------------------
                // Nút điều khiển: Trước | Phát/Tạm dừng | Dừng | Tiếp
                // -----------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ctrlBtn(id: 'btn_prev', icon: Icons.skip_previous_rounded, size: 36, onTap: _playPrevious, tooltip: 'Trước'),
                    GestureDetector(
                      key: const Key('btn_play_pause'),
                      onTap: isPlaying ? _pause : _play,
                      child: Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [song.themeColor, song.themeColor.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          boxShadow: [BoxShadow(color: song.themeColor.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2)],
                        ),
                        child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 42),
                      ),
                    ),
                    _ctrlBtn(id: 'btn_stop', icon: Icons.stop_rounded, size: 32, onTap: _stop, tooltip: 'Dừng'),
                    _ctrlBtn(id: 'btn_next', icon: Icons.skip_next_rounded, size: 36, onTap: _playNext, tooltip: 'Tiếp theo'),
                  ],
                ),
                const SizedBox(height: 20),

                // -----------------------------------------------
                // Thanh âm lượng
                // -----------------------------------------------
                Row(
                  children: [
                    const Icon(Icons.volume_down_rounded, color: Colors.white38, size: 20),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: Colors.white54,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: Colors.white60,
                        ),
                        child: Slider(
                          key: const Key('slider_volume'),
                          value: _volume, min: 0.0, max: 1.0,
                          onChanged: (v) async {
                            setState(() => _volume = v);
                            await _audioPlayer.setVolume(v);
                          },
                        ),
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded, color: Colors.white38, size: 20),
                  ],
                ),
                const SizedBox(height: 16),

                // -----------------------------------------------
                // Danh sách phát thu nhỏ
                // -----------------------------------------------
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: List.generate(_playlist.length, (i) {
                      final s = _playlist[i];
                      final isActive = i == _currentIndex;
                      return ListTile(
                        key: Key('playlist_item_$i'),
                        onTap: () => _playAtIndex(i),
                        dense: true,
                        leading: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.themeColor.withValues(alpha: isActive ? 0.9 : 0.3),
                          ),
                          child: Icon(
                            isActive && _playerState == PlayerState.playing
                                ? Icons.graphic_eq_rounded
                                : s.icon,
                            color: Colors.white, size: 18,
                          ),
                        ),
                        title: Text(s.title, style: TextStyle(
                          color: isActive ? s.themeColor : Colors.white70,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                          fontSize: 13,
                        )),
                        subtitle: Text(s.artist, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        trailing: isActive ? Icon(Icons.equalizer_rounded, color: s.themeColor, size: 20) : null,
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ctrlBtn({
    required String id,
    required IconData icon,
    required double size,
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
            child: Icon(icon, color: Colors.white70, size: size),
          ),
        ),
      ),
    );
  }
}
