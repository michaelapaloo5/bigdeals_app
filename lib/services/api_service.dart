import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class ApiService {
  static String? _sessionId;
  static Map<String, String> _cookies = {};

  static Future<Map<String, String>> _headers() async {
    if (_sessionId == null) {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString('session_id');
    }
    final cookieStr = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      if (_sessionId != null) 'Cookie': cookieStr.isNotEmpty ? cookieStr : 'PHPSESSID=$_sessionId',
    };
  }

  static void _saveCookies(http.Response response) {
    final setCookies = response.headers['set-cookie'];
    if (setCookies != null) {
      for (var c in setCookies.split(',')) {
        final parts = c.split(';')[0].split('=');
        if (parts.length >= 2) {
          _cookies[parts[0].trim()] = parts[1].trim();
        }
      }
      final phpsessid = _cookies['PHPSESSID'];
      if (phpsessid != null) {
        _sessionId = phpsessid;
        SharedPreferences.getInstance().then((p) => p.setString('session_id', phpsessid));
      }
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, String action, [Map<String, String>? body]) async {
    final url = ApiConfig.endpoint(endpoint, action);
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    ).timeout(const Duration(seconds: 30));
    _saveCookies(response);
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> get(String endpoint, String action, [Map<String, String>? params]) async {
    var url = ApiConfig.endpoint(endpoint, action);
    if (params != null) {
      params.forEach((k, v) => url += '&$k=$v');
    }
    final headers = await _headers();
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    ).timeout(const Duration(seconds: 30));
    _saveCookies(response);
    return json.decode(response.body);
  }

  static Future<void> clearSession() async {
    _sessionId = null;
    _cookies.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');
  }

  static bool get isLoggedIn => _sessionId != null;

  // AUTH
  static Future<Map<String, dynamic>> register(String email, String password, String confirmPassword, {String? referralCode}) {
    final body = {
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    };
    if (referralCode != null && referralCode.isNotEmpty) body['referral_code'] = referralCode;
    return post('auth', 'register', body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) {
    return post('auth', 'login', {'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> verifyOtp(String otp) {
    return post('auth', 'verify_otp', {'otp': otp});
  }

  static Future<Map<String, dynamic>> resendOtp() {
    return post('auth', 'resend_otp');
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) {
    return post('auth', 'forgot_password', {'email': email});
  }

  static Future<Map<String, dynamic>> resetPassword(String token, String password) {
    return post('auth', 'reset_password', {'token': token, 'password': password});
  }

  static Future<Map<String, dynamic>> getProfile() {
    return get('auth', 'profile');
  }

  static Future<Map<String, dynamic>> updateProfile(String name, String email) {
    return post('auth', 'update_profile', {'name': name, 'email': email});
  }

  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) {
    return post('auth', 'change_password', {'current_password': currentPassword, 'new_password': newPassword});
  }

  // WALLET
  static Future<Map<String, dynamic>> getBalance() {
    return get('wallet', 'balance');
  }

  static Future<Map<String, dynamic>> getTransactions({int page = 1}) {
    return get('wallet', 'transactions', {'page': page.toString()});
  }

  static Future<Map<String, dynamic>> initiateDeposit(double amount, String method) {
    return post('wallet', 'initiate_deposit', {
      'amount': amount.toStringAsFixed(2),
      'method': method,
    });
  }

  // SHOP
  static Future<Map<String, dynamic>> getShopProducts({String? category, String? country}) {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (country != null) params['country'] = country;
    return get('shop', 'products', params.isNotEmpty ? params : null);
  }

  static Future<Map<String, dynamic>> getShopProduct(int id) {
    return get('shop', 'product', {'id': id.toString()});
  }

  static Future<Map<String, dynamic>> shopCheckout(Map<String, dynamic> data) {
    final body = data.map((k, v) => MapEntry(k, v.toString()));
    return post('shop', 'checkout', body);
  }

  static Future<Map<String, dynamic>> getShopOrders() {
    return get('shop', 'my_orders');
  }

  static Future<Map<String, dynamic>> getShopOrderDetail(int id) {
    return get('shop', 'order_detail', {'id': id.toString()});
  }

  static Future<Map<String, dynamic>> getShopCountries() {
    return get('shop', 'countries');
  }

  static Future<Map<String, dynamic>> getShopCategories() {
    return get('shop', 'categories');
  }

  // PROXIES
  static Future<Map<String, dynamic>> getProxyProducts() {
    return get('proxies', 'products');
  }

  static Future<Map<String, dynamic>> buyProxy(int productId) {
    return post('proxies', 'buy', {'product_id': productId.toString()});
  }

  static Future<Map<String, dynamic>> getProxyOrders() {
    return get('proxies', 'my_orders');
  }

  static Future<Map<String, dynamic>> getProxyOrderDetail(int id) {
    return get('proxies', 'order_detail', {'id': id.toString()});
  }

  // SMS/NUMBERS
  static Future<Map<String, dynamic>> getSmsServices() {
    return get('numbers', 'services');
  }

  static Future<Map<String, dynamic>> purchaseSms(int serviceId) {
    return post('numbers', 'purchase', {'service_id': serviceId.toString()});
  }

  static Future<Map<String, dynamic>> getSmsHistory() {
    return get('numbers', 'history');
  }

  static Future<Map<String, dynamic>> getSmsCountries() {
    return get('numbers', 'countries');
  }

  // REFERRALS
  static Future<Map<String, dynamic>> getReferralStats() {
    return get('referrals', 'stats');
  }

  static Future<Map<String, dynamic>> getReferralHistory() {
    return get('referrals', 'history');
  }

  // SUPPORT
  static Future<Map<String, dynamic>> getSupportRequests() {
    return get('support', 'my_requests');
  }

  static Future<Map<String, dynamic>> sendSupportMessage(String message, {int? requestId}) {
    final body = {'message': message};
    if (requestId != null) body['request_id'] = requestId.toString();
    return post('support', 'send_message', body);
  }

  static Future<Map<String, dynamic>> getSupportMessages(int requestId, {int afterId = 0}) {
    return get('support', 'messages', {
      'request_id': requestId.toString(),
      'after_id': afterId.toString(),
    });
  }

  // NOTIFICATIONS
  static Future<Map<String, dynamic>> getNotifications() {
    return get('notifications', 'list');
  }

  static Future<Map<String, dynamic>> getUnreadCount() {
    return get('notifications', 'unread_count');
  }

  static Future<Map<String, dynamic>> markNotificationRead({int? id}) {
    return post('notifications', 'mark_read', id != null ? {'id': id.toString()} : {});
  }
}
