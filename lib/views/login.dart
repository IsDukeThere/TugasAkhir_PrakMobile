import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project_akhir/views/register.dart';
import 'package:project_akhir/widgets/navbar.dart';

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
      backgroundColor: const Color.fromARGB(255, 31, 44, 68),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            margin: EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              image: DecorationImage(image: 
              AssetImage(
                "assets/ico/Steam-icon.png"
              ), fit: BoxFit.cover
              ),
            ),
          ),
          _usernameField(), 
          _passwordField(), 
          _loginButton(context),
          Text(
            "Belum memiliki akun?",
            style: TextStyle(
              color: Colors.white
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => Register())
                );
          }, child: Text("Daftar"))
          ],
      ),
    );
  }

  Widget _usernameField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        enabled: true,
        controller: usernameC,
        style: TextStyle(
          color: Color.fromARGB(255, 72, 74, 74),
          fontWeight: FontWeight.bold
        ),
        decoration: InputDecoration(
          hintText: "Username. . .",
          hintStyle: TextStyle(
            color: Color.fromARGB(255, 72, 74, 74),
            // fontWeight: FontWeight.bold,
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        enabled: true,
        obscureText: true,
        controller: passwordC,
         style: TextStyle(
          color: Color.fromARGB(255, 72, 74, 74),
          fontWeight: FontWeight.bold
        ),
        decoration: InputDecoration(
          hintText: "Password. . .",
          hintStyle: TextStyle(
            color: Color.fromARGB(255, 72, 74, 74),
            // fontWeight: FontWeight.bold,
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
      padding: EdgeInsets.symmetric(
        horizontal: 20, 
        vertical: 10
      ),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          print("LOGIN");
          _login();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 54, 103, 160),
        ),
        child: Text("LOGIN", 
        style: TextStyle(
          fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  void _login(){
    String text = "", username, password;
      username = usernameC.text.trim();
      password = passwordC.text.trim();

      var box = Hive.box('users');
      if (box.containsKey(username)) {
    // Ambil password yang tersimpan
    final savedPassword = box.get(username);

    if (savedPassword == password) {
      // Login berhasil
      setState(() {
        text = "Login Berhasil!";
        isLoginSuccess = true;
      });

      // Navigasi ke halaman utama
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

      print("Username : $username");
      print("Password : $password");

      SnackBar snackBar = SnackBar(
        backgroundColor: (isLoginSuccess) ? Colors.green : Colors.red,
        content: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
