// =============================================================
// Bai 6: SQLite User Profile Management
// Tinh nang:
//   - Hien thi danh sach nguoi dung voi avatar hinh tron
//   - Them nguoi dung moi
//   - Trang "Edit Profile": chinh sua ten, email, chon anh avatar
//   - Xoa nguoi dung
//   - Luu toan bo thong tin vao SQLite
// =============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../db/database_helper.dart';
import '../models/user_model.dart';

// ==============================================================
// Man hinh danh sach nguoi dung
// ==============================================================
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final DatabaseHelper _db = DatabaseHelper();

  // Danh sach nguoi dung tai tu SQLite
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // ============================================================
  // Tai danh sach nguoi dung tu SQLite
  // ============================================================
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _db.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // Mo trang Edit Profile (them moi hoac chinh sua)
  // ============================================================
  Future<void> _openEditProfile({User? user}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: user),
      ),
    );
    // Neu luu thanh cong, load lai danh sach
    if (result == true) {
      _loadUsers();
    }
  }

  // ============================================================
  // Xoa nguoi dung voi xac nhan
  // ============================================================
  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoa nguoi dung',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Ban co chac muon xoa "${user.name}" khong?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huy', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoa',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteUser(user.id!);
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Da xoa "${user.name}"'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profiles',
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
        // Hien thi so luong user trong appbar
        actions: [
          if (!_isLoading)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_users.length} users',
                  style: const TextStyle(
                      color: Color(0xFF9E9EFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: const Color(0xFF0F0F1A),

      // --------------------------------------------------------
      // FAB: Them nguoi dung moi
      // --------------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_add_user'),
        onPressed: () => _openEditProfile(),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label:
            const Text('Them User', style: TextStyle(color: Colors.white)),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _users.isEmpty
              ? _buildEmptyState()
              : _buildUserList(),
    );
  }

  // ============================================================
  // Trang thai chua co nguoi dung nao
  // ============================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline_rounded,
                size: 60, color: Color(0xFF4A4A6A)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chua co nguoi dung nao',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhan nut ben duoi de them nguoi dung moi',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Danh sach nguoi dung - ListView voi avatar hinh tron
  // ============================================================
  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user, index);
      },
    );
  }

  // ============================================================
  // Card hien thi thong tin nguoi dung
  // ============================================================
  Widget _buildUserCard(User user, int index) {
    // Mau sac xoay vong theo thu tu user
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6B9D),
      const Color(0xFF00BCD4),
      const Color(0xFFFF9800),
      const Color(0xFF4CAF50),
    ];
    final color = colors[index % colors.length];

    return Container(
      key: Key('user_card_${user.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _openEditProfile(user: user),

        // ------- Avatar hinh tron -------
        leading: _buildAvatarCircle(user, color, size: 52),

        // ------- Thong tin user -------
        title: Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              user.email,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'ID: ${user.id}',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // ------- Nut hanh dong -------
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nut Chinh sua
            IconButton(
              key: Key('btn_edit_user_${user.id}'),
              onPressed: () => _openEditProfile(user: user),
              icon: Icon(Icons.edit_rounded, color: color, size: 20),
              tooltip: 'Chinh sua',
            ),
            // Nut Xoa
            IconButton(
              key: Key('btn_delete_user_${user.id}'),
              onPressed: () => _deleteUser(user),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 20),
              tooltip: 'Xoa',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Widget avatar hinh tron - co the dung o nhieu cho
  // ============================================================
  static Widget _buildAvatarCircle(User user, Color color,
      {double size = 52}) {
    final hasAvatar =
        user.avatarPath != null && user.avatarPath!.isNotEmpty;
    final initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasAvatar
            ? null
            : LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: hasAvatar
            // Avatar tu file anh thiet bi
            ? Image.file(
                File(user.avatarPath!),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => _buildInitialsWidget(
                    initials, color, size),
              )
            // Hien thi chu cai dau ten
            : _buildInitialsWidget(initials, color, size),
      ),
    );
  }

  static Widget _buildInitialsWidget(
      String initials, Color color, double size) {
    return Container(
      color: color.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.32,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ==============================================================
// Man hinh Edit Profile: Them moi / Chinh sua User
// ==============================================================
class EditProfileScreen extends StatefulWidget {
  // Neu user != null thi dang o che do chinh sua, nguoc lai la them moi
  final User? user;

  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  String? _selectedAvatarPath; // Duong dan anh avatar da chon
  bool _isSaving = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    // Dien san thong tin neu dang chinh sua
    _nameCtrl = TextEditingController(
      text: widget.user?.name ?? '',
    );
    _emailCtrl = TextEditingController(
      text: widget.user?.email ?? '',
    );
    _selectedAvatarPath = widget.user?.avatarPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // Mo gallery de chon anh avatar
  // ============================================================
  Future<void> _pickAvatar() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 400,  // Giam kich thuoc anh de tiet kiem bo nho
        maxHeight: 400,
      );
      if (file != null) {
        setState(() => _selectedAvatarPath = file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loi khi chon anh: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ============================================================
  // Luu thong tin user vao SQLite
  // ============================================================
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        // Cap nhat user hien tai
        final updatedUser = widget.user!.copyWith(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          avatarPath: _selectedAvatarPath,
        );
        await _db.updateUser(updatedUser);
      } else {
        // Them user moi
        final newUser = User(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          avatarPath: _selectedAvatarPath,
        );
        await _db.insertUser(newUser);
      }

      if (mounted) {
        Navigator.pop(context, true); // Tra ve true -> load lai danh sach
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loi khi luu: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Chinh sua Profile' : 'Them User Moi',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          // Nut Luu tren Appbar
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton.icon(
              key: const Key('btn_save_profile'),
              onPressed: _saveUser,
              icon: const Icon(Icons.save_rounded,
                  color: Color(0xFF9E9EFF), size: 18),
              label: const Text(
                'Luu',
                style: TextStyle(
                  color: Color(0xFF9E9EFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // ------------------------------------------------
              // Khu vuc chon avatar (nhan vao de doi anh)
              // ------------------------------------------------
              _buildAvatarPicker(color),

              const SizedBox(height: 32),

              // ------------------------------------------------
              // Form nhap ten
              // ------------------------------------------------
              _buildTextField(
                key: const Key('field_name'),
                controller: _nameCtrl,
                label: 'Ho va Ten',
                icon: Icons.person_rounded,
                color: color,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui long nhap ten';
                  }
                  if (v.trim().length < 2) {
                    return 'Ten phai co it nhat 2 ky tu';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // Form nhap email
              // ------------------------------------------------
              _buildTextField(
                key: const Key('field_email'),
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_rounded,
                color: color,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui long nhap email';
                  }
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Email khong hop le';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------
              // Nut Luu chinh
              // ------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  key: const Key('btn_save_main'),
                  onPressed: _isSaving ? null : _saveUser,
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: Text(
                    _isSaving
                        ? 'Dang luu...'
                        : (_isEditing ? 'Cap nhat Profile' : 'Tao User Moi'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: color.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              // Hien thi thong tin SQLite
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.storage_rounded,
                        color: color.withValues(alpha: 0.7), size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Du lieu duoc luu vao SQLite (multimedia_app.db)\n'
                        'Avatar_path luu duong dan file tren thiet bi.',
                        style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Widget chon avatar
  // ============================================================
  Widget _buildAvatarPicker(Color color) {
    final hasAvatar =
        _selectedAvatarPath != null && _selectedAvatarPath!.isNotEmpty;

    return GestureDetector(
      key: const Key('btn_pick_avatar'),
      onTap: _pickAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Vong tron avatar lon
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasAvatar
                  ? null
                  : LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.7),
                        color.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: Border.all(
                color: color.withValues(alpha: 0.6),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClipOval(
              child: hasAvatar
                  ? Image.file(
                      File(_selectedAvatarPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.person_rounded,
                              color: Colors.white70, size: 50),
                    )
                  : const Icon(Icons.person_rounded,
                      color: Colors.white70, size: 50),
            ),
          ),

          // Nut camera nho ben goc
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF0F0F1A), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Widget TextField tuy chinh
  // ============================================================
  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}

