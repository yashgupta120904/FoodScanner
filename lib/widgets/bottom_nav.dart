import 'package:flutter/material.dart';
import 'package:foodscanner_2/screens/HomeScreen.dart';
import 'package:foodscanner_2/screens/MoreScreen.dart';
import 'package:foodscanner_2/screens/compare.dart';
import 'package:foodscanner_2/screens/scan_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavWithScanner extends StatefulWidget {
  final Widget body;
  final int initialIndex;

  const BottomNavWithScanner({
    super.key,
    required this.body,
    this.initialIndex = 0,
  });

  @override
  State<BottomNavWithScanner> createState() => _BottomNavWithScannerState();
}

class _BottomNavWithScannerState extends State<BottomNavWithScanner> {
  late int _selectedIndex;
  bool _showScanner = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // Already on this tab, do nothing
      return;
    }

    setState(() {
      _selectedIndex = index;
      _showScanner = false;
    });

    // Navigate to the appropriate page based on index
    Widget? destination;
    switch (index) {
      case 0:
        destination = HomePageWork();
        break;
      case 1:
      // Today functionality - just print for now
        print("just ok ");
        return; // Return without navigation
      case 2:
        destination = CompareProductsScreen();
        break;
      case 3:
      // Show MoreScreen as bottom sheet instead of navigating
        _showMoreScreen();
        return; // Return without further navigation
    }

    if (destination != null) {
      // Replace the current screen instead of pushing a new one
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination!),
      );
    }
  }

  void _showMoreScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MoreScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showScanner
          ? Center(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            'Scanner On ',
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
      )
          : widget.body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        backgroundColor: const Color.fromARGB(255, 223, 206, 15),
        selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.home, 0), label: 'Home'),
          BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.today, 1), label: 'Today'),
          BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.compare_arrows_sharp, 2),
              label: 'Compare'),
          BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.more_horiz_rounded, 3),
              label: 'More'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScannerScreen()),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        top: isSelected ? 0 : 4,
        bottom: isSelected ? 4 : 0,
      ),
      child: Icon(
        icon,
        size: isSelected ? 30 : 24,
        color: isSelected ? Colors.black : const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}