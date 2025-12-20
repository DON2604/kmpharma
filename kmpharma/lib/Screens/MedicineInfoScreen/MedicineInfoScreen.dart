// import 'package:flutter/material.dart';

// class MedicineInfoScreen extends StatefulWidget {
//   const MedicineInfoScreen({super.key});

//   @override
//   State<MedicineInfoScreen> createState() => _MedicineInfoScreenState();
// }

// class _MedicineInfoScreenState extends State<MedicineInfoScreen> {
//   int qty = 1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff0D1B2A),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           "Product Details",
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),

//       bottomNavigationBar: _bottomButton(),

//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _heroBanner(),

//             const SizedBox(height: 20),

//             _infoSection(),

//             const SizedBox(height: 20),

//             _highlightsSection(),

//             _expandable(
//               "Description",
//               "Paracetamol 500mg is a popular pain-relief and fever-reducing medication. "
//               "Manufactured by **HealthCare Pharma Ltd**, this medicine is widely used for headaches, "
//               "migraine, cold & flu symptoms, backache, menstrual cramps, muscle pain and mild arthritis.",
//             ),

//             _expandable(
//               "Side Effects",
//               "Rare side effects include:\n\n• Rash or itching\n• Nausea\n• Mild dizziness\n• Allergic reactions",
//             ),

//             _expandable(
//               "Safety Advice",
//               "• Do not exceed more than 4 tablets in 24 hours.\n"
//               "• Avoid alcohol while taking this medicine.\n"
//               "• Safe for adults above 18.\n"
//               "• Not recommended during pregnancy without doctor’s advice.",
//             ),

//             const SizedBox(height: 40)
//           ],
//         ),
//       ),
//     );
//   }

//   // --------------------------------------------------------
//   // HERO BANNER
//   // --------------------------------------------------------
//   Widget _heroBanner() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       height: 230,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xff1B263B), Color(0xff415A77)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black45,
//             blurRadius: 25,
//             offset: Offset(3, 10),
//           )
//         ],
//       ),
//       child: Center(
//         child: Icon(
//           Icons.medication_liquid,
//           size: 110,
//           color: Colors.white.withValues(alpha: 0.9),
//         ),
//       ),
//     );
//   }

//   // --------------------------------------------------------
//   // MAIN INFO SECTION
//   // --------------------------------------------------------
//   Widget _infoSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: const Color(0xff1B263B),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black38,
//             blurRadius: 20,
//             offset: Offset(2, 4),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Paracetamol 500mg",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 28,
//               fontWeight: FontWeight.w700,
//             ),
//           ),

//           const SizedBox(height: 5),

//           Text(
//             "Manufactured by: HealthCare Pharma Ltd.",
//             style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
//           ),

//           const SizedBox(height: 25),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // PRICE
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "\$12.79",
//                     style: TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xff00E0FF),
//                     ),
//                   ),
//                   Text(
//                     "\$15.99",
//                     style: TextStyle(
//                       color: Colors.grey.shade500,
//                       decoration: TextDecoration.lineThrough,
//                     ),
//                   ),
//                 ],
//               ),

//               // QTY
//               _qtyBox(),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // --------------------------------------------------------
//   // HIGHLIGHTS SECTION
//   // --------------------------------------------------------
//   Widget _highlightsSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: const Color(0xff1E2D3D),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Highlights",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),

//           const SizedBox(height: 15),

//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             children: [
//               _tag("Fast Pain Relief"),
//               _tag("Reduces Fever"),
//               _tag("Doctor Recommended"),
//               _tag("Safe for Adults"),
//               _tag("WHO Approved Formula"),
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Widget _tag(String text) {
//   return Container(
//     constraints: const BoxConstraints(minWidth: 140),
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     decoration: BoxDecoration(
//       color: const Color(0xff415A77),
//       borderRadius: BorderRadius.circular(16),
//     ),
//     child: Center(
//       child: Text(
//         text,
//         style: const TextStyle(color: Colors.white, fontSize: 14),
//       ),
//     ),
//   );
// }

//   // --------------------------------------------------------
//   // QTY SELECTOR
//   // --------------------------------------------------------
//   Widget _qtyBox() {
//     return Container(
//       height: 48,
//       decoration: BoxDecoration(
//         color: const Color(0xff243447),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           _qtyBtn(Icons.remove, () {
//             if (qty > 1) setState(() => qty--);
//           }),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               "$qty",
//               style: const TextStyle(fontSize: 20, color: Colors.white),
//             ),
//           ),
//           _qtyBtn(Icons.add, () => setState(() => qty++)),
//         ],
//       ),
//     );
//   }

//   Widget _qtyBtn(IconData icon, VoidCallback tap) {
//     return InkWell(
//       onTap: tap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: Icon(icon, color: Colors.white, size: 22),
//       ),
//     );
//   }

//   // --------------------------------------------------------
//   // EXPANDABLE SECTION
//   // --------------------------------------------------------
//   Widget _expandable(String title, String content) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xff1B263B),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: ExpansionTile(
//         title: Text(
//           title,
//           style: const TextStyle(color: Colors.white, fontSize: 17),
//         ),
//         childrenPadding: const EdgeInsets.all(16),
//         children: [
//           Text(
//             content,
//             style: TextStyle(color: Colors.grey.shade300, height: 1.5),
//           ),
//         ],
//       ),
//     );
//   }

//   // --------------------------------------------------------
//   // BOTTOM BUTTON
//   // --------------------------------------------------------
//   Widget _bottomButton() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: const BoxDecoration(
//         color: Color(0xff1B263B),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 12,
//             color: Colors.black45,
//             offset: Offset(0, -2),
//           )
//         ],
//       ),
//       child: SizedBox(
//         height: 55,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xff00E0FF),
//             foregroundColor: Colors.black,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//           ),
//           onPressed: () {},
//           child: const Text(
//             "Add to Cart",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
