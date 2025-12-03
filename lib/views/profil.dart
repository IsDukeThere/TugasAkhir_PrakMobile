import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_akhir/views/login.dart';
import 'package:hive/hive.dart';
import 'package:project_akhir/utils/encryption.dart';

class Profil extends StatefulWidget {
  final String user;
  const Profil({super.key, required this.user});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  late String _nama;
  final String _nim = "124230070";
  final String _kelas = "Pemrograman Aplikasi Mobile SI - B";

  @override
  void initState() {
    super.initState();
    _nama = widget.user;
  }

  // Dialog untuk ganti password
  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(
                color: Color.fromARGB(255, 37, 216, 101), width: 1),
          ),
          title: const Text("Ganti Password",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Password lama",
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Password baru",
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 37, 216, 101),
              ),
              onPressed: () {
                _changePassword(
                    oldPasswordController.text, newPasswordController.text);
                Navigator.pop(context);
              },
              child: const Text("Confirm",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi update password di Hive
  void _changePassword(String oldPassword, String newPassword) {
    var box = Hive.box('users');
    if (box.containsKey(_nama)) {
      final savedHash = box.get(_nama);
      final oldHash = hashPassword(oldPassword);

      if (savedHash == oldHash) {
        final newHash = hashPassword(newPassword);
        box.put(_nama, newHash);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Password berhasil diganti!",
                style: TextStyle(color: Colors.white)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Password lama salah!",
                style: TextStyle(color: Colors.white)),
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
            "Profil",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginPage();
                    },
                  ),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.rightFromBracket,
                  color: Colors.white),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                        image: AssetImage("assets/img/duki.jpg"),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _infoRow("Nama", _nama),
                _infoRow("NIM", _nim),
                _infoRow("Kelas", _kelas),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _showChangePasswordDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Ganti Password",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _infoRow(String label, String value,
      {bool isEditable = false, VoidCallback? onEdit}) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const Text(":", style: TextStyle(color: Colors.white)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
