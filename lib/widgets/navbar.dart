import 'package:flutter/material.dart';
import 'package:project_akhir/views/home.dart';
import 'package:project_akhir/views/profil.dart';
import 'package:project_akhir/views/watchlist.dart';

class Navbar extends StatefulWidget {
  final String name;
  const Navbar({
    super.key, 
    required this.name,
    });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      Home(username: widget.name),
      Watchlist(username: widget.name),
      Profil(user: widget.name),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex =index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Watchlist"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ]),
    );
  }
}