import 'package:flutter/material.dart';
import 'package:project_akhir/views/login.dart';

class Profil extends StatelessWidget {
  final String user;
  const Profil({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 29, 37),
        title: Text(
          "Profil",
        style: TextStyle(
          color: Colors.white),
          ),
        actions: [
          IconButton(onPressed: (){
            Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (context) {
                    return LoginPage();
                  }
                  ),
                );
          }, 
          icon: Icon(Icons.logout, color: Colors.red,))
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 31, 44, 68),
              Color.fromARGB(255, 54, 103, 160)
          ] 
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 15),
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(
                  "assets/img/duki.jpg"
                ), fit: BoxFit.cover,
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
            //Lempar data ke widget dibawah
            const SizedBox(height: 20),
            _infoRow("Nama", "Alfiyan Masduqi"),
            _infoRow("NIM", "124230070"),
            _infoRow("Kelas", "Pemrograman Aplikasi Mobile SI - B"),
          ],
        ),
      ),
    );
  }
Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: double.infinity,
      decoration: BoxDecoration(
      ),
      child: Row(
        children: [
          
          Text(
            "$label : ",
            style: const TextStyle(fontWeight: FontWeight.bold,
            color: Colors.white),
          ),
          Expanded(
            child: Text(
              value, 
              style: TextStyle(
                color: Colors.white
                ),
                ),
          ),
        ],
      ),
    );
  }
}