import 'package:get/get.dart';
import '../../models/user.dart';

class AuthController extends GetxController {
  final user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Initialize user if needed
    // This is a stub - implement as needed
  }
}
