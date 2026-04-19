import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  final List<Color> _neoColors = [
    const Color(0xFFB9F6CA),
    const Color(0xFFEA80FC),
    const Color(0xFF80DEEA),
    const Color(0xFFFFD180),
    const Color(0xFFFFA4A2),
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.rpc('get_user_list');
      final allUsers = response as List<dynamic>;

      final filteredUsers = allUsers.where((user) {
        return user['email'] != 'admin@gmail.com';
      }).toList();

      setState(() {
        _users = filteredUsers;
      });
    } catch (e) {
      debugPrint('Gagal memuat user: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await Supabase.instance.client
          .rpc('delete_user_by_id', params: {'user_id': userId});
      showSnackBarWithOK('Akun berhasil dihapus!',
          backgroundColor: const Color(0xFFB9F6CA));
      _fetchUsers();
    } catch (e) {
      showSnackBarWithOK('Gagal menghapus: $e',
          backgroundColor: const Color(0xFFFF8A80));
    }
  }

  void _confirmDelete(String userId, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        title: const Text('HAPUS AKUN?',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.black)),
        content: Text('Yakin ingin mencabut akses untuk akun:\n$email?',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w900)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteUser(userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A80),
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 2),
              elevation: 0,
            ),
            child: const Text('HAPUS',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  InputDecoration _neoInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(fontWeight: FontWeight.w900, color: Colors.black54),
      prefixIcon: Icon(icon, color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 3)),
    );
  }

  void _showAddAccountDialog() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool obscurePass = true;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            backgroundColor: const Color(0xFF80DEEA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.black, width: 4),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF59D),
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('TAMBAH AKUN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Colors.black,
                      letterSpacing: 1.0)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _neoInputDecoration('Email', Icons.email),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passCtrl,
                  obscureText: obscurePass,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  decoration:
                      _neoInputDecoration('Password', Icons.lock).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscurePass ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black),
                      onPressed: () =>
                          setStateSB(() => obscurePass = !obscurePass),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('BATAL',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w900)),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                          showSnackBarWithOK('Harap isi email dan password!',
                              backgroundColor: const Color(0xFFFFD180));
                          return;
                        }
                        setStateSB(() => isSaving = true);
                        try {
                          await Supabase.instance.client.auth.signUp(
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text.trim(),
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            showSnackBarWithOK('Akun berhasil dibuat!',
                                backgroundColor: const Color(0xFFB9F6CA));
                            _fetchUsers();
                          }
                        } catch (e) {
                          showSnackBarWithOK('Gagal: $e',
                              backgroundColor: const Color(0xFFFF8A80));
                        } finally {
                          setStateSB(() => isSaving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA80FC),
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.black))
                    : const Text('SIMPAN',
                        style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'KELOLA AKUN',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFEB3B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: Colors.black, height: 4.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'DAFTAR AKUN AKTIF',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black))
                : _users.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF59D),
                            border: Border.all(color: Colors.black, width: 3),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black, offset: Offset(4, 4))
                            ],
                          ),
                          child: const Text('Belum ada akun terdaftar.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];

                          final cardColor =
                              _neoColors[index % _neoColors.length];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.black, width: 2)),
                                  child: const Icon(Icons.person,
                                      color: Colors.black, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['email'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.black,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: const Text('AKUN AKTIF',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 10,
                                                color: Colors.black)),
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () =>
                                      _confirmDelete(user['id'], user['email']),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFFF8A80),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.black, width: 2)),
                                    child: const Icon(Icons.delete_outline,
                                        color: Colors.black, size: 24),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF80DEEA),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          onPressed: _showAddAccountDialog,
          icon: const Icon(Icons.add, color: Colors.black, size: 24),
          label: const Text('TAMBAH AKUN',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0)),
        ),
      ),
    );
  }
}
