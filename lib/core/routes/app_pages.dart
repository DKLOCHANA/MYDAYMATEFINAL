import 'package:get/get.dart';
import 'package:mydaymate/core/routes/app_routes.dart';
import 'package:mydaymate/features/add_expences_or_incomes/view/add_expences_page.dart';
import 'package:mydaymate/features/add_expences_or_incomes/view/add_incomes_page.dart';
import 'package:mydaymate/features/financial_planner/binding/financial_planner_binding.dart';
import 'package:mydaymate/features/financial_planner/view/financial_planner_page.dart';
import 'package:mydaymate/features/home/binding/home_binding.dart';
import 'package:mydaymate/features/home/view/home_page.dart';
import 'package:mydaymate/features/onboard/binding/onboard_binding.dart';
import 'package:mydaymate/features/onboard/view/onboard_page.dart';
import 'package:mydaymate/features/auth/view/register_page.dart';
import 'package:mydaymate/features/auth/view/login_page.dart';
import 'package:mydaymate/features/auth/binding/auth_binding.dart';
import 'package:mydaymate/features/profile/binding/profile_binding.dart';
import 'package:mydaymate/features/profile/view/profile_page.dart';

abstract class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.initial,
      page: () => const OnboardPage(),
      binding: OnboardBinding(),
    ),
    GetPage(
      name: AppRoutes.onboard,
      page: () => const OnboardPage(),
      binding: OnboardBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.financial,
      page: () => const FinancialPlannerPage(),
      binding: FinancialPlannerBinding(),
    ),
    GetPage(
      name: AppRoutes.addIncome,
      page: () => const AddIncomesPage(),
    ),
    GetPage(
      name: AppRoutes.addExpense,
      page: () => const AddExpencesPage(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
  ];
}
