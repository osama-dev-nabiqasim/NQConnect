// body: Stack(
//   children: [
//     // 🔹 Background Gradient
//     Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.blue.shade900,
//             Colors.blue.shade700,
//             Colors.blue.shade400,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//     ),

//     // 🔹 Blob Top-Left
//     Positioned(
//       top: -80,
//       left: -50,
//       child: Container(
//         width: 200,
//         height: 200,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white.withOpacity(0.12),
//         ),
//       ),
//     ),

//     // 🔹 Blob Bottom-Right
//     Positioned(
//       bottom: -100,
//       right: -60,
//       child: Container(
//         width: 250,
//         height: 250,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white.withOpacity(0.08),
//         ),
//       ),
//     ),

//     // 🔹 Foreground content
//     Column(
//       children: [
//         // Welcome Banner (fixed)
//         Container(
//           width: double.infinity,
//           margin: EdgeInsets.only(top: 86, left: 16, right: 16, bottom: 12),
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: Colors.white.withOpacity(0.1),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.25),
//                 blurRadius: 12,
//                 offset: Offset(0, 6), // 👈 shadow under banner
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "👋 Hi, ${userController.userName.value}",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 "$role • $department",
//                 style: TextStyle(fontSize: 16, color: Colors.white70),
//               ),
//             ],
//           ),
//         ),

//         // Scrollable content
//         Expanded(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(
//               horizontal: Responsive.width(context) * 0.04,
//               vertical: 10,
//             ),
//             child: _buildRoleBasedLayout(context, role),
//           ),
//         ),
//       ],
//     ),
//   ],
// ),
