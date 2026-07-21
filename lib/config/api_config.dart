class ApiConfig {
  static const String baseUrl = 'https://bigdeals.page.gd/api/index.php';
  static const String imageBase = 'https://bigdeals.page.gd';

  static String endpoint(String ep, [String action = '']) {
    var url = '$baseUrl?endpoint=$ep';
    if (action.isNotEmpty) url += '&action=$action';
    return url;
  }
}
