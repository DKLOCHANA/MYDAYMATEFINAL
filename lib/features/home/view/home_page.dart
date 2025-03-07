import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/widgets/home_card.dart';
import '../controller/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          height: 1 / 3 * MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 36 + 20,
                ),
                height: 1 / 3 * MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    color: Color(0xFFB2FFFB),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    )),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("MyDayMate",
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          Spacer(),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            foregroundImage:
                                AssetImage("assets/images/home/profile.png"),
                          )
                        ],
                      ),
                      Text("Good Morning, User",
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(
                        height: 30,
                      ),
                      Text("Today's Plan",
                          style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: Colors.black),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Assessment",
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              Text("Saturday, 10th July 2021",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset("assets/images/home/bot.png"),
                    Text("Need Any Assistance?",
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              MealPlannerContainer(),
            ],
          ),
        ),
      ],
    ));
  }
}
