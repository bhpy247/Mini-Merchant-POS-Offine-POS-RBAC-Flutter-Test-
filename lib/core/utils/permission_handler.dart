import '../constants/app_roles.dart';

class PermissionHelper {
  static bool canCreateOrder(String role) {
    return role == AppRoles.admin || role == AppRoles.merchant;
  }

  static bool canMakePayment(String role) {
    return role == AppRoles.admin || role == AppRoles.merchant;
  }

  static bool canEditProducts(String role) {
    return role == AppRoles.admin;
  }

  static bool canViewReports(String role) {
    return role == AppRoles.admin;
  }

  static bool canViewAllOrders(String role) {
    return role == AppRoles.admin;
  }

  static bool canViewOwnOrders(String role) {
    return role != AppRoles.employee;
  }
}
