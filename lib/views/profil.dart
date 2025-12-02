import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_akhir/views/login.dart';

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

  void _showEditNameDialog() {
    TextEditingController _controller = TextEditingController(text: _nama);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(color: Color.fromARGB(255, 37, 216, 101), width: 1),
          ),
          title: const Text("Ubah Username", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Masukkan Username baru",
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 37, 216, 101),),
              onPressed: () {
                setState(() {
                  _nama = _controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          icon: FaIcon(FontAwesomeIcons.rightFromBracket, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
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
              const SizedBox(height: 20),
              _infoRow("Nama", _nama),
              _infoRow("NIM", _nim),
              _infoRow("Kelas", _kelas),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _showEditNameDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 37, 216, 101),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Edit Profil",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

Widget _infoRow(String label, String value, {bool isEditable = false, VoidCallback? onEdit}) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: double.infinity,
      decoration: BoxDecoration(
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80, // Lebar tetap untuk label agar rapi
            child: Text(
              "$label",
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
          // Jika isEditable true, tampilkan icon pensil
          if (isEditable)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.amber, size: 20),
              onPressed: onEdit,
              tooltip: "Ubah Nama",
            )
        ],
      ),
    );
  }
}