import 'package:flutter/material.dart';
import 'package:project_akhir/views/home.dart';
import 'package:project_akhir/views/profil.dart';
import 'package:project_akhir/views/watchlist.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      extendBody: true,
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15)
          )
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15)
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(255, 37, 216, 101),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex =index),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house), label: "Home"),
              BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.ticket), label: "Watchlist"),
              BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.solidUser), label: "Profile"),
            ]
          ),
        ),
      ),
    );
  }
}