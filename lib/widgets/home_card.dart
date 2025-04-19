import 'package:flutter/material.dart';

class HomeCardContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String backgroundImage;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final Color borderColor;

  const HomeCardContainer({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
    this.onTap,
    this.width = 170,
    this.height = 170,
    this.borderColor = const Color(0xFF8BC1CA),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.lightBlue[100], // Fallback color if image fails to load
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
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
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                backgroundImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Theme.of(context).primaryColor,
                      size: 48,
                    ),
                  );
                },
              ),
            ),

            // Darkened overlay for better text readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.black.withOpacity(0.4),
              ),
            ),

            // Text in center
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// For backward compatibility, keep the MealPlannerContainer
class MealPlannerContainer extends StatelessWidget {
  final VoidCallback? onTap;

  const MealPlannerContainer({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeCardContainer(
      title: 'Meal Planner',
      subtitle: 'Plan your meals',
      backgroundImage: "assets/images/home/f1.png",
      onTap: onTap,
    );
  }
}
