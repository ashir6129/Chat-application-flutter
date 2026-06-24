// import 'package:flutter/material.dart';
// import 'package:zyntra/core/app_colors.dart';
//
// class PostEarningDetailsScreen extends StatelessWidget {
//   const PostEarningDetailsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.cardBackground(context),
//       body: CustomScrollView(
//         slivers: [
//           // ── APP BAR ──
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: AppColors.cardBackground(context),
//             elevation: 0,
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back_ios_new_rounded,
//                   size: 18, color: AppColors.primaryText(context)),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: Text(
//               'Post Earnings',
//               style: TextStyle(
//                 color: AppColors.primaryText(context),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.share_outlined,
//                     size: 20, color: AppColors.mutedText(context)),
//                 onPressed: () {},
//               ),
//             ],
//           ),
//
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── POST PREVIEW STRIP ──
//                   _postPreviewStrip(context),
//                   const SizedBox(height: 16),
//
//                   // ── TOTAL EARNINGS HERO ──
//                   _earningsHero(context),
//                   const SizedBox(height: 12),
//
//                   // ── KEY METRICS GRID ──
//                   _keyMetricsGrid(context),
//                   const SizedBox(height: 12),
//
//                   // ── EARNINGS BREAKDOWN ──
//                   _earningsBreakdownCard(context),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── POST PREVIEW STRIP ──────────────────────────────────────────────────
//   Widget _postPreviewStrip(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground(context),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.borderLine(context), width: 0.8),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               color: AppColors.buttonColor(context).withOpacity(0.12),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(Icons.play_circle_fill_rounded,
//                 color: AppColors.buttonColor(context), size: 28),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'How I built a \$10K/mo side hustle',
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.primaryText(context),
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     height: 1.3,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Published · Mar 15, 2026',
//                   style: TextStyle(
//                     color: AppColors.mutedText(context),
//                     fontSize: 11,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Text(
//               'Live',
//               style: TextStyle(
//                 color: Colors.green,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── EARNINGS HERO ───────────────────────────────────────────────────────
//   Widget _earningsHero(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.buttonColor(context).withOpacity(0.18),
//             AppColors.buttonColor(context).withOpacity(0.05),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppColors.buttonColor(context).withOpacity(0.25),
//           width: 0.8,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Total post earnings',
//             style: TextStyle(
//               color: AppColors.mutedText(context),
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             '\$5.82',
//             style: TextStyle(
//               color: AppColors.primaryText(context),
//               fontSize: 36,
//               fontWeight: FontWeight.bold,
//               height: 1,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'All time · Last updated Apr 1, 2026',
//             style: TextStyle(
//               color: AppColors.mutedText(context),
//               fontSize: 11,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               _heroStat('\$3.20', 'Standard', context),
//               _heroDivider(context),
//               _heroStat('\$2.62', 'Additional', context),
//               _heroDivider(context),
//               _heroStat('\$0.00', 'Gifts', context),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _heroStat(String value, String label, BuildContext context) {
//     return Expanded(
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               color: AppColors.primaryText(context),
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             label,
//             style: TextStyle(
//               color: AppColors.mutedText(context),
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _heroDivider(BuildContext context) {
//     return Container(
//       width: 1,
//       height: 28,
//       color: AppColors.buttonColor(context).withOpacity(0.3),
//     );
//   }
//
//   // ── KEY METRICS GRID ────────────────────────────────────────────────────
//   Widget _keyMetricsGrid(BuildContext context) {
//     final metrics = [
//       {'icon': Icons.visibility_outlined, 'label': 'Views', 'value': '4.2K'},
//       {'icon': Icons.people_outline, 'label': 'Reach', 'value': '3.8K'},
//       {'icon': Icons.thumb_up_alt_outlined, 'label': 'Likes', 'value': '312'},
//       {'icon': Icons.comment_outlined, 'label': 'Comments', 'value': '87'},
//       {'icon': Icons.repeat_outlined, 'label': 'Shares', 'value': '54'},
//       {'icon': Icons.bookmark_outline, 'label': 'Saves', 'value': '143'},
//     ];
//
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: metrics.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 8,
//         crossAxisSpacing: 8,
//         childAspectRatio: 1.3,
//       ),
//       itemBuilder: (context, i) {
//         final m = metrics[i];
//         return Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: AppColors.cardBackground(context),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//                 color: AppColors.borderLine(context), width: 0.8),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(m['icon'] as IconData,
//                   size: 16, color: AppColors.mutedText(context)),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     m['value'] as String,
//                     style: TextStyle(
//                       color: AppColors.primaryText(context),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     m['label'] as String,
//                     style: TextStyle(
//                       color: AppColors.mutedText(context),
//                       fontSize: 10,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // ── EARNINGS BREAKDOWN ──────────────────────────────────────────────────
//   Widget _earningsBreakdownCard(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground(context),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.borderLine(context), width: 0.8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Earnings breakdown',
//             style: TextStyle(
//               color: AppColors.primaryText(context),
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 14),
//           _breakdownRow('RPM', '\$1.38', 'per 1K qualified views', context),
//           _divider(context),
//           _breakdownRow('Qualified views', '1,900', 'out of 4,200 total', context),
//           _divider(context),
//           _breakdownRow('Standard reward', '\$3.20', '55% of total earnings', context),
//           _divider(context),
//           _breakdownRow('Additional reward', '\$2.62', '45% of total earnings', context),
//           _divider(context),
//           _breakdownRow('Gift earnings', '\$0.00', '0 gifts received', context),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: AppColors.buttonColor(context).withOpacity(0.08),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.lightbulb_outline,
//                     size: 13, color: AppColors.buttonColor(context)),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Your RPM is 25x the platform average. Strong retention is the key driver.',
//                     style: TextStyle(
//                       color: AppColors.secondaryText(context),
//                       fontSize: 11,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _breakdownRow(
//       String label, String value, String sub, BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label,
//                   style: TextStyle(
//                       color: AppColors.primaryText(context), fontSize: 13)),
//               const SizedBox(height: 2),
//               Text(sub,
//                   style: TextStyle(
//                       color: AppColors.mutedText(context), fontSize: 10)),
//             ],
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: AppColors.primaryText(context),
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _divider(BuildContext context) {
//     return Divider(
//       height: 1,
//       thickness: 0.6,
//       color: AppColors.borderLine(context),
//     );
//   }
// }