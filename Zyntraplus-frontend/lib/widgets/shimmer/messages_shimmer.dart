import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/app_colors.dart';

class MessagesShimmer extends StatelessWidget {
  const MessagesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    Widget box({
      double w = double.infinity,
      double h = 10,
      double r = 8,
    }) {
      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.primaryBackground(context),
      child: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  box(w: 130, h: 20, r: 6),
                  const Spacer(),
                  box(w: 40, h: 40, r: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(child: Center(child: box(w: 70, h: 12))),
                    Expanded(child: Center(child: box(w: 90, h: 12))),
                    Expanded(child: Center(child: box(w: 70, h: 12))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: 8,
                itemBuilder: (_, __) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [

                        Shimmer.fromColors(
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              box(w: 120, h: 12),
                              const SizedBox(height: 6),
                              box(w: double.infinity, h: 10),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        box(w: 36, h: 10),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}