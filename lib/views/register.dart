import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project_akhir/utils/encryption.dart'; // import fungsi hashPassword

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void _register() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan password tidak boleh kosong")),
      );
      return;
    }

    final box = Hive.box('users');

    if (box.containsKey(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username sudah terdaftar')),
      );
      return;
    }

    // Simpan password dalam bentuk hash
    final hashedPassword = hashPassword(password);
    await box.put(username, hashedPassword);

    print('Data tersimpan: $username -> $hashedPassword'); // debug

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrasi berhasil! Silakan login.")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/ico/Steam-icon.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _usernameField(),
          _passwordField(),
          _DaftarButton(context),
        ],
      ),
    );
  }

  Widget _usernameField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        controller: usernameController,
        style: const TextStyle(
          color: Color.fromARGB(255, 72, 74, 74),
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          hintText: "Username. . .",
          hintStyle: TextStyle(
            color: Color.fromARGB(255, 72, 74, 74),
          ),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        obscureText: true,
        controller: passwordController,
        style: const TextStyle(
          color: Color.fromARGB(255, 72, 74, 74),
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          hintText: "Password. . .",
          hintStyle: TextStyle(
            color: Color.fromARGB(255, 72, 74, 74),
          ),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _DaftarButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          print("DAFTAR");
          _register();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 37, 216, 101),
        ),
        child: const Text(
          "DAFTAR",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
