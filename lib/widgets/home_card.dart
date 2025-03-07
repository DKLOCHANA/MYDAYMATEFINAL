import 'package:flutter/material.dart';

class MealPlannerContainer extends StatelessWidget {
  const MealPlannerContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8BC1CA),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Meal planner text
          Positioned(
            top: 15,
            left: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Meal Planner',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Plan Your Plate, Save Your Time',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),

          // Food bowl illustration
          Positioned(
            bottom: 10,
            right: 10,
            width: 70,
            height: 70,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/home/profile.png',
                  width: 60,
                  height: 60,
                  // If you don't have the actual image, you can use a placeholder:
                  // errorBuilder: (context, error, stackTrace) {
                  //   return const Icon(Icons.restaurant, size: 40, color: Color(0xFF8BC1CA));
                  // },
                ),
              ),
            ),
          ),

          // Food icon 1 (small)
          Positioned(
            top: 70,
            right: 30,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFBF2DE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/home/profile.png',
                  width: 25,
                  height: 25,
                  // Placeholder alternative:
                  // errorBuilder: (context, error, stackTrace) {
                  //   return const Icon(Icons.egg_alt, size: 20, color: Color(0xFFE8A54A));
                  // },
                ),
              ),
            ),
          ),

          // Food icon 2 (small)
          Positioned(
            top: 50,
            right: 80,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F2F4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/home/profile.png',
                  width: 20,
                  height: 20,
                  // Placeholder alternative:
                  // errorBuilder: (context, error, stackTrace) {
                  //   return const Icon(Icons.fastfood, size: 15, color: Color(0xFF8BC1CA));
                  // },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
