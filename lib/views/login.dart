import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project_akhir/views/register.dart';
import 'package:project_akhir/widgets/navbar.dart';
import 'package:project_akhir/utils/encryption.dart'; // import hashPassword

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameC = TextEditingController();
  final passwordC = TextEditingController();
  bool isLoginSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            margin: const EdgeInsets.only(bottom: 30),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/ico/Steam-icon.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _usernameField(),
          _passwordField(),
          _loginButton(context),
          const Text(
            "Belum memiliki akun?",
            style: TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Register()),
              );
            },
            child: const Text(
              "Daftar",
              style: TextStyle(
                color: Color.fromARGB(255, 37, 216, 101),
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _usernameField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        controller: usernameC,
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
        controller: passwordC,
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

  Widget _loginButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          _login();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 37, 216, 101),
        ),
        child: const Text(
          "LOGIN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _login() {
    String text = "", username, password;
    username = usernameC.text.trim();
    password = passwordC.text.trim();

    var box = Hive.box('users');
    if (box.containsKey(username)) {
      final savedHash = box.get(username);
      final inputHash = hashPassword(password);

      if (savedHash == inputHash) {
        // Login berhasil
        setState(() {
          text = "Login Berhasil!";
          isLoginSuccess = true;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navbar(name: username)),
        );
      } else {
        // Password salah
        setState(() {
          text = "Password salah!";
          isLoginSuccess = false;
        });
      }
    } else {
      // Username tidak ditemukan
      setState(() {
        text = "Username tidak ditemukan!";
        isLoginSuccess = false;
      });
    }

    SnackBar snackBar = SnackBar(
      backgroundColor: (isLoginSuccess) ? Colors.green : Colors.red,
      content: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
