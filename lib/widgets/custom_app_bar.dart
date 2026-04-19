import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/register_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogout; 

  const CustomAppBar({super.key, required this.title, this.showLogout = false});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    final currentUser = Supabase.instance.client.auth.currentUser;
    
    final isAdmin = currentUser?.email == 'admin@gmail.com';

    Widget? leadingWidget;
    if (canPop) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
        onPressed: () => Navigator.pop(context),
      );
    }

    return AppBar(
      leading: leadingWidget,
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
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
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black, size: 28),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          onSelected: (String value) {
            if (value == 'register') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
            } else if (value == 'logout') {
              _confirmLogout(context);
            }
          },
          itemBuilder: (BuildContext context) {
            final List<PopupMenuEntry<String>> menuItems = [];

            if (isAdmin) {
              menuItems.add(
                const PopupMenuItem<String>(
                  value: 'register',
                  child: Row(
                    children: [
                      Icon(Icons.manage_accounts, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Kelola Akun', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                    ],
                  ),
                ),
              );
            }

            menuItems.add(
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Keluar', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent)),
                  ],
                ),
              ),
            );

            return menuItems;
          },
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
          side: const BorderSide(color: Colors.black, width: 3)
        ),
        title: const Text('KELUAR?', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        content: const Text('Yakin ingin keluar dari akun ini?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('BATAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Supabase.instance.client.auth.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A80),
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 2),
              elevation: 0,
            ),
            child: const Text('KELUAR', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}