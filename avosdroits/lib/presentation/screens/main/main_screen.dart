import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../menu/menu_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../contact/contact_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MenuScreen(),
    const ChatbotScreen(),
    const ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DesignSystem.primaryGreen,
        title: Text(
          'À Vos Droits',
          style: DesignSystem.headingLarge.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // TODO: Implement logout
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: DesignSystem.primaryGreen,
            child: Row(
              children: [
                _buildNavButton('Accueil', 0),
                _buildNavButton('ChatBot', 1),
                _buildNavButton('Contact', 2),
              ],
            ),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildNavButton(String title, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: DesignSystem.buttonLarge.copyWith(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
} 