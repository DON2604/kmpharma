// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:kmpharma/Screens/ServicesScreen/ServicesScreen.dart';

// class Bottomnavbar extends StatefulWidget {
//   const Bottomnavbar({super.key});

//   @override
//   State<Bottomnavbar> createState() => _BottomnavbarState();
// }

// class _BottomnavbarState extends State<Bottomnavbar> {
//   int _selectedIndex = 0;

//   final List<Widget> widgetOptions = const [ServicesScreen()];

//   // Create navigation items (now using Material icons)
//   final List<NavItems> navItems = [
//     const NavItems(
//       label: 'Home',
//       activeIcon: Icons.home,
//       inactiveIcon: Icons.home_outlined,
//     ),
//     const NavItems(
//       label: 'Appointments',
//       activeIcon: Icons.event,
//       inactiveIcon: Icons.event_outlined,
//     ),
//     const NavItems(
//       label: 'Records',
//       activeIcon: Icons.description,
//       inactiveIcon: Icons.description_outlined,
//     ),
//     const NavItems(
//       label: 'Pharmacy',
//       activeIcon: Icons.local_pharmacy,
//       inactiveIcon: Icons.local_pharmacy_outlined,
//     ),
//     const NavItems(
//       label: 'Profile',
//       activeIcon: Icons.person,
//       inactiveIcon: Icons.person_outline,
//     ),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   // Function to handle back button press
//   Future<bool> _onWillPop() async {
//     final bool? shouldPop = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Exit App'),
//         content: const Text('Are you sure you want to exit?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () {
//               // Exit the app
//               SystemNavigator.pop();
//             },
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//     return shouldPop ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) async {
//         if (didPop) return;
//         final bool shouldPop = await _onWillPop();
//         if (shouldPop && context.mounted) {
//           SystemNavigator.pop();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: widgetOptions[_selectedIndex],
//         bottomNavigationBar: Padding(
//           padding: const EdgeInsets.only(top: 6.0),
//           child: BottomNavigationBar(
//             showSelectedLabels: true,
//             showUnselectedLabels: true,
//             type: BottomNavigationBarType.fixed,
//             selectedFontSize: 13,
//             unselectedFontSize: 12,
//             backgroundColor: const Color(0xFF1E1E1E),
//             unselectedItemColor: Colors.white54,
//             selectedItemColor: Colors.white,
//             items: navItems.map((navItem) => navItem.item).toList(),
//             currentIndex: _selectedIndex,
//             onTap: _onItemTapped,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class NavItems {
//   final String label;
//   final IconData activeIcon;
//   final IconData inactiveIcon;

//   const NavItems({
//     required this.label,
//     required this.activeIcon,
//     required this.inactiveIcon,
//   });

//   // Provide a BottomNavigationBarItem for this nav entry using built-in icons
//   BottomNavigationBarItem get item => BottomNavigationBarItem(
//     icon: Icon(inactiveIcon),
//     activeIcon: Icon(activeIcon),
//     label: label,
//   );
// }
